require 'rspec'
require_relative '../orm'

using ORM

describe 'Al usar ORM' do

  class Nota
    has_one Numeric, named: :value

    def initialize calificacion
      @value=calificacion
    end
  end

  class Validaciones
    has_one String, named: :full_name, no_blank: true
    has_one Numeric, named: :age, from: 18, to: 100
    has_many Nota, named: :grades, validate: proc{ value > 2 }

    def initialize
      @full_name="anteojito"
      @age=50
      @grades = [(Nota.new 5), (Nota.new 4)]
    end
  end

  it "un objeto valido pasa perfecto" do
    expect{Validaciones.new.validate!}.not_to raise_error
  end

  it 'deberia validar no_blank' do
    v=Validaciones.new
    v.full_name=""
    expect{v.validate!}.to raise_error(RuntimeError)
  end
end