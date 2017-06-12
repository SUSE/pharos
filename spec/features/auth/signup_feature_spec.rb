# frozen_string_literal: true
require "rails_helper"

feature "Signup feature" do
  before do
    visit new_user_registration_path
  end

  let(:user) { build(:user) }

  scenario "I am able to signup from login page" do
    visit new_user_session_path
    click_link("Create an account")
    expect(current_path).to eq new_user_registration_path
  end

  scenario "I am able to go back to the login page" do
    user.save
    visit new_user_registration_path

    find("#sign-in").click
    expect(current_path).to eq new_user_session_path
  end

  scenario "I am able to signup" do
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    fill_in "user_password_confirmation", with: user.password
    click_button("Create Admin")

    expect(page).to have_content("You have signed up successfully")
  end

  scenario "It reports a wrong email format", js: true do
    fill_in "user_email", with: "gibberish@asdasd"

    expect(page).to have_content("Warning: it's preferred to \
      use an email address in the format \"user@example.com\"")
  end

  scenario "It reports password and password confirmation not matching" do
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "12341234"
    fill_in "user_password_confirmation", with: "532"
    click_button("Create Admin")

    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
