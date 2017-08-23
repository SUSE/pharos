# frozen_string_literal: true

require "net/ldap/dn"
require "velum/ldap"

# User represents administrators in this application.
class User < ApplicationRecord
  enabled_devise_modules = [:ldap_authenticatable, :registerable,
                            :rememberable, :trackable, :validatable].freeze

  devise(*enabled_devise_modules)

  before_create :create_ldap_user

  protected

  def create_ldap_user
    # add to OpenLDAP - this should be disabled when using any other LDAP server!

    # Behavior:
    # 1) make sure the People org unit exists, if not, create it
    # 2) make sure the Administrators groupOfUniqueNames exists, if not, create it
    # 3) check if the new user created is a member of the Administrators group, if not, add it
    # 4) check if the user exists, if not, add it
    if new_record?
      # check to see if this is because the LDAP auth succeeded, or if we're coming from registration
      # we do this by performing an LDAP search for the new user. If it fails, we need to create the
      # user in LDAP
      ldap_config = YAML.load(ERB.new(File.read(::Devise.ldap_config || Rails.root.join("config", "ldap.yml"))).result)[Rails.env]

      conn_params = {
        :host => ldap_config["host"],
        :port => ldap_config["port"],
        :auth => {
          :method => :simple,
          :username => ldap_config["admin_user"],
          :password => ldap_config["admin_password"],
        }
      }

      Velum::LDAP::configure_ldap_tls!(ldap_config, conn_params)

      ldap = Net::LDAP.new **conn_params

      uid = email[0,email.index('@')]
      userDN = "uid=#{uid},#{ldap_config['base']}"

      # first, look for the People org unit
      treebase = ldap_config["base"]
      found = false
      ldap.search(:base => treebase, :scope => Net::LDAP::SearchScope_BaseObject) do |entry|
        found = true
      end

      if not found
        peopleDN = Net::LDAP::DN.new(treebase).to_a

        attrs = {
          :ou => peopleDN[1],
          :objectclass => ["top", "organizationalUnit"],
        }

        result = ldap.add(:dn => treebase, :attributes => attrs)
        Velum::LDAP::fail_if_with(result, "Unable to create People organizational unit in LDAP: #{ldap.get_operation_result.message}")
      end

      # next, look for the group base
      treebase = ldap_config["group_base"]
      groupFound = false
      ldap.search(:base => treebase, :scope => Net::LDAP::SearchScope_BaseObject) do |entry|
        groupFound = true
      end

      if not groupFound
        groupDN = Net::LDAP::DN.new(treebase).to_a

        attrs = {
          :ou => groupDN[1],
          :objectclass => ["top", "organizationalUnit"],
        }

        result = ldap.add(:dn => treebase, :attributes => attrs)
        Velum::LDAP::fail_if_with(result, "Unable to create Group organizational unit in LDAP: #{ldap.get_operation_result.message}")
      end

      # next, look for the Administrators group in the group base
      treebase = ldap_config["required_groups"][0]
      groupFound = false
      memberFound = false
      ldap.search(:base => treebase, :scope => Net::LDAP::SearchScope_BaseObject) do |entry|
        if (entry[:uniquemember].is_a?(Array) and entry[:uniquemember].include?(userDN)) or entry[:uniquemember].eql?(userDN)
          memberFound = true
        end
        groupFound = true
      end

      if not groupFound
        adminDN = Net::LDAP::DN.new(treebase).to_a

        attrs = {
          :cn => adminDN[1],
          :objectclass => ["top", "groupOfUniqueNames"],
          :uniqueMember => userDN,
        }

        result = ldap.add(:dn => treebase, :attributes => attrs)
        Velum::LDAP::fail_if_with(result, "Unable to create Administrators group of unique names in LDAP: #{ldap.get_operation_result.message}")
      elsif not memberFound
        # if the group already exists, make sure this user is in there
        ops = [
          [:add, :uniqueMember, userDN]
        ]
        result = ldap.modify(:dn => treebase, :operations => ops)
        Velum::LDAP::fail_if_with(result, "Unable to add user to Administrators group in LDAP: #{ldap.get_operation_result.message}")
      end

      filter = Net::LDAP::Filter.eq(ldap_config["attribute"], email)
      treebase = ldap_config["base"]
      found = false
      ldap.search(:base => treebase, :filter => filter) do |entry|
        found = true
      end

      if not found
        attrs = {
          :cn => "A User",
          :objectclass => ["person", "inetOrgPerson"],
          :uid => uid,
          :userPassword => password,
          :givenName => "A",
          :sn => "User",
          :mail => email,
        }

        result = ldap.add(:dn => "#{userDN}", :attributes => attrs)
        Velum::LDAP::fail_if_with(result, "Unable to create Person in LDAP: #{ldap.get_operation_result.message}")
      end
    end
  end
end
