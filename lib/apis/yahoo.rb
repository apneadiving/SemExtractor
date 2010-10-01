require 'nokogiri'
require 'open-uri'
require 'uri'

class SemExtractor
 class Yahoo < SemExtractor
    def terms
      begin
        Nokogiri::XML(remote_xml).css('Result').map { |h| {"name" => h.content} }
      rescue
        []
      end
    end

    def uri
      api_uri = URI.parse(gateway)
      api_uri.query = {
         'appid'   => @api_key,
         'output'  => 'xml',
         'context' => @context
      }.map { |k,v| "#{URI.escape(k || '')}=#{URI.escape(v || '')}" }.join('&')
      api_uri
    end

    private
      def gateway
        'http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction'
      end

      def remote_xml
        begin
          open(uri).read
        rescue => e
          $stderr.puts "Couldn't fetch from API: #{e.message}" if $VERBOSE
          nil
        end
      end
 end
end
