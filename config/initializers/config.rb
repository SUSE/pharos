default    = File.join(Rails.root, "config", "config.yml")
local      = ENV["VELUM_LOCAL_CONFIG_PATH"] || File.join(Rails.root, "config", "config-local.yml")
cfg        = Velum::Config.new(default, local)
APP_CONFIG = cfg.fetch
