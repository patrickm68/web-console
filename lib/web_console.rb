require 'web_console/error_page'
require 'web_console/middleware'
require 'active_support/lazy_load_hooks'
require 'web_console/repl'
require 'web_console/engine'
require 'web_console/colors'
require 'web_console/slave'

module WebConsole
  class << self
    attr_accessor :application_root
    attr_accessor :logger
  end

  # Shortcut the +WebConsole::Engine.config.web_console+.
  def self.config
    Engine.config.web_console
  end

  ActiveSupport.run_load_hooks(:web_console, self)
end

require "binding_of_caller"
require "web_console/exception_extension"
require 'web_console/rails' if defined? Rails::Railtie
