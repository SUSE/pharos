# frozen_string_literal: true

# ApplicationHelper contains all the view helpers.
module ApplicationHelper
  # Render the user profile picture depending on the gravatar configuration.
  def user_image_tag(owner)
    email = owner.nil? ? nil : owner.email
    gravatar_image_tag(email)
  end

  # Provide a mocked collection of nodes for ui testing purposes.
  def test_nodes
    [
      # rubocop:disable LineLength
      { id: 1,  name: "Gru",    ip: "192.168.15.20", network: "Europe",  master: true,  status: "installing", ram: "4 Gb",   cpu: "8",  model: "Galaxy Note S7"  },
      { id: 2,  name: "Kevin",  ip: "192.168.15.30", network: "Europe",  master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Galaxy Note S7"  },
      { id: 3,  name: "Kyle",   ip: "120.158.85.34", network: "America", master: false, status: "info",       ram: "16 Gb",  cpu: "8",  model: "Galaxy Note S7"  },
      { id: 4,  name: "Bob",    ip: "120.158.85.20", network: "America", master: false, status: "info",       ram: "16 Gb",  cpu: "8",  model: "Galaxy Note S7"  },
      { id: 5,  name: "Stuart", ip: "220.68.155.90", network: "Asia",    master: false, status: "warning",    ram: "16 Gb",  cpu: "8",  model: "Galaxy Note S7"  },
      { id: 6,  name: "Dave",   ip: "192.168.15.55", network: "Europe",  master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Raspberry pi 3"  },
      { id: 7,  name: "Steve",  ip: "192.168.15.20", network: "America", master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Raspberry pi 3"  },
      { id: 8,  name: "Donny",  ip: "192.168.15.20", network: "America", master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Raspberry pi 3"  },
      { id: 9,  name: "Ken",    ip: "220.68.155.93", network: "Asia",    master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Raspberry pi 3"  },
      { id: 10, name: "Mike",   ip: "220.68.155.94", network: "Asia",    master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Nokia 1100"      },
      { id: 11, name: "Paul",   ip: "220.68.155.96", network: "Asia",    master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Nokia 1100"      },
      { id: 12, name: "Larry",  ip: "220.68.155.97", network: "Asia",    master: false, status: "ready",      ram: "16 Gb",  cpu: "8",  model: "Nokia 1100"      }
      # rubocop:enable LineLength
    ]
  end
end
