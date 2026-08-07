# (GET) This is our homepage. Grabs all the plans dynamically from the plans database.
class HomeController < ApplicationController
  def index
    @plans = Plan.ordered_by_min_diameter
  end
end
