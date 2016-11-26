class Ai
  attr_accessor :me, :player_number

  def initialize(game, my_player_number)
    @game_board = game.board
    @my_board = game.board_for_player(my_player_number)
    @me = my_player_number
  end

  def do_move
    determine_move
    @game_board.game.update_board({'col' => @suggested_move.to_s})
  end

  def suggested_move
    @suggested_move
  end

  def determine_move
    winning_move?(@my_board - @game_board.clean_board) ||
      imminent_threats? ||
      determine_optimal_move
  end

  #private

  def winning_move?(board)
    @suggested_move ||= find_winning_move(board)
    @suggested_move.present?
  end
  
  # calculates column of first possible winning
  # move
  def find_winning_move(board)
    @game_board.available_columns(board).each do |col_index|
      move_option = possible_moves(@game_board.board[0].to_i) & @game_board.col_bitboard_for(col_index)
      return col_index if @game_board.check_for_win(move_option + board) 
    end
    nil
  end


  def imminent_threats?
    fail NotImplementedError, '#imminent_threats? not implemented'
  end

  def determine_optimal_move
    fail NotImplementedError, '#determine_optimal_move not implemented'
  end

  def possible_moves(check_board)
    @game_board.possible_moves(check_board)
  end
end
