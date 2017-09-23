require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar persistencia' do

  context "con una clase que no existe" do
    it 'deberia dejarme crear las clases' do
      class Person
        has_one String, named: :last_name
      end
    end
  end

  context "con una clase existente" do

    class Person
      has_one String, named: :first_name
      has_one String, named: :last_name
      has_one Numeric, named: :age
      has_one Boolean, named: :admin

      attr_accessor :some_other_non_persistible_attribute
    end


    it 'deberia crearme los accesors' do
      p = Person.new
      p.last_name = "perez"
      expect(p.last_name).to eq("perez")
    end

    it "deberia tener los atributos de clase" do
      expect(Person.class_variables).to include(:@@campos_persistibles)
      expect(Person.class_variables).to include(:@@tabla_persistencia)
    end

    it "deberia dejarme guardar" do
      p = Person.new
      p.first_name = "demian"
      p.last_name = "morales"
      p.age = 29
      p.admin = false
      p.save!
    end

    it "deberia tener id al guardar" do
      p = Person.new
      p.first_name = "first"
      p.last_name = "last"
      p.age = 1
      p.admin = false
      p.save!
      expect(p).to have_attributes(:id => a_value)
    end

    it 'responder search_by_id' do
      p = Person.new
      p.first_name = "raul"
      p.last_name = "perez"
      p.age = 3
      p.admin = false
      p.save!
      Person.search_by_id 123
    end
  end

  after :each do
    #borramos la base de datos
    #FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end