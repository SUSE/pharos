require "velum/salt"

class InternalApi::V1::MinionsController < InternalApiController
  include Api

  before_action :filter_known_minions

  def create
    Minion.find_by(minion_id: event_data_params[:minion_id]).tap do |minion|
      if event_data_params[:minion_id] == "admin"
        minion.role = Minion.roles[:admin]
      end
      minion.fqdn = Velum::Salt.minions[event_data_params[:minion_id]]["fqdn"]
      minion.highstate = Minion.highstates[:not_applied]
    end.save!
    ok
  rescue ActiveRecord::RecordInvalid
    ko
  end

  private

  def event_data_params
    params.require(:event_data).permit(:minion_id)
  end

end
