class Board < ActiveRecord::Base
  class InvalidMoveError < StandardError; end

  belongs_to :game

  validates :rows,    numericality: { only_integer: true, greater_than: 0 }
  validates :columns, numericality: { only_integer: true, greater_than: 0 }

  before_create :initialize_board

  def initialize_board
    self.board = [].tap do |new_board|
      columns.times { new_board << ("0" * rows) }
    end
  end

  def available_columns
    [].tap do |open_columns|
      board.each_with_index do |col, index|
        open_columns << index if col.match(/^0.*/).present?
      end
    end
  end

  def do_move(player_number, play_hash)
    col = play_hash[:col]
    validate_move(col)
    col = col.to_i
    row_index = board[col].rindex("0")
    board[col][row_index] = player_number.to_s
    self.save
  end

  def validate_move(column)
    fail InvalidMoveError unless column.present?                          # must be present
    fail InvalidMoveError unless column.to_i.to_s == column.to_s          # must be numeric
    fail InvalidMoveError unless column.to_i == column.to_f               # must be an integer
    fail InvalidMoveError unless available_columns.include?(column.to_i)  # must be available to play
    true
  end
end
