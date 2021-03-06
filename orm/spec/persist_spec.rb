require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar ORM' do

  context "sin haber creado clases" do

    it "deberia poder crear una clase persistente" do
      class Animal
        has_one String, named: :last_name
      end

      expect(Animal.new).not_to be_nil
    end

    it "deberia poder crear una clase NO persistente" do
      class Cohete
        attr_accessor :combustible
      end

      expect(Cohete.new).not_to respond_to(:save!)
    end
  end

  context "con una clase persistente" do

    class Person
      has_one String, named: :first_name
      has_one String, named: :last_name
      has_one Numeric, named: :age
      has_one Boolean, named: :admin

      attr_accessor :some_other_non_persistible_attribute

      def initialize(first_name="juan", last_name="topo", age=50, admin=false)
        @first_name=first_name
        @last_name=last_name
        @age= age
        @admin=admin
      end
    end

    it 'deberia tener los accesors' do
      p = Person.new
      expect(p).to respond_to(:last_name)
      expect(p).to respond_to(:last_name=)
    end

    it "deberia tener los atributos de clase" do
      expect(Person).to respond_to(:campos_persistibles)
      expect(Person).to respond_to(:tabla_persistencia)
    end

    it "deberia dejarme guardar" do
      p = Person.new
      p.save!
    end

    it "deberia buscar por id inexistente y retornar nil" do
      expect((Person.find_by_id 123).length == 0).to eq true
    end

    it "deberia buscar por id existente y retornar objeto" do
      p = Person.new
      p.save!

      found = (Person.find_by_id p.id)[0]

      expect(found).to have_attributes(
                           :first_name => p.first_name,
                           :last_name => p.last_name,
                           :age => p.age,
                           :admin => p.admin
                       )
    end

    it 'deberia actualizar los campos del objeto' do
      p = Person.new
      p.save!

      p.first_name = "pedro"
      p.refresh!

      expect(p.first_name).to eq "juan"
    end

    it "deberia fallar si intento refrescar una instancia aun no persistida" do
      expect {Person.new.refresh!}.to raise_error(StandardError)
    end

    it 'deberia dejarme eliminar' do
      p = Person.new
      p.save!
      expect(p.id).not_to eq nil

      p.forget!
      expect(p.id).to eq nil
    end

    context "y varias instancias persistidas" do

      before :each do
        (Person.new "pedro", "escamoso", 100, true).save!
        (Person.new "pedro", "escamoso", 100, true).save!
        (Person.new "juan", "pistolas", 100, true).save!
      end

      it "deberia poder obtener todas las instancias" do
        all = Person.all_instances

        expect(all).to be_a(Array)
        expect(all.length).to eq(3)
        expect(all[0]).to be_a(Person)
      end

      it "deberia buscar por atributo existente y retornar lista de objetos" do
        found = Person.find_by_first_name "pedro"

        expect(found).to be_a(Array)
        expect(found.length).to eq(2)
        expect(found[0]).to be_a(Person)
      end

    end

  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end