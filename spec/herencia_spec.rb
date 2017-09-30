require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar ORM' do

  module Persona
    has_one String, named: :nombre
  end

  # <-- general -->
  it "deberia poder incluir un modulo persistible" do
    class Estudiante
      include Persona
    end

    e = Estudiante.new

    expect(e.respond_to? :nombre).to be true
  end

  # <-- clase persistible por inclusion o herencia -->
  it "deberia poder heredar una clase persistible" do
    class AyudanteDeCatedra < Estudiante
    end

    expect(AyudanteDeCatedra.respond_to? :find_by_id).to be true
  end

  it "deberia ser persistible una clase que incluye un mixin persistible" do
    class Pera
      include Persona
    end

    expect(Pera.respond_to? :find_by_id).to be true
  end

  # <-- no modifica clases de la que hereda -->
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

  # <-- campos_persistibles por herencia e inclusion -->
  it "deberia guardar todos los campos heredados" do
    class SoyClase
      has_one String, named: :nombre
    end

    class SoySubClase < SoyClase
    end

    subc = SoySubClase.new
    subc.nombre = 'norman'
    id = subc.save!

    unObjecto = (SoySubClase.find_by_id id).first
    expect(unObjecto.nombre == 'norman').to be true
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

    rBase = (F.find_by_id id).first
    expect(rBase.nombre == 'norman').to be true
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

    w = W.new
    w.nombre = 'norman'
    w.edad = 23
    w.apellido = 'perrin'
    id = w.save!

    wBase = (W.find_by_id id).first
    expect((wBase.nombre == 'norman') && (wBase.apellido == 'perrin') && (wBase.edad == 23)).to be true
  end

  # <-- descendants -->
  it "deberia responder correctamente a los descendants un modulo incluido por una clase y esta a la vez heredada por otra" do
    module MM
      has_one String, named: :nombre
    end

    class CC
      include MM
      has_one String, named: :apellido
    end

    class AA < CC
    end

    expect((MM.descendants.include? CC) && (MM.descendants.include? AA)).to eq true
  end

  # <-- find_by_id -->
  it "deberia responder con una lista de 1 elemento find_by_id llamado desde un padre con 1 instancia en hijos" do
    module VV ; has_one String, named: :nombre ; end
    class ZZ ; include VV ; has_one String, named: :apellido ; end
    class UU < ZZ ; end

    q = UU.new
    q.nombre='norman'
    q.apellido='perrin'
    idQ= q.save!

    resultados= VV.find_by_id idQ
    expect(resultados.length == 1).to eq true
  end

  it "deberia responder con una lista del elemento instanciado desde hijo en find_by_id llamado desde un padre" do
    module LL ; has_one String, named: :nombre ; end
    class OO ; include LL ; has_one String, named: :apellido ; end
    class QQ < OO ; end

    q = QQ.new
    q.nombre='norman'
    q.apellido='perrin'
    idQ= q.save!

    resultados= LL.find_by_id idQ
    expect(resultados[0].id == idQ).to eq true
  end

  # <-- no se puede testear sin un update -->
  # it "deberia responder con una lista de 2 elementos instanciado desde hijo en find_by_id llamado desde un padre" do
  #   module LLL ; has_one String, named: :nombre ; end
  #   class OOO ; include LLL ; has_one String, named: :apellido ; end
  #   class QQQ < OOO ; end

  #   q = QQQ.new
  #   q.nombre='norman'
  #   q.apellido='perrin'
  #   q.id = '123'
  #   q.save!

  #   o = OOO.new
  #   o.nombre='alberto'
  #   o.apellido='rodriguez'
  #   o.id = '123'
  #   o.save!

  #   resultados= LLL.find_by_id 123
  #   expect(resultados.length == 2).to eq true
  # end

  # it "deberia responder con una lista de los 2 elementos instanciados desde hijo en find_by_id llamado desde un padre" do
  #   module LLL ; has_one String, named: :nombre ; end
  #   class OOO ; include LLL ; has_one String, named: :apellido ; end
  #   class QQQ < OOO ; end

  #   q = QQQ.new
  #   q.nombre='norman'
  #   q.apellido='perrin'
  #   q.id = '123'
  #   q.save!

  #   o = OOO.new
  #   o.nombre='alberto'
  #   o.apellido='rodriguez'
  #   o.id = '123'
  #   o.save!

  #   resultados= LLL.find_by_id '123'
  #   p resultados
  #   expect((resultados[0].nombre == 'norman') && (resultados[1].nombre == 'alberto')).to eq true
  # end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end