require 'elm-sprockets'
require 'sprockets/cache'
require 'fileutils'

describe ElmSprockets::ElmProcessor do
  let(:input) {
    {
     content_type: 'application/elm',
     data: File.read('test.js.elm'),
     name: 'test',
     cache: Sprockets::Cache.new,
     metadata: { mapping: [] },
     filename: 'test.js.elm',
     source_path: 'test.js.elm'
    }
  }

  before(:each) {
    File.open('test.js.elm', 'w') do |file|
      elm =<<EOF
import Html exposing (text)

main =
  text "Hello, World!"
EOF
      file.write elm
    end

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
  }

  after(:each) {
    FileUtils.rm 'test.js.elm'
    FileUtils.rm 'elm-package.json'
  }

  context '##call' do
    it 'compile elm file' do
      elm_out = ElmSprockets::ElmProcessor.call(input)
      expect(elm_out[:data]).to match(/var Elm/)
    end
  end
end
