
class BpmIntegration::ProcessDefinition < BpmIntegrationBaseModel

  belongs_to :tracker_process_definition
  accepts_nested_attributes_for :tracker_process_definition

  has_many :task_definitions
  has_many :form_fields, class_name: 'BpmIntegration::FormField', as: :form_able

  has_many :form_field_definitions, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :form_field_definitions

  scope :latest, -> {joins('join ' +
                            '(select pd.key as p_key, max(pd.version) as max_version ' +
                              'from bpmint_process_definitions pd group by pd.key) as tmp ' +
                               'on bpmint_process_definitions.key = tmp.p_key ' +
                               'and bpmint_process_definitions.version = tmp.max_version')}

end
