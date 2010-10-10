class SemExtractor
  class Textwise < SemExtractor
    #I kept methods here instead of variables because,each one leads to a http call
   
    def initialize(options={})
      self.set(options)
    end
    
    def terms
      @options = { 'content' => @context }
      get_entity
    end

    def categories
      @options = {'content' => @context, 'showLabels' => "true" }
      @type = 'category'
      get_entity
    end
    
    def filter
      @options = {'uri' => @context }
      @type = 'filter/web'
      remote_xml
    end
    
    def match
      @type = 'match/rsscombined'
      @options = {'content' => @context }
    end
    
    def get_entity
      begin
         Nokogiri::XML(remote_xml).css(@type).map { |h|  {"score" => h['weight'], "name" => h['label']} }
      rescue
        []
      end
    end

    def uri
      api_uri = URI.parse(gateway)
      api_uri.query = @options.map { |k,v| "#{URI.escape(k || '')}=#{URI.escape(v || '')}" }.join('&')
      api_uri
    end

    private
      def gateway
        @type ||= 'concept'
        'http://api.semantichacker.com/' + @api_key  + '/' + @type + '?'
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
