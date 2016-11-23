class RemoveDefaultArrayFromBoards < ActiveRecord::Migration
  def up
    change_column_default :boards, :board, nil
  end

  def down
    change_column_default :boards, :board, []
  end
end
