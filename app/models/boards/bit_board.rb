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


    def initialize_board(player_count)
      self.board ||= Array.new(player_count + 1) { clean_board }
    end

    def clean_board
      (2**((rows + 1) * columns))
    end

    
    def board_for_player(player_number)
      board[player_number].to_i
    end

    def do_move(player_number, play_hash)
      selected_column = play_hash['col'].to_i
      fail InvalidMoveError unless valid_move?(selected_column)
      new_boards = determine_updated_boards(board[0].to_i, board[player_number].to_i, selected_column)
      update_board(0, new_boards[0])
      update_board(player_number, new_boards[1])
      self.save
      return selected_column, new_boards[2]
    end

    # returns an updated available_board, player_board
    # and the row index where the play happened
    def determine_updated_boards(available_board, player_board, col_index)
      closed_rows = closed_rows_in_column(available_board, col_index)
      row_board, row_index = find_first_open_row_in_column(closed_rows)
      fail InvalidMoveError unless row_index >= 0
      move_board = build_move_board(col_index, row_index)
      available_board = available_board + move_board
      player_board = player_board + move_board
      return [available_board, player_board, row_index]
    end

    def update_board(board_index, new_board)
      board[board_index] = new_board
    end

    #-------HELPERS------
    # Helper methods below this
    # point should not operate on
    # current board state, but
    # rather operate on boards
    # passed in.
    #-------HELPERS------

    def available_columns(check_board)
      top_row = row_bitboard_for(rows)
      avail = top_row + check_board
      [].tap do |column_list|
        columns.times do |col_index|
          if (avail & col_bitboard_for(col_index) ^ col_bitboard_for(col_index)) > 0
            column_list << col_index
          end
        end
      end
    end

    def build_move_board(col_index, row_index)
      col_bitboard_for(col_index) & row_bitboard_for(row_index)
    end

    def possible_moves(check_board)
      base_board = 0
      columns.times do |col_index|
        closed_rows = closed_rows_in_column(check_board, col_index)
        row_board, row_index = find_first_open_row_in_column(closed_rows)
        move_board = build_move_board(col_index, row_index)
        base_board = base_board + move_board
      end
      base_board
    end

    def win_detected?(player_number)
      player_board = board[player_number].to_i - clean_board
      if check_for_win(player_board)
        @winner = player_number
        return true
      end
      false 
    end

    def check_for_win(player_board)
      forward_diagonal_winner?(player_board) ||
        backward_diagonal_winner?(player_board) ||
        column_winner?(player_board) ||
        row_winner?(player_board)
    end

    def forward_diagonal_winner?(player_board)
      # / check as data is represented, \ as displayed
      shift_1 = player_board & (player_board >> rows)
      shift_1 & (shift_1 >> (2 * rows)) > 0
    end

    def backward_diagonal_winner?(player_board)
      # \ check as data is represented, / as displayed
      shift_1 = player_board & (player_board >> (rows + 2))
      shift_1 & (shift_1 >> (2 * (rows + 2))) > 0
    end

    def row_winner?(player_board)
      # | check as data is represented, - as board is displayed
      shift_1 = player_board & (player_board >> 1)
      shift_1 & (shift_1 >> 2) > 0
    end

    def column_winner?(player_board)
      # - check as data is represented, | as board is displayed
      shift_1 = player_board & (player_board >> (rows + 1))
      shift_1 & (shift_1 >> (2 * (rows + 1))) > 0
    end

    def forward_diagonal_shift(player_board, rotations)
      player_board >> (rows * rotations)
    end
    
    def backward_diagonal_shift(player_board, rotations)
      player_board >> ((rows + 2) * rotations)
    end

    def column_shift(player_board, rotations)
      player_board >> ((rows + 1) * rotations)
    end
    
    def row_shift(player_board, rotations)
      player_board >> (1 * rotations)
    end

    def find_first_open_row_in_column(row_options)
      row_index = 0
      while(row_index < rows)
        row_board = row_bitboard_for(row_index)
        return row_board, row_index unless (row_board & row_options) > 0
        row_index += 1
      end
      return 0, -1
    end

    def closed_rows_in_column(check_board, selected_column)
      col_board = col_bitboard_for(selected_column)
      col_board & check_board
    end

    def valid_move?(selected_column)
      avail_board = board[0].to_i
      available_columns(avail_board).include?(selected_column)
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
