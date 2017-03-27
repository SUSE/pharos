# frozen_string_literal: true
require "rails_helper"

feature "Monitoring feature" do
  let!(:user) { create(:user) }

  before do
    login_as user, scope: :user
    Minion.create!(hostname: "minion0.k8s.local", role: "master")
    visit authenticated_root_path
  end

  scenario "It works if there are no minions", js: true do
    Minion.destroy_all
    visit authenticated_root_path

    using_wait_time 10 do
      expect(page).not_to have_content("minion0.k8s.local")
    end
  end

  scenario "It updates the status of the minions automatically", js: true do
    # We poll every 5 seconds so the default Capybara wait time might not be enough
    using_wait_time 10 do
      expect(page).to have_selector(".nodes-container tbody tr i.fa.fa-circle-o")
      Minion.first.update!(highstate: "pending")
      expect(page).to have_selector(".nodes-container tbody tr i.fa.fa-refresh")
    end
  end

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations:
  scenario "It shows a message about new minions", js: true do
    using_wait_time 10 do
      expect(page).not_to have_content("minion1.k8s.local")
      expect(page).not_to have_content(
        "nodes are available but have not been added to the cluster yet"
      )
      Minion.create!(hostname: "minion1.k8s.local", role: nil)
      expect(page).to have_content(
        "1 new nodes are available but have not been added to the cluster yet"
      )
      expect(page).not_to have_content("minion1.k8s.local")
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleExpectations:
end
