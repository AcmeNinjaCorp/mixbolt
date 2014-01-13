class @MixboltParameter
	constructor: (default_value) ->
		@observers = []
		@value = default_value

	add_listener: (context, listener) ->
		@observers.push([context, listener])

	remove_listener: (context, listener) ->
		index = @observers.indexOf([context, listener])
		@observers.splice(index, 1)

	notify: ->
		for fun in @observers
			fun[1].call(fun[0], @value)

	change_value: (new_value) ->
		if new_value != @value
			@value = new_value
			@notify()