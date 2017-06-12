# frozen_string_literal: true
require "rails_helper"

feature "Manage nodes updates feature" do
  let!(:user) { create(:user) }

  before do
    login_as user, scope: :user
    Minion.create!(minion_id: SecureRandom.hex, fqdn: "minion0.k8s.local", role: "master")
  end

  scenario "Admin node has no update available", js: true do
    setup_stubbed_update_status!(stubbed: [["admin" => ""], ["admin" => ""]])

    visit authenticated_root_path

    expect(page).not_to have_content("Update admin node")
  end

  context "Admin node has an update available" do
    before do
      setup_stubbed_update_status!(stubbed: [["admin" => true], ["admin" => ""]])

      visit authenticated_root_path
    end

    scenario "Admin node has an update available", js: true do
      expect(page).to have_content("Admin node is running outdated software")
    end

    # rubocop:disable RSpec/MultipleExpectations
    scenario "User clicks on admin 'Update admin node'", js: true do
      expect(page).not_to have_content("Reboot to update")

      # clicks on "Update admin node"
      find(".update-admin-btn").click

      expect(page).to have_content("The admin node needs to reboot "\
                                   "in order to apply the software update")
      expect(page).to have_content("Reboot to update")
    end
    # rubocop:enable RSpec/MultipleExpectations

    scenario "User clicks on 'Reboot to update'", js: true do
      allow(::Velum::Salt).to receive(:call)

      # clicks on "Update admin node"
      find(".update-admin-btn").click

      # clicks on "Reboot to update"
      find(".reboot-update-btn").click

      # rubocop:disable RSpec/MessageSpies
      expect(::Velum::Salt).to receive(:call)
      # rubocop:enable RSpec/MessageSpies
      expect(page).to have_content("Rebooting...")
    end
  end

  scenario "Admin node has an update available (failed to update)", js: true do
    setup_stubbed_update_status!(stubbed: [["admin" => ""], ["admin" => true]])

    visit authenticated_root_path

    expect(page).to have_content("Admin node is running outdated software (failed to update)")
  end
end
