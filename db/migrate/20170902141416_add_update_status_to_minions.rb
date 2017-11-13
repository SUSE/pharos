class AddUpdateStatusToMinions < ActiveRecord::Migration
  def change
    add_column :minions, :update_status, :integer, index: true, default: 0, after: :highstate
  end
end
