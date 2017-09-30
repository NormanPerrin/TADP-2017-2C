module ORM
  require_relative 'intelligentdb'
  require_relative 'persistente'
  require_relative 'restricciones'

  Object.const_set(:Boolean, Module.new)
  FalseClass.send :include, Boolean
  TrueClass.send :include, Boolean

  refine Module do
    def has_one(tipo_dato, metadatos)
      self.send :include, Persistente
      has_one(tipo_dato, metadatos)
    end

    def has_many(tipo_dato, metadatos)
      self.send :include, Persistente
      has_many(tipo_dato, metadatos)
    end
  end

end