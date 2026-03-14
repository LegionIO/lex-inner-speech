# frozen_string_literal: true

require_relative 'lib/legion/extensions/inner_speech/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-inner-speech'
  spec.version       = Legion::Extensions::InnerSpeech::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Inner speech engine for LegionIO'
  spec.description   = 'Vygotsky inner speech for LegionIO — ' \
                       'internal monologue, dialogic voices, rumination detection, and speech condensation'
  spec.homepage      = 'https://github.com/LegionIO/lex-inner-speech'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']
end
