class @MixboltUiSlider
	constructor: (@container, options) ->
		defaults =
			width: 120
			height: 30
			minimum: 0
			maximum: 100
			default_value: 50
			snapping: true
			on_change:  ->
		
		@options = $.extend {}, defaults, options

		@value = @options.default_value
		@graphic_context =  @container.getContext("2d")
		
		@container.width = @options.width
		@container.height = @options.height

		@draw()
		$(@container).bind("mousedown", @startDrag)
		$(@container).bind("dblclick", @resetPosition)
		$(@container).bind("mousewheel", @scroll)


	resetPosition: =>
		@change_value(@options.default_value)
	
	startDrag: (e) =>
		e.preventDefault()
		start_position = $(@container).offset()

		$(document).bind(
			'mousemove.mixboltUiSlider',
			(e) =>
				local_offset = (e.pageX - start_position.left) / (@options.width - 0.5)
				@change_value((@options.maximum - @options.minimum) * local_offset)
		).bind(
			'mouseup.mixboltUiSlider',
			() ->
				$(document).unbind('mousemove.mixboltUiSlider mouseup.mixboltUiSlider')
		)
		
	scroll: (e) =>
		if e.originalEvent.wheelDelta > 0
			@change_value(@value + 1)
		else
			@change_value(@value - 1)

	clear: ->
		# @container.width = @container.width
		@graphic_context.clearRect(0, 0, @container.width, @container.height)

	draw: ->
		@clear()
		center = Math.round(@container.width/2) + 0.5
		half_height = Math.round(@options.height / 2)
		# Draw track
		@graphic_context.fillStyle = style.track_style
		@graphic_context.fillRect(0, half_height - 2.5, @options.width, 4.5)
		# Draw shadow stroke
		@graphic_context.beginPath()
		@graphic_context.moveTo(0, half_height - 2.5)
		@graphic_context.lineTo(@options.width, half_height - 2.5)
		@graphic_context.strokeStyle = 'rgba(0,0,0,0.3)'
		@graphic_context.stroke()
		@graphic_context.closePath()
		# Draw highlight stroke
		@graphic_context.beginPath()
		@graphic_context.moveTo(0, half_height + 2.5)
		@graphic_context.lineTo(@options.width, half_height + 2.5)
		@graphic_context.strokeStyle = 'rgba(255,255,255,0.1)'
		@graphic_context.stroke()
		@graphic_context.closePath()
		# Draw center line
		@graphic_context.beginPath()
		@graphic_context.moveTo(center, 0)
		@graphic_context.lineTo(center, @options.height)
		@graphic_context.strokeStyle = style.button_foreground
		@graphic_context.stroke()
		@graphic_context.closePath()
		# Draw handle as 2 halfs
		@graphic_context.fillStyle = style.button_background
		position = ((@value / (@options.maximum - @options.minimum)) * (@options.width - 20)) + 0.5
		@graphic_context.fillRect(position, 0, 9.5, @options.height)
		@graphic_context.fillRect(position + 10.5, 0, 9.5, @options.height)
		# Draw recticle on the handle
		@graphic_context.beginPath()
		@graphic_context.moveTo(position + 10, 0)
		@graphic_context.lineTo(position + 10, @options.height / 4)
		
		@graphic_context.moveTo(position + 10, (@options.height / 4) * 3)
		@graphic_context.lineTo(position + 10, @options.height)
		@graphic_context.closePath()
		@graphic_context.strokeStyle = style.button_foreground
		@graphic_context.stroke()

		border = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		border.addColorStop(0, 'rgba(255,255,255,0.2)')
		border.addColorStop(0.5, 'rgba(0,0,0,0.2)')
		@graphic_context.beginPath()
		@graphic_context.rect(position, 0.5, 20, @options.height - 1)
		@graphic_context.closePath()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = border
		@graphic_context.stroke()
		

	change_value: (new_value) =>
		# Clip value
		if new_value > @options.maximum
			new_value = @options.maximum
		if new_value < @options.minimum
			new_value = @options.minimum
		# Round value
		proposed_value = Math.round(new_value)
		# Only fire things up if value has changed
		if proposed_value != @value
			@value = proposed_value
			@draw()
			@options.on_change(@value)