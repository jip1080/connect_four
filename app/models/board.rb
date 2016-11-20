class Board < ActiveRecord::Base
  class InvalidMoveError < StandardError; end

  belongs_to :game

  validates :rows,    numericality: { only_integer: true, greater_than: 0 }
  validates :columns, numericality: { only_integer: true, greater_than: 0 }

  before_create :initialize_board

  ########################
  # Board Layout:
  # [ "col1", "col2", ..., "coln" ]
  # col = "r1r2r3r4...rn"
  # coordinates start from upper
  # left corner, counting up in
  # each case
  ########################
  # TODO: Make comment better

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
    return col, row_index
  end

  def win_detected?
    column_winner? ||
      row_winner? ||
      forward_diagonal_winner? ||
      backward_diagonal_winner?
  end

  def winner
    @winner
  end

  def column_winner?
    board.each do |col|
      return true if extract_winner_if_present(col)
    end
    false
  end

  def row_winner?
    rows.times do |index|
      row = board.map { |c| c[index] }.join('')
      return true if extract_winner_if_present(row)
    end
    false
  end

  def forward_diagonal_winner?
    row = 3 # can't make 4-in-a-row / starting higher
    col = 0
   # while (row < rows && col < columns) do
    possible_diagonals.times do |i|
      diagonal_candidate = build_diagonal(:forward, row, col)
      return true if extract_winner_if_present(diagonal_candidate)
      col += 1 unless row < (rows - 1)
      row += 1 if row < (rows - 1)
    end
    false
  end

  def backward_diagonal_winner?
    row = [columns - 4, rows].min
    col = 0
    possible_diagonals.times do |i|
      diagonal_candidate = build_diagonal(:backward, row, col)
      return true if extract_winner_if_present(diagonal_candidate)
      col += 1 if row == 0
      row -= 1 unless row == 0
    end
    false
  end

  def build_diagonal(direction, row, col)
    row_delta = (direction == :forward ? -1 : 1)
    row_string = ""
    while(row < rows && col < columns) do
      row_string << board[col][row]
      col += 1
      row += row_delta if row >= 0
    end
    row_string
  end

  # calculates total possible diagonal lines of length
  # greater than 4 which can be made on an
  # arbitrary size grid

  def possible_diagonals
    min = [rows, columns].min
    max = [rows, columns].max
    base = (min - 4) * 2 + 1
    total = (max - min) + base
  end

  def extract_winner_if_present(candidate)
    matches = candidate.match(/.*([1]{4}|[2]{4}).*/).try(:[], 1)
    if matches.present?
      @winner = matches[0]
      return true
    end
    false
  end

  def validate_move(column)
    fail InvalidMoveError unless column.present?                          # must be present
    fail InvalidMoveError unless column.to_i.to_s == column.to_s          # must be numeric
    fail InvalidMoveError unless available_columns.include?(column.to_i)  # must be available to play
    true
  end
end
