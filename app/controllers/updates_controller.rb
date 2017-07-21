# frozen_string_literal: true

require "velum/salt"

# UpdatesController handles all the interaction with the updates of all nodes.
class UpdatesController < ApplicationController
  include AdminUpdates

  before_action :admin_needs_update_hook, only: :create

  # Reboot the admin node.
  def create
    ::Velum::Salt.call(
      action:  "cmd.run",
      targets: "admin",
      arg:     "systemctl reboot"
    )

    render json: { status: Minion.statuses[:rebooting] }
  end

  protected

  # It does nothing if the admin node needs an updated. Otherwise it will render
  # a JSON with an `unknown` minion status.
  def admin_needs_update_hook
    return if admin_needs_update?
    render json: { status: Minion.statuses[:unknown] }
  end
end
