module Persistencia

  class ConstructorClasePersistente
    attr_accessor :klass, :superklass

    def <(superklass)
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
      if !(@superklass.nil?)
        @clase = Class.new(@superklass)
      else
        @clase = Class.new
      end
      Object.const_set @klass, @clase
    end

    def construir_metodos
      @clase.extend(MetodosDeClase)
      @clase.include(MetodosDeInstancia)
    end

    def construir_evaluando_bloque(bloque)
      p "construir_evaluando_bloque"
      p @clase.instance_methods
      @clase.class_eval &bloque
      #@clase.instance_eval &bloque
    end

    def construir_clase_persistible(&bloque)
      obtener_clase_persistible(self)
      construir_metodos
      construir_evaluando_bloque(bloque)
    end
  end

  module MetodosDeClase
    def crear_atributo_en_autoclase(tipo, nombre_simbolo)
      self.class_variable_set(:@@atributosPersistibles, {}) unless self.class_variable_defined?(:@@atributosPersistibles)
      raise NameError, "El atributo #{nombre_simbolo.to_s} ya existe" if
          (self.class_variable_get(:@@atributosPersistibles)).has_key? nombre_simbolo
      (self.class_variable_get(:@@atributosPersistibles))[nombre_simbolo]=tipo
      p "atributosPersistibles"
p self.class_variable_get(:@@atributosPersistibles)
    end
    def crear_setter(tipo, nombre)
      define_method(nombre.to_s+"=") do |valor|
        raise TypeError, "El valor no es #{tipo.to_s}" unless valor.is_a?tipo
        self.instance_variable_set("@#{nombre}",valor)
      end
    end
    def has_one(tipo_dato, descripcion = {})
      puts "Se persiste el atributo #{descripcion} de tipo #{tipo_dato}."
      crear_atributo_en_autoclase(tipo_dato, descripcion[:named])
      attr_reader descripcion[:named]
      crear_setter(tipo_dato, descripcion[:named])
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
  module MetodosDeInstancia
    def metodoDeInstancia
      p "soy metodo de clase"
    end
  end


    # class A
    #   p "Antes has_one"
    #   has_one String, named: :nombre
    #   p "Luego has_one"
    # end



end


