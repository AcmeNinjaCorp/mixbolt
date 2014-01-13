#_require ../button.coffee

class @MixboltUiButtonPlay extends MixboltUiButton
	constructor: (@container, @param) ->
		super(@container, 60, 30)
		@param.add_listener(this, @draw)
	
	click: (e) =>
		e.preventDefault()
		if @param.value
			@param.change_value(false)
		else
			@param.change_value(true)

	draw: ->
		super()

		# Draw graphic
		@graphic_context.fillStyle = @foreground
		if @param.value
			@graphic_context.beginPath()
			@graphic_context.moveTo(20,7)
			@graphic_context.lineTo(28,7)
			@graphic_context.lineTo(28,23)
			@graphic_context.lineTo(20,23)
			@graphic_context.closePath()
			@graphic_context.fill()

			@graphic_context.beginPath()
			@graphic_context.moveTo(32,7)
			@graphic_context.lineTo(40,7)
			@graphic_context.lineTo(40,23)
			@graphic_context.lineTo(32,23)
			@graphic_context.closePath()
			@graphic_context.fill()
		else
			@graphic_context.beginPath()
			@graphic_context.moveTo(20,7)
			@graphic_context.lineTo(40,15)
			@graphic_context.lineTo(20,23)
			@graphic_context.closePath()
			@graphic_context.fill()