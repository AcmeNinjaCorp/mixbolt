#_require ../button.coffee

class @MixboltUiButtonControls extends MixboltUiButton
	constructor: (@container, @param) ->
		@param.add_listener(this, @draw)
		super(container, 20, 20)
	
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
			@graphic_context.moveTo(5,15)
			@graphic_context.lineTo(10,5)
			@graphic_context.lineTo(15,15)
			@graphic_context.closePath()
			@graphic_context.fill()
		else
			@graphic_context.beginPath()
			@graphic_context.moveTo(5,5)
			@graphic_context.lineTo(10,15)
			@graphic_context.lineTo(15,5)
			@graphic_context.closePath()
			@graphic_context.fill()