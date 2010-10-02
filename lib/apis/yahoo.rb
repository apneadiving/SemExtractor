class SemExtractor
 class Yahoo < SemExtractor
    def initialize(options={})
     self.set(options)
     @terms = Nokogiri::XML(remote_xml).css('Result').map { |h| {"name" => h.content} }
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
