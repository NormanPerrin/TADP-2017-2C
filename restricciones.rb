class RestriccionFactory

  def self.crear tipo_dato
    return RestriccionMany.new tipo_dato if is_composicion_multiple(tipo_dato)
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

#Interfaz
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

  def transform_to_db(value)
    #Transforma el atributo a un tipo primitivo
    #Realiza los pasos intermedios para persistir el atributo (si no es primitivo)
    #Si es un objeto compuesto, lo persiste y en su lugar devuelve el id
    value
  end

  def transform_to_instance(value)
    #Transforma un valor primitivo a atributo
    #Realiza los pasos intermedios para construir el atributo (si no es primitivo)
    #Si es un objeto compuesto, busca por id y lo instancia.
    value
  end
end


class RestriccionPrimitivo < RestriccionTipo
end

class RestriccionPersistible < RestriccionTipo
  def transform_to_db(value)
    @tipo.persist(value)
  end

  def transform_to_instance(value)
    @tipo.find_by_id value
  end
end

class RestriccionMany < RestriccionTipo
  def passes? value
    value.is_a? @tipo
  end

  def transform_to_db(value)
    #Aca haria el manytomany en la base
  end

  def transform_to_instance(value)
    #Aca leeria el manytomany en la base
  end
end