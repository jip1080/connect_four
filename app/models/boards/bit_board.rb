module Boards
  class BitBoard < Board
    ################################################
    # Board Layout:
    # [ <big_int_available>, <big_int_play1>, <big_int_play2> ]
    # <big_int> is the integer found by:
    # 2**((rows + 1) * column)
    # board starts from lower left corner, counting
    # up the column to row+1 total entries
    # then wraps around to the bottom of the next
    # column to the right. e.g. for a 4x4 board:
    # 4 9 14 19
    # 3 8 13 18
    # 2 7 12 17
    # 1 6 11 16
    # 0 5 10 15
    # where 4, 9, 14 and 19 are 0 value.
    ################################################


    def initialize_board
      self.board = [
        (2**((rows + 1) * columns)),
        (2**((rows + 1) * columns)),
        (2**((rows + 1) * columns))
      ]
    end

    def available_moves
      top_row = row_bitboard_for(rows)
      avail = top_row & board[0].to_i
      [].tap do |available_columns|
        columns.times do |col_index|
          available_columns << col_index if (avail ^ col_bitboard_for(col_index))
        end
      end
    end

    def do_move(player_number, play_hash)
      @move = play_hash['col']
      fail InvalidMoveError unless valid_move?
      closed_rows = closed_rows_in_column
      row_board, row_index = find_first_open_row_in_column(closed_rows)
      move_board = row_board & col_bitboard_for(@move)
      board[0] = board[0].to_i + move_board
      board[player_number] = board[player_number] + move_board
      self.save
      return @move, row_index
    end

    def win_detected?(player_number)
      @player_board = board[player_number] >> rows
      if forward_diagonal_winner? ||
        backward_diagonal_winner? ||
        column_winner? ||
        row_winner?
        @winner = player_number
        return true
      end
      false 
    end

    def forward_diagonal_winner?
      return true if (@player_board & (@player_board >> (2 * (rows + 2))))  # / check
    end

    def backward_diagonal_winner?
      return true if (@player_board & (@player_board >> (2 * rows)))        # \ check
    end

    def column_winner?
      return true if (@player_board & (@player_board >> (2 * (rows + 3))))  # | check
    end

    def row_winner?
      return true if (@player_board & (@player_board >> (2 * (rows + 1))))  # - check
    end

    def find_first_open_row_in_column(row_options)
      row_index = 0
      while(row_index < rows)
        row_board = row_bitboard_for(row_index)
        return row_board, row_index unless (row_board & row_options)
        row_index += 1
      end
      fail InvalidMoveError
    end

    def closed_rows_in_column
      col_board = col_bitboard_for(@move)
      col_board & board[0].to_i
    end

    def valid_move?
      available_moves.include?(@move)
    end

    def col_bitboard_for(col)
      base_col_bitboard >> (col * (rows + 1))
    end

    def base_col_bitboard
      @base_col ||= calc_base_column
    end

    def calc_base_column
      y = 0
      rows.times { |row_index| y += (2**(row_index)) }
      y << (columns*rows + 1)
    end

    def row_bitboard_for(row)
      base_row_bitboard >> row
    end

    def base_row_bitboard
      @base_row ||= calc_base_row
    end

    # creates a bitboard value for the base row
    # existing as occupied
    def calc_base_row
      y = 0
      columns.times { |i| y += (2**((rows+1)*(i+1))) }
      y >> 1
    end
  end
end
