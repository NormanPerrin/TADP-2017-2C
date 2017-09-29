# require 'rspec'
# require_relative '../orm'

# using ORM

# describe 'Al usar ORM con composicion' do

#   class Grade
#     has_one Numeric, named: :value
#   end

#   class Student
#     has_one String, named: :full_name
#     has_one Grade, named: :grade
#   end

#   it 'deberia guardar en cascada' do
#     s = Student.new
#     s.full_name = "leo sbaraglia"
#     s.grade = Grade.new
#     s.grade.value = 8
#     s.save!

#     expect(s.id).not_to be_nil
#     expect(s.grade.id).not_to be_nil
#   end

#   after :each do
#     #borramos la base de datos
#     FileUtils.rm_f Dir.glob("#{Dir.pwd}/db/*")
#   end

# end