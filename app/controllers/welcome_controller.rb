class WelcomeController < ApplicationController
  def index
    players = Player.all
    @leaderboard = if players.any?
                     players.all.sort_by { |p| p.wins.count }.reverse
                   else
                     []
                   end
  rescue => ex
    Rails.logger.error ex
  end
end
