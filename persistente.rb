module Persistente

  def self.included clase
    clase.extend MetodosClase
  end

  module MetodosClase

    def inherited subclass
      subclass.send :include, Persistente
      subclass.campos_persistibles = self.campos_persistibles.clone
    end

    def included subclass
      self.inherited subclass
    end

    attr_writer :campos_persistibles, :tabla_persistencia

    def campos_persistibles
      @campos_persistibles ||= Hash.new
    end

    def tabla_persistencia
      @tabla_persistencia ||= IntelligentDB.new self
    end

    def has_one(tipo_dato, metadatos)
      raise ArgumentError.new "La clase #{tipo_dato} no es persistible" unless is_persistible(tipo_dato)
      campo = metadatos[:named]
      self.campos_persistibles[campo] = tipo_dato
      attr_accessor campo
      # puts "atributo #{campo} de tipo #{tipo_dato}."
    end

    def all_instances
      entries = tabla_persistencia.entries
      #  aca buscaria los entries de las sublcases;
      #  entries.addAll(subclases.entries)  <= recursivo, no?
      entries.map {|hash| hash_to_instance(hash, self.new)}
    end

    def method_missing(sym, *args, &block)
      # Caso generico de find_by_<what>
      super(sym, *args, &block) unless sym.to_s.start_with? "find_by_"

      field = "#{sym.to_s[("find_by_".length)..-1]}".to_sym #string magicpulation
      value = args[0]

      encontrados = tabla_persistencia.search_by(field, value)
      encontrados.map {|hash| hash_to_instance(hash, self.new)}
    end

    def find_by_id(id)
      # Caso especial de find_by_<what>
      merge(self.new, id)
    end

    def persist(objeto)
      hash = instance_to_hash(objeto)
      id_generado = self.tabla_persistencia.insertOrUpdate(hash)
      objeto.id = id_generado
    end

    def remove(objeto)
      self.tabla_persistencia.delete(objeto.id)
      objeto.id = nil
    end

    def merge(objeto,id)
      hash = self.tabla_persistencia.search_by_id(id)
      return hash_to_instance(hash, objeto) unless hash.nil?
      #TODO: Diseño: definir que hacer cuando el id no existe en la base: nil? excepcion?
      nil
    end

    private
    def instance_to_hash(instance)
      Hash[self.campos_persistibles.map {
          |nombre, tipo| [nombre, to_primitive(tipo, instance.send(nombre.to_sym))]
      }]
    end

    def hash_to_instance(hash, instance)
      #TODO: logica sobre campos compuestos!
      hash.each {|nombre, valor| instance.send "#{nombre}=".to_sym, valor}

      self.campos_persistibles.select{
        |nombre,tipo| !is_primitive(tipo)
      }.each{
        |nombre, tipo|
          valor = tipo.find_by_id(hash[nombre])
          instance.send "#{nombre}=".to_sym, valor
      }
      instance
    end

    def to_primitive(tipo, valor)
      return valor if is_primitive(tipo)
      tipo.persist(valor)
    end

    def is_persistible(tipo_dato)
      is_primitive(tipo_dato) || (tipo_dato < Persistente)
    end

    def is_primitive(tipo)
      [String, Numeric, Boolean].include? tipo
    end

  end

  attr_accessor :id

  def save!
    self.validate!
    self.class.persist(self)
  end

  def validate!
    true #implementar!
  end

  def refresh!
    raise RuntimeError.new "No se puede refresh! sin antes hacer save!" if self.id.nil?
    self.class.merge(self,self.id)
  end

  def forget!
    self.class.remove(self)
  end

end
