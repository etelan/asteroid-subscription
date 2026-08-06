class CreateInitialSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :address
      t.string :email
      t.boolean :is_admin, default: false

      t.timestamps
    end

    create_table :asteroids do |t|
      t.string :spkid, null: false
      t.string :full_name
      t.string :kind
      t.float :diameter
      t.float :diameter_sigma
      t.datetime :first_obs
      t.datetime :last_obs
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :asteroids, :spkid, unique: true

    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :asteroid, null: false, foreign_key: true
      t.integer :upcoming_asteroid_id # Reference to asteroid(s).spkid or id
      t.float :max_diameter
      t.float :min_diameter
      t.integer :perMonth

      t.timestamps
    end
  end
end
