class SemExtractor
  class Calais < SemExtractor
    
     def initialize(options={})
       self.set(options)
        Nokogiri::XML(remote_xml).xpath('//rdf:Description').map { |h|  
          node_type = h.xpath('rdf:type').first['resource']
          if node_type.include?('/type/cat/')
            @categories << { "name" => sanitize(h.xpath('c:categoryName')), "score"=> sanitize(h.xpath('c:score'))}
          elsif node_type.include?('/type/em/')
            @terms << { "name" => sanitize(h.xpath('c:name')), "score" => nil, "nationality" => sanitize(h.xpath('c:nationality')) }
          elsif node_type.include?('/type/sys/InstanceInfo')
            #nothing to do, no info to take
          elsif node_type.include?('/type/sys/RelevanceInfo')
            # I assume here, Open Calais will keep on giving information in the proper order, seems fair :)
            @terms.last["score"] = sanitize(h.xpath('c:relevance'))
          elsif node_type.include?('/Geo/')
            @geos <<{ "name" => sanitize(h.xpath('c:name')) } 
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
      def sanitize(item)
        item.first.nil? ? 'N/A' : item.first.content 
      end
      
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