class InternalApi::V1::HighstatesController < InternalApiController
  include Api

  before_action :filter_known_minions

  def update
    Minion.find_by(minion_id: event_data_params[:minion_id]).tap do |minion|
      minion.highstate = Minion.highstates[:failed] unless event_data_params[:success]
    end.save!
    ok
  end

  private

  def event_data_params
    params.require(:event_data).permit(:minion_id, :success)
  end

end
