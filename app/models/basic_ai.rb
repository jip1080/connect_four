class BasicAi

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

  def determine_move
    winning_move?(@my_board) ||
      imminent_threats? ||
      determine_optimal_move
  end

  def suggested_move
    @suggested_move
  end

  #private

  # calculates column of first possible winning
  # move
  def find_winning_move(board)
    @game_board.available_columns(board).each do |col_index|
      move_option = possible_moves & @game_board.col_bitboard_for(col_index)
      return col_index if @game_board.check_for_win(move_option + board) 
    end
    nil
  end

  def winning_move?(board)
    @suggested_move ||= find_winning_move(board)
    @suggested_move.present?
  end

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

  def possible_moves
    @possible_moves ||= @game_board.possible_moves
  end
end