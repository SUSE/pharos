class RemoveJidsPillarsSaltEventsSaltReturns < ActiveRecord::Migration
  def change
    [:jids, :salt_events, :salt_returns].each do |table|
      drop_table table
    end
  end
end
