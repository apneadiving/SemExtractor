class SemExtractor
  class Calais < SemExtractor
    
     def initialize(options={})
       self.set(options)
        Nokogiri::XML(remote_xml).xpath('//rdf:Description').map { |h|  
          node_type = h.xpath('rdf:type').first['resource']
          if node_type.include?('/type/cat/')
            @categories << { "name" => h.xpath('c:categoryName').first.content, "score"=>h.xpath('c:score').first.content}
          elsif node_type.include?('/type/em/')
            nationality = h.xpath('c:nationality').first.nil? ? 'N/A' : h.xpath('c:nationality').first.content
            @terms << { "name" => h.xpath('c:name').first.content, "score" => nil, "nationality" => nationality }
          elsif node_type.include?('/type/sys/InstanceInfo')
            #nothing to do, no info to take
          elsif node_type.include?('/type/sys/RelevanceInfo')
            # I assume here, Open Calais will keep on giving information in the proper order, seems fair :)
            @terms.last["score"] = h.xpath('c:relevance').first.content
          elsif node_type.include?('/Geo/')
            @geos <<{ "name" => h.xpath('c:name').first.content } 
          end
          }
      end

     def uri
       URI.parse(gateway + '?' + URI.escape(post_params.collect{ |k, v| "#{k}=#{v}" }.join('&')))
     end

    def post_params
      {
        'licenseID' => @api_key,
        'content'   => @context
      }
    end

  private
      def gateway
        'http://api.opencalais.com/enlighten/rest/'
      end

      def remote_xml
        begin
          Net::HTTP.get_response((uri)).body
        rescue => e
          $stderr.puts "Couldn't fetch from API: #{e.message}" if $VERBOSE
          nil
        end
      end
  end
end