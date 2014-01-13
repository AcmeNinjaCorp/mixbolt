#_require ../button.coffee

class @MixboltUiButtonSync extends MixboltUiButton
	constructor: (@container, @state) ->
		$(@container).bind("contextmenu", @change_sync_start)
		super(@container, 70, 30)
	
	click: (e) =>
		e.preventDefault()
		@state.sync()

	change_sync_start: =>
		if @state.synced_start.value
			@state.synced_start.change_value(false)
		else
			@state.synced_start.change_value(true)
		@draw()
		false

	draw: ->
		if @state.synced_start.value
			@alternate = true
			label = 'AutoSync'
		else
			@alternate = false
			label = 'Sync'
		super()

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		@graphic_context.fillText(label, @width/2, @height/2)