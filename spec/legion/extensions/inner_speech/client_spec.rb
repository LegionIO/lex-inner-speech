# frozen_string_literal: true

RSpec.describe Legion::Extensions::InnerSpeech::Client do
  subject(:client) { described_class.new }

  it 'includes the InnerSpeech runner' do
    expect(client).to respond_to(:inner_speak)
  end

  it 'accepts an injected voice' do
    voice = Legion::Extensions::InnerSpeech::Helpers::InnerVoice.new
    c = described_class.new(voice: voice)
    expect(c.inner_speak(content: 'test')[:success]).to be true
  end

  it 'supports full conversation flow' do
    client.inner_speak(content: 'hmm, what should I do?', mode: :questioning)
    client.inner_plan(content: 'first, check the data')
    client.inner_speak(content: 'that looks right', mode: :affirming)

    stats = client.inner_speech_stats
    expect(stats[:total_utterances]).to eq(3)

    narrative = client.inner_narrative
    expect(narrative[:narrative]).to include('check the data')
  end

  it 'supports debate and voice switching' do
    client.switch_inner_voice(voice_type: :curious)
    client.inner_debate(
      content_a: 'this approach is fast',
      content_b: 'but this approach is safe',
      topic:     :architecture
    )
    stats = client.inner_speech_stats
    expect(stats[:active_voice]).to eq(:curious)
    expect(stats[:total_utterances]).to eq(2)
  end
end
