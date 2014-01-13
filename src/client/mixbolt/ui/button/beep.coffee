#_require ../button.coffee

class @MixboltUiButtonBeep extends MixboltUiButton
	constructor: (@container, @state) ->
		@state.beep.add_listener(this, @draw)
		super(@container, 40, 30)
	
	click: (e) =>
		e.preventDefault()
		if @state.beep.value
			@state.beep.change_value(false)
		else
			@state.beep.change_value(true)
		@draw()
		false

	draw: ->
		@alternate =  @state.beep.value
		super()

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		@graphic_context.fillText('Beep', @width/2, @height/2)