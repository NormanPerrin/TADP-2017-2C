require 'rspec'
require_relative '../orm'

using ORM

describe 'Creacion de clases' do

  context "La clase no existe" do
    it 'deberia dejarme crear las clases' do
      class Person
        has_one String, named: :last_name
      end
    end
  end

  context "La clase ya existe" do

    class Person
      has_one String, named: :last_name
    end

    it 'deberia crearme los accesors' do
      p = Person.new
      p.last_name = "perez"
      expect(p.last_name).to eq("perez")
    end
  end


end