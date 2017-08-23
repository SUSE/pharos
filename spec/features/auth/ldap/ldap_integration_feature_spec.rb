# frozen_string_literal: true
require "rails_helper"

require "velum/ldap"

# Tests out that the LDAP integration works as expected.

feature "LDAP Integration feature" do
  let(:user) { build(:user) }

  before do
    # open LDAP connection
    ldap_config = YAML.load(ERB.new(File.read(::Devise.ldap_config || Rails.root.join("config", "ldap.yml"))).result)[Rails.env]

    conn_params = {
      :host => ldap_config["host"],
      :port => ldap_config["port"],
      :auth => {
        :method => :simple,
        :username => ldap_config["admin_user"],
        :password => ldap_config["admin_password"],
      },
    }

    if ldap_config.has_key?("ssl")
      conn_params[:auth].merge!(
        :encryption => :ldap_config["ssl"].to_sym,
      )
    end

    @people_base = ldap_config["base"]
    @group_base = ldap_config["group_base"]
    @admin_group = ldap_config["required_groups"][0]

    @ldap = Net::LDAP.new **conn_params

    # clear out LDAP
    # dependencies are hard here, and there's no such thing as a depth first search,
    # and sort order isn't guaranteed, so we run this a few times until we don't get
    # any error code 66 messages, guaranteeing that we've cleared the tree
    last_error = nil
    count = 0

    begin
      last_error = nil
      count = count + 1
      [@admin_group, @group_base, @people_base].each do |base|
        @ldap.search(:base => base) do |entry|
          result = @ldap.delete(:dn => entry.dn)

          # 66 = Not Allowed On Non-Leaf, which means this entry has children
          op_result = @ldap.get_operation_result
          if not result and op_result.code == 66
            last_error = op_result
          end
        end
      end

      if count > 20
        # this is just to avoid an infinite loop. It really shouldn't happpen,
        # but if it does, you won't be scratching your head on why there is no
        # test output
        raise "after 20 tries, LDAP is not empty, failing"
      end
    end while not last_error.nil?
  end

  scenario "TLS is configured properly when needed" do
    # open LDAP connection
    ldap_config = YAML.load(ERB.new(File.read(::Devise.ldap_config || Rails.root.join("config", "ldap.yml"))).result)[Rails.env]

    ldap_config["ssl"] = "start_tls"

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

    expect(conn_params[:auth][:encryption]).to be(:start_tls)
  end

  scenario "People org unit does not exist" do
    self.create_account

    expect(@ldap.search(:base => @people_base, :return_result => false, :scope => Net::LDAP::SearchScope_BaseObject)).to be(true)
  end

  scenario "Administrators groupOfUniqueNames does not exist" do
    self.create_account

    expect(@ldap.search(:base => @admin_group, :return_result => false, :scope => Net::LDAP::SearchScope_BaseObject)).to be(true)
  end

  scenario "User is already a member of Administrators group" do
    # create the group OU
    groupDN = Net::LDAP::DN.new(@group_base).to_a

    attrs = {
      :ou => groupDN[1],
      :objectclass => ["top", "organizationalUnit"],
    }

    expect(@ldap.add(:dn => @group_base, :attributes => attrs)).to be(true)

    # create the admin group, adding the user
    adminDN = Net::LDAP::DN.new(@admin_group).to_a

    uid = user.email[0,user.email.index('@')]
    userDN = "uid=#{uid},#{@people_base}"

    attrs = {
      :cn => adminDN[1],
      :objectclass => ["top", "groupOfUniqueNames"],
      :uniqueMember => userDN,
    }

    expect(@ldap.add(:dn => @admin_group, :attributes => attrs)).to be(true)

    self.create_account

    expect(@ldap.search(:base => @admin_group, :return_result => false, :scope => Net::LDAP::SearchScope_BaseObject)).to be(true)
  end

  scenario "User is not already a member of Administrators group" do
    # create the group OU
    groupDN = Net::LDAP::DN.new(@group_base).to_a

    attrs = {
      :ou => groupDN[1],
      :objectclass => ["top", "organizationalUnit"],
    }

    expect(@ldap.add(:dn => @group_base, :attributes => attrs)).to be(true)

    # create the admin group, adding the user
    adminDN = Net::LDAP::DN.new(@admin_group).to_a

    uid = user.email[0,user.email.index('@')]
    userDN = "uid=#{uid},#{@people_base}"

    attrs = {
      :cn => adminDN[1],
      :objectclass => ["top", "groupOfUniqueNames"],
      :uniqueMember => "uid=foo,#{@people_base}",
    }

    expect(@ldap.add(:dn => @admin_group, :attributes => attrs)).to be(true)

    self.create_account

    filter = Net::LDAP::Filter.eq("uniqueMember", userDN)
    expect(@ldap.search(:base => @admin_group, :filter => filter, :return_result => false, :scope => Net::LDAP::SearchScope_BaseObject)).to be(true)
  end

  scenario "User already exists" do
    peopleDN = Net::LDAP::DN.new(@people_base).to_a

    attrs = {
      :ou => peopleDN[1],
      :objectclass => ["top", "organizationalUnit"],
    }

    expect(@ldap.add(:dn => @people_base, :attributes => attrs)).to be(true)

    # create the group OU
    groupDN = Net::LDAP::DN.new(@group_base).to_a

    attrs = {
      :ou => groupDN[1],
      :objectclass => ["top", "organizationalUnit"],
    }

    expect(@ldap.add(:dn => @group_base, :attributes => attrs)).to be(true)

    # create the admin group, adding the user
    adminDN = Net::LDAP::DN.new(@admin_group).to_a

    uid = user.email[0,user.email.index('@')]
    userDN = "uid=#{uid},#{@people_base}"

    attrs = {
      :cn => adminDN[1],
      :objectclass => ["top", "groupOfUniqueNames"],
      :uniqueMember => "uid=foo,#{@people_base}",
    }

    expect(@ldap.add(:dn => @admin_group, :attributes => attrs)).to be(true)

    attrs = {
      :cn => "A User",
      :objectclass => ["person", "inetOrgPerson"],
      :uid => uid,
      :userPassword => user.password,
      :givenName => "A",
      :sn => "User",
      :mail => user.email,
    }

    expect(@ldap.add(:dn => "#{userDN}", :attributes => attrs)).to be(true)

    self.create_account
  end

  scenario "Fail_if_with tests failure case" do
    expect {
      Velum::LDAP::fail_if_with(false, "Foobar")
    }.to raise_error(RuntimeError)
  end

  scenario "LDAP Failure causes 500" do
    allow_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_raise(DeviseLdapAuthenticatable::LdapException.new("expected"))

    visit setup_path

    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    click_button("Log in")

    expect(page.status_code).to eq(500)
  end

  def create_account
    visit new_user_session_path
    click_link("Create an account")
    expect(page).to have_current_path(new_user_registration_path)

    # successful account creation
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    fill_in "user_password_confirmation", with: user.password
    click_button("Create Admin")
    expect(page).to have_content("You have signed up successfully")
    click_link("Logout")
  end
end