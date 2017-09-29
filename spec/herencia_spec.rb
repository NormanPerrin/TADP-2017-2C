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
    end

    expect(Estudiante.new).to respond_to(:nombre)
  end

  it "deberia ser persistible una clase al incluir un modulo persistible" do
    class Tomate
      include Persona
    end

    tomate = Tomate.new
    tomate.nombre = "tomate asesino"
    tomate.save!

    expect(tomate).to respond_to(:id)
  end

  it "deberia poder heredar una clase persistible" do
    class AyudanteDeCatedra < Estudiante
    end

    expect(AyudanteDeCatedra).to respond_to(:find_by_id)
  end

  it "deberia quedar intacta la clase de la que hereda" do
    class AyudanteDeCatedra < Estudiante
      has_one String, named: :tipo
    end

    expect(Estudiante.campos_persistibles).not_to include(:tipo)
  end

  it "deberian quedar intactas las instancias de la clase de la que hereda" do
    class AyudanteDeCatedra < Estudiante
      has_one String, named: :tipo
    end

    expect(Estudiante.new).not_to respond_to(:tipo)
  end

  it "deberia ser persistible una clase que incluye un mixin persistible" do
    class Pera
      include Persona
    end

    expect(Pera).to respond_to(:find_by_id)
  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end