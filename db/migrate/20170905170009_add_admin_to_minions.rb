class AddAdminToMinions < ActiveRecord::Migration
  def change
    require "velum/salt"
    admin_minion = Minion.find_or_create_by(minion_id: "admin") do |minion|
      minion.role = Minion.roles[:admin]
      minion.fqdn = Velum::Salt.minions["admin"]["fqdn"]
      minion.highstate = Minion.highstates[:not_applied]
    end
  end
end
