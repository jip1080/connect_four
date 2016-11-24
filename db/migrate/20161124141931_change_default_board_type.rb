class ChangeDefaultBoardType < ActiveRecord::Migration
  def change
    change_column_default :boards, :type, 'Boards::BitBoard'
  end
end
