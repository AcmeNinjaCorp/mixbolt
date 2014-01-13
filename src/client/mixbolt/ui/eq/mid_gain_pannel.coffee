class @MixboltUiEqGainMidPannel
	constructor: (@container) ->
		@options =
			width: 46
			height: 50
			label_style: 'rgba(0,0,0,0.4)'
			label_font: style.label_font

		@graphic_context =  @container.getContext("2d")
		
		@container.width = @options.width
		@container.height = @options.height

		@draw()

	clear: ->
		@graphic_context.clearRect(0, 0, @container.width, @container.height)

	draw: =>
		@clear()

		@graphic_context.font = @options.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = style.dial_foreground
		
		@graphic_context.shadowColor = 'rgba(128,128,128,0.2)'
		@graphic_context.shadowOffsetX = 0.5;
		@graphic_context.shadowOffsetY = 0.5;
		@graphic_context.shadowBlur = 0;

		# Draw gain label
		@graphic_context.fillText('- Gain -', @options.width/2, 25)