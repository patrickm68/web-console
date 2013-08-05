require 'rails/version'
require 'active_support/lazy_load_hooks'
require 'web_console/engine'
require 'web_console/repl'

module WebConsole
  # Shortcut the +WebConsole::Engine.config.web_console+.
  def self.config
    Engine.config.web_console
  end

  ActiveSupport.run_load_hooks(:web_console, self)
end

if Rails::VERSION::MAJOR == 3
  # ActiveModel::Model is not defined in Rails 3. Use a backported version.
  require 'web_console/backport/active_model'
end
