require 'ipaddr'
require 'rails/engine'

require 'active_model'
require 'sprockets/rails'

module WebConsole
  class Engine < ::Rails::Engine
    config.web_console = ActiveSupport::OrderedOptions.new
    config.web_console.whitelisted_ips = %w( 127.0.0.1 ::1 )

    initializer 'web_console.initialize' do
      ActionDispatch::DebugExceptions.class_eval do
        def render_exception_with_web_console(env, exception)
          render_exception_without_web_console(env, exception).tap do
            wrapper = ActionDispatch::ExceptionWrapper.new(env, exception)

            # Get the original exception if ExceptionWrapper decides to follow it.
            env['web_console.exception'] = wrapper.exception
          end
        end

        alias_method_chain :render_exception, :web_console
      end

      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers.send(:include, Helper)
      end

      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Helper)
      end
    end

    initializer 'web_console.insert_middleware' do |app|
      app.middleware.insert_before ActionDispatch::DebugExceptions, Middleware
    end

    initializer 'web_console.process_whitelisted_ips' do
      config.web_console.tap do |c|
        # Ensure that it is an array of IPAddr instances and it is defaulted to
        # 127.0.0.1 if not precent. Only unique entries are left in the end.
        c.whitelisted_ips = Array(c.whitelisted_ips).map { |ip|
          if ip.is_a?(IPAddr)
            ip
          else
            IPAddr.new(ip.presence || '127.0.0.1')
          end
        }.uniq

        # IPAddr instances can cover whole networks, so simplify the #include?
        # check for the most common case.
        def (c.whitelisted_ips).include?(ip)
          if ip.is_a?(IPAddr)
            super
          else
            any? { |net| net.include?(ip.to_s) }
          end
        end
      end
    end
  end
end
