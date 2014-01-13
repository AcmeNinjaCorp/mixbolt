class @MixboltUiDial
	constructor: (@container) ->
		@graphic_context =  @container.getContext("2d")
		@horizontal_center = @container.width / 2
		@vertical_center = @container.height / 2

		@draw()

		dial = this
		$(@container).bind("mousedown", @startDrag)
		$(@container).bind(
			"mouseover",
			->
				dial.hovering = true
				dial.draw()		
		)
		$(@container).bind(
			"mouseout",
			->
				dial.hovering = false
				dial.draw()
		)
		$(@container).bind("mousewheel", @scroll)

	clear: ->
		@graphic_context.clearRect(0, 0, @container.width, @container.height)

	draw: ->
		@clear()
		# Draw background
		@background = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		if @hovering
			@background.addColorStop(1, style.adjust(style.button_active_background, 20))
			@background.addColorStop(0.5, style.button_active_background)
			@foreground = style.button_active_foreground
		else
			@background.addColorStop(1, style.adjust(style.button_background, 20))
			@background.addColorStop(0.5, style.button_background)
			@foreground = style.button_foreground

		@border = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		@border.addColorStop(1, 'rgba(255,255,255,0.2)')
		@border.addColorStop(0.5, 'rgba(0,0,0,0.2)')
		@graphic_context.beginPath()
		@graphic_context.rect(0.5, 0.5, @container.width - 1, @container.height - 1)
		@graphic_context.closePath()
		@graphic_context.fillStyle = @background
		@graphic_context.fill()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = @border
		@graphic_context.stroke()

		@graphic_context.beginPath()
		@graphic_context.rect(1.5, 1.5, @container.width - 3, @container.height - 3)
		@graphic_context.closePath()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = 'rgba(0,0,0,0.3)'
		@graphic_context.stroke()

