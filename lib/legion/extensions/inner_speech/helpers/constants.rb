# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      module Helpers
        module Constants
          MAX_UTTERANCES = 500
          MAX_STREAM_LENGTH = 100
          MAX_HISTORY = 200

          # Speech condensation: inner speech is ~3x compressed vs external
          CONDENSATION_RATIO = 0.33

          # Rumination detection: same topic repeated N+ times
          RUMINATION_THRESHOLD = 3

          # Speed constants (utterances per tick)
          AUTOMATIC_SPEED = 3
          CONTROLLED_SPEED = 1
          EGOCENTRIC_SPEED = 0.5

          # Decay: how quickly old utterances lose salience
          SALIENCE_DECAY = 0.05
          SALIENCE_FLOOR = 0.01

          SPEECH_MODES = %i[
            planning rehearsal monitoring evaluating
            questioning affirming narrating debating
            comforting warning remembering imagining
          ].freeze

          VOICE_TYPES = %i[
            rational emotional cautious bold
            critical supportive curious skeptical
          ].freeze

          URGENCY_LABELS = {
            (0.8..)     => :critical,
            (0.6...0.8) => :high,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :low,
            (..0.2)     => :background
          }.freeze
        end
      end
    end
  end
end
