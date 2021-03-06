module ProxyFetcher
  module Providers
    class XRoxy < Base
      PROVIDER_URL = 'http://www.xroxy.com/proxylist.php'.freeze

      def load_proxy_list(filters = { type: 'All_http' })
        doc = load_document(PROVIDER_URL, filters)
        doc.xpath('//div[@id="content"]/table[1]/tr[contains(@class, "row")]')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = parse_element(html_element, 'td[2]')
          proxy.port = convert_to_int(parse_element(html_element, 'td[3]'))
          proxy.anonymity = parse_element(html_element, 'td[4]')
          proxy.country = parse_element(html_element, 'td[6]')
          proxy.response_time = convert_to_int(parse_element(html_element, 'td[7]'))
          proxy.type = parse_type(html_element)
        end
      end

      private

      def parse_type(element)
        https = parse_element(element, 'td[5]')
        https.casecmp('true').zero? ? ProxyFetcher::Proxy::HTTPS : ProxyFetcher::Proxy::HTTP
      end
    end

    ProxyFetcher::Configuration.register_provider(:xroxy, XRoxy)
  end
end
