# frozen_string_literal: true

# ApplicationController is the superclass of all controllers.
class ApplicationController < ActionController::Base
  prepend_before_action :redirect_to_secure
  prepend_before_action :authenticate_user!
  prepend_before_action :redirect_to_setup
  protect_from_forgery with: :exception

  private

  def redirect_to_setup
    return true unless signed_in?
    redirect_to setup_path unless setup_done?
  end

  # setup means minions were assigned to roles
  # returns true if at least one minion has role != nil
  # return false otherwise
  def setup_done?
    !Minion.assigned_role.count.zero?
  end

  # TODO: (mssola) remove once we have a reverse-proxy setup in place.
  def redirect_to_secure
    self.class.force_ssl unless Rails.env.test?
    true
  end
end
