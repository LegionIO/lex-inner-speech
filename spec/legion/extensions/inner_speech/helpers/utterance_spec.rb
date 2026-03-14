# frozen_string_literal: true

RSpec.describe Legion::Extensions::InnerSpeech::Helpers::Utterance do
  subject(:utterance) do
    described_class.new(id: :utt_one, content: 'I should check the data first')
  end

  describe '#initialize' do
    it 'sets content and defaults' do
      expect(utterance.content).to eq('I should check the data first')
      expect(utterance.mode).to eq(:narrating)
      expect(utterance.voice).to eq(:rational)
      expect(utterance.topic).to eq(:general)
      expect(utterance.urgency).to eq(0.5)
      expect(utterance.salience).to eq(0.5)
    end

    it 'accepts custom attributes' do
      u = described_class.new(
        id:               :utt_two,
        content:          'danger ahead',
        mode:             :warning,
        voice:            :cautious,
        topic:            :safety,
        urgency:          0.9,
        salience:         0.8,
        source_subsystem: :emotion
      )
      expect(u.mode).to eq(:warning)
      expect(u.voice).to eq(:cautious)
      expect(u.topic).to eq(:safety)
      expect(u.urgency).to eq(0.9)
      expect(u.source_subsystem).to eq(:emotion)
    end

    it 'defaults invalid mode to :narrating' do
      u = described_class.new(id: :x, content: 'test', mode: :bogus)
      expect(u.mode).to eq(:narrating)
    end

    it 'defaults invalid voice to :rational' do
      u = described_class.new(id: :x, content: 'test', voice: :bogus)
      expect(u.voice).to eq(:rational)
    end

    it 'clamps urgency' do
      u = described_class.new(id: :x, content: 'test', urgency: 2.0)
      expect(u.urgency).to eq(1.0)
    end
  end

  describe '#condensed_content' do
    it 'returns abbreviated version' do
      condensed = utterance.condensed_content
      expect(condensed.split.size).to be < utterance.content.split.size
    end

    it 'keeps at least one word' do
      u = described_class.new(id: :x, content: 'hello')
      expect(u.condensed_content).to eq('hello')
    end
  end

  describe '#urgent?' do
    it 'returns true for high urgency' do
      u = described_class.new(id: :x, content: 'test', urgency: 0.8)
      expect(u.urgent?).to be true
    end

    it 'returns false for low urgency' do
      u = described_class.new(id: :x, content: 'test', urgency: 0.2)
      expect(u.urgent?).to be false
    end
  end

  describe '#background?' do
    it 'returns true for very low urgency' do
      u = described_class.new(id: :x, content: 'test', urgency: 0.1)
      expect(u.background?).to be true
    end
  end

  describe '#decay_salience!' do
    it 'reduces salience' do
      original = utterance.salience
      utterance.decay_salience!
      expect(utterance.salience).to be < original
    end

    it 'does not go below floor' do
      20.times { utterance.decay_salience! }
      expect(utterance.salience).to be >= 0.01
    end
  end

  describe '#salient?' do
    it 'returns true when salience is high' do
      expect(utterance.salient?).to be true
    end

    it 'returns false after heavy decay' do
      15.times { utterance.decay_salience! }
      expect(utterance.salient?).to be false
    end
  end

  describe '#urgency_label' do
    it 'returns a symbol' do
      expect(utterance.urgency_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(utterance.to_h).to include(
        :id, :content, :condensed, :mode, :voice, :topic,
        :urgency, :salience, :source_subsystem, :urgency_label
      )
    end
  end
end
