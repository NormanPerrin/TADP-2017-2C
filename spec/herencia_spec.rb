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

  it "deberia guardar todos los campos heredados" do
    class SoyClase
      has_one String, named: :nombre
    end

    class SoySubClase < SoyClase
    end

    subc = SoySubClase.new
    subc.nombre = 'norman'
    id = subc.save!

    unObjecto = SoySubClase.find_by_id id
    p unObjecto
    expect(unObjecto.respond_to? :nombre).to be true
  end

  it "deberia guardar todos los campos incluidos por modulo" do
    module G
      has_one String, named: :nombre
    end

    class F
      include G
    end

    subm = F.new
    subm.nombre = 'norman'
    id = subm.save!

    unObjecto = F.find_by_id id
    p unObjecto
    expect(unObjecto.respond_to? :nombre).to be true
  end

  it "deberia guardar campo persistible de modulo, herencia y clase" do
    module Y
      has_one String, named: :nombre
    end

    class K
      has_one String, named: :apellido
    end

    class W < K
      include Y
      has_one Numeric, named: :edad
    end

    subm = W.new
    subm.nombre = 'norman'
    subm.edad = 23
    subm.apellido = 'perrin'
    id = subm.save!

    unObjecto = W.find_by_id id
    p unObjecto

    expect((unObjecto.respond_to? :nombre) && (unObjecto.respond_to? :apellido) && (unObjecto.respond_to? :edad)).to be true
  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end