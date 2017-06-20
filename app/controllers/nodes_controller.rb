# frozen_string_literal: true

# NodesController holds methods for managing nodes in the cluster.
class NodesController < ApplicationController
  # Remove a node from the cluster in a way that it can be re-added afterwards
  # if needed.
  def destroy
    node = Minion.find(params[:id])
    # TODO: remove from salt-master, salt-key and possibly other stuff
    node.destroy
    head status: 200
  end
end
