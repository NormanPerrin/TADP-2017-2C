# Por alguna razon ejecutandolo desde el IDE no funca... pero desde pry si

require_relative './module.rb'
using Persisted


class Persona
  has_one
end

p = Persona.new
p.save!