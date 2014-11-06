class Cat < SQLObject  
  
  belongs_to(
    :owner,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: "Human"
  )
  
  self.finalize!
  
end