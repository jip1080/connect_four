class Board < ActiveRecord::Base
  class InvalidMoveError < StandardError; end

  belongs_to :game

  validates :rows,    numericality: { only_integer: true, greater_than: 0 }
  validates :columns, numericality: { only_integer: true, greater_than: 0 }

  def self.type_list
    types = ObjectSpace.each_object(Class).select { |klass| klass < self }
    types.map { |type| type.name.gsub('Boards::', '') }
  end
  
  def initialize_board(player_count)
    fail NotImplementediError, '#initialize_board was not defined'
  end

  def available_columns(check_board)
    fail NotImplementedError, '#available_columns was not defined'
  end

  def do_move(player_number, play_hash)
    fail NotImplmentedError, '#do_move was not defined'
  end

  def win_detected?(player_number)
    fail NotImplmentedError, '#win_detected? was not defined'
  end

  def board_for_player(player_number)
    fail NotImplementedError, '#board_for_player was not defined'
  end

  def possible_moves
    fail NotImplementedError, '#possible_moves was not defined'
  end

  def winner
    @winner
  end
end
