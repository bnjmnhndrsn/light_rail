require 'webrick'
require 'require_all'
require_relative '../lib/helpers/url_helper'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative '../lib/sql_object/sql_object'
require_all 'models'

router = Router.new
router.resources :cats, [:index, :show, :edit, :new]

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start