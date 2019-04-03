# This is a rails runner that will print the status of the database
# Possible outcomes:
#
#   * `LDAP_READY`: connection successfull
#   * `LDAP_FAIL`: cannot authenticate within ldap server
#   * `LDAP_DOWN`: cannot connect to the ldap server

def ldap_ready?
  ldap_config = Velum::LDAP.ldap_config
  ldap = Net::LDAP.new(ldap_config)

  if ldap.bind
    puts "LDAP_READY"
  else
    puts "LDAP_FAIL"
  end
rescue Errno::ECONNREFUSED, Net::LDAP::Error
  puts "LDAP_DOWN"
end

ldap_ready?
