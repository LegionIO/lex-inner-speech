# frozen_string_literal: true

require 'legion/extensions/inner_speech/version'
require 'legion/extensions/inner_speech/helpers/constants'
require 'legion/extensions/inner_speech/helpers/utterance'
require 'legion/extensions/inner_speech/helpers/speech_stream'
require 'legion/extensions/inner_speech/helpers/inner_voice'
require 'legion/extensions/inner_speech/runners/inner_speech'
require 'legion/extensions/inner_speech/client'

module Legion
  module Extensions
    module Helpers
      module Lex; end
    end
  end
end

module Legion
  module Logging
    def self.method_missing(*); end
    def self.respond_to_missing?(*) = true
  end
end
