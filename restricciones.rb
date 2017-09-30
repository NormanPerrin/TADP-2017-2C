class RestriccionFactory

  def self.crear tipo_dato, nombre_campo
    return RestriccionMany.new tipo_dato[0], nombre_campo if is_composicion_multiple(tipo_dato)
    return RestriccionPersistible.new tipo_dato if is_composicion_simple(tipo_dato)
    return RestriccionPrimitivo.new tipo_dato if is_primitivo(tipo_dato)
    raise ArgumentError.new "El tipo #{tipo_dato} no se puede persistir"
  end

  def self.is_primitivo(tipo_dato)
    [String, Numeric, Boolean].include? tipo_dato
  end

  def self.is_composicion_simple(tipo_dato)
    tipo_dato < Persistente
  end

  def self.is_composicion_multiple(tipo_dato)
    tipo_dato.is_a? Array and is_composicion_simple(tipo_dato[0])
  end

  def self.is_persistible(tipo)
    is_composicion_multiple(tipo) or
        is_composicion_simple(tipo) or
        is_primitivo(tipo)
  end

end

class RestriccionTipo

  def initialize(tipo_dato)
    @tipo = tipo_dato
  end

  def try value,name
    raise RuntimeError.new "El valor #{value} de #{name} no es un #{@tipo}" unless value.is_a? @tipo
  end

  def transform_to_hash(value)
    #Transforma el atributo a un tipo primitivo
    value
  end

  def transform_to_instance(value)
    #Transforma un valor primitivo a atributo
    value
  end
end

class RestriccionPrimitivo < RestriccionTipo
end

class RestriccionPersistible < RestriccionTipo
  def transform_to_hash(value)
    @tipo.persist(value)
  end

  def transform_to_instance(value)
    @tipo.find_by_id value
  end
end

class RestriccionMany < RestriccionTipo

  def initialize(tipo_dato, nombre_campo)
    super(tipo_dato)
    @tabla_intermedia = TADB::DB.table("#{tipo_dato}_#{nombre_campo}")
  end

  def try values,name
    byebug
    raise RuntimeError.new "El contenido de #{name} (#{values}) no es una lista de #{@tipo}" unless
    values.is_a? Array and values.all? {|elem| elem.is_a? @tipo}
  end

  def transform_to_hash(values)
    #no se persisten los valores en la entidad sino en una tabla intermedia
    nil
  end

  def transform_to_instance(values)
    #no se recuperan los valores desde el hash sino desde la tabla intermedia
    []
  end

  def persist_join(id, values)
    values.each do |val|
      hash = Hash.new
      hash[:id] = id
      if RestriccionFactory.is_primitivo(@tipo)
        hash[:value] =val
      else
        hash[:stepvalue] = @tipo.persist(val)
      end
      @tabla_intermedia.insert(hash)
    end
  end

  def recover_join(id)
    entries = @tabla_intermedia.entries.select {|hash| hash[:id] == id}
    entries.map do |hash|
      if RestriccionFactory.is_primitivo(@tipo)
        hash[:value]
      else
        @tipo.find_by_id value
      end
    end
  end

end

class RestriccionContenidoFactory

  def self.crear hash
    hash.map {|k,v| crear_restriccion(k,v)}.select {|v| !v.nil?}
  end

  def self.crear_restriccion(key,value)
    return RestriccionNoBlank.new if key==:no_blank and value
    return RestriccionFrom.new value if key==:from
    return RestriccionTo.new value if key==:to
    return RestriccionValidate.new value if key==:validate
    #Ignoramos :named y :default (retorna nil)
  end

end

class RestriccionNoBlank
  def try value, name
    raise RuntimeError.new "El valor de #{name} no debe estar vacio" unless
    !(value == "" or value.nil?)
  end
end

class RestriccionFrom
  def initialize from
    @from=from
  end

  def try value,name
    raise RuntimeError.new "#{value} es menor a #{from} para el atributo #{name}" unless
    value >= @from
  end
end

class RestriccionTo
  def initialize to
    @to=to
  end

  def try value,name
    raise RuntimeError.new "#{value} es menor a #{from} para el atributo #{name}" unless
    value <= @to
  end
end

class RestriccionValidate
  def initialize proc
    @bloque = proc
  end

  def try value,name
    raise RuntimeError.new "#{value} no cumple con el procedimiento definido para el atributo #{name}" unless
    value.instance_eval &@bloque
  end
end