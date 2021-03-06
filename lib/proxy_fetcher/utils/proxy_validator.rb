module ProxyFetcher
  class ProxyValidator
    URL_TO_CHECK = 'https://google.com'.freeze

    def initialize(proxy_addr, proxy_port)
      uri = URI.parse(URL_TO_CHECK)
      @http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port.to_i)

      return unless uri.scheme.casecmp('https').zero?

      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def connectable?
      @http.open_timeout = ProxyFetcher.config.connection_timeout
      @http.read_timeout = ProxyFetcher.config.connection_timeout

      @http.start { |connection| return true if connection.request_head('/') }

      false
    rescue StandardError
      false
    end

    class << self
      def connectable?(proxy_addr, proxy_port)
        new(proxy_addr, proxy_port).connectable?
      end
    end
  end
end
