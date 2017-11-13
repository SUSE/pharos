require "velum/salt"
require "velum/salt_orchestration"

# Orchestration represents a salt orchestration event
class Orchestration < ApplicationRecord
  class OrchestrationAlreadyRan < StandardError; end

  enum kind: [:bootstrap, :upgrade]
  enum status: [:in_progress, :succeeded, :failed]

  after_create :set_pending_minions
  after_save :set_finished_minions

  # rubocop:disable Rails/SkipsModelValidations
  def run
    raise OrchestrationAlreadyRan if jid.present?
    update_column :status, Orchestration.statuses[:in_progress]
    _, job = case kind
             when "bootstrap"
               Velum::Salt.orchestrate
             when "upgrade"
               Velum::Salt.update_orchestration
    end
    update_column :jid, job["return"].first["jid"]
    true
  end
  # rubocop:enable Rails/SkipsModelValidations

  def self.run(kind: :bootstrap)
    Orchestration.create!(kind: kind).tap(&:run)
  end

  def self.retryable?(kind: :bootstrap)
    case kind
    when :bootstrap
      Orchestration.bootstrap.last.try(:status) == "failed"
    when :upgrade
      Orchestration.upgrade.last.try(:status) == "failed"
    end
  end

  # Returns the proxy for the salt orchestration
  def salt
    @salt ||= Velum::SaltOrchestration.new orchestration: self
  end

  private

  def set_pending_minions
    case kind
    when "bootstrap"
      Minion.mark_pending_bootstrap
    when "upgrade"
      Minion.mark_pending_update
    end
  end

  def set_finished_minions
    if status_changed? && status_was == "in_progress"
      # rubocop:disable SkipsModelValidations
      case status
      when "succeeded"
        Minion.pending.update_all highstate: Minion.highstates[:applied]
      when "failed"
        Minion.pending.update_all highstate: Minion.highstates[:failed]
      end
      # rubocop:enable SkipsModelValidations
    end
  end
end
