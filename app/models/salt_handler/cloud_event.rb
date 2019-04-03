require "velum/salt"

# This class is responsible to handle salt-cloud events.
class SaltHandler::CloudEvent
  attr_reader :salt_event

  def self.can_handle_event?(event)
    # Salt-cloud event format: salt/cloud/<VM ID>/<action>
    event.tag.include?("salt/cloud")
  end

  def initialize(salt_event)
    @salt_event = salt_event
  end

  # At the moment, we only handle 'destroyed' events, in which
  # case we trigger removal of the minion from the database.
  def process_event
    tag_elems = salt_event.tag.split("/")
    tag_id = tag_elems[2]
    tag_act = tag_elems[3]

    Minion.remove_minion(tag_id) if tag_act == "destroyed"
  end
end
