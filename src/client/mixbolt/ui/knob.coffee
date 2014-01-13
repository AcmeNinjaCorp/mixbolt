class @MixboltUiKnob
	constructor: (@container, @parameter) ->
		@options =
			middle_angle: 1.5
			radius: 17
			width: 5
			minimum: 0
			maximum: 100
			default_value: 50

		@graphic_context =  @container.getContext("2d")
		
		@container.width = @options.radius * 2
		@container.height = @options.radius * 2

		@x = $(@container).position().left
		@y = $(@container).position().top

		@draw()
		knob = this

		$(@container).bind("mousedown", @startDrag)
		$(@container).bind(
			'dblclick',
			->
				knob.change_value(knob.options.default_value)
		)
		$(@container).bind("mousewheel", @scroll)
		
		@parameter.add_listener(this, @draw)

	scroll: (e) =>
		if e.originalEvent.wheelDelta > 0
			@change_value(@parameter.value + 1)
		else
			@change_value(@parameter.value - 1)
	
	startDrag: (e) =>
		e.preventDefault()
		start_position = $(@container).position()
		start_x = e.pageX - start_position.left
		start_y = e.pageY - start_position.top
		start_value = @parameter.value

		$(document).bind(
			'mousemove.mixboltUiKnob',
			(e) =>
				local_offset = start_value  + (start_y - (e.pageY - start_position.top))
				@change_value(local_offset)
		).bind(
			'mouseup.mixboltUiKnob',
			() ->
				$(document).unbind('mousemove.mixboltUiKnob mouseup.mixboltUiKnob')
		)

	clear: ->
		# @container.width = @container.width
		@graphic_context.clearRect(0, 0, @container.width, @container.height)

	draw: ->
		@clear()
		center = Math.round(@container.width/2) + 0.5

		# Draw background
		# bg_gradient = @graphic_context.createLinearGradient(2, 2, @container.width - 2, @container.height - 2)
		# bg_gradient.addColorStop(0, 'rgba(255, 255, 255, 0.2)')
		# bg_gradient.addColorStop(1, 'rgba(0, 0, 0, 0.3)')
		# @graphic_context.fillStyle = bg_gradient
		# @graphic_context.beginPath()
		# @graphic_context.arc(@options.radius, @options.radius, @options.radius - 2, 0, 2 * Math.PI, false);
		# @graphic_context.fill()
		# @graphic_context.closePath()

		# Draw track
		@graphic_context.beginPath()
		@graphic_context.strokeStyle = style.button_background
		@graphic_context.lineWidth = @options.width
		@graphic_context.arc( @options.radius , @options.radius, @options.radius - @options.width, (@options.middle_angle - 0.75) * Math.PI, (@options.middle_angle + 0.75) * Math.PI, false)
		@graphic_context.stroke()
		@graphic_context.closePath()

		# Draw shadow
		@graphic_context.beginPath()
		shadow_gradient = @graphic_context.createLinearGradient(2, 2, @container.width - 4, @container.height - 4)
		shadow_gradient.addColorStop(0.5, 'rgba(0, 0, 0, 0.5)')
		shadow_gradient.addColorStop(1, 'rgba(255, 255, 255, 0.2)')
		@graphic_context.strokeStyle = shadow_gradient
		@graphic_context.lineWidth = 1
		@graphic_context.arc( @options.radius , @options.radius, @options.radius - 2 , 0, 2 * Math.PI, false)
		@graphic_context.stroke()
		@graphic_context.closePath()

		# Draw highlight
		@graphic_context.beginPath()
		@graphic_context.arc( @options.radius , @options.radius, @options.radius - 8 , 0, 2 * Math.PI, false)

		handle_gradient = @graphic_context.createLinearGradient(8, 8, @container.width - 8, @container.height - 8)
		handle_gradient.addColorStop(0, 'rgba(255, 255, 255, 0.2)')
		handle_gradient.addColorStop(1, 'rgba(0, 0, 0, 0.1)')
		@graphic_context.fillStyle = handle_gradient
		@graphic_context.fill()
		
		highlight_gradient = @graphic_context.createLinearGradient(8, 8, @container.width - 8, @container.height - 8)
		highlight_gradient.addColorStop(0, 'rgba(255, 255, 255, 0.5)')
		highlight_gradient.addColorStop(1, 'rgba(0, 0, 0, 0.2)')
		@graphic_context.strokeStyle = highlight_gradient
		@graphic_context.lineWidth = 1
		@graphic_context.stroke()
		@graphic_context.closePath()

		position = ((@options.middle_angle - 0.75) * Math.PI) + @normalized_value() * (((@options.middle_angle + 0.75) * Math.PI)-((@options.middle_angle - 0.75) * Math.PI))

		# Draw recticle
		@graphic_context.strokeStyle = style.button_foreground
		@graphic_context.lineWidth = @options.width
		@graphic_context.beginPath()
		@graphic_context.arc(@options.radius , @options.radius, @options.radius - @options.width, (@options.middle_angle - 0.75) * Math.PI, position, false)
		@graphic_context.stroke()
		@graphic_context.closePath()

	normalized_value: =>
		@parameter.value / (@options.maximum - @options.minimum)

	change_value: (new_value) =>
		# Round and clip value
		proposed_value = Math.round(Math.max(Math.min(new_value, @options.maximum), @options.minimum))
		@parameter.change_value(proposed_value)