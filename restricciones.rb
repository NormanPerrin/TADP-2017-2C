class RestriccionFactory

  def self.crear tipo_dato, nombre_campo
    return RestriccionMany.new tipo_dato[0], nombre_campo if is_composicion_multiple(tipo_dato)
    return RestriccionPersistible.new tipo_dato if is_composicion_simple(tipo_dato)
    return RestriccionPrimitivo.new tipo_dato if is_primitivo(tipo_dato)
    return RestriccionContenido.new tipo_dato
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

class Restriccion
  def passes? value
    #Testea el contenido de un atributo
    #Permite (o no) guardarlo en la base
    return true
  end
end

class RestriccionTipo < Restriccion

  def initialize(tipo_dato)
    @tipo = tipo_dato
  end

  def pases? value
    value.is_a? @tipo
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

  def passes? values
    return false unless values.is_a? Array
    values.all? {|elem| elem.is_a? @tipo}
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