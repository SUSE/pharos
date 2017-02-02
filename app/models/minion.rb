# frozen_string_literal: true

require "pharos/salt_minion"

# Minion represents the minions that have been registered in this application.
class Minion < ApplicationRecord
  class NotEnoughMinions < StandardError; end
  class CouldNotAssignRole < StandardError; end

  enum role: [:master, :minion]

  validates :hostname, uniqueness: true

  # This method is used to assign the specified roles to Minions which do not
  # have a roles already assigned (available minions).
  # roles param are the roles we absolutely have to assign. If we can't assign
  # one of those, the method will raise.
  # default_role param can be set if we want all the rest of the available
  # minions to get a default role.
  def self.assign_roles(roles: [], default_role: nil)
    minions = Minion.where(role: nil)

    # only the needed number of minions or all if we have a default role
    minions = minions.limit(roles.size) unless default_role

    raise NotEnoughMinions if minions.count < roles.size

    minions.find_each do |minion|
      unless minion.assign_role(roles.pop || default_role)
        raise CouldNotAssignRole
      end
    end
  end

  # rubocop:disable SkipsModelValidations
  # Assigns a role to this minion locally in the database, and send that role
  # to salt subsystem.
  def assign_role(new_role)
    return false if role.present?

    Minion.transaction do
      update_column :role, new_role
      salt.assign_role new_role
    end
    true
  rescue Pharos::SaltApi::SaltConnectionException
    false
  end
  # rubocop:enable SkipsModelValidations

  # Returns the proxy for the salt minion
  def salt
    @salt ||= Pharos::SaltMinion.new minion_id: hostname
  end
end
