require "velum/salt"

# SaltController holds methods for triggering updates of nodes
class SaltController < ApplicationController
  include AdminUpdates

  before_action :admin_needs_update_hook, only: :update
  skip_before_action :redirect_to_setup

  def update
    Minion.mark_pending_update
    Velum::Salt.update_orchestration

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def accept_minion
    Velum::Salt.accept_minion(minion_id: minion_id_param)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def minion_id_param
    params.require(:minion_id)
  end

  protected

  # It does nothing if the admin node does *not* need to be updated. Otherwise
  # it will render a JSON with an `unknown` minion status.
  def admin_needs_update_hook
    return unless admin_needs_update?
    render json: { status: Minion.statuses[:unknown] }
  end
end
