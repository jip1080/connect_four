module Ais
  class AdvancedAi < Ai

    def initialize(game, my_player_number)
      super
      options = initial_available.size
      @wins_by_column   = Array.new(options) { 0 }
      @loses_by_column  = Array.new(options) { 0 }
    end

    private

    LOOK_AHEAD  = 6 # min number of moves to win
    LOSS_WEIGHT = 100
    TURN_OPPO   = 1
    TURN_SELF   = 2

    def imminent_threats?
      one_move_threat?
      two_move_trap? unless @suggested_move
      @suggested_move.present?
    end

    def two_move_trap?
      opponent_two_in_a_row = @game_board.column_shift(opponent_board, 1) & opponent_board
      return false unless opponent_two_in_a_row > 0
      possible = possible_moves(@game_board.board[0].to_i)
      lshift1 = @game_board.column_shift(opponent_two_in_a_row, 1)
      rshift2 = @game_board.column_shift(opponent_two_in_a_row, -2)
      lshift2 = @game_board.column_shift(opponent_two_in_a_row, 2)
      rshift3 = @game_board.column_shift(opponent_two_in_a_row, -3)

      if ((lshift1 & possible > 0) && (rshift2 & possible > 0)) &&
        ((lshift2 & possible > 0) || (rshift3 & possible > 0))
        blocking_board = blocking_board_for(lshift1)
        @suggested_move = @game_board.available_columns(blocking_board).first
        return true
      end
    end

    def blocking_board_for(left_blocking_move)
      full_board = @game_board.clean_board - 1
      full_board_corrected_top = full_board - @game_board.row_bitboard_for(@game_board.rows)
      full_board_corrected_top - left_blocking_move
    end

    def opponent_board
      TURN_SELF == @me ? @game_board.board[TURN_OPPO].to_i : @game_board.board[TURN_SELF].to_i
    end

    def determine_optimal_move
      populate_win_loss_counts
      select_optimal_move unless @suggested_move
    end

    def select_optimal_move
      results = []
      @wins_by_column.each_with_index { |win_count, index| results << win_count - @loses_by_column[index] }
      @suggested_move = results.rindex(results.max)
    end

    def initial_available
      @game_board.available_columns(@game_board.board[0].to_i)
    end

    def empty_board?
      @game_board.board[0].to_i == @game_board.clean_board
    end

    def optimal_first_move
      @suggested_move = (@game_board.columns / 2).ceil
    end

    def populate_win_loss_counts
      return optimal_first_move if empty_board?
      move_options = initial_available
      moves_count = move_options.size
      moves_count.times do |option_index|
        #bias toward the middle of the board since that has the highest win likelihood
        selected_index = ((moves_count/2).ceil + option_index) % moves_count
        selected_col = move_options[selected_index]
        results = @game_board.determine_updated_boards(@game_board.board[0].to_i,
                                                       @game_board.board[@me].to_i,
                                                       selected_col)
        mini_max(results[0], results[1], opponent_board,
                 selected_index, LOOK_AHEAD-1, TURN_OPPO)
      end
    end

    def mini_max(avail_board, my_board, opponent_board, starting_move, current_depth, whose_turn)
      if @game_board.check_for_win(my_board)
        @wins_by_column[starting_move] += 1
      elsif @game_board.check_for_win(opponent_board)
        @loses_by_column[starting_move] += (LOOK_AHEAD - (LOOK_AHEAD - current_depth)) * LOSS_WEIGHT
      elsif current_depth > 0
        calculate_deeper_moves(avail_board, my_board, opponent_board, starting_move, current_depth, whose_turn)
      end
    end

    def calculate_deeper_moves(avail_board, my_board, opponent_board, starting_move, current_depth, whose_turn)
      move_options = @game_board.available_columns(avail_board)
      moves_count = move_options.size
      moves_count.times do |i|
        selected_col = determine_selected_column(move_options, i)
        new_boards = update_board(whose_turn, avail_board, my_board, opponent_board, selected_col)
        if whose_turn == TURN_SELF
          mini_max(new_boards[0], new_boards[1], opponent_board, starting_move, current_depth - 1, TURN_OPPO)
        else
          mini_max(new_boards[0], my_board, new_boards[1], starting_move, current_depth - 1, TURN_SELF)
        end
      end
    end

    def determine_selected_column(move_options, offset)
      selected_index = select_index(move_options.count, offset)
      move_options[selected_index]
    end

    def update_board(whose_turn, avail_board, my_board, opponent_board, selected_col)
      board_to_update = whose_turn == TURN_SELF ? my_board : opponent_board
      @game_board.determine_updated_boards(avail_board, board_to_update, selected_col)
    end

    def select_index(total_moves, index)
      ((total_moves/2).ceil + index) % total_moves
    end
  end
end
