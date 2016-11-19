class Game < ActiveRecord::Base

  has_one :board

  belongs_to :winner, class_name: 'Player'

  has_many :game_players
  has_many :players, through: :game_players

  enum status: [ :active, :completed ]

  def current_player
    game_players.find { |gp| gp.player_number == (turn + 1) }.player
  end

  def rotate_turn
    self.turn = (self.turn + 1) % players.count
  end

end
