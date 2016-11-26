class AddAiTypeColumnToPlayer < ActiveRecord::Migration
  def up
    add_column :players, :ai_type, :string
  end

  def down
    remove_column :players, :ai_type
  end
end
