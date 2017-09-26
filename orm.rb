module ORM
  require 'tadb'

  class IntelligentDB

    def initialize(_table)
      @table = _table
    end

    def insertOrUpdate(registro)
      #1. hacer search by campos de registro
      #2. si no esta hacer insert
      @table.insert(registro)
      #3. si esta hacer delete e insert TODO: verificar si actualizar id o q onda...
    end

    def all_instances
      @table.entries
    end

    def search_by(field, value)
      self.all_instances.select {|h| h[field] == value}
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
        subclass.campos_persistibles = self.campos_persistibles
      end

      def campos_persistibles
        @campos_persistibles ||= Hash.new
      end

      def tabla_persistencia
        @tabla_persistencia ||= IntelligentDB.new TADB::DB.table(self)
      end

      attr_writer :campos_persistibles, :tabla_persistencia

      def has_one(tipo_dato, metadatos)
        campo = metadatos[:named]
        self.campos_persistibles[campo] = tipo_dato
        attr_accessor campo
        # puts "atributo #{campo} de tipo #{tipo_dato}."
      end

      def find_by_id(id)
        # Caso especial de find_by_<what>
        self.merge_id(self.new, id)
      end

      def method_missing(sym, *args, &block)
        # Caso generico de find_by_<what>
        super(sym, *args, &block) unless sym.to_s.start_with? "find_by_"

        field = "#{sym.to_s[("find_by_".length)..-1]}".to_sym #string magicpulation
        value = args[0]

        encontrados = self.tabla_persistencia.search_by(field, value)
        encontrados.map {|hash| merge_hash(self.new, hash)}
      end

      def merge_id(objeto, id)
        encontrados = self.tabla_persistencia.search_by(:id, id)
        return merge_hash(objeto,encontrados[0]) unless encontrados.length != 1
        return nil
      end

      def merge_hash(objeto, hash)
        hash.each {|k, v| objeto.send "#{k}=".to_sym, v}
        return objeto
      end

    end

    attr_accessor :id

    def save!
      self.validate!
      tabla = self.class.tabla_persistencia
      campos = self.class.campos_persistibles
      registro = Hash[campos.map {|k, v| [k, self.send(k.to_sym)]}]
      self.id= tabla.insertOrUpdate(registro)
    end

    def validate!
      true #implementar!
    end

    def refresh!
      self.class.merge_id(self, self.id) if self.respond_to? :id
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