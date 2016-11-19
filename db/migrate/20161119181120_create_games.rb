class CreateGames < ActiveRecord::Migration
  def up
    create_table :games do |t|
      t.column :status, :integer, default: 0
      t.column :turn, :integer, default: 0
      t.column :winner, :integer
    end
  end

  def down
    drop_table :games
  end
end
