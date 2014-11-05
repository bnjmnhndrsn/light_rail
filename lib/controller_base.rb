require_relative './cookie'
require_relative './params'
require 'active_support/core_ext'
require 'erb'

#PRIME
class ControllerBase
  include UrlHelper
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    include_helpers
   
    @req, @res = req, res
    @params = Params.new(req, route_params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "already built response" if already_built_response?
    self.session.store_session(@res)
    self.flash.store_flash(@res)
    @res.status = 302
    @res["Location"] = url
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, type)
    raise "already built response" if already_built_response?
    self.session.store_session(@res)
    self.flash.store_flash_now(@res)
    @res.content_type = type
    @res.body = content
    @already_built_response = true
  end
  
  def render(template_name)
    f = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    erb = ERB.new(f)
    content = erb.result(binding)
    render_content(content, "text/html")
  end
  
  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
  
  def session
    @session ||= Session.new(@req)
  end
  
  def flash
    @flash ||= Flash.new(@req)
  end
end