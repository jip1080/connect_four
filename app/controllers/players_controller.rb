class PlayersController < ApplicationController
  def index
    @players = Player.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @players }
    end
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
