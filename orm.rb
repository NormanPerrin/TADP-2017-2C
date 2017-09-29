module ORM
  require_relative 'intelligentdb'
  require_relative 'persistente'

  Object.const_set :Boolean, Module.new

  refine FalseClass do
    include Boolean
  end

  refine TrueClass do
    include Boolean
  end


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