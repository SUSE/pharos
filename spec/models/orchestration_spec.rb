# frozen_string_literal: true
require "rails_helper"

describe Orchestration do

  let(:orchestration) { FactoryGirl.create :orchestration }
  let(:upgrade_orchestration) { FactoryGirl.create :upgrade_orchestration }

  context "run a bootstrap orchestration" do
    before do
      allow(Velum::Salt).to receive(:orchestrate) do
        [nil, { "return" => [{ "jid" => "20170706104527757674" }] }]
      end
    end

    it "spawns a new bootstrap orchestration" do
      expect { described_class.run kind: :bootstrap }.to change { described_class.bootstrap.count }
      expect(Velum::Salt).to have_received(:orchestrate).once
    end
  end

  context "run an upgrade orchestration" do
    before do
      allow(Velum::Salt).to receive(:update_orchestration) do
        [nil, { "return" => [{ "jid" => "20170706104527757674" }] }]
      end
    end

    it "spawns a new bootstrap orchestration" do
      expect { described_class.run kind: :upgrade }.to change { described_class.upgrade.count }
      expect(Velum::Salt).to have_received(:update_orchestration).once
    end
  end

  context "when asking for the proxy" do
    it "returns the expected proxy" do
      expect(orchestration.salt).to be_a(Velum::SaltOrchestration)
    end
  end

  context "is bootstrap orchestration retryable" do
    context "when the last orchestration was successful" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:bootstrap],
                           status: described_class.statuses[:succeeded]
      end

      it "is not retryable" do
        expect(described_class.retryable?(kind: :bootstrap)).to be_falsey
      end
    end

    context "when there is an orchestration ongoing" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:bootstrap],
                           status: described_class.statuses[:in_progress]
      end

      it "is not retryable" do
        expect(described_class.retryable?(kind: :bootstrap)).to be_falsey
      end
    end

    context "when the last orchestration was a failure" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:bootstrap],
                           status: described_class.statuses[:failed]
      end

      it "is retryable" do
        expect(described_class.retryable?(kind: :bootstrap)).to be_truthy
      end
    end
  end

  context "is upgrade orchestration retryable" do
    context "when the last orchestration was successful" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:upgrade],
                           status: described_class.statuses[:succeeded]
      end

      it "is not retryable" do
        expect(described_class.retryable?(kind: :upgrade)).to be_falsey
      end
    end

    context "when there is an orchestration ongoing" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:upgrade],
                           status: described_class.statuses[:in_progress]
      end

      it "is not retryable" do
        expect(described_class.retryable?(kind: :upgrade)).to be_falsey
      end
    end

    context "when the last orchestration was a failure" do
      before do
        FactoryGirl.create :orchestration,
                           kind:   described_class.kinds[:upgrade],
                           status: described_class.statuses[:failed]
      end

      it "is retryable" do
        expect(described_class.retryable?(kind: :upgrade)).to be_truthy
      end
    end
  end
end
