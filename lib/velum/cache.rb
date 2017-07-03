module Velum
  # This class has cache utilities that can be used for the whole project
  class Cache
    def self.fetch(key:, use_cache: true, expires_in:, &blk)
      if use_cache
        Rails.cache.fetch(key, expires_in: expires_in) do
          blk.call
        end
      else
        blk.call
      end
    end
  end
end
