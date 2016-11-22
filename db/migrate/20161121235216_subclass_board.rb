class SubclassBoard < ActiveRecord::Migration
  def up
    add_column :boards, :type, :string, null: false, default: 'Boards::StringBoard'
  end

  def down
    remove_column :boards, :type
  end
end
