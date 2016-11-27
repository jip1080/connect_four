module Ais
  class BasicAi < Ai

    private

    def imminent_threats?
      one_move_threat?
    end

    def determine_optimal_move
      col_list = @game_board.available_columns(@game_board.board[0].to_i)
      i = col_list.length
      col = rand(i)
      @suggested_move = col_list[col]
    end

  end
end
