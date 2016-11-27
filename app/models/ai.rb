class Ai
  attr_accessor :me, :player_number

  def initialize(game, my_player_number)
    @game_board = game.board
    @my_board   = game.board_for_player(my_player_number)
    @me         = my_player_number
  end

  def do_move
    determine_move
    @game_board.game.update_board({'col' => @suggested_move.to_s})
  rescue => ex
    # Need more debugging on why the failed move from
    # the AI from time to time...
  end

  def suggested_move
    @suggested_move
  end

  def determine_move
    winning_move?(@my_board - @game_board.clean_board) ||
      imminent_threats? ||
      determine_optimal_move
  end

  private

  def one_move_threat?
    @game_board.board.each_with_index do |board, index|
      next if index == 0
      next if index == @me
      @suggested_move = find_winning_move(board.to_i)
      return true if @suggested_move
    end
    false
  end

  def winning_move?(board)
    @suggested_move ||= find_winning_move(board)
    @suggested_move.present?
  end
  
  def find_winning_move(board)
    options = possible_moves(@game_board.board[0].to_i)
    @game_board.available_columns(board).each do |col_index|
      move_option = options & @game_board.col_bitboard_for(col_index)
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
