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

      def inherited subclass
        subclass.send :include, Persistente
        subclass.campos_persistibles = self.campos_persistibles.clone
      end

      def included subclass
        subclass.send :include, Persistente
        subclass.campos_persistibles = self.campos_persistibles.clone
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

      def all_instances
        entries = tabla_persistencia.entries
        #  aca buscaria los entries de las sublcases;
        #  entries.addAll(subclases.entries)  <= recursivo, no?
        entries.map{|hash| hash_to_instance(hash, self.new)}
      end

      def method_missing(sym, *args, &block)
        # Caso generico de find_by_<what>
        super(sym, *args, &block) unless sym.to_s.start_with? "find_by_"

        field = "#{sym.to_s[("find_by_".length)..-1]}".to_sym #string magicpulation
        value = args[0]

        encontrados = tabla_persistencia.search_by(field, value)
        encontrados.map{|hash| hash_to_instance(hash, self.new)}
      end

      def find_by_id(id)
        # Caso especial de find_by_<what>
        dummy=self.new
        dummy.id = id
        self.refresh(dummy)
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

=begin
    def has_many(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistibles
      puts "clase #{self} inicializada para persistencia"

      self.has_many(tipo_dato, metadatos)
    end
=end
  end

end