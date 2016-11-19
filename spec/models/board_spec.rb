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
end
