# lex-inner-speech

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-inner-speech`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::InnerSpeech`

## Purpose

Inner speech and verbal thought stream for LegionIO agents. Provides a rolling buffer of internal utterances across multiple speech modes (planning, rehearsing, questioning, evaluating, warning, debating) and voice types. Detects and breaks rumination (same topic repeating >= 3 times), condenses long utterance streams, and surfaces a running inner narrative. Drives the agent's deliberative self-talk at the utterance level.

## Gem Info

- **Require path**: `legion/extensions/inner_speech`
- **Ruby**: >= 3.4
- **License**: MIT
- **Registers with**: `Legion::Extensions::Core`

## File Structure

```
lib/legion/extensions/inner_speech/
  version.rb
  helpers/
    constants.rb      # Modes, voice types, urgency labels, limits
    utterance.rb      # Utterance value object
    speech_stream.rb  # Rolling utterance buffer with rumination detection
    inner_voice.rb    # Voice-switching deliberation interface
  runners/
    inner_speech.rb   # Runner module

spec/
  legion/extensions/inner_speech/
    helpers/
      constants_spec.rb
      utterance_spec.rb
      speech_stream_spec.rb
      inner_voice_spec.rb
    runners/inner_speech_spec.rb
  spec_helper.rb
```

## Key Constants

```ruby
MAX_UTTERANCES      = 500
MAX_STREAM_LENGTH   = 100  # rolling buffer capacity
CONDENSATION_RATIO  = 0.33 # condensed_content is 33% of original length
RUMINATION_THRESHOLD = 3   # same topic N+ times = ruminating

SPEECH_MODES = %i[
  planning rehearsing questioning evaluating warning
  debating narrating recalling imagining reflecting
  problem_solving clarifying
]

VOICE_TYPES = %i[
  analytical cautious bold empathetic critical creative
  practical visionary
]

URGENCY_LABELS = {
  (0.8..)     => :critical,
  (0.6...0.8) => :high,
  (0.4...0.6) => :moderate,
  (0.2...0.4) => :low,
  (..0.2)     => :background
}
```

## Helpers

### `Helpers::Utterance` (class)

Single inner thought unit.

| Attribute | Type | Description |
|---|---|---|
| `id` | String (UUID) | unique identifier |
| `content` | String | the utterance text |
| `mode` | Symbol | speech mode |
| `voice_type` | Symbol | voice type |
| `topic` | Symbol | subject matter (for rumination detection) |
| `urgency` | Float (0..1) | how pressing this thought is |
| `salience` | Float (0..1) | current salience (decays over time) |

Key methods:
- `condensed_content` — returns first 33% of content characters (simple truncation compression)
- `urgent?` — urgency >= 0.6
- `background?` — urgency < 0.2
- `decay_salience!` — subtracts 0.05 from salience, floors at 0
- `urgency_label` — :critical / :high / :moderate / :low / :background

### `Helpers::SpeechStream` (class)

Rolling buffer of utterances with rumination detection.

| Method | Description |
|---|---|
| `append(utterance)` | adds to stream; shifts oldest when at MAX_STREAM_LENGTH |
| `ruminating?` | true if the same topic appears RUMINATION_THRESHOLD or more times in recent stream |
| `decay_all` | calls decay_salience! on all utterances |
| `condensed_stream` | returns condensed_content of recent utterances as joined string |
| `interrupt(utterance)` | prepends an urgent utterance to the front of the stream |

### `Helpers::InnerVoice` (class)

Voice-switching deliberation interface layered over a SpeechStream.

| Method | Description |
|---|---|
| `speak(content, mode:, topic:, urgency:)` | appends utterance in current voice |
| `switch_voice(voice_type)` | changes active voice type |
| `plan(steps)` | sequential planning utterances |
| `rehearse(action)` | rehearsal utterance |
| `question(query)` | questioning utterance |
| `evaluate(subject)` | evaluating utterance |
| `warn(concern)` | high-urgency warning utterance |
| `debate(topic)` | bold vs cautious voice exchange (two utterances) |
| `interrupt(content)` | high-urgency stream interruption |
| `break_rumination` | adds a deliberate topic-shift utterance when ruminating? is true |
| `tick` | calls decay_all on the stream |

## Runners

Module: `Legion::Extensions::InnerSpeech::Runners::InnerSpeech`

Private state: `@voice` (memoized `InnerVoice` instance).

| Runner Method | Parameters | Description |
|---|---|---|
| `inner_speak` | `content:, mode:, topic:, urgency: 0.5` | Append an utterance |
| `inner_plan` | `steps:` | Generate planning utterances |
| `inner_question` | `query:` | Generate a questioning utterance |
| `inner_debate` | `topic:` | Generate bold vs cautious debate exchange |
| `switch_inner_voice` | `voice_type:` | Switch active voice type |
| `inner_interrupt` | `content:` | High-urgency stream interruption |
| `break_inner_rumination` | (none) | Break detected rumination loop |
| `recent_inner_speech` | `limit: 20` | Recent utterances |
| `inner_narrative` | (none) | Condensed stream as prose |
| `update_inner_speech` | `tick_results: {}` | Decay salience; generate tick-driven reflection utterances |
| `inner_speech_stats` | (none) | Total utterances, ruminating?, current voice, avg urgency |

## Integration Points

- **lex-self-talk**: `lex-self-talk` provides the IFS-inspired multi-voice deliberation layer (Manager, Exile, Firefighter voices). `lex-inner-speech` provides the lower-level utterance stream and speech modes that `lex-self-talk` can write into.
- **lex-tick**: `update_inner_speech` is called each tick to decay salience and generate reflection utterances from tick_results.
- **lex-language**: inner narrative output from `inner_narrative` can be passed to `lex-language` for summarization.
- **lex-metacognition**: `InnerSpeech` is listed under `:introspection` capability category.

## Development Notes

- `condensed_content` is purely length-based truncation (first 33% of characters) — not semantic compression. It is a placeholder for future summarization.
- Rumination detection checks for the same `:topic` symbol appearing RUMINATION_THRESHOLD or more times in the rolling buffer. Topics are caller-assigned symbols; two semantically identical topics with different symbols will not be detected as rumination.
- `debate` always uses `:bold` vs `:cautious` voice types regardless of current active voice. The active voice is restored after the debate exchange.
- `interrupt` prepends to the stream buffer — it does not pause or replace the current stream. On the next `condensed_stream` call, the interrupt will appear first.
- No persistent storage — all state is in-memory. Salience decays via `update_inner_speech` or manual `tick` calls.
