# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      module Helpers
        class InnerVoice
          include Constants

          attr_reader :stream, :voices, :active_voice, :history

          def initialize
            @stream       = SpeechStream.new
            @voices       = VOICE_TYPES.dup
            @active_voice = :rational
            @history      = []
            @speed        = CONTROLLED_SPEED
          end

          def speak(content:, mode: :narrating, topic: :general, **)
            utterance = @stream.append(
              content: content,
              mode:    mode,
              voice:   @active_voice,
              topic:   topic,
              **
            )
            record_event(:speak, utterance_id: utterance&.id) if utterance
            utterance
          end

          def switch_voice(voice:)
            sym = voice.to_sym
            return nil unless VOICE_TYPES.include?(sym)

            old_voice = @active_voice
            @active_voice = sym
            record_event(:switch_voice, from: old_voice, to: sym)
            @active_voice
          end

          def plan(content:, topic: :general, **)
            speak(content: content, mode: :planning, topic: topic, **)
          end

          def rehearse(content:, topic: :general, **)
            speak(content: content, mode: :rehearsal, topic: topic, **)
          end

          def question(content:, topic: :general, **)
            speak(content: content, mode: :questioning, topic: topic, **)
          end

          def evaluate(content:, topic: :general, **)
            speak(content: content, mode: :evaluating, topic: topic, **)
          end

          def warn(content:, topic: :general, **)
            speak(content: content, mode: :warning, topic: topic, urgency: 0.8, **)
          end

          def debate(content_a:, content_b:, topic: :general, **)
            old_voice = @active_voice
            @active_voice = :bold
            utt_a = speak(content: content_a, mode: :debating, topic: topic, **)
            @active_voice = :cautious
            utt_b = speak(content: content_b, mode: :debating, topic: topic, **)
            @active_voice = old_voice
            [utt_a, utt_b].compact
          end

          def interrupt(content:, **)
            utterance = @stream.interrupt(content: content, **)
            record_event(:interrupt, utterance_id: utterance&.id) if utterance
            utterance
          end

          SPEED_MAP = {
            automatic:  AUTOMATIC_SPEED,
            controlled: CONTROLLED_SPEED,
            egocentric: EGOCENTRIC_SPEED
          }.freeze

          def set_speed(mode:)
            @speed = SPEED_MAP.fetch(mode, CONTROLLED_SPEED)
          end

          def ruminating?
            @stream.ruminating?
          end

          def break_rumination(redirect_topic:)
            return false unless ruminating?

            speak(content: 'Let me think about something else.', mode: :narrating, topic: redirect_topic)
            true
          end

          def recent_speech(count: 5)
            @stream.recent(count: count)
          end

          def narrative
            @stream.narrative
          end

          def condensed_narrative
            @stream.condensed_stream.join(' ')
          end

          def tick
            @stream.decay_all
            @stream.to_h.merge(active_voice: @active_voice, speed: @speed)
          end

          def to_h
            {
              active_voice:     @active_voice,
              speed:            @speed,
              stream_size:      @stream.size,
              ruminating:       ruminating?,
              total_utterances: @stream.counter,
              history_size:     @history.size
            }
          end

          private

          def record_event(type, **details)
            @history << { type: type, at: Time.now.utc }.merge(details)
            @history.shift while @history.size > MAX_HISTORY
          end
        end
      end
    end
  end
end
