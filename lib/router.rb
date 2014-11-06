class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    return false unless @pattern.is_a?(Regexp)
    !!(@pattern.match(req.path) && req.request_method.downcase.to_sym == @http_method)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = req.path.match(@pattern)
    route_params = match_data ? Hash[match_data.names.zip(match_data.captures)] : {}
    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end
  
  
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end
  
  #allow for Rails-like "resources call"
  def resources(name, actions)
    actions.each do |action|
      hash = UrlHelper::get_url_hash(action, name)
      open_controller(name.to_s)
      self.send(hash[:method], hash[:pattern], "#{name.to_s.capitalize}Controller".constantize, action)
    end
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
  
  # opens controller file so it can be instantiated later
  def open_controller(name)
    require_relative "../controllers/#{name.pluralize.downcase}_controller"
  end
  
  
end