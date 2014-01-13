#_require ../button.coffee

class @MixboltUiButtonSave extends MixboltUiButton
	constructor: (@container, @state) ->
		super(@container, 50, 30)
		@state.loaded.add_listener(this, @draw)
	
	click: (e) =>
		e.preventDefault()
		if @state.loaded.value
			@state.tune.save()

	draw: ->
		super()

		if @state.loaded.value
			label = 'Save'
		else
			label = '--'

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		@graphic_context.fillText(label, @width/2, @height/2)