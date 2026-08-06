class AddDiameterIndexToAsteroids < ActiveRecord::Migration[8.1]
  def change
    add_index :asteroids, :diameter
    add_index :asteroids, [ :diameter, :id ]
  end
end
