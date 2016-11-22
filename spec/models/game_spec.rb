require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../rails_helper'

describe Game do
  let!(:game) { FactoryGirl.create(:game) }

  let!(:board) { FactoryGirl.create(:string_board, game: game) }

  let!(:player1) { FactoryGirl.create(:player, name: 'player1') }
  let!(:player2) { FactoryGirl.create(:player, name: 'player2') }
  let!(:player3) { FactoryGirl.create(:player, name: 'player3') }

  let!(:game_player1) { FactoryGirl.create(:game_player, game: game, player: player1, player_number: 1) }
  let!(:game_player2) { FactoryGirl.create(:game_player, game: game, player: player2, player_number: 2) }
  let!(:game_player3) { FactoryGirl.create(:game_player, game: game, player: player3, player_number: 3) }

  context '#current_player' do

    it 'returns player1 when it is their turn' do
      game.turn = 0
      game.save!
      expect(game.current_player).to eq(player1)
    end

    it 'returns player2 when it is their turn' do
      game.turn = 1
      game.save!
      expect(game.current_player).to eq(player2)
    end

    it 'returns player3 when it is their turn' do
      game.turn = 2
      game.save!
      expect(game.current_player).to eq(player3)
    end
  end

  context '#rotate_turn' do

    it 'increments the turn' do
      expect { game.rotate_turn }
        .to change(game, :turn)
        .from(0)
        .to(1)
    end

    it 'returns to player1 after player3' do
      game.turn = 2
      game.save!
      expect { game.rotate_turn }
        .to change(game, :turn)
        .from(2)
        .to(0)
    end
  end

  context '#update_board' do
    it 'rotates the turn after updating the board' do
      cur_turn = game.turn
      expect { game.update_board({col: "2"}) }
        .to change(game, :turn)
        .from(cur_turn)
        .to(cur_turn + 1 % 3)
    end
  end
end
