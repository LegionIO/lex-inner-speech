# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      module Runners
        module InnerSpeech
          include Helpers::Constants
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def inner_speak(content:, mode: :narrating, topic: :general, **)
            utterance = voice.speak(content: content, mode: mode, topic: topic)
            return { success: false, reason: :stream_full } unless utterance

            { success: true, utterance_id: utterance.id, mode: utterance.mode }
          end

          def inner_plan(content:, topic: :general, **)
            utterance = voice.plan(content: content, topic: topic)
            return { success: false, reason: :stream_full } unless utterance

            { success: true, utterance_id: utterance.id }
          end

          def inner_question(content:, topic: :general, **)
            utterance = voice.question(content: content, topic: topic)
            return { success: false, reason: :stream_full } unless utterance

            { success: true, utterance_id: utterance.id }
          end

          def inner_debate(content_a:, content_b:, topic: :general, **)
            results = voice.debate(content_a: content_a, content_b: content_b, topic: topic)
            { success: true, utterances: results.map(&:id), count: results.size }
          end

          def switch_inner_voice(voice_type:, **)
            result = voice.switch_voice(voice: voice_type)
            return { success: false, reason: :invalid_voice } unless result

            { success: true, active_voice: result }
          end

          def inner_interrupt(content:, **)
            utterance = voice.interrupt(content: content)
            return { success: false, reason: :stream_full } unless utterance

            { success: true, utterance_id: utterance.id }
          end

          def break_inner_rumination(redirect_topic: :general, **)
            result = voice.break_rumination(redirect_topic: redirect_topic)
            { success: true, rumination_broken: result }
          end

          def recent_inner_speech(count: 5, **)
            speech = voice.recent_speech(count: count)
            { success: true, utterances: speech, count: speech.size }
          end

          def inner_narrative(**)
            { success: true, narrative: voice.narrative, condensed: voice.condensed_narrative }
          end

          def update_inner_speech(**)
            result = voice.tick
            { success: true }.merge(result)
          end

          def inner_speech_stats(**)
            { success: true }.merge(voice.to_h)
          end

          private

          def voice
            @voice ||= Helpers::InnerVoice.new
          end
        end
      end
    end
  end
end
