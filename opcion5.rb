module Persistencia

  class ConstructorClasePersistente
    attr_accessor :klass, :superklass

    def <(superklass)
      p "paso por def <"
      self.superklass= superklass
      return self
    end

    def initialize(constante)
      @klass=constante
    end

    def obtener_clase_persistible(builder)
      ##### Define al @klass dependiendo si tiene superclase, y crea la constante en Object
      ##### Si es un builder solamente pasara una vez en la declaracion de la clase persistible luego para
      ##### Open Class lo hara como constante
      p "obtener clase persistible"
      p builder
      p builder.class
      p self
      p @superKlass.nil?
      if !(@superklass.nil?)
        p "paso por super"
        @clase = Class.new(@superklass)
      else
        p "paso por sola"
        @clase = Class.new
      end
      p builder.klass
      p @clase
      Object.const_set @klass, @clase
    end

    def construir_metodos
      @clase.extend(MetodosDeClase)
      @clase.include(MetodosDeInstancia)
    end

    def construir_evaluando_bloque(bloque)
      @clase.class_eval &bloque
    end

    def construir_clase_persistible(&bloque)
      p "construir clase persistible"
      p self
      obtener_clase_persistible(self)
      construir_metodos
      construir_evaluando_bloque(bloque)
    end
  end

  module MetodosDeClase
    def metodoDeClase
      p "soy metodo de clase"
    end
  end
  module MetodosDeInstancia
    def has_one(tipo_dato, metadatos)
      puts "Se persiste el atributo #{metadatos} de tipo #{tipo_dato}."
      attr_accessor metadatos
    end
    def has_many
      p "soy has_many"
    end
  end

  def self.const_missing(sym)
    ConstructorClasePersistente.new(sym)
  end

  def self.clase_persistente(entorno_persitencia, &bloque)
    if entorno_persitencia.class == ConstructorClasePersistente
      p "clase_persistente Constructor"
      entorno_persitencia.construir_clase_persistible(&bloque)
    else
      p "clase_persistente openClass"
      entorno_persitencia.class_eval &bloque
    end
  end



  class B
    def metodoB
      p "metodo b"
    end
  end
  clase_persistente A < B do

  end

  p A.instance_variables
  p A.singleton_methods
  p A.instance_methods()
end