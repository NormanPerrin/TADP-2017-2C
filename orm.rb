module ORM
  require 'tadb'

  class IntelligentDB

    def self.table(clase)
      return TADB::DB.table(clase)
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

    end

    def save!
      raise Error, "No valido!" unless self.validate!
      tabla = self.class.class_variable_get :@@tabla_persistencia
      campos = self.class.class_variable_get :@@campos_persistibles
      registro = Hash[campos.map {|k, v| [k, self.send(k.to_sym)]}]
      @_id = tabla.insert(registro)
    end

    def validate!
      true #implementar!
    end

  end

  refine Class do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistible
      self.class_variable_set(:@@tabla_persistencia, IntelligentDB.table(self)) unless self.class_variable_defined? :@@tabla_persistencia

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