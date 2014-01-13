class @MixboltUi
	constructor: ->
		@createMixer()
		@controls_visible = new MixboltParameter(false)
		# @createControlButtons()
		
		window.addEventListener('drop', (ev) ->
			ev.preventDefault()
		, false)
		window.addEventListener('dragover', (ev) ->
			ev.preventDefault()
		, false)

	createLeftDeck: (state) ->
		@left_deck = new MixboltUiDeck(state, 'left')

	createRightDeck: (state) ->
		@right_deck = new MixboltUiDeck(state, 'right')

	createEq: (left_eq, right_eq)->
		@eq = new MixboltUiEq(left_eq, right_eq)
	
	createMixer: ->
		@xfader = new MixboltUiSlider( $('#xfader')[0] )

	createControlButtons: ->
		@left_deck_controls_button = new MixboltUiButtonControls($('#left-deck-controls-button')[0], @controls_visible)
		@right_deck_controls_button = new MixboltUiButtonControls($('#right-deck-controls-button')[0], @controls_visible)
		@controls_visible.add_listener(this, 
			(value) ->
				if @controls_visible.value
					@showControls()
				else
					@hideControls()
		)

	showControls: ->
		$('#player').animate({height: 265}, {duration: 500})
		$('.deck').animate({height: 265}, 500)
		$('.deck-controls').animate({height: 'show'}, 500)
		$('#eq-gain').animate({height: 'show'}, 500)

	hideControls: ->
		$('#player').animate({height: 215}, {duration: 500})
		$('.deck').animate({height: 215}, 500)
		$('.deck-controls').animate({height: 'hide'}, 500)
		$('#eq-gain').animate({height: 'hide'}, 500)