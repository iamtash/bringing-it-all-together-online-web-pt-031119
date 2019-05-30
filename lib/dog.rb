require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0]
    self.new_from_db(row)
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = 'INSERT INTO dogs (name, breed) VALUES (?,?)'
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
    result = DB[:conn].execute(sql, name, breed)
    if !result.empty?
      dog_data = result[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
