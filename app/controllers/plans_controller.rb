# (GET) All this controller does it show one the page of a specific plan by id
class PlansController < ApplicationController
  def show
    @plan = Plan.find(params[:id])
    @asteroid_count = Asteroid.where(diameter: @plan.min_diameter..@plan.max_diameter).count
  end
end
