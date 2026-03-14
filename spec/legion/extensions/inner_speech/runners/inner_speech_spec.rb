# frozen_string_literal: true

RSpec.describe Legion::Extensions::InnerSpeech::Runners::InnerSpeech do
  let(:host) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#inner_speak' do
    it 'creates an utterance' do
      result = host.inner_speak(content: 'testing', mode: :planning)
      expect(result[:success]).to be true
      expect(result[:utterance_id]).to be_a(Symbol)
      expect(result[:mode]).to eq(:planning)
    end
  end

  describe '#inner_plan' do
    it 'creates a planning utterance' do
      result = host.inner_plan(content: 'step one')
      expect(result[:success]).to be true
    end
  end

  describe '#inner_question' do
    it 'creates a questioning utterance' do
      result = host.inner_question(content: 'what if?')
      expect(result[:success]).to be true
    end
  end

  describe '#inner_debate' do
    it 'creates a two-sided debate' do
      result = host.inner_debate(content_a: 'yes', content_b: 'no', topic: :choice)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end
  end

  describe '#switch_inner_voice' do
    it 'switches voice' do
      result = host.switch_inner_voice(voice_type: :emotional)
      expect(result[:success]).to be true
      expect(result[:active_voice]).to eq(:emotional)
    end

    it 'rejects invalid voice' do
      result = host.switch_inner_voice(voice_type: :bogus)
      expect(result[:success]).to be false
    end
  end

  describe '#inner_interrupt' do
    it 'creates an interruption' do
      result = host.inner_interrupt(content: 'ALERT')
      expect(result[:success]).to be true
    end
  end

  describe '#break_inner_rumination' do
    it 'attempts to break rumination' do
      result = host.break_inner_rumination(redirect_topic: :work)
      expect(result[:success]).to be true
      expect(result[:rumination_broken]).to be false
    end
  end

  describe '#recent_inner_speech' do
    it 'returns recent speech' do
      host.inner_speak(content: 'hello')
      result = host.recent_inner_speech(count: 5)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#inner_narrative' do
    it 'returns the narrative' do
      host.inner_speak(content: 'first thought')
      result = host.inner_narrative
      expect(result[:success]).to be true
      expect(result[:narrative]).to include('first thought')
    end
  end

  describe '#update_inner_speech' do
    it 'ticks the inner voice' do
      result = host.update_inner_speech
      expect(result[:success]).to be true
    end
  end

  describe '#inner_speech_stats' do
    it 'returns stats' do
      result = host.inner_speech_stats
      expect(result[:success]).to be true
      expect(result).to have_key(:active_voice)
      expect(result).to have_key(:stream_size)
    end
  end
end
