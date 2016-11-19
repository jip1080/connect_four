class CreateGamePlayers < ActiveRecord::Migration
  def up
    create_table :game_players do |t|
      t.belongs_to :game, index: true
      t.belongs_to :player, index: true
      t.integer :player_number
    end
  end

  def down
    drop_table :game_players
  end
end
