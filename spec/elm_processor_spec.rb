require 'elm_sprockets'
require 'sprockets/cache'
require 'fileutils'

describe ElmSprockets::ElmProcessor do
  before(:each) do
    elm_content = <<EOF
import Html exposing (text)

main =
  text "Hello, World!"
EOF

    @input = {
      environment: Sprockets::Environment.new,
      filename: 'test.elm',
      content_type: 'application/elm',
      data: elm_content,
      name: 'test',
      cache: Sprockets::Cache.new,
      metadata: { }
    }

    File.open('elm-package.json', 'w') do |file|
      package = <<EOF
{
    "version": "1.0.0",
    "summary": "helpful summary of your project, less than 80 characters",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "source-directories": [
        "."
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "3.0.0 <= v < 4.0.0",
        "evancz/elm-html": "4.0.2 <= v < 5.0.0"
    },
    "elm-version": "0.16.0 <= v < 0.17.0"
}
EOF
      file.write package
    end

    # If elm-make is installed, uncomment the following line
    allow(ElmSprockets::Autoload::Elm).to(
      receive(:make) { ElmSprockets::Autoload::Elm::Runnable.new 'echo' })
  end

  after(:each) do
    FileUtils.rm 'elm-package.json'
  end

  context '##call' do
    it 'compile elm file without exception' do
      expect { ElmSprockets::ElmProcessor.call(@input) }.to_not raise_error
    end

    # Enable this test if elm-make is installed
    xit 'compile elm file' do
      elm_out = ElmSprockets::ElmProcessor.call(@input)
      expect(elm_out[:data]).to match(/var Elm/)
    end
  end
end
