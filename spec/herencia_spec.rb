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

    e = Estudiante.new

    expect(e.respond_to? :nombre).to be true
  end

  it "deberia ser persistible una clase al incluir un modulo persistible" do
    class Tomate
      include Persona
    end

    expect(Tomate.respond_to? :campos_persistibles).to be true
  end

  it "deberia poder heredar una clase persistible" do
    class AyudanteDeCatedra < Estudiante
    end

    expect(AyudanteDeCatedra.respond_to? :find_by_id).to be true
  end

  it "deberia quedar intacta la clase de la que hereda" do
    class AyudanteDeCatedra < Estudiante
      has_one String, named: :tipo
    end

    expect(Estudiante.campos_persistibles.include? :tipo).to be false
  end

  it "deberian quedar intactas las instancias de la clase de la que hereda" do
    class AyudanteDeCatedra < Estudiante
      has_one String, named: :tipo
    end

    e = Estudiante.new
    expect(e.respond_to? :tipo).to be false
  end

  it "deberia ser persistible una clase que incluye un mixin persistible" do
    class Pera
      include Persona
    end

    expect(Pera.respond_to? :find_by_id).to be true
  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end