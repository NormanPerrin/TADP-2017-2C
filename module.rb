module Persisted

  module InstanceMethods
    def save!
      puts "#{self} se mando a guardar"
    end
  end

  refine Class do
    def has_one
      puts "#{self} declarado como clase persistible"
      self.instance_eval do
        include InstanceMethods
      end
    end
  end

end
