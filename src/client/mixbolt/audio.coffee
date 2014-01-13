class @MixboltAudio
	constructor: (@audio_context) ->
		@left_state = new MixboltAudioState(@audio_context)
		@right_state = new MixboltAudioState(@audio_context)

		@left_state.set_other_state(@right_state)
		@right_state.set_other_state(@left_state)

		@left_deck = new MixboltAudioDeck(@left_state)
		@right_deck = new MixboltAudioDeck(@right_state)

		@left_eq = new MixboltAudioEq(@audio_context)
		@right_eq = new MixboltAudioEq(@audio_context)

		@mixer = new MixboltAudioMixer(@audio_context)

		@left_eq.plug(@left_deck.processor)
		@right_eq.plug(@right_deck.processor)

		@left_eq.connect(@mixer.xfader_gain_left)
		@right_eq.connect(@mixer.xfader_gain_right)

		@mixer.connect(@audio_context.destination)