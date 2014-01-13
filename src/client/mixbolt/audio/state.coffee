#_require ../parameter.coffee

class @MixboltAudioState
	constructor: (@audio_context) ->
		@buffer_size = 2048
		@channels = 2
		
		# Position in audio buffer, in samples
		@position = new MixboltParameter(0)

		# Deck's bpm, used to calculate the playback rate
		@bpm = new MixboltParameter(100)
		
		# Looping parameters
		@looping = new MixboltParameter(false)
		@loop_start = new MixboltParameter(0)
		@loop_end = 0
		@loop_length = new MixboltParameter(8)

		# Playing?
		@playing = new MixboltParameter(false)

		# Synced start?
		@synced_start = new MixboltParameter(true)

		# Metronome type thing
		@beep = new MixboltParameter(false)

		# Samples per beat
		@spb = 0

		# Image
		@image_loaded = new MixboltParameter(false)
		@canvas = document.createElement("canvas")
		@canvas.height = 80
		@image = @canvas.getContext("2d")

		# Sound
		@sound_loaded = new MixboltParameter(false)
		@buffer = null

		# Are we loading?
		@loading = new MixboltParameter(false)
		@loaded = new MixboltParameter(false)
		@image_loaded.add_listener(this, @finished_loading)
		@sound_loaded.add_listener(this, @generate_image)
		@sound_loaded.add_listener(this, @finished_loading)

		@tune = null

		@looping.add_listener(this, @update_looping_end)
		@loop_start.add_listener(this, @update_looping_end)
		@loop_length.add_listener(this, @update_looping_end)
		
		@playing.add_listener(this, @play)

	set_other_state: (state) ->
		@other_state = state
		@other_state.bpm.add_listener(this, @check_sync)

	check_sync: ->
		if @synced_start.value and @playing.value and @other_state.playing.value
			@bpm.change_value(@other_state.bpm.value)
	
	play: ->
		if @synced_start.value and @playing.value and @other_state.playing.value
			@sync()

	load: (file) ->
		@unload()
		@tune = new MixboltModelTune(file)
		@loading.change_value(true)
		state = this
		tune = @tune
		@tune.loaded.add_listener(this, ->
			state.decode_file(tune.buffer)
			tune.bpm.add_listener(state, state.beatgrid_update)
			tune.first_beat.add_listener(state, state.get_first_beat)
		)

	unload: () ->
		@playing.change_value(false)
		@looping.change_value(false)
		@position.change_value(0)
		@beep.change_value(false)

		@loaded.change_value(false)

		if @tune
			@tune.bpm.remove_listener(this, @beatgrid_update)
			@tune.first_beat.remove_listener(this, @get_first_beat)

		@buffer = null

		@image_loaded.change_value(false)
		@sound_loaded.change_value(false)
		@loading.change_value(false)

	beatgrid_update: ->
		@get_spb()
		@get_first_beat()
		unless @other_state.playing.value
			@bpm.change_value(@tune.bpm.value)

	finished_loading: () ->
		if @image_loaded.value and @sound_loaded.value
			@loading.change_value(false)
			@loaded.change_value(true)
			@beatgrid_update()
			unless @other_state.playing.value
				@bpm.change_value(@tune.bpm.value)
		else
			@loading.change_value(true)

	decode_file: (data) ->
		state = this
		window.audio_context.decodeAudioData(data, (buffer) ->
			state.buffer = buffer
			state.sound_loaded.change_value(true)
		)

	get_rms: (data) ->
		sum = 0.0
		value = 0.0
		length = data.length
		i = 0
		while (++i < length)
			value = Math.abs(data[i])
			sum = sum + (value * value)
		return Math.sqrt(sum / length)
	
	generate_image: (v) ->
		return unless v
		pixels_per_minute = 1200
		samples_per_pixel = Math.floor((@audio_context.sampleRate * 60) / pixels_per_minute)
		pixels_in_file = Math.floor(@buffer.length / samples_per_pixel)
		@canvas.width = pixels_in_file

		left_channel = @buffer.getChannelData(0)
		right_channel = @buffer.getChannelData(1)

		left_values = []
		left_max = 0.0
		right_values = []
		right_max = 0.0
		i = 0
		while (++i < pixels_in_file)
			offset = i * samples_per_pixel
			left_value = @get_rms(left_channel.subarray(offset, offset + samples_per_pixel))
			left_max = left_value if left_value > left_max
			left_values.push(left_value)

			right_value = @get_rms(right_channel.subarray(offset, offset + samples_per_pixel))
			right_max = right_value if right_value > right_max
			right_values.push(right_value)
		
		half_height = @canvas.height / 2
		left_scale = half_height / left_max
		right_scale = half_height / right_max

		@image.lineWidth = 1
		@image.strokeStyle = '#0080FF'

		i = 0
		while (++i < pixels_in_file)
			left_value = left_values[i] * left_scale
			right_value = right_values[i] * right_scale
			
			@image.beginPath()
			@image.moveTo(i, half_height - left_value)
			@image.lineTo(i, half_height + right_value)
			@image.stroke()
			@image.closePath()

		@image_loaded.change_value(true)

		

	get_closest_beat: (position, offset) ->
		offset_position = position - @first_beat_in_samples
		
		nearest_beat = offset_position / @spb
		previous_beat = Math.floor(nearest_beat)
		next_beat = Math.ceil(nearest_beat)

		threshold = .01;

		if Math.abs(next_beat - nearest_beat) < threshold
			nearest_beat = next_beat
		else if Math.abs(previous_beat - nearest_beat) < threshold
			nearest_beat = previous_beat

		if offset > 0
			closest_beat = Math.ceil(nearest_beat) * @spb + @first_beat_in_samples
			offset = offset - 1
		else
			closest_beat = Math.floor(nearest_beat) * @spb + @first_beat_in_samples
			offset = offset + 1

		Math.round(closest_beat + offset * @spb)
	
	start_loop: (length_in_beats) ->
		if @looping.value and (@loop_length.value == length_in_beats)
			@looping.change_value(false)
		else if @looping.value and (@loop_length.value != length_in_beats)
			@loop_length.change_value(length_in_beats)
		else
			@loop_start.change_value(@get_current_beat())
			@loop_length.change_value(length_in_beats)
			@looping.change_value(true)

	move_loop_forward: ->
		if (@position.value > @loop_start.value) and (@position.value < @loop_end)
			loop_distance = @position.value - @loop_start.value

		@loop_start.change_value(@loop_end)

		if loop_distance
			@position.change_value(@loop_start.value + loop_distance)
	
	move_loop_back: ->
		if (@position.value > @loop_start.value) and (@position.value < @loop_end)
			loop_distance = @position.value - @loop_start.value

		@loop_start.change_value(@loop_start.value - (@spb  * @loop_length.value))

		if loop_distance
			@position.change_value(@loop_start.value + loop_distance)
	
	update_looping_end: () ->
		@loop_end = ~~(@loop_start.value + (@spb  * @loop_length.value))

	get_first_beat: () ->
		@first_beat_in_samples = @tune.first_beat.value * @audio_context.sampleRate

	# Samples per beat
	get_spb: () ->
		@spb = (60 / @tune.bpm.value) * @audio_context.sampleRate * 4

	# Nearest beat position
	get_nearest_beat: () ->
		@get_closest_beat(@position.value, 1)
	
	get_current_beat: () ->
		@get_closest_beat(@position.value, -1)

	get_beep_beat: (position) ->
		offset_position = position - @first_beat_in_samples
		beep_spb = @spb / 4
		beep_beat = Math.round(Math.round(offset_position / beep_spb) * beep_spb + @first_beat_in_samples)
		return beep_beat

	sync: ->
		if @loaded.value and @playing.value and @other_state.playing.value
			@bpm.change_value(@other_state.bpm.value)
			
			local_previous_beat = @get_closest_beat(@position.value, -1)
			local_next_beat = @get_closest_beat(@position.value, 1)
			if local_previous_beat == local_next_beat
				local_next_beat = @get_closest_beat(@position.value, 2)

			other_previous_beat = @other_state.get_closest_beat(@other_state.position.value, -1)
			other_next_beat = @other_state.get_closest_beat(@other_state.position.value, 1)
			if other_previous_beat == other_next_beat
				other_next_beat = @other_state.get_closest_beat(@other_state.position.value, 2)

			local_beat_distance = Math.abs(local_next_beat - local_previous_beat)
			other_beat_distance = Math.abs(other_next_beat - other_previous_beat)
			other_beat_fraction = (@other_state.position.value - other_previous_beat) / other_beat_distance

			local_near_next = local_next_beat - @position.value <= @position.value - local_previous_beat
			other_near_next = other_next_beat - @other_state.position.value <= @other_state.position.value - other_previous_beat

			if local_near_next == other_near_next
					corrected_position = local_previous_beat + other_beat_fraction * local_beat_distance
			else if local_near_next and not other_near_next
					corrected_position = local_next_beat + other_beat_fraction * local_beat_distance
			else
					local_previous_beat = @get_closest_beat(@position.value, -2)
					corrected_position = local_previous_beat + other_beat_fraction * local_beat_distance
			@position.change_value(corrected_position)