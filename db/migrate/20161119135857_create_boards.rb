class CreateBoards < ActiveRecord::Migration
  def up
    create_table :boards do |t|
      t.integer :rows, null: false
      t.integer :columns, null: false
      t.string  :board, array: true, default: []
      t.timestamps null: false
    end
  end

  def down
    drop_table :boards
  end
end
