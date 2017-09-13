class Class
  def has_one(tipo_dato, metadatos)
	puts "Se persiste el atributo #{metadatos[:named]} de tipo #{tipo_dato}."
	attr_accessor metadatos[:named]
  end
end
