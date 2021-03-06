module ProxyFetcher
  class Configuration
    UnknownProvider = Class.new(StandardError)
    RegisteredProvider = Class.new(StandardError)
    WrongCustomClass = Class.new(StandardError)

    attr_accessor :provider, :connection_timeout
    attr_accessor :http_client, :proxy_validator, :logger

    class << self
      def providers
        @providers ||= {}
      end

      def register_provider(name, klass)
        raise RegisteredProvider, "`#{name}` provider already registered!" if providers.key?(name.to_sym)

        providers[name.to_sym] = klass
      end
    end

    def initialize
      reset!
    end

    def reset!
      @connection_timeout = 3
      @http_client = HTTPClient
      @proxy_validator = ProxyValidator

      self.provider = :hide_my_name # currently default one
    end

    def provider=(name)
      @provider = self.class.providers[name.to_sym]

      raise UnknownProvider, "unregistered proxy provider `#{name}`!" if @provider.nil?
    end

    def http_client=(klass)
      @http_client = setup_custom_class(klass, required_methods: :fetch)
    end

    def proxy_validator=(klass)
      @proxy_validator = setup_custom_class(klass, required_methods: :connectable?)
    end

    private

    def setup_custom_class(klass, required_methods: [])
      unless klass.respond_to?(*required_methods)
        raise WrongCustomClass, "#{klass} must respond to [#{Array(required_methods).join(', ')}] class methods!"
      end

      klass
    end
  end
end
