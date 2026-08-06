class UpdateSchemaForPlansAndAsteroids < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.text :description
      t.float :min_diameter
      t.float :max_diameter
      t.float :price

      t.timestamps
    end

    add_column :asteroids, :moid_ld, :float

    change_table :users do |t|
      t.references :plan, foreign_key: true
      t.date :plan_start_date
      t.references :upcoming_asteroid, foreign_key: { to_table: :asteroids }
    end

    drop_table :subscriptions
  end
end
