class PlayersController < ApplicationController
  def index
    @players = Player.all
  end

  def new
  end

  def create
    Player.create(player_params)
    redirect_to action: :index
  end

  def show
    @player = Player.find(params[:id])
  end

  private

  def player_params
    params.permit(:name)
  end
end
