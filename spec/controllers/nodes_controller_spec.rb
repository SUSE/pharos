# frozen_string_literal: true
require "rails_helper"

RSpec.describe NodesController, type: :controller do
  describe "DELETE /nodes/:id" do
    let!(:user)   { create(:user)          }
    let!(:master) { create(:master_minion) }
    let!(:minion) { create(:worker_minion) }

    before do
      sign_in user
    end

    it "deletes the given minion from the DB" do
      expect do
        delete :destroy, id: minion.id
      end.to change(Minion, :count).by(-1)
    end

    it "returns a 404 if we are passing a wrong minion" do
      expect do
        delete :destroy, id: minion.id + 1
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
