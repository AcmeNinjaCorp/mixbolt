class @MixboltUiPosition
	constructor: (@container, @state) ->
		@options =
			width: 390
			height: 10
		
		@graphic_context =  @container.getContext("2d")
		@container.width = @options.width
		@container.height = @options.height
		
		@draw()

		$(@container).bind("mousedown", @click)
	
	update_width: (width) =>
		@options.width = width
		@container.width = @options.width
		@draw()

	click: (e) =>
		e.preventDefault()
		if @state.loaded.value
			offset = (e.offsetX - 5) / @options.width
			offset = Math.min(offset, 1)
			offset = Math.max(offset, 0)
			@state.position.change_value(@state.buffer.length * offset)
			@state.sync()

	draw: ->
		width = @container.width
		height = @container.height
		
		@graphic_context.clearRect(0, 0, width, height)
		@graphic_context.fillStyle = style.button_background
		@graphic_context.fillRect(0, 0, width, height)

		if @state.loaded.value
			progress_width = width * (@state.position.value / @state.buffer.length)
			@graphic_context.fillStyle = style.button_foreground
			@graphic_context.fillRect(0, 0, progress_width, height)

		# Draw shadow stroke
		@graphic_context.beginPath()
		@graphic_context.moveTo(0, 0.5)
		@graphic_context.lineTo(width, 0.5)
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