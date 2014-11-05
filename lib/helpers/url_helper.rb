module UrlHelper
  @@routes = []
  
  def self.get_url_hash(method, plural)
    sing = plural.to_s.singularize
    hash = {
      index: { 
        name: "#{plural}_url", method: :get, pattern: /^\/#{plural}$/, string: "#{plural}"
      },
      show: { 
        name: "#{sing}_url", method: :get, pattern: /^\/#{plural}\/(?<#{sing}_id>\d+)$/, string: "#{plural}/<id>"
      },
      create: {
         name: "#{plural}_url", method: :post, pattern: /^\/#{plural}$/, string: "#{plural}" 
      },
      edit: { 
        name: "edit_#{sing}_url", method: :get, pattern: /^\/#{plural}\/(?<#{sing}_id>\d+)\/edit$/, string: "#{plural}/<id>/edit"
      },
      update: { 
        name: "#{sing}_url", method: :put, pattern: /^\/#{plural}\/(?<#{sing}_id>\d+)$/, string: "#{plural}/<id>"
      },
      destroy: { 
        name: "#{sing}_url", method: :delete, pattern: /^\/#{plural}\/(?<#{sing}_id>\d+)$/, string: "#{plural}/<id>" 
      },
      new: { 
        name: "new_#{sing}_url", method: :get, pattern: /^\/#{plural}\/new$/, string: "#{plural}/new" 
      }
    }
  
    @@routes << hash[method]
    hash[method]
  end
    
  def include_helpers
    @@routes.each do |route_hash|
      self.class.send(:define_method, route_hash[:name]) do |id|
        route_hash[:string].gsub("<id>", id.to_s)
      end
    end
  end
  
end