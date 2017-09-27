module Persistencia
  require 'tadb'
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
  end

  module MetodosDeClase
    def crear_atributo_en_autoclase(tipo, nombre_simbolo)
      self.class_variable_set(:@@atributosPersistibles, {}) unless
          self.class_variable_defined?(:@@atributosPersistibles)
      (self.class_variable_get(:@@atributosPersistibles))[nombre_simbolo]=tipo
    end
    def crear_setter(tipo, nombre)
      define_method(nombre.to_s+"=") do |valor|
        # if tipo.instance_methods.include?(:save!) && tipo.instance_methods.include?(:refresh!)
        valorValido = ( [:save!, :refresh!] - tipo.instance_methods ).empty? && !valor.is_a?(tipo) ?
            tipo.buscar_instancia(valor) : valor
        #   instancia = tipo.buscar_instancias_coincidentes(:id,valor)
        # end
        raise TypeError, "El atributo #{nombre} con valor #{valorValido} no es del tipo #{tipo.to_s}" unless valorValido.is_a?tipo
        self.instance_variable_set("@#{nombre}",valorValido)
      end
    end
    def has_one(tipo_dato, descripcion = {})
      crear_atributo_en_autoclase(tipo_dato, descripcion[:named])
      attr_reader descripcion[:named]
      crear_setter(tipo_dato, descripcion[:named])
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
        instanciasCoincidentes = instancias.select {
            |instancia|
          (instancia.methods.include?(:id) && instancia.id == entrada[:id])
        }
        if (instanciasCoincidentes.length == 1)
          instanciaParaAgregar = instanciasCoincidentes.first
        else
          instanciaParaAgregar = armarObjeto(entrada)
        end
        vectorInstancias << instanciaParaAgregar
      }
      vectorInstancias
    end
    def buscar_instancia(id)
      (self.all_instances.select do
      |instancia|
        id===instancia.__send__(:id)
      end).first
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

    def has_many
      p "soy has_many"
    end
  end

  def self.const_missing(sym)
    ConstructorClasePersistente.new(sym)
  end

  def self.clase_persistente(entorno_persitencia, &bloque)
    if entorno_persitencia.class == ConstructorClasePersistente
      entorno_persitencia.construir_clase_persistible(&bloque)
    else
      entorno_persitencia.class_eval &bloque
    end

  end
  module MetodosDeInstancia
    def crear_hash_atributos
      hash ||= {}
      self.class.class_variable_get("@@atributosPersistibles").each do
      |nombreAtributo, tipo|
        valor = self.send(nombreAtributo)
        if !valor.nil?
          if valor.respond_to?("save!") && valor.respond_to?("refresh!")
            id=valor.save!
            hash[nombreAtributo]=id
          else
            hash[nombreAtributo]=valor
          end
        end
      end
      hash
    end

    def save!
      if @id.nil?
        hash = crear_hash_atributos
        # self.class.__send__(:attr_accessor, "id")
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
      raise TypeError, "​El​ ​objeto​ #{self} no​ ​tiene​ ​id!" unless !@id.nil?
      self.class.class_variable_get("@@atributosPersistibles").each do
      |nombreAtributo, tipo|
        valor = self.send(nombreAtributo)
        valor.forget! if valor.respond_to?("save!") && valor.respond_to?("refresh!")
      end
      TADB::DB.table(self.class.name.to_s).delete(@id)
    end

    def refresh!
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