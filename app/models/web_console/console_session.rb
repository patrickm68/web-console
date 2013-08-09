module WebConsole
  class ConsoleSession
    include Mutex_m

    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    # In-memory storage for the console sessions. Session preservation is
    # troubled on servers with multiple workers and threads.
    INMEMORY_STORAGE = {}

    # Store and define the available attributes.
    ATTRIBUTES = %w( id input output ).each do |attr|
      attr_accessor attr.to_sym
    end

    # Raised when trying to find a session that is no longer in the in-memory
    # session storage.
    class NotFound < Exception
      def to_json(*)
        { error: message }.to_json
      end
    end

    class << self
      # Finds a session by its id.
      #
      # Raises WebConsole::ConsoleSession::Expired if there is no such session.
      def find(id)
        INMEMORY_STORAGE[id.to_i] or raise NotFound, 'Session unavailable'
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create
        INMEMORY_STORAGE[(model = new).id] = model
      end
    end

    def initialize(attributes = {})
      super.tap do
        @repl = WebConsole::REPL.new
        populate_repl_attributes!
      end
    end

    # Saves the model into the in-memory storage.
    #
    # Returns false if the model is not valid (e.g. its missing input).
    def save(attributes = {})
      self.attributes = attributes if attributes.present?
      populate_repl_attributes!
      store!
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[id]
    end

    # Returns an Enumerable of all key attributes if any is set, regardless if
    # the object is persisted or not.
    def to_key
      super if persisted?
    end

    protected

      # Returns a hash of the attributes and their values.
      def attributes
        return Hash[ATTRIBUTES.zip([nil])]
      end

      # Sets model attributes from a hash.
      def attributes=(attributes)
        attributes.each do |attr, value|
          next unless ATTRIBUTES.include?(attr.to_sym)
          public_send(:"#{attr}=", value)
        end
      end

    private

      def populate_repl_attributes!(options = {})
        synchronize do
          @repl.send_input(input)

          self.output = @repl.pending_output
          self.id     = @repl.pid
        end
      end

      def store!
        synchronize { INMEMORY_STORAGE[id] = self }
      end
  end

  # Explicitly configue include_root_in_json for Rails 3 compatibility.
  ConsoleSession.include_root_in_json = false
end
