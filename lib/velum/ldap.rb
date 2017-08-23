module Velum
  class LDAP
    class << self
      def configure_ldap_tls!(ldap_config, conn_params)
        if ldap_config.has_key?("ssl")
          conn_params[:auth].merge!(
            :encryption => ldap_config["ssl"].to_sym,
          )
        end
      end

      def fail_if_with(result, message)
        if not result
          raise message
        end
      end
    end
  end
end