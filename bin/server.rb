require 'webrick'
require_relative '../lib/helper/url_helper'
require_relative '../lib/controller_base'
require_relative '../lib/router'


# $cats = [
#   { id: 1, name: "Curie" },
#   { id: 2, name: "Markov" }
# ]
#
# $statuses = [
#   { id: 1, cat_id: 1, text: "Curie loves string!" },
#   { id: 2, cat_id: 2, text: "Markov is mighty!" },
#   { id: 3, cat_id: 1, text: "Curie is cool!" }
# ]

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