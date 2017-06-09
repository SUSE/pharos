# frozen_string_literal: true

require "velum/salt"

# UpdatesController handles all the interaction with the updates of all nodes.
class UpdatesController < ApplicationController
  def update
    # TODO: can we target this to a specific minion?
    ::Velum::Salt.update

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end
end
