require 'sprockets'

# Sprockets extension to compile elm files
module Sprockets
  require 'elm_sprockets/elm_processor'

  register_mime_type 'text/elm', extensions: ['.elm']
  register_transformer(
    'text/elm',
    'application/javascript',
    ElmSprockets::ElmProcessor)
  register_preprocessor(
    'text/elm',
    DirectiveProcessor.new(comments: ['--', ['{-', '-}']]))
end
