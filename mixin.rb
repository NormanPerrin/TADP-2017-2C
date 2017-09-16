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
    end
  end
end
