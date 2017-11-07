require "velum/salt"

# AdminUpdates is a concern that encapsulates shared methods related to updates
# of the admin node.
module AdminUpdates
  extend ActiveSupport::Concern

  # Returns true if the admin node has needed updates, or some older update has
  # failed, false otherwise.
  def admin_needs_update?
    needed, failed = ::Velum::Salt.update_status(targets: "*", cached: true)
    status = Minion.computed_status("admin", needed, failed)
    status == Minion.statuses[:update_needed] || status == Minion.statuses[:update_failed]
  end
end
