class AddComputerFlagToPlayer < ActiveRecord::Migration
  def up
    add_column :players, :computer, :boolean, default: false
  end

  def down
    remove_column :players, :computer
  end
end
