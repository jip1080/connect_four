class AddWinnerIndexToGames < ActiveRecord::Migration
  def up
    add_index :games, :winner_id
  end

  def down
    remove_index :games, :winner_id
  end
end
