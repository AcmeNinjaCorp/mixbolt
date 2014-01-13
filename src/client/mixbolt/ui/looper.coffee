class @MixboltUiLooper
	constructor: (@container, @state) ->
		@options =
			width: 278
			height: 30
		
		@graphic_context =  @container.getContext("2d")
		@container.width = @options.width
		@container.height = @options.height
		@offset = $(@container).css("margin-left").replace("px", "")
		@buttons = [
			{x: 0, y:0, label:'<', value: 'back'},
			{x: 31, y:0, label:'1/4', value: 0.25},
			{x: 62, y:0, label:'1/2', value: 0.5},
			{x: 93, y:0, label:'1', value: 1},
			{x: 124, y:0, label:'2', value: 2},
			{x: 155, y:0, label:'4', value: 4},
			{x: 186, y:0, label:'8', value: 8},
			{x: 217, y:0, label:'16', value: 16},
			{x: 248, y:0, label:'>', value: 'forward'}
		]
		@draw()
		$(@container).bind("mousedown", @click)
		$(@container).bind("mouseover mousemove", @hover)
		$(@container).bind("mouseout", @hover_end)

	clear: ->
		@graphic_context.clearRect(0, 0, @container.width, @container.height)

	click: (e) =>
		e.preventDefault()
		button_key = @get_current_button(e)
		button = @buttons[button_key]
		if button.value == 'forward'
			@state.move_loop_forward()
		else if button.value == 'back'
			@state.move_loop_back()
		else
			@state.start_loop(button.value)
		

	hover: (e) =>
		@hovering = true
		@current_button = @get_current_button(e)
		@draw()
	
	get_current_button: (mouse_event) ->
		cursor_x = mouse_event.offsetX
		for button, key in @buttons
			if cursor_x >= button.x and cursor_x <= button.x + 31
				return key

	hover_end: (e) =>
		@hovering = false
		@draw()

	draw: ->
		@clear()
		for button, key in @buttons
			if @hovering and @current_button == key
				@draw_button(button.label, button.x, button.y, style.button_active_background)
			else if @state.looping.value and @state.loop_length.value == button.value
				@draw_button(button.label, button.x, button.y, style.button_active_background)
			else
				@draw_button(button.label, button.x, button.y, style.button_background)
		
	draw_button: (label, x, y, background) ->
		background_gradient = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		background_gradient.addColorStop(0, style.adjust(background, 20))
		background_gradient.addColorStop(0.5, background)

		border = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		border.addColorStop(0, 'rgba(255,255,255,0.2)')
		border.addColorStop(0.5, 'rgba(0,0,0,0.2)')
		# Draw bg
		@graphic_context.fillStyle = background_gradient
		@graphic_context.beginPath()
		@graphic_context.rect(x + 1.5, y + 1.5, 27, 27)
		@graphic_context.closePath()
		@graphic_context.fillStyle = background_gradient
		@graphic_context.fill()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = border
		@graphic_context.stroke()

		@graphic_context.beginPath()
		@graphic_context.rect(x + 0.5, y + 0.5, 29, 29)
		@graphic_context.closePath()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = 'rgba(0,0,0,0.3)'
		@graphic_context.stroke()

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = style.button_foreground
		@graphic_context.fillText(label, x+15, y+15)