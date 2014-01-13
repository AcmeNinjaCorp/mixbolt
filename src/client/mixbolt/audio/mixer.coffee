class @MixboltAudioMixer
	constructor: (@audio_context) ->
		@xfader_gain_left = @audio_context.createGain()
		@xfader_gain_right = @audio_context.createGain()
		@factor = 0.5

	connect: (output) ->
		@xfader_gain_left.connect(output)
		@xfader_gain_right.connect(output)

	change_value: (value) ->
		@factor = Math.max(Math.min(value, 1), 0)
		if @factor <= 0.5
      @xfader_gain_right.gain.value = @factor * 2
      @xfader_gain_left.gain.value = 1
		else
			@xfader_gain_right.gain.value = 1
			@xfader_gain_left.gain.value = (1 - @factor) * 2