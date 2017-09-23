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

    def search_by_id(id)
      # mergear con clase nueva y esa
      @table.entries.select { |h| h[:id] == id }
    end

  end

  Object.const_set :Boolean, Class.new

  module Persistencia

    def self.included clase
      clase.extend MetodosClase
    end

    module MetodosClase

      def has_one(tipo_dato, metadatos)
        campo = metadatos[:named]
        campos = self.class_variable_get :@@campos_persistibles
        campos[campo] = tipo_dato

        attr_accessor campo

        # puts "atributo #{campo} de tipo #{tipo_dato}."
      end

      def search_by_id(id)
        self.merge(self.new, id)
      end

      def merge(objeto, id)
        hash = @tabla.search_by_id id
        hash.each { |k,v| objeto.send (k+"=").to_sym, v }
      end

    end

    def id
      @id
    end

    def save!
      raise Error, "No valido!" unless self.validate!
      tabla = self.class.class_variable_get :@@tabla_persistencia
      campos = self.class.class_variable_get :@@campos_persistibles
      registro = Hash[campos.map {|k, v| [k, self.send(k.to_sym)]}]
      @id = tabla.insertOrUpdate(registro)
    end

    def validate!
      true #implementar!
    end

    def refresh!
      self.class.merge(self, self.id)
    end

  end

  refine Class do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) #unless
      table = IntelligentDB.new TADB::DB.table(self)
      self.class_variable_set(:@@tabla_persistencia, table) #unless
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