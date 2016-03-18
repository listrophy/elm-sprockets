require 'elm_sprockets/autoload'

module ElmSprockets
  # Compile Elm files for sprockets
  class ElmProcessor
    VERSION = '1'.freeze

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call input
    end

    def initialize(options = {})
      @options = options.merge(warn: true).freeze
      @opts = (Autoload::Elm::Options.with @options).freeze

      @cache_key = [
        self.class.name,
        VERSION,
        @options
      ].freeze
    end

    def call(input)
      data = input[:data]
      context = input[:environment].context_class.new(input)
      elm = input[:cache].fetch(@cache_key + [input[:filename]] + [data]) do
        Autoload::Elm.compiler.content(input[:data]).to_s
      end
      deps = Elm::Dependencies.from_content(data)
      deps.each do |dep|
        context.depend_on File.absolute_path(dep)
      end
      context.metadata.merge(data: elm.output)
    end
  end
end
