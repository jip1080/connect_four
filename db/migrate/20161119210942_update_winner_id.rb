class UpdateWinnerId < ActiveRecord::Migration
  def up
    rename_column :games, :winner, :winner_id
  end

  def down
    rename_column :games, :winner_id, :winner
  end
end
