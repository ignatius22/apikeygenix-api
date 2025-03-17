class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.string :key, null: false
      t.string :status, default: 'active'
      t.integer :usage_count, default: 0
      t.references :user, null: false, foreign_key: true
      t.datetime :last_used_at
      t.timestamps
    end
    add_index :api_keys, :key, unique: true
  end
end
