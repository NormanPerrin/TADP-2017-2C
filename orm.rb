module ORM
  require 'tadb'

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

        puts "Se persiste el atributo #{campo} de tipo #{tipo_dato}."
      end

      def save(instancia)
        # instancia.validate! # "save!" implica "validate!"?
        tabla = self.class_variable_get :@@tabla_persistencia
        campos = self.class_variable_get :@@campos_persistibles
        # aca haria un hash solo con los campos persistibles y sus valores
        id = tabla.insert(Hash.new)
        instancia.instance_variable_set :@id, id
      end

    end

    def save!
      self.class.save(self)
    end

  end

  refine Class do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistible
      self.class_variable_set(:@@tabla_persistencia, TADB::DB.table(self)) unless self.class_variable_defined? :@@tabla_persistencia

      puts "clase #{self} inicializada para persistencia"

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