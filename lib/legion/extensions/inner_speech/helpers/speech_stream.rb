# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      module Helpers
        class SpeechStream
          include Constants

          attr_reader :utterances, :counter

          def initialize
            @utterances = []
            @counter    = 0
          end

          def append(content:, mode: :narrating, **)
            return nil if @utterances.size >= MAX_STREAM_LENGTH

            @counter += 1
            utterance = Utterance.new(
              id:      :"utt_#{@counter}",
              content: content,
              mode:    mode,
              **
            )
            @utterances << utterance
            utterance
          end

          def current
            @utterances.last
          end

          def recent(count: 5)
            @utterances.last(count).map(&:to_h)
          end

          def by_mode(mode:)
            @utterances.select { |u| u.mode == mode }.map(&:to_h)
          end

          def by_voice(voice:)
            @utterances.select { |u| u.voice == voice }.map(&:to_h)
          end

          def by_topic(topic:)
            @utterances.select { |u| u.topic == topic }.map(&:to_h)
          end

          def salient
            @utterances.select(&:salient?).map(&:to_h)
          end

          def urgent
            @utterances.select(&:urgent?).map(&:to_h)
          end

          def ruminating?
            return false if @utterances.size < RUMINATION_THRESHOLD

            recent_topics = @utterances.last(RUMINATION_THRESHOLD).map(&:topic)
            recent_topics.uniq.size == 1
          end

          def rumination_topic
            return nil unless ruminating?

            @utterances.last&.topic
          end

          def decay_all
            @utterances.each(&:decay_salience!)
            prune_stale
          end

          def interrupt(content:, mode: :warning, **)
            append(content: content, mode: mode, urgency: 0.9, salience: 0.9, **)
          end

          def condensed_stream
            @utterances.select(&:salient?).map(&:condensed_content)
          end

          def narrative
            @utterances.map(&:content).join(' ')
          end

          def clear
            @utterances.clear
          end

          def size
            @utterances.size
          end

          def to_h
            {
              size:              @utterances.size,
              total_generated:   @counter,
              ruminating:        ruminating?,
              rumination_topic:  rumination_topic,
              salient_count:     @utterances.count(&:salient?),
              urgent_count:      @utterances.count(&:urgent?),
              mode_distribution: mode_distribution
            }
          end

          private

          def prune_stale
            @utterances.reject! { |u| u.salience <= SALIENCE_FLOOR }
          end

          def mode_distribution
            dist = Hash.new(0)
            @utterances.each { |u| dist[u.mode] += 1 }
            dist
          end
        end
      end
    end
  end
end
