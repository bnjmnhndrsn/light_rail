require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
      @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
      @primary_key = options[:primary_key] || :id
      @class_name = options[:class_name] || name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options 
    define_method(name) do 
     foreign_key = self.send(options.foreign_key)
     options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do 
     primary_key = self.send(options.primary_key)
     options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
  
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_table = through_options.model_class.table_name
      source_table = source_options.model_class.table_name
      query = <<-SQL
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table}
      ON
        #{through_table}.#{source_options.foreign_key} = 
          #{source_table}.#{source_options.primary_key}
      WHERE
        #{through_table}.#{through_options.primary_key} = ?
      SQL
      debugger
      result = DBConnection.execute(query, self.send(through_options.foreign_key)).first
      source_options.model_class.new(result)
    end
  end
end