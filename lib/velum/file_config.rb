# frozen_string_literal: true
require "json"
require "fileutils"
require "securerandom"

module Velum
  # Handle IO operations and data serialisation for configuration files under a specific directory.
  class FileConfig
    def initialize(base_dir)
      @base_dir = base_dir
    end

    # Return true only if the specified file name exists in the configuration base directory.
    def exist?(file_name)
      File.exist?(File.join(@base_dir, file_name))
    end

    # Deserialise JSON text from the specified file into a hash structure and return.
    def read_hash(file_name)
      JSON.parse(IO.read(File.join(@base_dir, file_name)))
    end

    # Serialise the hash structure into JSON text and overwrite the specified file with it.
    def write_hash(file_name, hash)
      FileUtils.mkdir_p(@base_dir)
      IO.write(File.join(@base_dir, file_name), JSON.dump(hash))
    end
  end

  # Manage persistent application-wide secret data.
  class AppSecrets
    def initialize(base_dir)
      @files = FileConfig.new(base_dir)
    end

    # Generate a new random "secret_key_base" value and return.
    def new_secret_key_base
      SecureRandom.hex(64)
    end

    # Return persisted "secret_key_base", or save a new one if persistent value does not exist.
    def generate_secret_key_base
      name = "app_secrets.json"
      return @files.read_hash(name)["base"] if @files.exist?(name)
      new_base = new_secret_key_base
      @files.write_hash(name, "base" => new_base)
      new_base
    end
  end
end
