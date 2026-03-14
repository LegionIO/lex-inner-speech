# lex-inner-speech

Inner verbal thought stream for LegionIO agents. Part of the LegionIO cognitive architecture extension ecosystem (LEX).

## What It Does

`lex-inner-speech` gives an agent a rolling buffer of internal utterances across multiple speech modes and voice types. It supports deliberate planning, rehearsal, questioning, evaluating, warning, and bold-vs-cautious debate. Detects rumination (same topic repeated 3+ times) and can break it with a deliberate topic shift. A condensed inner narrative is always available.

Key capabilities:

- **12 speech modes**: planning, rehearsing, questioning, evaluating, warning, debating, narrating, recalling, imagining, reflecting, problem_solving, clarifying
- **8 voice types**: analytical, cautious, bold, empathetic, critical, creative, practical, visionary
- **Rumination detection**: same topic appearing 3+ times in the rolling buffer
- **Salience decay**: urgency-weighted salience fades over time
- **Inner narrative**: condensed prose view of the recent thought stream

## Installation

Add to your Gemfile:

```ruby
gem 'lex-inner-speech'
```

Or install directly:

```
gem install lex-inner-speech
```

## Usage

```ruby
require 'legion/extensions/inner_speech'

client = Legion::Extensions::InnerSpeech::Client.new

# Speak an inner thought
client.inner_speak(content: 'Should I retry this API call?', mode: :questioning, topic: :api_retry)

# Generate planning utterances
client.inner_plan(steps: ['check rate limit', 'wait 1 second', 'retry with backoff'])

# Run a bold vs cautious internal debate
client.inner_debate(topic: :deploy_now)

# Switch voice for different perspective
client.switch_inner_voice(voice_type: :cautious)

# Break a rumination loop
client.break_inner_rumination if client.inner_speech_stats[:ruminating]

# Read the inner narrative
puts client.inner_narrative[:condensed]

# Recent thoughts
client.recent_inner_speech(limit: 10)
```

## Runner Methods

| Method | Description |
|---|---|
| `inner_speak` | Append an utterance in the current voice |
| `inner_plan` | Generate sequential planning utterances |
| `inner_question` | Generate a questioning utterance |
| `inner_debate` | Generate bold vs cautious voice debate exchange |
| `switch_inner_voice` | Switch the active voice type |
| `inner_interrupt` | High-urgency stream interruption |
| `break_inner_rumination` | Break a detected rumination loop |
| `recent_inner_speech` | Recent utterances from the stream |
| `inner_narrative` | Condensed thought stream as prose |
| `update_inner_speech` | Decay salience and generate tick-driven reflection utterances |
| `inner_speech_stats` | Total utterances, ruminating flag, current voice, avg urgency |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
