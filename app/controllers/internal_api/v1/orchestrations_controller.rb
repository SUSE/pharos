class InternalApi::V1::OrchestrationsController < InternalApiController

  before_action :interesting_orchestration?
  before_action :find_orchestration, only: :update

  def create
    orchestration = Orchestration.find_or_create_by(jid: event_data_params[:jid]) do |orch|
      orch.kind = case event_data_params[:orchestration]
                  when "orch.kubernetes"
                    Orchestration.kinds[:bootstrap]
                  when "orch.update"
                    Orchestration.kinds[:upgrade]
      end
    end
    orchestration.started_at = Time.zone.parse event_data_params[:_stamp]
    orchestration.save
    ok
  end

  def update
    @orchestration.tap do |orchestration|
      orchestration.status = if event_data_params[:success] && event_data_params[:retcode] == 0
        Orchestration.statuses[:succeeded]
      else
        Orchestration.statuses[:failed]
      end
      orchestration.finished_at = Time.zone.parse event_data_params[:_stamp]
    end.save
    ok
  end

  private

  def interesting_orchestration?
    ok unless orchestration_matches? "orch.kubernetes", "orch.update"
  end

  def find_orchestration
    @orchestration = Orchestration.find_by jid: params[:jid]
    ko status: 404 unless @orchestration
  end

  def event_data_params
    case action_name
    when "create"
      params.require(:event_data).permit(:jid, :orchestration, :_stamp)
    when "update"
      params.require(:event_data).permit(:orchestration, :retcode, :success, :_stamp)
    end
  end

  def orchestration_matches?(*orchestrations)
    orchestrations.include? event_data_params[:orchestration]
  end

end
