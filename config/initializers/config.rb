require 'ostruct'

config_file = "/etc/mmmmblog.yml"
if !File.exist?(config_file)
  config_file = RAILS_ROOT+"/config/mmmblog.yml"
end

if !File.exist?(config_file)
  raise StandardError,  "Config file was not found"
end

options = YAML.load_file(config_file)
if !options[RAILS_ENV]
  raise "'#{RAILS_ENV}' was not found in #{config_file}"
end

AppConfig = OpenStruct.new(options[RAILS_ENV])

REST_AUTH_SITE_KEY         = AppConfig.rest_auth_key
REST_AUTH_DIGEST_STRETCHES = AppConfig.rest_aut_digest_stretches

ActionController::Base.session_options[:domain] = ".#{AppConfig.domain}"
ActionController::Base.session_options[:key] = AppConfig.session_key
ActionController::Base.session_options[:secret] = AppConfig.session_secret
