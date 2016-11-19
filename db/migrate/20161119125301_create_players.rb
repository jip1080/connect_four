class CreatePlayers < ActiveRecord::Migration
  def up
    create_table :players do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end

  def down
    drop_table :players
  end
end
