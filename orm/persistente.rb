module Persistente

  def self.included clase
    clase.extend MetodosClase
  end

  module MetodosClase

    def descendants ; @descendants ||= [] ; end

    def inherited subclass
      descendants.push subclass
      unless (self.ancestors[1].to_s == "Persistente")
        self.ancestors[1].descendants.push subclass
      end

      subclass.send :include, Persistente

      subclass.campos_persistibles.merge!(self.campos_persistibles.clone)
    end

    def included subclass
      self.inherited subclass
    end

    def extended subclass
      raise "No se puede hacer extended de un modulo persistible"
    end

    def campos_persistibles
      @campos_persistibles ||= Hash.new
    end

    def tabla_persistencia
      @tabla_persistencia ||= IntelligentDB.new self
    end

    def has_one(tipo_dato, metadatos)
      raise ArgumentError.new "La clase #{tipo_dato} no es persistible" unless RestriccionFactory.is_persistible(tipo_dato)
      campo = metadatos[:named]
      self.campos_persistibles[campo] = [(RestriccionFactory.crear tipo_dato, campo)]
      self.campos_persistibles[campo].concat(RestriccionContenidoFactory.crear metadatos)
      attr_accessor campo
      # puts "atributo #{campo} de tipo #{tipo_dato}."
    end

    def has_many(tipo_dato, metadatos)
      has_one([tipo_dato], metadatos)
    end

    def all_instances
      unless self.descendants.empty?
        subInstancias = self.descendants[0].all_instances if self.descendants.length > 0
      else
        subInstancias = []
      end

      if self.class == Module
        subInstancias.flatten
      else
        entries = tabla_persistencia.entries
        instancias = entries.map do |hash|
          dummy = self.new
          dummy.id = hash[:id]
          hash_to_instance(hash, dummy)
        end
        instancias.concat(subInstancias).flatten
      end
    end

    def method_missing(sym, *args, &block)
      # Caso generico de find_by_<what>
      super(sym, *args, &block) unless sym.to_s.start_with? "find_by_"

      field = "#{sym.to_s[("find_by_".length)..-1]}".to_sym #string magicpulation
      value = args[0]

      if (self.descendants.select { |subclass| !(subclass.instance_methods.include? field) }).length > 0
        raise "Falla! No todos entienden #{field}" 
      end

      if self.class.to_s == 'Module'
        return self.descendants[0].send("find_by_#{field}", value).flatten if self.descendants.length > 0
        return []
      else 
        misEncontrados = tabla_persistencia.search_by(field, value)
        misIntancias = misEncontrados.map do |hash|
          dummy = self.new
          dummy.id = hash[:id]
          hash_to_instance(hash, dummy)
        end
        return self.descendants[0].send("find_by_#{field}", value).concat(misIntancias).flatten if self.descendants.length > 0
        return misIntancias.flatten
      end
    end

    def respond_to_missing?(sym, include_private = false)
      sym.to_s.start_with? "find_by_" || super
    end

    def find_by_id(id)
      if self.class.to_s == 'Module'
        return (self.descendants[0].find_by_id id).flatten if self.descendants.length > 0
        return []
      else
        dummy=self.new
        dummy.id = id
        clase = self.merge(dummy, id)
        if (clase.nil?)
          return (self.descendants[0].find_by_id id).flatten if self.descendants.length > 0
          return []
        else
          return (self.descendants[0].find_by_id id).push(clase).flatten if self.descendants.length > 0
          return [clase]
        end
      end
    end

    def persist(objeto)
      hash = instance_to_hash(objeto)
      id_generado = self.tabla_persistencia.insertOrUpdate(hash)
      objeto.id = id_generado
      has_many_restrictions.each do |nombre, restriccion|
        lista = objeto.send nombre
        restriccion.persist_join(id_generado, lista)
      end
      id_generado
    end

    def remove(objeto)
      self.tabla_persistencia.delete(objeto.id)
      objeto.id = nil
    end

    def merge(objeto, id)
      hash = self.tabla_persistencia.search_by_id(id)
      if hash.nil?
        #TODO: Diseño: definir que hacer cuando el id no existe en la base: nil? excepcion?
        return nil
      end

      hash_to_instance(hash, objeto)
      has_many_restrictions.each do |nombre, restriccion|
        lista = objeto.send nombre
        lista.push(restriccion.recover_join(id))
      end
      objeto
    end

    def is_valid(instance)
      self.campos_persistibles.all? do |nombre, restricciones|
        valor = instance.send nombre.to_sym
        restricciones.each {|restriccion| restriccion.try(valor, nombre)}
      end
    end

    private

    def has_many_restrictions
      self.campos_persistibles.map {|nombre, restricciones|
        r_has_many = restricciones.select {|restriccion| restriccion.is_a? RestriccionMany}
        if r_has_many.length !=1
          [nombre, nil]
        else
          [nombre, r_has_many[0]]
        end
      }.reject {|k, v| v.nil?}
    end

    def restriccion_tipo(restricciones)
      restricciones_tipo = restricciones.select {|restriccion| restriccion.is_a? RestriccionTipo}
      raise StandardError.new "Se esperaba solamente una restriccion de tipo" if restricciones_tipo.length != 1
      return restricciones_tipo[0]
    end

    def instance_to_hash(instance)
      hash = Hash[self.campos_persistibles.map do |nombre, restricciones|
        valor = instance.send(nombre.to_sym)
        [nombre, restriccion_tipo(restricciones).transform_to_hash(valor)]
      end]
      hash.reject! {|key, val| val.nil?}
      hash[:id] = instance.id unless instance.id.nil?
      hash
    end

    def hash_to_instance(hash, instance)
      self.campos_persistibles.each do |nombre, restricciones|
        valor = hash[nombre]
        instance.send "#{nombre}=".to_sym, restriccion_tipo(restricciones).transform_to_instance(valor)
      end
      instance
    end

  end

  attr_accessor :id

  def save!
    self.validate!
    self.class.persist(self)
  end

  def validate!
    self.class.is_valid(self)
  end

  def refresh!
    raise RuntimeError.new "No se puede refresh! sin antes hacer save!" if self.id.nil?
    self.class.merge(self, self.id)
  end

  def forget!
    self.class.remove(self)
  end

end
