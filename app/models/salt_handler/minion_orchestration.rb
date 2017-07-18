# frozen_string_literal: true

# This class is responsible to handle the salt events that are orchestration results.
# Only the bootstrap and update orchestrations will be handled by this class.
class SaltHandler::MinionOrchestration
  attr_reader :salt_event

  TAG_MATCHER = %r{salt/run/\d+/ret}

  def self.can_handle_event?(event)
    return false unless event.tag =~ TAG_MATCHER
    parsed_event_data = JSON.parse event.data
    parsed_event_data["fun"] == "runner.state.orchestrate" &&
      salt_fun_args_match(parsed_event_data, "orch.kubernetes", "orch.update")
  end

  # Returns true if the orchestration event matches any orchestration given in orchestrations.
  def self.salt_fun_args_match(parsed_event_data, *orchestrations)
    fun_args = parsed_event_data["fun_args"]
    orchestrations.any? { |o| fun_args.first == o || fun_args.first["mods"] == o }
  end

  def initialize(salt_event)
    @salt_event = salt_event
  end

  # This method is responsible for all actions needed when the bootstrap/update orchestration
  # has failed. We mark all pending minions as failed if the orchestration failed. If it
  # succeeded, we do nothing, as they will be marked as success by their own highstates events.
  def process_event
    data = JSON.parse salt_event.data

    orchestration_succeeded = data["success"] && data["return"]["retcode"].zero?
    return if orchestration_succeeded

    # rubocop:disable SkipsModelValidations
    Minion.pending.update_all highstate: Minion.highstates[:failed]
    # rubocop:enable SkipsModelValidations
  end
end
