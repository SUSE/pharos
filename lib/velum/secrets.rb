require 'securerandom'

module Velum
  # If there is a rails key base stored on disk, return the stored one.
  # Otherwise, create a new key base from cryptographic random pool and store it.
  def self.create_secret_key_base(pathname)
    key_base = nil
    if pathname.exist?
      content = IO.read(pathname)
      if content != ""
        key_base = content
      end
    end
    if key_base == nil
      key_base = SecureRandom.hex(64)
      IO.write(pathname, key_base)
    end
    key_base
  end
end