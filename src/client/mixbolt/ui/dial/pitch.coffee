#_require ../dial.coffee

class @MixboltUiDialPitch extends MixboltUiDial
	constructor: (@container, @state) ->
		@defaults =
			minimum: 0
			default_value:1
			maximum: 2

		@container.width = 120
		@container.height = 30

		$(@container).bind('dblclick', @resetPosition)
		@state.bpm.add_listener(this, @update_state)
		@state.loaded.add_listener(this, @update_state)
		super(@container)

	resetPosition: =>
		@change_value(@defaults.default_value)

	update_state: ->
		if @state.loaded.value
			@value = @state.bpm.value / @state.tune.bpm.value
			@draw()

	scroll: (e) =>
		if e.originalEvent.wheelDelta > 0
			@change_value(@value - 0.01)
		else
			@change_value(@value + 0.01)
	
	startDrag: (e) =>
		e.preventDefault()
		start_position = $(@container).position()
		start_x = e.pageX - start_position.left
		start_y = e.pageY - start_position.top
		start_value = @value

		$(document).bind(
			'mousemove.MixboltUiPitch',
			(e) =>
				local_offset = start_value  - ((start_y - (e.pageY - start_position.top)) / 1000)
				if @state.loaded.value
					@change_value(local_offset)
		).bind(
			'mouseup.MixboltUiPitch',
			() ->
				$(document).unbind('mousemove.MixboltUiPitch mouseup.MixboltUiPitch')
		)

	draw: ->
		super()

		# Draw label
		@graphic_context.font = style.label_font
		@graphic_context.textAlign = 'left'
		@graphic_context.textBaseline = 'middle'
		@graphic_context.fillStyle = @foreground
		@graphic_context.fillText((Math.floor(@state.bpm.value * 100) / 100).toFixed(2) , 10, @vertical_center)

		if @state.loaded.value
			ratio = (Math.floor((@state.bpm.value - @state.tune.bpm.value) * 100) / 100).toFixed(2)
			if ratio > 0
				ratio = '+' + ratio
		else
			ratio = '--'
		@graphic_context.textAlign = 'right'
		@graphic_context.fillText('('+ratio+')' , @container.width - 10, @vertical_center)

	change_value: (new_value) =>
		proposed_value = Math.max(Math.min(new_value, @defaults.maximum), @defaults.minimum)
		if @state.loaded.value and proposed_value != @value
			@value = proposed_value
			@state.bpm.change_value(@state.tune.bpm.value * @value)
