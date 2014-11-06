class CatsController < ControllerBase
  def index
    flash[:alert] = ["Hi"]
  end
  
  def show
  end
end