require 'json'
require 'webrick'
require 'byebug'

class CookieLite
  def initialize(req, name)
    cookie = req.cookies.select { |cookie| cookie.name == name }
    @cookie = cookie.empty? ? {} : JSON.parse(cookie.first.value)
  end

  def [](key)
    @cookie[key.to_s]
  end

  def []=(key, val)
    @cookie[key.to_s] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store(res, name)
    res.cookies << WEBrick::Cookie.new(name, @cookie.to_json) 
  end
end

class Session < CookieLite
  NAME = '_light_rail_app'
  
  def initialize(req)  
    super(req, NAME)
  end
  
  def store_session(res)
    store(res, NAME)
  end
  

end

class Flash < CookieLite
  NAME = '_light_rail_flash'
  
  def initialize(req)  
    super(req, NAME)
    @cookie["_next"] = {} if @cookie["_next"].nil?
  end
      
  def store_flash(res)
    @cookie = @cookie["_next"]
    store(res, NAME)
  end
  
  def store_flash_now(res)
    store(res, NAME)
  end
  
  def []=(key, val)
    @cookie["_next"][key.to_s] = val
  end
  
  def now
    @cookie
  end

end
