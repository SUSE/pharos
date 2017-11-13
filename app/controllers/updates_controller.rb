require "velum/salt"

# UpdatesController handles all the interaction with the updates of all nodes.
class UpdatesController < ApplicationController
  before_action :admin_needs_update, only: :create

  # Reboot the admin node.
  def create
    ::Velum::Salt.call(
      action:  "cmd.run",
      targets: "admin",
      arg:     "systemctl reboot"
    )

    render json: { status: Minion.update_statuses[:rebooting] }
  end

  protected

  def admin_needs_update
    unless ["update_needed", "update_failed"].include? Minion.admin.first.try(:update_status)
      render json: { status: Minion.update_statuses[:up_to_date] }
    end
  end
end
