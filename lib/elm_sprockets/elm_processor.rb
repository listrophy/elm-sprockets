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
        either do
          Autoload::Elm.compiler.content(input[:data]).to_s
        end
      end
      deps = Elm::Dependencies.from_content(data)
      deps.each do |dep|
        context.depend_on File.absolute_path(dep)
      end
      if elm[:right]
        context.metadata.merge(data: elm[:right].output)
      else
        context.metadata.merge(data: error_message(elm[:left]))
      end
    end

    def error_message(raw)
      raw.message.each_line.map do |line|
        line.gsub(/"/, '\"').sub(/^$/,'&nbsp;').rstrip
      end.map do |cleaned|
        %Q|document.write("<pre><code>#{cleaned}</code></pre>");|
      end.join("\n")
    end

    def either(&block)
      ret = nil
      begin
        ret = block.call
      rescue Exception => e
        {left: e}
      else
        {right: ret}
      end
    end
  end
end
