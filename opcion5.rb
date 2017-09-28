module Persistencia
  require 'tadb'
  require_relative 'tiposPersistibles'

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
      @clase.class_eval &bloque
    end
    def construir_clase_persistible(&bloque)
      obtener_clase_persistible(self)
      construir_metodos
      construir_evaluando_bloque(bloque)
    end
    def construir_modulo_persistible(&bloque)
      modulo = Object.const_set(@klass, Module.new)
      modulo.extend(MetodosDeClase)
      modulo.class_eval &bloque
    end
  end

  module MetodosDeClase
    def crear_atributo_en_autoclase(tipo, nombre_simbolo)
      objetoTipoPersistible = TiposPersistencia.crear_tipo_peristente(nombre_simbolo, tipo)
      get_atributos_persistentes_de_clase.push(objetoTipoPersistible)
      objetoTipoPersistible
    end
    def get_atributos_persistentes_de_clase
      self.singleton_class.instance_variable_set(:@atributosPersistibles, []) unless self.singleton_class.instance_variables.include?(:@atributosPersistibles)
      self.singleton_class.instance_variable_get(:@atributosPersistibles)
    end
    def get_atributos_persistentes
      ((self.ancestors - Object.ancestors).map {
          |entidad|
        entidad.singleton_class.instance_variable_get(:@atributosPersistibles)
      }).flatten.compact
    end
    def crear_setter(tipo, nombre)
      define_method(nombre.to_s+"=") do |valor|
        valor = tipo.obtener_valor(valor)
        raise TypeError, "El atributo #{nombre} no es del tipo #{tipo.tipo.to_s}" unless tipo.validar_tipo_de_valor(valor)
        self.instance_variable_set("@#{nombre}",valor)
      end
    end
    def has_one(tipo_dato, descripcion = {})
      objetoTipoPersistible = crear_atributo_en_autoclase(tipo_dato, descripcion[:named])
      attr_reader descripcion[:named]
      crear_setter(objetoTipoPersistible, descripcion[:named])
    end
    def has_many(tipo_dato, descripcion = {})
      has_one [tipo_dato], descripcion
      define_method(:initialize) do
        self.instance_variable_set("@#{descripcion[:named]}",[])
      end
    end
    def armarObjeto(datosInstancia)
      obj = self.new
      obj.accessors_para_id
      datosInstancia.each { |atributo,valor| obj.__send__("#{atributo}=", valor) unless valor.nil?}
      obj
    end
    def all_instances
      vectorInstancias ||= []
      instancias = ObjectSpace.each_object(self)
      TADB::DB.table(self.name.to_s).entries().each  {
          |entrada|
        instanciasExistentes = instancias.select {
            |instancia|
          (instancia.methods.include?(:id) && instancia.id == entrada[:id])
        }
        if (instanciasExistentes.length == 1)
          instanciaParaAgregar = instanciasExistentes.first
        else
          instanciaParaAgregar = armarObjeto(entrada)
        end
        vectorInstancias << instanciaParaAgregar
      }
      vectorInstancias
    end
    def buscar_instancia(id)
      self.all_instances.select do
      |instancia|
        # id===instancia.__send__(:id)
        id.include?instancia.__send__(:id)
      end
    end
    def buscar_instancias_coincidentes(metodo, args)
      self.all_instances.select do
      |instancia|
        args[0]===instancia.__send__(metodo)
      end
    end
    def method_missing(symbol, *args, &block)
      if !(/^find_by_/.match(symbol.to_s).nil?)
        metodo = symbol.to_s[8..-1].to_sym
        raise ArgumentError, "El ​mensaje​ #{metodo} ​recibe​ argumentos" unless
            instance_method(metodo).arity == 0
        buscar_instancias_coincidentes(metodo, args)
      else
        super(symbol, *args, &block)
      end
    end
    def self.respond_to_missing?(symbol, include_all=false)
      !(/^find_by_/.match(symbol.to_s).nil?)
    end
  end

  def self.const_missing(sym)
    ConstructorClasePersistente.new(sym)
  end

  def self.clase_persistente(entorno_persitencia, &bloque)
    self.construir_entidad_persistente(bloque, entorno_persitencia, :construir_clase_persistible)
  end

  def self.construir_entidad_persistente(bloque, entorno_persitencia, metodo)
    entorno_persitencia.send(metodo,&bloque) if entorno_persitencia.is_a?ConstructorClasePersistente
    entorno_persitencia.class_eval &bloque unless entorno_persitencia.is_a?ConstructorClasePersistente
  end

  def self.modulo_persistente(entorno_persitencia, &bloque)
    self.construir_entidad_persistente(bloque, entorno_persitencia,:construir_modulo_persistible)
  end

  module MetodosDeInstancia
    def crear_hash_atributos
      hash ||= {}
      self.class.get_atributos_persistentes.each do
      |tipo|
        valor = self.send(tipo.nombre)
        if !valor.nil?
          hash[tipo.nombre]=tipo.obtener_valor_de_dato_para_hash(valor)
        end
      end
      hash
    end
    def save!
      if @id.nil?
        hash = crear_hash_atributos
        accessors_para_id
        self.__send__("id=", TADB::DB.table(self.class.name.to_s).insert(hash))
      else
        refresh!
      end
      @id
    end
    def accessors_para_id
      self.define_singleton_method(:id) { @id }
      self.define_singleton_method(:id=) { |valor| @id=valor }
    end
    def borrar_registro_si_existe
      # raise TypeError, "​El​ ​objeto​ #{self} no​ ​tiene​ ​id!" unless !@id.nil?
      self.class.get_atributos_persistentes.each do
      |nombreAtributo|
        valor = self.send(nombreAtributo.nombre)
        nombreAtributo.obtener_instancia_a_borrar(valor)
      end
      TADB::DB.table(self.class.name.to_s).delete(@id)
    end
    def refresh!
      raise TypeError, "​El​ ​objeto​ #{self} no​ ​tiene​ ​id!" unless !@id.nil?
      borrar_registro_si_existe
      hash = crear_hash_atributos
      hash[:id]=@id
      TADB::DB.table(self.class.name.to_s).insert(hash)
      @id
    end
    def forget!
      borrar_registro_si_existe
      @id=nil
    end
  end
end