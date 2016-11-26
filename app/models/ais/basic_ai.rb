module Ais
  class BasicAi < Ai

    private

    def imminent_threats?
      @game_board.board.each_with_index do |board, index|
        next if index == 0
        next if index == @me
        @suggested_move = find_winning_move(board.to_i)
        return true if @suggested_move
      end
      false
    end

    def determine_optimal_move
      col_list = @game_board.available_columns(@game_board.board[0].to_i)
      i = col_list.length
      col = rand(i)
      @suggested_move = col_list[col]
    end

  end
end
