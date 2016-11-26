module Ais
  class AdvancedAi < Ai

    def initialize(game, my_player_number)
      super
      options = @game_board.available_columns(@game_board.board[0].to_i).size
      @wins_by_column   = Array.new(options) { 0 }
      @loses_by_column  = Array.new(options) { 0 }
    end

    #private

    LOOK_AHEAD = 7 # min number of moves to win
    LOSS_WEIGHT = 100
    TURN_OPPO = 1
    TURN_SELF = 2

    def imminent_threats?
      one_move_threat?
      two_move_trap? unless @suggested_move
      @suggested_move.present?
    end

    def one_move_threat?
      @game_board.board.each_with_index do |board, index|
        next if index == 0
        next if index == @me
        @suggested_move = find_winning_move(board.to_i)
        return true if @suggested_move
      end
      false
    end

    # may need to offset by clear_board?
    def two_move_trap?
      # Not worried about vertical two-in-a-row, only horizontal
      # with open moves on either side.  Diagonal determination
      # will come later
      opponent_two_in_a_row = @game_board.column_shift(opponent_board, 1) & opponent_board
      if opponent_two_in_a_row > 0
        possible = possible_moves(@game_board.board[0].to_i) 
        lshift1 = @game_board.column_shift(opponent_two_in_a_row, 1)
        rshift2 = @game_board.column_shift(opponent_two_in_a_row, -2)
        lshift2 = @game_board.column_shift(opponent_two_in_a_row, 2)
        rshift3 = @game_board.column_shift(opponent_two_in_a_row, -3)

        if ((lshift1 & possible > 0) && (rshift2 & possible > 0)) &&
           ((lshift2 & possible > 0) || (rshift3 & possible > 0))
          # THERE IS A HORIZONTAL TRAP SET!!
          # eventually use blah method to determine which is better move, 
          l = (@game_board.clean_board - 1 - @game_board.row_bitboard_for(@game_board.rows) - lshift1)
          @suggested_move = @game_board.available_columns(l).first
          return true
        end
      end
      return false
    end

    def opponent_board
      TURN_SELF == @me ? @game_board.board[TURN_OPPO].to_i : @game_board.board[TURN_SELF].to_i
    end

    def determine_optimal_move
      explore_initial_move_options
      #now look through wins / loses and determine best move
      results = []
      @wins_by_column.each_with_index { |win_count, index| results << win_count - @loses_by_column[index] }
      @suggested_move = results.rindex(results.max)
    end

    def explore_initial_move_options
      moves_options = @game_board.available_columns(@game_board.board[0].to_i)
      moves_count = moves_options.size
      moves_count.times do |i|
        #bias toward the middle of the board since that has the highest win likelihood
        selected_index = ((moves_count/2).ceil + i) % moves_count
        selected_col = moves_options[selected_index]
        results = @game_board.determine_updated_boards(@game_board.board[0].to_i, @game_board.board[@me].to_i, selected_col)
        blah(results[0], results[1], opponent_board, selected_index, LOOK_AHEAD-1, TURN_OPPO)
      end
    end


    def blah(avail_board, my_board, opponent_board, starting_move, current_depth, whose_turn)
      if @game_board.check_for_win(my_board)
        @wins_by_column[starting_move] += 1
      elsif @game_board.check_for_win(opponent_board)
        @loses_by_column[starting_move] += (LOOK_AHEAD - (LOOK_AHEAD - current_depth)) * LOSS_WEIGHT
      elsif current_depth > 0
        moves_options = @game_board.available_columns(avail_board)
        moves_count = moves_options.size
        moves_count.times do |i|
          selected_index = ((moves_count/2).ceil + i) % moves_count
          selected_col = moves_options[selected_index]
          board_to_update = whose_turn == TURN_SELF ? my_board : opponent_board
          new_boards = @game_board.determine_updated_boards(avail_board, board_to_update, selected_col)
          if whose_turn == TURN_SELF
            blah(new_boards[0], new_boards[1], opponent_board, starting_move, current_depth - 1, TURN_OPPO)
          else
            blah(new_boards[0], my_board, new_boards[1], starting_move, current_depth - 1, TURN_SELF)
          end
        end
      end
    end
  end
end
