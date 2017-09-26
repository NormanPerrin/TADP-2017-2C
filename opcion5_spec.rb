require 'rspec'
require_relative 'opcion5'

using Persistencia
context "con una clase que no existe" do
  it 'deberia dejarme crear las clases' do
    module Persistencia
      clase_persistente A do
        attr_accessor :uno, :dos
        has_one String, named: :nombre
        has_one String, named: :numero
        has_one Numeric, named: :numero
        attr_accessor :tres, :cuatro
        attr_reader :cinco
        def metodoClaseA
          nombre === "3" && numero===12
        end
        def metodoClaseAConArgs(rr)
          nombre === "3" && numero===12
        end
      end
      a= A.new
      otra_a= A.new
      otra_a.nombre="rrr"
      otra_a.numero=35
      otra_a.save!
      p "Comienzo"
      p a.methods
      p A.instance_methods(false)
      p A.singleton_methods
      p A.methods
      p A.ancestors
      p A.instance_variables
      p A.class_variable_get(:@@atributosPersistibles)
      p a.nombre
      a.nombre="3"
      p a.nombre
      p a.numero
      a.numero=3
      p a.numero
      a.save!
      p a.id
      a.numero=12
      a.refresh!
      p a.numero
      p a.id
      i = A.all_instances
      p i
      p i.last.numero
      i = A.find_by_numero(9)
      p i
      p i.last.numero
      i = A.find_by_nombre("rrr")
      p i
      p i.last.nombre if !i.last.nil?
      i = A.find_by_metodoClaseA(true)
      p i
      p i.last.nombre if !i.last.nil?
      i = A.find_by_metodoClaseAConArgs(true)
      p i
      p i.last.nombre if !i.last.nil?
      a.forget!
      p a.id
      p "Fin"

      class B
        attr_accessor :atributoClaseB
        def metodoClaseB
          p "metodoClaseB"
        end
      end
      clase_persistente C < B  do
        attr_accessor :uno, :dos
        has_one String, named: :nombre
        has_one Numeric, named: :numero
        attr_accessor :tres, :cuatro
        attr_reader :cinco
        def metodoClaseC
          p "metodoClaseC"
        end
      end
      c=C.new
      p "Comienzo"
      p c.methods
      p C.instance_methods(false)
      p C.singleton_methods
      p C.methods
      p C.ancestors
      p C.instance_variables
      p c.nombre
      c.nombre="3"
      p c.nombre
      p c.numero
      c.numero=3
      p c.numero
      c.metodoClaseC
      c.metodoClaseB

      p "Fin"
    end
  end
end