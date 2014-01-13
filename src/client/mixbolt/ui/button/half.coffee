#_require ../button.coffee

class @MixboltUiButtonHalf extends MixboltUiButton
	constructor: (@container, @state) ->
		super(@container, 15, 15)
	
	click: (e) =>
		e.preventDefault()
		if @state.loaded.value
			@state.tune.bpm.change_value(@state.tune.bpm.value / 2)

	draw: ->
		super()
		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		@graphic_context.fillText('/2', @width/2, @height/2)