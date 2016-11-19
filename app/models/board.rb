class Board < ActiveRecord::Base

  belongs_to :game

  validates :rows,    numericality: { only_integer: true, greater_than: 0 }
  validates :columns, numericality: { only_integer: true, greater_than: 0 }

  before_save :initialize_board

  def initialize_board
    self.board = [].tap do |new_board|
      columns.times { new_board << ("0" * rows) }
    end
  end
end
