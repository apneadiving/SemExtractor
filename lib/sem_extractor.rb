require 'nokogiri'
require 'uri'
require 'net/http'
require 'open-uri'

class SemExtractor
  attr_accessor :context, :api_key, :categories, :terms, :geos

  def set(options)
    @context = options[:context]
    @api_key = options[:api_key]
    @type = options[:type]
    @categories, @terms, @geos, @relations = Array.new, Array.new, Array.new, Array.new
  end

end

%w{yahoo zemanta textwise calais}.each{|t| require "apis/#{t}"}