class Human < SQLObject
  self.table_name = 'humans'
    
  has_many(
    :cats,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: "Cat"
  )
  
  self.finalize!
  
end