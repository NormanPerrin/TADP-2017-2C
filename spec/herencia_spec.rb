require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar ORM' do

  module Persona
    has_one String, named: :nombre
  end

  it "deberia poder incluir un modulo persistible" do
    class Estudiante
      include Persona
      has_one Numeric, named: :nota
    end
  end

  it "deberia poder heredar una clase persistible" do
    class AyudanteDeCatedra < Estudiante
      has_one String, named: :tipo
    end
  end

  after :each do
    #borramos la base de datos
    #FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end