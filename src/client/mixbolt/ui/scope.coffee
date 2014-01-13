class @MixboltUiScope
	constructor: (@container, @state) ->
		@options =
			width: 390
			height: 80
			background_style: 'rgba(0,0,0,1)'
			label_font: style.label_font
			default_value: 0

		@graphic_context =  @container.getContext("2d")
		@graphic_context.webkitImageSmoothingEnabled = true
		@graphic_context.mozImageSmoothingEnabled = true
		@graphic_context.imageSmoothingEnabled = true
		
		@container.width = @options.width
		@container.height = @options.height

		@center = Math.round(@container.width / 2) + 0.5

		@image = new Image()
		@image_loaded = false

		@rotations_since_started = 1
		@sample_rate = @state.audio_context.sampleRate

		@draw()

		$(@container).bind("click", @snap)

	update_width: (width) =>
		@options.width = width
		@container.width = width
		@center = Math.round(width / 2) + 0.5
	
	samples_to_pixels: (position_value) ->
		position_in_seconds = position_value / @sample_rate
		position_in_pixels = position_in_seconds * 20

	pixels_to_samples: (pixel_value) ->
		position_in_seconds = pixel_value / 20
		position_in_samples = position_in_seconds * @sample_rate
	
	calculate_nearest_beat: (pixel_position) ->
		if @state.loaded.value
			# Assuming first beat value is in seconds
			first_beat_in_samples = @state.tune.first_beat.value * @sample_rate
			sample_position = @pixels_to_samples(pixel_position - @center)
			global_sample_position = @state.position.value + sample_position
			offset_sample_position = global_sample_position - first_beat_in_samples
			spacing_in_samples = (60 / @state.tune.bpm.value) * @sample_rate * 4
			@nearest_beat = Math.round(offset_sample_position / spacing_in_samples)
			@nearest_beat_position = (@nearest_beat * spacing_in_samples) + first_beat_in_samples
	
	snap: (e) =>
		e.preventDefault()
		@cursor_x = e.offsetX - 5
		@calculate_nearest_beat(@cursor_x)
		@state.position.change_value(@nearest_beat_position)
		@state.sync()
		return false

	get_spacing: ->
		(1200 / @state.tune.bpm.value) * 4

	draw: ->
		width = @container.width
		height = @container.height
		@graphic_context.clearRect(0, 0, width, height)

		bg_gradient = @graphic_context.createLinearGradient(0, 0, 0, height)
		bg_gradient.addColorStop(0.5, 'rgba(0, 0, 0, 0.6)')
		bg_gradient.addColorStop(1, 'rgba(0, 0, 0, 0.2)')

		@graphic_context.fillStyle = bg_gradient
		@graphic_context.fillRect(0, 0, width, height)

		# If we have stuff loaded on the deck
		if @state.loaded.value
			local_position = ~~(@samples_to_pixels(@state.position.value))
			bitmap_offset = @center - local_position
			spacing = @get_spacing()

			# Draw waveform
			if @state.image_loaded.value
				@graphic_context.drawImage(@state.canvas, bitmap_offset, 0)

			# Draw looping region
			if @state.looping.value
				loop_start = bitmap_offset + @samples_to_pixels(@state.loop_start.value)
				loop_end = @samples_to_pixels(@state.loop_end - @state.loop_start.value)
				@graphic_context.fillStyle = 'rgba(190,214,48,0.3)'
				@graphic_context.fillRect(loop_start, 0, loop_end, height)

			first_beat = @samples_to_pixels(@state.tune.first_beat.value * @sample_rate)
			
			first_marker = (@center - local_position + first_beat) % spacing
			last_marker = width - first_marker + spacing
			beat_count_unclean = ((local_position - first_beat) - @center) / spacing

			if beat_count_unclean < 0
				beat_count = Math.ceil(beat_count_unclean) 
			else
				beat_count = Math.floor(beat_count_unclean)

			for x in [first_marker..last_marker] by spacing
				@graphic_context.beginPath()
				@graphic_context.moveTo(x, 0)
				@graphic_context.lineTo(x, height)
				if (beat_count != 0)
					# Draw 1/4 beat
					@graphic_context.strokeStyle = 'rgba(255,202,5,0.2)'
					@graphic_context.closePath()
					@graphic_context.stroke()
				else
					# Draw first beat
					@graphic_context.strokeStyle = 'rgba(255,255,255,1)'
					@graphic_context.closePath()
					@graphic_context.stroke()
					# Draw a little flag
					@graphic_context.fillStyle = 'rgba(255,255,255,1)'
					@graphic_context.beginPath()
					@graphic_context.moveTo(x, 0)
					@graphic_context.lineTo(x+4.5, 4.5)
					@graphic_context.lineTo(x, 9)
					@graphic_context.closePath()
					@graphic_context.fill()
					

				beat_count++

			# Draw center line
			@graphic_context.beginPath()
			@graphic_context.moveTo(@center, 10)
			@graphic_context.lineTo(@center, height - 10)
			@graphic_context.closePath()
			@graphic_context.strokeStyle = 'rgba(240,90,35,1)'
			@graphic_context.stroke()

		else if @state.loading.value
			@graphic_context.translate(@center, height / 2)
			@graphic_context.strokeStyle = "rgba(255,255,255,0.05)"
			@graphic_context.lineWidth = 5
			@graphic_context.beginPath()
			@graphic_context.arc(0,0,35,0,Math.PI*2,true)
			@graphic_context.closePath()
			@graphic_context.stroke()
			rotation = (@rotations_since_started / 100)
			@graphic_context.rotate(rotation)
			for i in [0..2]
				@graphic_context.rotate(Math.PI * 2 / 3)
				@graphic_context.beginPath()
				@graphic_context.moveTo(20, 0)
				@graphic_context.lineTo(32, 0)
				@graphic_context.closePath()
				@graphic_context.stroke()
			@rotations_since_started++
			@graphic_context.setTransform(1, 0, 0, 1, 0, 0)

			@graphic_context.font = @options.label_font
			@graphic_context.textAlign = 'center'
			@graphic_context.textBaseline = 'middle'
			@graphic_context.fillStyle = style.button_foreground
			@graphic_context.fillText("Processing", @center, height / 2)
			@graphic_context.lineWidth = 1
		else
			@graphic_context.font = @options.label_font
			@graphic_context.textAlign = 'center'
			@graphic_context.textBaseline = 'middle'
			@graphic_context.fillStyle = style.button_foreground
			@graphic_context.fillText("Drop an audio file here to start", @center, height / 2)
		
		# Draw shadow stroke
		@graphic_context.beginPath()
		@graphic_context.moveTo(0, 0)
		@graphic_context.lineTo(width, 0)
		@graphic_context.strokeStyle = 'rgba(0,0,0,0.3)'
		@graphic_context.stroke()
		@graphic_context.closePath()
		# Draw highlight stroke
		@graphic_context.beginPath()
		@graphic_context.moveTo(0, height - 0.5)
		@graphic_context.lineTo(width, height - 0.5)
		@graphic_context.strokeStyle = 'rgba(255,255,255,0.2)'
		@graphic_context.stroke()
		@graphic_context.closePath()
		null

	param_updated: (new_value) =>
		@draw()
