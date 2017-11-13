class InternalApi::V1::PresencesController < InternalApiController

  def update
    render json: params
  end

end
