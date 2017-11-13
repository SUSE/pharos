require "velum/salt"

# Discovery implements the discovery method that is shared both when
# bootstrapping and when showing the dashboard.
module Discovery
  extend ActiveSupport::Concern

  # Responds with either an HTML or JSON version of the available minions.
  def discovery
    assigned_minions                  = Minion.cluster_role
    unassigned_minions                = Minion.accepted.unassigned_role
    pending_minions                   = Minion.not_accepted
    admin_status                      = Minion.admin.first.try :update_status
    retryable_bootstrap_orchestration = Orchestration.retryable?

    respond_to do |format|
      format.html
      format.json do
        hsh = {
          assigned_minions:                  assigned_minions,
          unassigned_minions:                unassigned_minions,
          pending_minions:                   pending_minions,
          admin:                             { update_status: admin_status },
          retryable_bootstrap_orchestration: retryable_bootstrap_orchestration
        }
        render json: hsh, methods: [:update_status]
      end
    end
  end
end
