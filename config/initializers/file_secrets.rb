# frozen_string_literal: true
# Be sure to restart your server when you modify this file.
require "velum/file_config"
app_secrets = Velum::AppSecrets.new(ENV.fetch("VELUM_SECRETS_DIR"))
Rails.application.secrets.secret_key_base = app_secrets.generate_secret_key_base
