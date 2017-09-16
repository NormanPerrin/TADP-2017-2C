module Persistencia

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def save!
      puts "Save! ponele..."
    end
  end

  module ClassMethods

    def has_one(tipo_dato, metadatos)
      puts "Se persiste el atributo #{metadatos[:named]} de tipo #{tipo_dato}."
      attr_accessor metadatos[:named]

      self.class_variable_set(:@@campos_persistibles, Hash.new) unless self.class_variable_defined? :@@campos_persistibles
    end
  end
end
