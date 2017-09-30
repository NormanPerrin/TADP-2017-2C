module ORM
  require 'tadb'

  class IntelligentDB

    def initialize(clase)
      @table = TADB::DB.table(clase)
    end

    def insertOrUpdate(hash)
      if self.search_by_id(hash[:id]).nil?
        return insert(hash)
      else
        return update(hash)
      end
    end

    def insert(hash)
      @table.insert(hash)
    end

    def update(hash)
      #TODO: que hacemos con un update?
      @table.insert(hash)
    end

    def entries
      @table.entries
    end

    def search_by_id(id)
      posible = self.search_by(:id, id)
      return nil if posible.length == 0
      return posible[0] if posible.length == 1
      raise IOError "La base informa #{posible.length} registros con ese id."
    end

    def search_by(field, value)
      @table.entries.select {|hash| hash[field]==value}
    end

    def delete(id)
      @table.delete(id)
    end

  end

  Object.const_set :Boolean, Class.new

  module Persistente

    def self.included clase
      clase.extend MetodosClase
    end

    module MetodosClase

      def descendants ; @descendants ||= [] ; end

      def inherited subclass
        descendants.push subclass
        unless (self.ancestors[1].to_s == "ORM::Persistente")
          self.ancestors[1].descendants.push subclass
        end

        subclass.send :include, Persistente

        unless defined?(subclass.campos_persistibles).nil?
          subclass.campos_persistibles = subclass.campos_persistibles.merge(self.campos_persistibles.clone)
        else
          subclass.campos_persistibles = self.campos_persistibles.clone
        end
      end

      def included subclass
        descendants.push subclass
        unless (self.ancestors[1].to_s == "ORM::Persistente")
          self.ancestors[1].descendants.push subclass
        end

        subclass.send :include, Persistente

        unless defined?(subclass.campos_persistibles).nil?
          subclass.campos_persistibles = subclass.campos_persistibles.merge(self.campos_persistibles.clone)
        else
          subclass.campos_persistibles = self.campos_persistibles.clone
        end
      end

      def extended subclass
        raise RuntimeError "No se puede hacer extended de un modulo persistible"
      end

      attr_writer :campos_persistibles, :tabla_persistencia

      def campos_persistibles
        @campos_persistibles ||= Hash.new
      end

      def tabla_persistencia
        @tabla_persistencia ||= IntelligentDB.new self
      end

      def has_one(tipo_dato, metadatos)
        campo = metadatos[:named]
        self.campos_persistibles[campo] = tipo_dato
        attr_accessor campo
        # puts "atributo #{campo} de tipo #{tipo_dato}."
      end

      # TODO: arreglar que trae duplicados
      def all_instances
        subInstancias = self.descendants.map { |subclase| subclase.all_instances.flatten }
        if self.class.to_s == 'Module'
          subInstancias.flatten
        else
          entries = tabla_persistencia.entries
          entries.map{|hash| hash_to_instance(hash, self.new)}.concat(subInstancias).flatten
        end
      end

      def method_missing(sym, *args, &block)
        # Caso generico de find_by_<what>
        super(sym, *args, &block) unless sym.to_s.start_with? "find_by_"

        field = "#{sym.to_s[("find_by_".length)..-1]}".to_sym #string magicpulation
        value = args[0]

        if self.class.to_s == 'Module'
          subInstanciasEncontradas = self.descendants.map { |subclase| subclase.send("find_by_#{field} (value)").flatten }.flatten
        else 
          misEncontrados = tabla_persistencia.search_by(field, value)
          misIntancias = misEncontrados.map{|hash| hash_to_instance(hash, self.new)}
          subInstanciasEncontradas = self.descendants.map { |subclase| subclase.send("find_by_#{field} (value)").flatten }.flatten
          subInstanciasEncontradas.concat(misIntancias)
        end

      end

      # TODO: arreglar que trae duplicados
      def find_by_id(id)
        if self.class.to_s == 'Module'
          self.descendants.map { |subclase| (subclase.find_by_id id).flatten }.flatten
        else
          dummy=self.new
          dummy.id = id
          clase = self.refresh(dummy)
          self.descendants.map { |subclase| (subclase.find_by_id id).flatten }.push(clase).flatten
        end
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

      def refresh(objeto)
        raise RuntimeError "No se puede refresh! sin antes hacer save!" if objeto.id.nil?
        hash = self.tabla_persistencia.search_by_id(objeto.id)
        return hash_to_instance(hash,objeto) unless hash.nil?
        #TODO: Diseño: definir que hacer cuando el id no existe en la base: nil? excepcion?
        nil
      end

      private
      def instance_to_hash(instance)
        #TODO: logica sobre campos compuestos!
        Hash[self.campos_persistibles.map {|k, v| [k, instance.send(k.to_sym)]}]
      end

      def hash_to_instance(hash,instance)
        #TODO: logica sobre campos compuestos!
        hash.each {|k, v| instance.send "#{k}=".to_sym, v}
        instance
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
      self.class.refresh(self)
    end

    def forget!
      self.class.remove(self)
    end

  end

  refine Module do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistente
      # puts "clase #{self} inicializada para persistencia"
      self.has_one(tipo_dato, metadatos)
    end

  end

end