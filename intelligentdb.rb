require 'tadb'

class IntelligentDB

  def initialize(clase)
    @table = TADB::DB.table(clase)
  end

  def insertOrUpdate(hash)
    if search_by_id(hash[:id]).nil?
      return insert(hash)
    else
      return update(hash)
    end
  end

  def insert(hash)
    @table.insert(hash)
  end

  def update(hash)
    #TODO: que hacemos con un update?
    @table.insert(hash)
  end

  def entries
    @table.entries
  end

  def search_by_id(id)
    posible = search_by(:id, id)
    return nil if posible.length == 0
    return posible[0] if posible.length == 1
    raise IOError "La base informa #{posible.length} registros con ese id."
  end

  def search_by(field, value)
    @table.entries.select {|hash| hash[field]==value}
  end

  def delete(id)
    @table.delete(id)
  end

end
