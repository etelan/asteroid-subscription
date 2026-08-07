# (GET) All this controller does it show one the page of a specific asteroid by id
class AsteroidsController < ApplicationController
  def show
    @asteroid = Asteroid.find(params[:id])
  end
end
