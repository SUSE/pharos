# frozen_string_literal: true
require "rails_helper"

describe "nodes/index" do
  before do
    render
  end

  context "regular render" do
    it "has the url on the data-url attribute" do
      section = assert_select("#nodes")
      attribute = JSON.parse(section.attribute("data-plugin").value).first["options"]["nodesUrl"]
      expect(attribute).to eq nodes_path
    end

    it "has a button to bootstrap the cluster" do
      section = assert_select("#bootstrap-cluster")
      l = link?(section[0], bootstrap_nodes_path, "Bootstrap cluster")
      expect(l).to be_truthy
    end

    it "polls for minions" do
      section = assert_select("#nodes")
      attribute = JSON.parse(section.attribute("data-plugin").value).first["name"]
      expect(attribute).to eq "velumMinionPoller"
    end

  end
end
