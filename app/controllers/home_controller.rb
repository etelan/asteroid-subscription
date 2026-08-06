class HomeController < ApplicationController
  def index
    @plans = Plan.order(:min_diameter)
  end
end
