# frozen_string_literal: true

RSpec.describe Legion::Extensions::InnerSpeech::Helpers::InnerVoice do
  subject(:iv) { described_class.new }

  describe '#initialize' do
    it 'starts with rational voice' do
      expect(iv.active_voice).to eq(:rational)
    end

    it 'has an empty stream' do
      expect(iv.stream.size).to eq(0)
    end
  end

  describe '#speak' do
    it 'adds an utterance with active voice' do
      u = iv.speak(content: 'hello world')
      expect(u.voice).to eq(:rational)
      expect(u.content).to eq('hello world')
    end

    it 'uses the specified mode' do
      u = iv.speak(content: 'planning step', mode: :planning)
      expect(u.mode).to eq(:planning)
    end

    it 'records event in history' do
      iv.speak(content: 'test')
      expect(iv.history.size).to eq(1)
    end
  end

  describe '#switch_voice' do
    it 'changes the active voice' do
      iv.switch_voice(voice: :emotional)
      expect(iv.active_voice).to eq(:emotional)
    end

    it 'rejects invalid voice' do
      result = iv.switch_voice(voice: :bogus)
      expect(result).to be_nil
      expect(iv.active_voice).to eq(:rational)
    end

    it 'records event in history' do
      iv.switch_voice(voice: :bold)
      expect(iv.history.last[:type]).to eq(:switch_voice)
    end
  end

  describe 'convenience methods' do
    it '#plan creates a planning utterance' do
      u = iv.plan(content: 'step one: gather data')
      expect(u.mode).to eq(:planning)
    end

    it '#rehearse creates a rehearsal utterance' do
      u = iv.rehearse(content: 'practice the response')
      expect(u.mode).to eq(:rehearsal)
    end

    it '#question creates a questioning utterance' do
      u = iv.question(content: 'what if this fails?')
      expect(u.mode).to eq(:questioning)
    end

    it '#evaluate creates an evaluating utterance' do
      u = iv.evaluate(content: 'that went well')
      expect(u.mode).to eq(:evaluating)
    end

    it '#warn creates a high-urgency warning' do
      u = iv.warn(content: 'careful with that')
      expect(u.mode).to eq(:warning)
      expect(u.urgency).to eq(0.8)
    end
  end

  describe '#debate' do
    it 'creates two utterances with different voices' do
      results = iv.debate(
        content_a: 'we should proceed',
        content_b: 'but what about the risks?',
        topic:     :decision
      )
      expect(results.size).to eq(2)
      expect(results.first.voice).to eq(:bold)
      expect(results.last.voice).to eq(:cautious)
    end

    it 'restores the original voice after debate' do
      iv.switch_voice(voice: :curious)
      iv.debate(content_a: 'yes', content_b: 'no')
      expect(iv.active_voice).to eq(:curious)
    end
  end

  describe '#interrupt' do
    it 'adds a high-urgency interruption' do
      u = iv.interrupt(content: 'STOP!')
      expect(u.urgency).to eq(0.9)
    end

    it 'records event in history' do
      iv.interrupt(content: 'alert')
      expect(iv.history.any? { |e| e[:type] == :interrupt }).to be true
    end
  end

  describe '#set_speed' do
    it 'sets automatic speed' do
      iv.set_speed(mode: :automatic)
      expect(iv.to_h[:speed]).to eq(3)
    end

    it 'sets controlled speed' do
      iv.set_speed(mode: :controlled)
      expect(iv.to_h[:speed]).to eq(1)
    end

    it 'sets egocentric speed' do
      iv.set_speed(mode: :egocentric)
      expect(iv.to_h[:speed]).to eq(0.5)
    end
  end

  describe '#ruminating?' do
    it 'delegates to stream' do
      4.times { iv.speak(content: 'same worry', topic: :anxiety) }
      expect(iv.ruminating?).to be true
    end
  end

  describe '#break_rumination' do
    it 'redirects when ruminating' do
      4.times { iv.speak(content: 'same thing', topic: :worry) }
      result = iv.break_rumination(redirect_topic: :work)
      expect(result).to be true
    end

    it 'returns false when not ruminating' do
      result = iv.break_rumination(redirect_topic: :work)
      expect(result).to be false
    end
  end

  describe '#recent_speech' do
    it 'returns recent utterances' do
      3.times { |i| iv.speak(content: "thought #{i}") }
      result = iv.recent_speech(count: 2)
      expect(result.size).to eq(2)
    end
  end

  describe '#narrative and #condensed_narrative' do
    it 'returns full narrative' do
      iv.speak(content: 'first')
      iv.speak(content: 'second')
      expect(iv.narrative).to eq('first second')
    end

    it 'returns condensed narrative from salient utterances' do
      iv.speak(content: 'this is a longer thought that will be condensed', salience: 0.8)
      expect(iv.condensed_narrative).to be_a(String)
    end
  end

  describe '#tick' do
    it 'decays stream and returns status' do
      iv.speak(content: 'test')
      result = iv.tick
      expect(result).to include(:active_voice, :speed)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(iv.to_h).to include(
        :active_voice, :speed, :stream_size, :ruminating,
        :total_utterances, :history_size
      )
    end
  end
end
