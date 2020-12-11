require_relative "../config/environment.rb"

class Student

    # has a name and a grade
    # has an id that defaults to `nil` on initialization
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

    # creates the students table in the database
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY, 
      name TEXT,
      grade INTEGER
      )
      SQL
      DB[:conn].execute(sql)
  end

  # drops the students table from the database
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students 
      SQL
      DB[:conn].execute(sql)
  end

  # saves an instance of the Student class to the database and then sets the given students `id` attribute
  # updates a record if called on an object that is already persisted

  def save
    if self.id
      self.update
    else 
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

    # creates a student with two attributes, name and grade, and saves it into the students table.
  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end
    # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)# return the newly created instance
  end
    #     returns an instance of student that matches the name from the DB
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first

  end
    #     updates the record associated with a given instance
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end




#  DB[:conn]


end
