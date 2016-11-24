class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def new
    @players = Player.all
    @board_types = Board.type_list
  end

  def create
    game = Game.new()
    game.params_from_controller(game_params)
    game.save!
    redirect_to action: :show, id: game.id
  end

  def show
    @game = Game.find(params[:id])
  end

  def update_board
    game = game_board
    player_num = game.current_player_number
    col, row = game.update_board(update_board_params)
    response = {
      status: 'success',
      column: col,
      row: row,
      player_number: player_num,
      player_turn: game.current_player.name,
      win_condition: game.completed?,
      computer_move: game.computer_move?
    }

    render json: response
  rescue => ex
    render json: { status: 'failed' }
  end

  def computer_move
    game = game_board
    player_num = game.current_player_number
    ai = BasicAi.new(game, player_num)
    col, row = ai.do_move
    response = {
      status: 'success',
      column: col,
      row: row,
      player_number: player_num,
      player_turn: game.current_player.name,
      win_condition: game.completed?,
      computer_move: false
    }
    render json: response
  rescue => ex
    render json: { status: 'failed' }
  end

  private

  def game_board
    Game.find(params[:game_id])
  end

  def update_board_params
    params.permit(:col)
  end

  def game_params
    valid_players = [].tap do |players|
      params[:player_count].to_i.times do |i|
        players << "player#{ i + 1 }"
      end
    end
    valid_params = [:board_type, :rows, :columns, :player_count]
    valid_params.push(*valid_players)
    params.permit(*valid_params)
  end
end
