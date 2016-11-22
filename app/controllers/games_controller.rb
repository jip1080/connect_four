class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def new
    @players = Player.all
  end

  # TODO: make this not crappy
  def create
    b = Boards::StringBoard.new(rows: params[:rows].to_i, columns: params[:columns].to_i)
    b.save!
    g = Game.new(board: b)
    g.save!
    player1 = Player.find(params[:player1])
    player2 = Player.find(params[:player2])
    GamePlayer.new(game: g, player: player1, player_number: 1).save!
    GamePlayer.new(game: g, player: player2, player_number: 2).save!
    g.reload
    redirect_to action: :show, id: g.id
  end

  def show
    @game = Game.find(params[:id])
  end

  def update_board
    game = Game.find(params[:game_id])
    player_num = game.current_player_number
    col, row = game.update_board(update_board_params)
    response1 = {
      'status': 'success',
      'column': col,
      'row': row,
      'player_number': player_num,
      'player_turn': game.current_player.name,
      'win_condition': game.completed?
    }

    render json: response1
  rescue => ex
    render json: {'status': 'failed'}
  end

  private

  def update_board_params
    params.permit(:col)
  end
end
