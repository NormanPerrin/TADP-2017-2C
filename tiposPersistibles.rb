module TiposPersistencia
  attr_reader :nombre
  attr_accessor :tipo

  class Boolean
    def is_a?(valor)
      [true,false].include?(valor)
    end
  end

  def initialize(nombre, tipo)
    @nombre=nombre
    @tipo=tipo
  end
  def self.crear_tipo_peristente(nombre, tipo)
    obj = Primitivos.new(nombre, tipo) if es_tipo_primitivo(tipo)
    obj = ObjetosPersistibles.new(nombre, tipo) if es_tipo_objeto_persistible(tipo)
    obj = ListasObjetosPeristibles.new(nombre, tipo) if es_tipo_lista_objeto_persistible(tipo)
    obj
  end
  def self.es_tipo_lista_objeto_persistible(tipo)
    tipo.is_a?(Array) && es_tipo_objeto_persistible(tipo[0])
  end
  def self.es_tipo_primitivo(tipo)
    [String, Numeric, Boolean].include?(tipo)
  end
  def self.es_tipo_objeto_persistible(tipo)
    !tipo.is_a?(Array) && ([:save!, :refresh!, :forget!] - tipo.instance_methods).empty?
  end
  def validar_tipo_de_valor(valor)
    valor.is_a?tipo
  end
end

class Primitivos
  include TiposPersistencia
  def obtener_valor(valor)
    valor
  end
  def obtener_valor_de_dato_para_hash(valor)
    valor
  end
  def obtener_instancia_a_borrar(valor)
  end
end

class ObjetosPersistibles
  include TiposPersistencia
  def obtener_valor(valor)
    if valor.is_a?(self.tipo)
      valor
    else
      buscar_instancia(valor).first
    end
  end
  def obtener_valor_de_dato_para_hash(valor)
    valor.save!
  end
  def buscar_instancia(id)
    self.tipo.all_instances.select do
    |instancia|
      id.include?instancia.__send__(:id)
    end
  end
  def obtener_instancia_a_borrar(valor)
    valor.forget!
  end
end

class ListasObjetosPeristibles
  include TiposPersistencia
  def obtener_valor(valor)
    tipo[0].buscar_instancia(valor.split(','))
  end
  def obtener_valor_de_dato_para_hash(valor)
    (valor.map { |instancia| instancia.save!}).join(',')
  end
  def obtener_instancia_a_borrar(lista)
    lista.each { |instancia| instancia.forget!}
  end
  def validar_tipo_de_valor(valor)
    valor.is_a?(Array)
  end
end