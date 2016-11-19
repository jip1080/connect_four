class BoardBelongsToGames < ActiveRecord::Migration
  def up
    add_reference :boards, :game, index: true
  end

  def down
    remove_column :boards, :game_id
  end
end
