# frozen_string_literal: true

module Legion
  module Extensions
    module InnerSpeech
      module Helpers
        class Utterance
          include Constants

          attr_reader :id, :content, :mode, :voice, :topic,
                      :urgency, :salience, :source_subsystem, :created_at

          def initialize(id:, content:, mode: :narrating, **opts)
            @id               = id
            @content          = content
            @mode             = resolve_mode(mode)
            apply_opts(opts)
            @created_at = Time.now.utc
          end

          def condensed_content
            words = @content.split
            keep = [(words.size * CONDENSATION_RATIO).ceil, 1].max
            words.first(keep).join(' ')
          end

          def urgent?
            @urgency >= 0.6
          end

          def background?
            @urgency < 0.2
          end

          def decay_salience!
            @salience = [@salience - SALIENCE_DECAY, SALIENCE_FLOOR].max
          end

          def salient?
            @salience >= 0.3
          end

          def urgency_label
            URGENCY_LABELS.each { |range, lbl| return lbl if range.cover?(@urgency) }
            :background
          end

          def to_h
            {
              id:               @id,
              content:          @content,
              condensed:        condensed_content,
              mode:             @mode,
              voice:            @voice,
              topic:            @topic,
              urgency:          @urgency.round(4),
              salience:         @salience.round(4),
              source_subsystem: @source_subsystem,
              urgency_label:    urgency_label
            }
          end

          private

          def apply_opts(opts)
            @voice            = resolve_voice(opts.fetch(:voice, :rational))
            @topic            = opts.fetch(:topic, :general)
            @urgency          = opts.fetch(:urgency, 0.5).to_f.clamp(0.0, 1.0)
            @salience         = opts.fetch(:salience, 0.5).to_f.clamp(0.0, 1.0)
            @source_subsystem = opts.fetch(:source_subsystem, :unknown)
          end

          def resolve_mode(mode)
            sym = mode.to_sym
            SPEECH_MODES.include?(sym) ? sym : :narrating
          end

          def resolve_voice(voice)
            sym = voice.to_sym
            VOICE_TYPES.include?(sym) ? sym : :rational
          end
        end
      end
    end
  end
end
