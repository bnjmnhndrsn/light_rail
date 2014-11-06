class CatsController < ControllerBase
  def index
    cat = Cat.new
    debugger
    flash[:alert] = ["Hi"]
  end
  
  def show
  end
end