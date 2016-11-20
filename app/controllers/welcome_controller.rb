class WelcomeController < ApplicationController
  def index
    @leaderboard = Player.all.sort_by { |p| p.wins.count }.reverse
  end
end
