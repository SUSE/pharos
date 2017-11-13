class MigrateHighstateValueOnMinions < ActiveRecord::Migration
  def up
    Minion.update_all('highstate = highstate + 1')
  end
  def down
    Minion.update_all('highstate = highstate - 1')
  end
end
