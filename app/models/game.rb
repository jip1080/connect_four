class Game < ActiveRecord::Base
  class GameOverError < StandardError; end

  has_one :board

  belongs_to :winner, class_name: 'Player'

  has_many :game_players
  has_many :players, through: :game_players

  enum status: [ :active, :completed ]

  before_create :initialize_board
  after_create :initialize_game_players

  def params_from_controller(params=nil)
    @params ||= params
  end

  def initialize_board
    self.board ||= Board.create!(type: "Boards::#{@params['board_type']}",
                                 rows: @params['rows'].to_i,
                                 columns: @params['columns'].to_i)
    self.board.initialize_board(@params['player_count'].to_i)
  end

  def initialize_game_players
    return true if game_players.count > 0
    @params['player_count'].to_i.times do |i|
      player = Player.find(@params["player#{ i + 1 }"])
      self.game_players << GamePlayer.create!(game: self, player: player, player_number: i + 1)
    end
    self.save!
  end

  def update_board(play_hash)
    fail GameOverError unless active?
    col, row = board.do_move(current_player_number, play_hash)
    game_over? ? finish_game : rotate_turn
    self.save!
    return col, row
  rescue Board::InvalidMoveError => ex
    Rails.logger.error "Player: #{current_player_number} attempted illegal move"
    raise
  end

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

  def board_for_player(player_number)
    board.board_for_player(player_number).to_i
  end

  def computer_move?
    current_player.computer?
  end

  private

  def game_over?
    board.win_detected?(current_player_number)
  end

  def finish_game
    self.completed!
    self.winner = game_players.find { |gp| gp.player_number == board.winner.to_i }.player
  end

  def rotate_turn
    self.turn = (self.turn + 1) % players.count
  end
end
