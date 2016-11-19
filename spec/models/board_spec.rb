require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../rails_helper'

describe Board do
  context 'a new board' do
    let(:valid_row) { 5 }
    let(:valid_col) { 5 }
    let(:valid_board) do
      [].tap do |new_board|
        valid_col.times { new_board << ("0" * valid_row) }
      end
    end
    let(:new_board_object) { FactoryGirl.create(:board, rows: valid_row, columns: valid_col) }

    it 'requires a greater-than-zero row size' do
      expect { Board.new(rows: -10, columns: 2).save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'requires a greater-than-zero column size' do
      expect { Board.new(rows: 10, columns: -2).save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'automatically builds the board to the row/column sizes' do
      expect(new_board_object.board).to match_array(valid_board)
    end
  end

  context '#available_columns' do
    let(:board) { FactoryGirl.create(:board, rows: 4, columns: 4) }

    it 'returns the only the open columns' do
      board.board = ["0000", "1212", "1234", "0121"]
      expect(board.available_columns).to match_array([0,3])
    end
  end

  context '#do_move' do
    let(:starting_board) { ["0000", "0001", "0011", "1111"] }
    let(:board) { FactoryGirl.create(:board, rows: 4, columns: 4) }

    before(:each) do
      board.board = starting_board
      board.save!
    end

    it 'updates the board with a valid move' do
      after_move_board = ["0001", "0001", "0011", "1111"]
      expect(board.board).to match_array(starting_board)
      board.do_move("1", {col: "0"})
      board.reload
      expect(board.board).to match_array(after_move_board)
    end

    it 'places the token into the first available slot' do
      after_move_board = ["0000", "0011", "0011", "1111"]
      expect(board.board).to match_array(starting_board)
      board.do_move("1", {col: "1"})
      board.reload
      expect(board.board).to match_array(after_move_board)
    end

    it 'raises an error if the column is full' do
      expect { board.do_move(1, {col: "3"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the column does not exist' do
      expect { board.do_move(1, {col: "10"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the move is not an integer' do
      expect { board.do_move(1, {col: "10.1"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the move is not numeric' do
      expect { board.do_move(1, {col: "cat"}) }.to raise_error Board::InvalidMoveError
    end
  end
end
