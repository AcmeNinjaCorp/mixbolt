class @MixboltAudioDeck
	constructor: (@state) ->
		@buffer_size = @state.buffer_size
		# @buffer_size = 1024
		audio_context = @state.audio_context
		if audio_context.createScriptProcessor 
			@processor = audio_context.createScriptProcessor(@buffer_size, 0, @state.channels) # size, inputs, outputs
		else
			@processor = audio_context.createJavaScriptNode(@buffer_size, 0, @state.channels) # size, inputs, outputs
		
		deck = this
		@processor.onaudioprocess = (event) ->
			deck.get_samples(event)
		
		@rate = 1

		@state.bpm.add_listener(this, @update_bpm)
		@state.loaded.add_listener(this, @update_bpm)

		@zero_array = new Float32Array(@buffer_size)
		@beep_length = 882
		@beep_rate = 0.1
		@generate_beep()

		@looping = false
		@loop_start = 0
		@loop_end = 0

		@state.looping.add_listener(this, @update_loop)
		@state.loop_start.add_listener(this, @update_loop)
		@state.loop_length.add_listener(this, @update_loop)

		null

	generate_beep: ->
		@beep = new Float32Array(@beep_length)
		run_down_size = @beep_length
		while (--run_down_size >= 0)
			@beep[run_down_size] = Math.sin(run_down_size * @beep_rate)
		null

	interpolate: (input_channel, offset, alpha) ->
		x0 = input_channel[offset]
		x1 = input_channel[offset + 1]
		x2 = input_channel[offset + 2]
		x3 = input_channel[offset + 3]
		z = alpha - 0.5
		even1 = x2 + x1
		odd1 = x2 - x1
		even2 = x3 + x0
		odd2 = x3 - x0
		c0 = even1*0.32852206663814043 + even2*0.17147870380790242
		c1 = odd1*-0.35252373075274990 + odd2*0.45113687946292658
		c2 = even1*-0.240052062078895181 + even2*0.24004281672637814
		return ((c2*z+c1)*z+c0)

	connect: (output) ->
		@processor.connect()
		null

	update_bpm: (new_bpm) ->
		if @state.loaded.value
			@rate = (@state.bpm.value / @state.tune.bpm.value)
		null

	update_loop: ->
		if @state.sound_loaded.value and @state.looping.value
			unless @loop_start == @state.loop_start.value and @loop_end == @state.loop_end
				@state.update_looping_end()
				@loop_start = @state.loop_start.value
				@loop_end = @state.loop_end
				@looping = true
		else
			@looping = false

	process_loop_samples: (input_channels, output_channels) ->
		position = @state.position.value
		
		loop_length = @loop_end - @loop_start
		samples_to_loop_end = Math.floor((@loop_end - position) / @rate)
		samples_after_loop_start = @buffer_size - samples_to_loop_end

		if samples_to_loop_end > (@buffer_size * @rate)
			@process_samples(position, @buffer_size, input_channels, 0, output_channels)
			return position + (@buffer_size * @rate)
		else
			@process_samples(position, samples_to_loop_end, input_channels, 0, output_channels)
			if @loop_start < 0
				output_channels[0].set(@zero_array)
				output_channels[1].set(@zero_array)
			else
				@process_samples(@loop_start, samples_after_loop_start, input_channels, samples_to_loop_end, output_channels)
				# Fade out the end and fade in the start 20 samples
				if samples_to_loop_end > 20 and samples_after_loop_start > 20
					@fade_in(samples_to_loop_end, 20, output_channels)
					@fade_out(samples_to_loop_end, 20, output_channels)

			return @loop_start + (samples_after_loop_start * @rate)

	fade_in: (position, length, output_channels) ->
		end_left = output_channels[0][position + length]
		end_right = output_channels[0][position + length]

		step_left = end_left / length
		step_right = end_right / length

		value_left = 0.0
		value_right = 0.0
		i = 0
		while (++i <= length)
			output_channels[0][position + i] = value_left
			output_channels[1][position + i] = value_right
			value_left += step_left
			value_right += step_right

	fade_out: (position, length, output_channels) ->
		start_left = output_channels[0][position - length]	
		start_right = output_channels[1][position - length]	

		step_left = start_left / length
		step_right = start_right / length

		value_left = start_left
		value_right = start_right
		i = 0
		while (++i <= length)
			value_left -= step_left
			value_right -= step_right
			output_channels[0][position - i] = value_left
			output_channels[1][position - i] = value_right

	process_samples: (input_start, run_down_size, input_channels, output_start, output_channels) ->
		beeping = @state.beep.value
		if beeping
			beat = @state.get_beep_beat(input_start - @beep_length)
		while (--run_down_size >= 0)
			source_offset_float = input_start + (run_down_size * @rate)
			source_offset = Math.round(source_offset_float)
			destination_offset = output_start + run_down_size

			sample_l = input_channels[0][source_offset]
			sample_r = input_channels[1][source_offset]

			if beeping and source_offset >= beat and source_offset < (beat + @beep_length)
				output_channels[0][destination_offset] = (@beep[source_offset - beat] + sample_l) / 2
				output_channels[1][destination_offset] = (@beep[source_offset - beat] + sample_r) / 2
			else
				output_channels[0][destination_offset] = sample_l
				output_channels[1][destination_offset] = sample_r
		null

	get_samples: (event) ->
		output_channels = new Array(@state.channels)
		output_channels[0] = event.outputBuffer.getChannelData(0)
		output_channels[1] = event.outputBuffer.getChannelData(1)

		if @state.sound_loaded.value and @state.playing.value
			position = @state.position.value
			input_channels = new Array(@state.channels)
			input_channels[0] = @state.buffer.getChannelData(0)
			input_channels[1] = @state.buffer.getChannelData(1)

			# Dont sample beyond the end of input
			sampling_distance = @state.buffer_size
			end_position = (@buffer_size * @rate) + position
			edge_distance = @state.buffer.length - (end_position + 4)
			
			if position < 0
				# If we are below 0 position, play nothing and increase the position like normal
				output_channels[0].set(@zero_array)
				output_channels[1].set(@zero_array)
				@state.position.change_value(end_position)

			else if edge_distance <= 0
				# Stop playback if the end is reached
				@state.playing.change_value(false)
				output_channels[0].set(@zero_array)
				output_channels[1].set(@zero_array)
			# If the end of the sample will take is over the loop threshold - loop around!
			else if @looping and position < @loop_end and position > @loop_start
				new_position = @process_loop_samples(input_channels, output_channels)
				@state.position.change_value(new_position)
			else
				@process_samples(position, @buffer_size, input_channels, 0, output_channels)
				@state.position.change_value((@buffer_size * @rate) + position)
		else
			output_channels[0].set(@zero_array)
			output_channels[1].set(@zero_array)
		output_channels = null
		input_channels = null
		null