require "velum/salt"

namespace :salt do
  desc "Consolidate salt events"
  task consolidate: :environment do
    Velum::Salt.consolidate
  end
end
