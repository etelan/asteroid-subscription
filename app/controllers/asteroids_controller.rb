class AsteroidsController < ApplicationController
  def show
    @asteroid = Asteroid.find(params[:id])
  end
end
