require "velum/salt"

# Discovery implements the discovery method that is shared both when
# bootstrapping and when showing the dashboard.
module Discovery
  extend ActiveSupport::Concern

  # Responds with either an HTML or JSON version of the available minions.
  def discovery
    @assigned_minions   = assigned_with_status
    @unassigned_minions = Minion.unassigned_role

    respond_to do |format|
      format.html
      format.json do
        render json: {
                 assigned_minions:   @assigned_minions,
                 unassigned_minions: @unassigned_minions,
                 admin:              admin_status
               }, methods: [:update_status]
      end
    end
  end

  protected

  # TODO (mssola):
  #  1. It would make more sense to have the update status on the DB and have
  #     another process polling for this. Then, on the `discovery` method this
  #     would all be returned transparently (thus removing all the methods below).
  #  2. NOTE: Other nodes should only be taken into consideration if
  #     automatic updates has not been enabled.

  def assigned_with_status
    needed, failed = update_status

    # NOTE: this is highly inefficient and will disappear if we implement the
    # idea written above.
    minions = Minion.assigned_role
    minions.each do |minion|
      minion.update_status = computed_status(minion.minion_id, needed, failed)
    end

    minions
  end

  def admin_status
    needed, failed = update_status
    { update_status: computed_status("admin", needed, failed) }
  end

  def computed_status(id, needed, failed)
    if failed.first && !failed.first[id].blank?
      Minion.statuses[:update_failed]
    elsif needed.first && !needed.first[id].blank?
      Minion.statuses[:update_needed]
    else
      Minion.statuses[:unknown]
    end
  end

  def update_status
    Rails.cache.fetch("update_status", expires_in: 30.seconds) do
      ::Velum::Salt.update_status(targets: "*")
    end
  end
end
