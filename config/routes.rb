# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :process_definitions, except: [:destroy], as: :bpm_integration_process_definitions
resources :process_instances, only: [:show], as: :bpm_integration_process_instances

match 'bpm_task_instances/sync', controller: 'bpm_task_instances', action: 'sync', via: 'get'
