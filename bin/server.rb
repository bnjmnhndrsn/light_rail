require 'webrick'
require_relative '../lib/helpers/url_helper'
require_relative '../lib/controller_base'
require_relative '../lib/router'


class CatsController < ControllerBase
  def index
  end
end

router = Router.new
router.resources :cats, [:index, :show, :edit, :new]

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start