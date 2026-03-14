# frozen_string_literal: true

RSpec.describe Legion::Extensions::InnerSpeech::Helpers::SpeechStream do
  subject(:stream) { described_class.new }

  describe '#append' do
    it 'adds an utterance' do
      u = stream.append(content: 'thinking about lunch')
      expect(u).to be_a(Legion::Extensions::InnerSpeech::Helpers::Utterance)
      expect(stream.size).to eq(1)
    end

    it 'enforces MAX_STREAM_LENGTH' do
      100.times { |i| stream.append(content: "thought #{i}") }
      expect(stream.append(content: 'overflow')).to be_nil
    end
  end

  describe '#current' do
    it 'returns the most recent utterance' do
      stream.append(content: 'first')
      stream.append(content: 'second')
      expect(stream.current.content).to eq('second')
    end

    it 'returns nil when empty' do
      expect(stream.current).to be_nil
    end
  end

  describe '#recent' do
    it 'returns last N utterances' do
      5.times { |i| stream.append(content: "thought #{i}") }
      result = stream.recent(count: 3)
      expect(result.size).to eq(3)
    end
  end

  describe '#by_mode' do
    it 'filters by mode' do
      stream.append(content: 'plan A', mode: :planning)
      stream.append(content: 'what is that?', mode: :questioning)
      expect(stream.by_mode(mode: :planning).size).to eq(1)
    end
  end

  describe '#by_voice' do
    it 'filters by voice' do
      stream.append(content: 'careful now', voice: :cautious)
      stream.append(content: 'go for it', voice: :bold)
      expect(stream.by_voice(voice: :bold).size).to eq(1)
    end
  end

  describe '#by_topic' do
    it 'filters by topic' do
      stream.append(content: 'safe code', topic: :safety)
      stream.append(content: 'fast code', topic: :performance)
      expect(stream.by_topic(topic: :safety).size).to eq(1)
    end
  end

  describe '#salient' do
    it 'returns salient utterances' do
      stream.append(content: 'important', salience: 0.8)
      stream.append(content: 'fading', salience: 0.1)
      expect(stream.salient.size).to eq(1)
    end
  end

  describe '#urgent' do
    it 'returns urgent utterances' do
      stream.append(content: 'critical', urgency: 0.9)
      stream.append(content: 'calm', urgency: 0.2)
      expect(stream.urgent.size).to eq(1)
    end
  end

  describe '#ruminating?' do
    it 'returns false with few utterances' do
      stream.append(content: 'one', topic: :worry)
      expect(stream.ruminating?).to be false
    end

    it 'detects rumination on same topic' do
      4.times { stream.append(content: 'still worried', topic: :worry) }
      expect(stream.ruminating?).to be true
    end

    it 'returns false for varied topics' do
      stream.append(content: 'a', topic: :work)
      stream.append(content: 'b', topic: :food)
      stream.append(content: 'c', topic: :fun)
      expect(stream.ruminating?).to be false
    end
  end

  describe '#rumination_topic' do
    it 'returns the repeated topic' do
      4.times { stream.append(content: 'same thing', topic: :anxiety) }
      expect(stream.rumination_topic).to eq(:anxiety)
    end

    it 'returns nil when not ruminating' do
      expect(stream.rumination_topic).to be_nil
    end
  end

  describe '#decay_all' do
    it 'decays and prunes stale utterances' do
      stream.append(content: 'will fade', salience: 0.06)
      stream.decay_all
      expect(stream.size).to eq(0)
    end
  end

  describe '#interrupt' do
    it 'adds a high-urgency utterance' do
      u = stream.interrupt(content: 'ALERT!')
      expect(u.urgency).to eq(0.9)
      expect(u.mode).to eq(:warning)
    end
  end

  describe '#condensed_stream' do
    it 'returns condensed versions of salient utterances' do
      stream.append(content: 'I need to think about this carefully', salience: 0.8)
      condensed = stream.condensed_stream
      expect(condensed).to be_an(Array)
      expect(condensed.first.split.size).to be < 'I need to think about this carefully'.split.size
    end
  end

  describe '#narrative' do
    it 'joins all utterances into a string' do
      stream.append(content: 'first thought')
      stream.append(content: 'second thought')
      expect(stream.narrative).to eq('first thought second thought')
    end
  end

  describe '#clear' do
    it 'empties the stream' do
      stream.append(content: 'test')
      stream.clear
      expect(stream.size).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(stream.to_h).to include(
        :size, :total_generated, :ruminating, :rumination_topic,
        :salient_count, :urgent_count, :mode_distribution
      )
    end
  end
end
