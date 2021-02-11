require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize( id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    create table if not exists students (
      id integer primary key,
      name text, 
      grade integer
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    drop table students;
    SQL
    DB[:conn].execute(sql)
  end

  def save 
    if self.id
      self.update
    else
    sql = <<-SQL
    insert into students (name, grade)
    values (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end 

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      select *
      from students
      where name = ?
      limit 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
  end 

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end




  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
