module WebConsole
  class Middleware
    TEMPLATES_PATH = File.expand_path('../templates', __FILE__)

    DEFAULT_OPTIONS = {
      update_re: %r{/repl_sessions/(?<id>.+?)\z},
      binding_change_re: %r{/repl_sessions/(?<id>.+?)/trace\z}
    }

    def initialize(app, options = {})
      @app     = app
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def call(env)
      request = Request.new(env)
      return @app.call(env) unless request.from_whitelited_ip?

      if id = id_for_repl_session_update(request)
        return update_repl_session(id, request.params)
      elsif id = id_for_repl_session_stack_frame_change(request)
        return change_stack_trace(id, request.params)
      end

      status, headers, body = @app.call(env)
      response = Rack::Response.new(body, status, headers)

      if binding = env['web_console.binding']
        session = REPLSession.create(binding: binding)
      elsif exception = env['web_console.exception']
        session = REPLSession.create(binding: exception.bindings.first, binding_stack: exception.bindings)
      end

      if session && request.acceptable_content_type?
        template = ActionView::Base.new(TEMPLATES_PATH, session: session)
        response.write(template.render(template: 'session', layout: false))
      end

      response.finish
    end

    private

      class Request < ActionDispatch::Request
        # For a request to hit Web Console features, it needs to come from a
        # white listed IP and to be XMLHttpRequest.
        def from_whitelited_ip?
          WebConsole.config.whitelisted_ips.include?(remote_ip)
        end

        # An acceptable content type for Web Console is HTML only.
        # If a client didn't specified it, we'll assume its HTML.
        def acceptable_content_type?
          content_type.blank? || Mime::HTML == content_type
        end
      end

      def update_re
        @options[:update_re]
      end

      def binding_change_re
        @options[:binding_change_re]
      end

      def id_for_repl_session_update(request)
        if request.xhr? && request.put?
          update_re.match(request.path_info) { |m| m[:id] }
        end
      end

      def id_for_repl_session_stack_frame_change(request)
        if request.xhr? && request.post?
          binding_change_re.match(request.path_info) { |m| m[:id] }
        end
      end

      def update_repl_session(id, params)
        session = REPLSession.find(id)

        status  = 200
        headers = { 'Content-Type' => 'application/json; charset = utf-8' }
        body    = session.save(input: params[:input]).to_json

        Rack::Response.new(body, status, headers).finish
      end

      def change_stack_trace(id, params)
        session = REPLSession.find(id)
        session.binding = session.binding_stack[params[:frame_id].to_i]

        status  = 200
        headers = { 'Content-Type' => 'application/json; charset = utf-8' }
        body    = { ok: true }.to_json

        Rack::Response.new(body, status, headers).finish
      end
  end
end
