# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      class Client
        include Runners::InnerSpeech

        def initialize(voice: nil)
          @voice = voice || Helpers::InnerVoice.new
        end
      end
    end
  end
end
