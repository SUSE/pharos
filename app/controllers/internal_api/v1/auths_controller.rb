class InternalApi::V1::AuthsController < InternalApiController
  include Api

  before_action :filter_known_minions

  def create
    render json: Minion.find_or_create_by!(minion_id: event_data_params[:minion_id]), status: 201
  rescue ActiveRecord::RecordInvalid
    ko
  end

  private

  def event_data_params
    params.require(:event_data).permit(:minion_id)
  end

end
