class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def new
    @players = Player.all
  end

  # TODO: make this not crappy
  def create
    b = Board.new(rows: params[:rows].to_i, columns: params[:columns].to_i)
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
    game.update_board(update_board_params)
    render json: {"status": "success"}
  rescue => ex
    render json: {"status": "failed"}
  end

  private

  def update_board_params
    params.permit(:col)
  end
end
