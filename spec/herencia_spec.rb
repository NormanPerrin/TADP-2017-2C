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

  # <-- all_instances -->
  it "deberia responder con una lista de 1 elemento con all_instances llamado desde un padre" do
    module WDW ; has_one String, named: :nombre ; end
    class ZDZ ; include WDW ; has_one String, named: :apellido ; end
    class UDU < ZDZ ; end

    q = UDU.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    resultados= WDW.all_instances
    expect(resultados.length == 1).to eq true
  end

  it "deberia responder con una lista del elemento con all_instances llamado desde un padre" do
    module KJK ; has_one String, named: :nombre ; end
    class MNM ; include KJK ; has_one String, named: :apellido ; end
    class VNV < MNM ; end

    q = VNV.new
    q.nombre='norman'
    q.apellido='perrin'
    id= q.save!

    resultados= KJK.all_instances
    expect(resultados[0].id == id).to eq true
  end

  it "deberia responder con una lista de 2 elementos con all_instances llamado desde un padre" do
    module III ; has_one String, named: :nombre ; end
    class LG ; include III ; has_one String, named: :apellido ; end
    class PW < LG ; end

    q = PW.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    o = LG.new
    o.nombre='pedro'
    o.apellido='cabezempanada'
    o.save!

    resultados= III.all_instances
    expect(resultados.length == 2).to eq true
  end

  it "deberia responder con una lista de los 2 elementos con all_instances llamado desde un padre" do
    module YACA ; has_one String, named: :nombre ; end
    class LOL ; include YACA ; has_one String, named: :apellido ; end
    class AHRE < LOL ; end

    q = AHRE.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    o = LOL.new
    o.nombre='pedro'
    o.apellido='cabezempanada'
    o.save!

    resultados= YACA.all_instances
    expect((resultados[0].nombre == 'pedro') && (resultados[1].nombre == 'norman')).to eq true
  end

  # <-- find_by_what -->
  it "deberia responder con una lista de 1 elemento con find_by_what llamado desde un padre" do
    module TTA ; has_one String, named: :nombre ; end
    class OAO ; include TTA ; has_one String, named: :apellido ; end
    class DF < OAO ; end

    q = DF.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    resultados= TTA.find_by_nombre 'norman'
    expect(resultados.length == 1).to eq true
  end

  it "deberia responder con una lista del elemento con find_by_what llamado desde un padre" do
    module KJK ; has_one String, named: :nombre ; end
    class MNM ; include KJK ; has_one String, named: :apellido ; end
    class VNV < MNM ; end

    q = VNV.new
    q.nombre='norman'
    q.apellido='perrin'
    id= q.save!

    resultados= KJK.find_by_nombre 'norman'
    expect(resultados[0].id == id).to eq true
  end

  it "deberia responder con una lista de 2 elementos con find_by_what llamado desde un padre" do
    module KIS ; has_one String, named: :nombre ; end
    class LQW ; include KIS ; has_one String, named: :apellido ; end
    class RWE < LQW ; end

    q = RWE.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    o = LQW.new
    o.nombre='norman'
    o.apellido='cabezempanada'
    o.save!

    resultados= KIS.find_by_nombre 'norman'
    expect(resultados.length == 2).to eq true
  end

  it "deberia responder con una lista de los 2 elementos con find_by_what llamado desde un padre" do
    module JSU ; has_one String, named: :nombre ; end
    class YWY ; include JSU ; has_one String, named: :apellido ; end
    class IWI < YWY ; end

    q = IWI.new
    q.nombre='norman'
    q.apellido='perrin'
    q.save!

    o = YWY.new
    o.nombre='norman'
    o.apellido='cabezempanada'
    o.save!

    resultados= JSU.find_by_nombre 'norman'
    expect((resultados[0].apellido == 'perrin') && (resultados[1].apellido == 'cabezempanada')).to eq true
  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end