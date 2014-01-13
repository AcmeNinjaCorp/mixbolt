#_require ../dial.coffee

class @MixboltUiDialBpm extends MixboltUiDial
	constructor: (@container, @state) ->
		@container.width = 60
		@container.height = 30
		
		super(@container)
		@state.loaded.add_listener(this, @check_attachment)
		$(@container).bind('dblclick', @reset)

	check_attachment: =>
		if @state.loaded.value
			@draw()
			@state.tune.bpm.add_listener(this, @draw)
		else
			@state.tune.bpm.remove_listener(this, @draw)
	
	reset: =>
		if @state.loaded.value
			@state.tune.bpm.change_value(@state.tune.original_bpm)
	
	scroll: (e) =>
		if @state.loaded.value
			if e.originalEvent.wheelDelta > 0
				@change_value(@state.tune.bpm.value - 0.1)
			else
				@change_value(@state.tune.bpm.value + 0.1)

	startDrag: (e) =>
		e.preventDefault()
		start_position = $(@container).position()
		start_x = e.pageX - start_position.left
		start_y = e.pageY - start_position.top
		if @state.loaded.value
			start_value = @state.tune.bpm.value
		else
			start_value = 0


		$(document).bind(
			'mousemove.MixboltUiBpm',
			(e) =>
				change = ((start_y - (e.pageY - start_position.top)) / 1000)
				@change_value(start_value - change)
		).bind(
			'mouseup.MixboltUiBpm',
			() ->
				$(document).unbind('mousemove.MixboltUiBpm mouseup.MixboltUiBpm')
		)

	draw: ->
		super()

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'center'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		if @state.loaded.value
			label = (Math.floor(@state.tune.bpm.value * 1000) / 1000).toFixed(3)
		else
			label = '--'
		@graphic_context.fillText(label, @horizontal_center, @vertical_center)

	change_value: (new_value) =>
		proposed_value = Math.max(new_value, 0)
		if @state.loaded.value
			@state.tune.bpm.change_value(proposed_value)