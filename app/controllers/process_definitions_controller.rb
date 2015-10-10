class ProcessDefinitionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def index
    SyncProcessDefinitionsJob.perform_now
    @process_definitions = BpmIntegration::ProcessDefinition.latest
  end

  def edit
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])

    # Não entendi porque essa key fica no tracker_process_definition, se a relação é N-1
    @process_definition.tracker_process_definition = BpmIntegration::TrackerProcessDefinition.new(process_definition_key: @process_definition.key) unless @process_definition.tracker_process_definition
  end

  def update
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    @process_definition.update_attributes!(safe_params)

    flash[:notice] = t(:notice_successful_update)
    redirect_to action: :index
  end

  def create
    begin
      process_data = params[:bpm_integration_process_definition][:upload].tempfile
      response = BpmProcessDefinitionService.deploy_process(process_data)
      if !response.blank? && response.code == 201
        SyncProcessDefinitionsJob.perform_now
        handle_sucess('msg_process_uploaded')
      else
        handle_error('msg_process_upload_error')
      end
    rescue => error
      handle_error('msg_process_upload_error', error)
    end
  end

  def show
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    process_image = BpmProcessDefinitionService.process_image @process_definition.process_identifier
    send_data process_image, :type => 'image/png',:disposition => 'inline'
  end

  private

  def safe_params
    params.require(:bpm_integration_process_definition).permit(tracker_process_definition_attributes: [:tracker_id, :process_definition_key], form_field_definitions_attributes: [:custom_field_id, :id])
  end
end
