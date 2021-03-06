module ProxyFetcher
  module Providers
    class HideMyName < Base
      PROVIDER_URL = 'https://hidemy.name/en/proxy-list/'.freeze

      def load_proxy_list(filters = { type: 'hs' })
        doc = load_document(PROVIDER_URL, filters)
        doc.xpath('//table[@class="proxy__t"]/tbody/tr')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = parse_element(html_element, 'td[1]')
          proxy.port = convert_to_int(parse_element(html_element, 'td[2]'))
          proxy.anonymity = parse_element(html_element, 'td[6]')
          proxy.country = parse_country(html_element)
          proxy.type = parse_element(html_element, 'td[5]')
          proxy.response_time = parse_response_time(html_element)
        end
      end

      private

      def parse_country(element)
        clear(element.at_xpath('*//span[1]/following-sibling::text()[1]').content)
      end

      def parse_response_time(element)
        convert_to_int(element.at_xpath('td[4]').content.strip[/\d+/])
      end
    end

    ProxyFetcher::Configuration.register_provider(:hide_my_name, HideMyName)
  end
end
