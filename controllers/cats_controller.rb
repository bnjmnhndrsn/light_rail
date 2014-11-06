class CatsController < ControllerBase
  
  def index
    @cats = Cat.all
  end
  
  def show
    id = params[:cat_id]
    @cat = Cat.find(id)
    debugger
  end
  
  def new
    @cat = Cat.new
  end
end