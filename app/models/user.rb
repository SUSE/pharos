# frozen_string_literal: true
# User represents administrators in this application.
class User < ApplicationRecord
  enabled_devise_modules = [:ldap_authenticatable, :registerable,
                            :rememberable, :trackable, :validatable].freeze

  devise(*enabled_devise_modules)
end
