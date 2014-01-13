class @MixboltUiButton
	constructor: (@container, @width, @height) ->
		@hovering = false

		@graphic_context =  @container.getContext("2d")
		
		@container.width = @width
		@container.height = @height

		@draw()
		button = this
		$(@container).bind("click", @click)
		$(@container).bind("mouseover",	->
			button.hovering = true
			button.draw()		
		)
		$(@container).bind("mouseout", ->
			button.hovering = false
			button.draw()
		)

	draw: ->
		@graphic_context.clearRect(0, 0, @width, @height)
		# Draw background
		@background = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		if @hovering
			@background.addColorStop(0, style.adjust(style.button_active_background, 20))
			@background.addColorStop(0.5, style.button_active_background)
			@foreground = style.button_active_foreground
		else if @alternate
			@background.addColorStop(1, style.adjust(style.button_alternate_background, 50))
			@background.addColorStop(0.5, style.button_alternate_background)
			@foreground = style.button_foreground
		else
			@background.addColorStop(0, style.adjust(style.button_background, 20))
			@background.addColorStop(0.5, style.button_background)
			@foreground = style.button_foreground

		@border = @graphic_context.createLinearGradient(0, 0, 0, @container.height)
		@border.addColorStop(0, 'rgba(255,255,255,0.2)')
		@border.addColorStop(0.5, 'rgba(0,0,0,0.2)')
		@graphic_context.beginPath()
		@graphic_context.rect(1.5, 1.5, @width - 3, @height - 3)
		@graphic_context.closePath()
		@graphic_context.fillStyle = @background
		@graphic_context.fill()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = @border
		@graphic_context.stroke()

		@graphic_context.beginPath()
		@graphic_context.rect(0.5, 0.5, @width - 1, @height - 1)
		@graphic_context.closePath()
		@graphic_context.lineWidth = 1
		@graphic_context.strokeStyle = 'rgba(0,0,0,0.3)'
		@graphic_context.stroke()
