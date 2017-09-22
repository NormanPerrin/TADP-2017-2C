module ORM

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

        #puts "Se persiste el atributo #{campo} de tipo #{tipo_dato}."
      end

    end

  end

  refine Class do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistibles
      #puts "clase #{self} inicializada para persistencia"

      self.has_one(tipo_dato, metadatos)
    end

    def has_many(tipo_dato, metadatos)
      self.send :include, Persistencia
      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistibles
      puts "clase #{self} inicializada para persistencia"

      self.has_many(tipo_dato, metadatos)
    end
  end

end