class AddPasswordDigestToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :password_digest
  end
end
