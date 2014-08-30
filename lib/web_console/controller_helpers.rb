module WebConsole
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      # Flag to decide whether the console should be rendered.
      attr_internal :should_render_console

      # Storage of a binding the console to be rendered in.
      attr_internal :console_binding

      prepend_after_action :inject_console_into_view
    end

    def initialize(*)
      super

      @_should_render_console = true
    end

    # Helper for capturing a controller binding to prepare for console
    # rendering.
    def console(binding = nil)
      @_console_binding = binding || ::Kernel.binding.of_caller(1)
    end

    private

      # Attempt to inject an interactive console to a view.
      def inject_console_into_view
        return unless can_render_console?

        console_html = ActionView::Base.new(ActionController::Base.view_paths,
          console_session: REPLSession.create(binding: @_console_binding)
        ).render(partial: 'rescues/web_console')

        response.body = response.body + console_html
      end

      def can_render_console?
        console_binding && should_render_console && content_type == Mime::HTML
      end
  end
end
