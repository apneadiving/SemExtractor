class SemExtractor
  attr_accessor :context, :api_key, :categories

  def initialize(options={})
    @context = options[:context]
    @api_key = options[:api_key]
    @type = options[:type]
    @categories = nil
  end

end

%w{yahoo zemanta textwise}.each{|t| require "apis/#{t}"}