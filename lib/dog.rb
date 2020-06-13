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
        breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  def self.drop_table
    # sql =  "DROP TABLE dogs"
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
        if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(attr_hash)
    #dog = Dog.new(attr_hash) also passes
    dog = Dog.new(id: attr_hash[0], name: attr_hash[1], breed: attr_hash[2])
    attr_hash.each {|key, value| dog.send(("#{key}="), value)}
    dog.save
    dog
  end
  # def self.create(name:, breed:)
  #   dog = Dog.new(name, breed)
  #   dog.save
  #   dog
  # end  
  
    def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
       end.first
    end
    
    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        # dog = self.new_from_db(dog_data)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
      else
        dog = self.create(name: name, breed: breed)
      end
        dog
    end

    
    def self.find_by_name(name)
       sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end
    
    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
