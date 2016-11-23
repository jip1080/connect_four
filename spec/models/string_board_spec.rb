require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../rails_helper'

describe Boards::StringBoard do
  context 'a new board' do
    let(:valid_row) { 5 }
    let(:valid_col) { 5 }
    let(:valid_board) do
      [].tap do |new_board|
        valid_col.times { new_board << ("0" * valid_row) }
      end
    end
    let(:new_board_object) { FactoryGirl.create(:string_board, rows: valid_row, columns: valid_col) }

    it 'requires a greater-than-zero row size' do
      expect { Boards::StringBoard.new(rows: -10, columns: 2).save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'requires a greater-than-zero column size' do
      expect { Boards::StringBoard.new(rows: 10, columns: -2).save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'automatically builds the board to the row/column sizes' do
      expect(new_board_object.board).to match_array(valid_board)
    end
  end

  context '#available_moves' do
    let(:string_board) { FactoryGirl.create(:string_board, rows: 4, columns: 4) }

    it 'returns the only the open columns' do
      string_board.board = ["0000", "1212", "1234", "0121"]
      expect(string_board.available_moves).to match_array([0,3])
    end
  end

  context '#do_move' do
    let(:starting_board) { ["0000", "0001", "0011", "1111"] }
    let(:string_board) { FactoryGirl.create(:string_board, rows: 4, columns: 4) }

    before(:each) do
      string_board.board = starting_board
      string_board.save!
    end

    it 'updates the board with a valid move' do
      after_move_board = ["0001", "0001", "0011", "1111"]
      expect(string_board.board).to match_array(starting_board)
      string_board.do_move("1", {col: "0"})
      string_board.reload
      expect(string_board.board).to match_array(after_move_board)
    end

    it 'places the token into the first available slot' do
      after_move_board = ["0000", "0011", "0011", "1111"]
      expect(string_board.board).to match_array(starting_board)
      string_board.do_move("1", {col: "1"})
      string_board.reload
      expect(string_board.board).to match_array(after_move_board)
    end

    it 'raises an error if the column is full' do
      expect { string_board.do_move(1, {col: "3"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the column does not exist' do
      expect { string_board.do_move(1, {col: "10"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the move is not an integer' do
      expect { string_board.do_move(1, {col: "10.1"}) }.to raise_error Board::InvalidMoveError
    end

    it 'raises an error if the move is not numeric' do
      expect { string_board.do_move(1, {col: "cat"}) }.to raise_error Board::InvalidMoveError
    end
  end

  context 'win checking' do
    context 'simple 4x4 board' do
      let(:string_board) { FactoryGirl.create(:string_board, rows: 4, columns: 4) }

      it 'returns false when no win-condition is present' do
        string_board.board = ["0000", "0000", "0000", "0000"]
        string_board.save!
        expect(string_board.win_detected?).to be_falsey
      end

      it 'returns true for a column-win condition' do
        string_board.board = ["0000", "1111", "0000", "0000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a row-win condition' do
        string_board.board = ["0001", "0001", "0001", "0001"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a forward diagonal win condition' do
        string_board.board = ["0001", "0010", "0100", "1000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a backward diagonal win condition' do
        string_board.board = ["1000", "0100", "0010", "0001"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end
    end

    context 'complex 9x11 board' do
      let(:string_board) { FactoryGirl.create(:string_board, rows: 9, columns: 11) }

      it 'returns false when no win-condition is present' do
        string_board.board = ["000000000","000000000","000000000","000000000",
          "000000000","000000000","000000000","000000000",
          "000000000","000000000","000000000"]
        string_board.save!
        expect(string_board.win_detected?).to be_falsey
      end

      it 'returns true for a column-win condition' do
        string_board.board = ["000000000","000000000","000001111","000000000",
          "000000000","000000000","000000000","000000000",
          "000000000","000000000","000000000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a row-win condition' do
        string_board.board = ["000000000","000000000","000000001","000000001",
          "000000001","000000001","000000000","000000000",
          "000000000","000000000","000000000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a forward diagonal win condition' do
        string_board.board = ["000000000","000000000","000000000","000000000",
          "000000001","000000010","000000100","000001000",
          "000000000","000000000","000000000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end

      it 'returns true for a backward diagonal win condition' do
        string_board.board = ["000000000","000000000","000000000","000000000",
          "000001000","000000100","000000010","000000001",
          "000000000","000000000","000000000"]
        string_board.save!
        expect(string_board.win_detected?).to be_truthy
      end
    end
  end
end
