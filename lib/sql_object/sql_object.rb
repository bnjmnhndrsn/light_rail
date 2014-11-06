require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  
  extend Searchable
  extend Associatable
  
  def self.columns
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
    SQL
    DBConnection.execute2(query)[0].map(&:to_sym)
  end
  
  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize 
  end

  def self.all
    query = <<-SQL
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL
   results = DBConnection.execute(query)
   p results
   self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    query = <<-SQL
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ? 
    SQL
   result = DBConnection.execute(query, id.to_i).first
   result ? Cat.new(result) : nil 
  end

  def initialize(params = {})
    params.each do |key, val|
      attr_name = key.to_sym
      
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      
      self.send("#{attr_name}=", val)
    
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    query = <<-SQL
    INSERT INTO
    #{self.class.table_name} (#{self.class.columns.join ","})
    VALUES
    (#{(["?"] * attribute_values.length).join ","})
    SQL
    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    query = <<-SQL
    UPDATE
    #{self.class.table_name}
    SET
    #{self.class.columns.map {|col| "#{col} = ?"}.join ","}
    WHERE
    id = ?
    SQL
    
    DBConnection.execute(query, *attribute_values, id)  
  end

  def save
    if id.nil? then insert else update end
  end
end