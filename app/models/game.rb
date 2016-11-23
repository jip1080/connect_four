class Game < ActiveRecord::Base
  class GameOverError < StandardError; end

  has_one :board

  belongs_to :winner, class_name: 'Player'

  has_many :game_players
  has_many :players, through: :game_players

  enum status: [ :active, :completed ]

  # modulo rolls to 0, but player numbering starts
  # at 1, so the turn corresponds to 1 less than
  # the player's number. That will be taken into
  # account in many calculations

  def current_player
    game_players.find { |gp| gp.player_number == (turn + 1) }.player
  end

  def current_player_number
    turn + 1
  end

  def rotate_turn
    self.turn = (self.turn + 1) % players.count
  end

  def update_board(play_hash)
    fail GameOverError unless active?
    col, row = board.do_move(current_player_number, play_hash)
    if board.win_detected?(current_player_number)
      self.completed!
      self.winner = game_players.find { |gp| gp.player_number == board.winner.to_i }.player
    else
      rotate_turn
    end
    self.save!
    return col, row
  rescue Board::InvalidMoveError => ex
    Rails.logger.error "Player: #{current_player_number} attempted illegal move"
    raise
  end
end
