class HomeController < ApplicationController
  def index
    @plans = Plan.ordered_by_min_diameter
  end
end
