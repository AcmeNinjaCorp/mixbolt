#_require ../parameter.coffee

class @MixboltAudioEq
	constructor: (@audio_context) ->
		@gain_node = @audio_context.createGain()
		@gain_node.gain.value = 1
		@gain = new MixboltParameter(50)
		@gain.add_listener(this, @update_gain)

		@lowpass = @audio_context.createBiquadFilter()
		@lowpass.type = "lowshelf"
		@lowpass.frequency.value = 100
		@lowpass.Q.value = 1
		@lowpass.gain.value = 0
		@low_gain = new MixboltParameter(50)
		@low_gain.add_listener(this, @update_low_gain)
	
		@highpass = @audio_context.createBiquadFilter()
		@highpass.type = "highshelf"
		@highpass.frequency.value = 4000
		@highpass.Q.value = 0
		@highpass.gain.value = 0
		@high_gain = new MixboltParameter(50)
		@high_gain.add_listener(this, @update_high_gain)

		@mid = @audio_context.createBiquadFilter()
		@mid.type = "peaking"
		@mid.frequency.value = 2000
		@mid.Q.value = 2
		@mid.gain.value = 0
		@mid_gain = new MixboltParameter(50)
		@mid_gain.add_listener(this, @update_mid_gain)

		@lowpass.connect(@mid)
		@mid.connect(@highpass)
		@highpass.connect(@gain_node)

	connect: (output) ->
		@gain_node.connect(output)

	plug: (input) ->
		input.connect(@lowpass)
	
	update_gain: (value) ->
		@gain_node.gain.value = (value / 100) * 2
	
	update_high_gain: (value) ->
		@highpass.gain.value = @linear_to_db(value)
	
	update_mid_gain: (value) ->
		@mid.gain.value = @linear_to_db(value)
	
	update_low_gain: (value)->
		@lowpass.gain.value = @linear_to_db(value)
	
	linear_to_db: (linear) ->
		if linear < 50
			- (@db_to_linear(50.0 - linear))
		else if linear == 50
			0
		else
			@db_to_linear(linear - 50.0)

	db_to_linear: (db) ->
		Math.pow(10, (db / 30.0)) - 1.0

