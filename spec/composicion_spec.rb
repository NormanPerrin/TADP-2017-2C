require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar ORM con composicion' do

  context "si la clase compuesta no es persistente" do

    class Telefono
      attr_accessor :numero
    end

    it "lanza excepcion al intentar definir el campo persistente" do
      expect {
        class Casa
          has_one
        end
      }.to raise_error(ArgumentError)
    end

  end

  context "si la clase compuesta es persistente" do

    class Grade
      has_one Numeric, named: :value

      def initialize(value=0)
        @value=value
      end
    end

    class Student
      has_one String, named: :full_name
      has_one Grade, named: :grade

      def initialize(full_name=nil)
        @full_name = full_name
      end
    end

    it 'deberia guardar en cascada' do
      s = Student.new "leo sbaraglia"
      s.grade = Grade.new 8
      s.save!

      expect(s.id).not_to be_nil
      expect(s.grade.id).not_to be_nil
    end

    it "deberia poder recuperar en cascada" do
      chavo = Student.new "chavo del 8"
      chavo.grade = Grade.new 0 #que bruto, pongale 0
      chavo.save!

      recuperado = Student.find_by_id(chavo.id)

      expect(recuperado).to have_attributes(:full_name => chavo.full_name)
      expect(recuperado.grade).to have_attributes(:value => chavo.grade.value)
    end

  end

  after :each do
    #borramos la base de datos
    FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
  end

end