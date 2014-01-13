#_require dial/beat.coffee
#_require dial/bpm.coffee
#_require dial/pitch.coffee
#_require button/half.coffee
#_require button/double.coffee
#_require button/tap.coffee
#_require button/beep.coffee
#_require button/save.coffee
#_require button/play.coffee
#_require button/sync.coffee
#_require scope.coffee
#_require position.coffee
#_require looper.coffee

class @MixboltUiDeck
	constructor: (@state, @prefix)->
		@first_beat = new MixboltUiDialFirstBeat( $("##{@prefix}-deck-first-beat")[0], state)
		@deck_bpm = new MixboltUiDialBpm( $("##{@prefix}-deck-bpm")[0], state)

		@deck_half_button = new MixboltUiButtonHalf($("##{@prefix}-deck-half-button")[0], state)
		@deck_double_button = new MixboltUiButtonDouble($("##{@prefix}-deck-double-button")[0], state)

		@deck_tap_button = new MixboltUiButtonTap($("##{@prefix}-deck-tap-button")[0], state)
		@deck_beep_button = new MixboltUiButtonBeep($("##{@prefix}-deck-beep-button")[0], state)

		@deck_save_button = new MixboltUiButtonSave($("##{@prefix}-deck-save-button")[0], state)

		@deck_scope = new MixboltUiScope( $("##{@prefix}-deck-scope")[0], state)
		@deck_position = new MixboltUiPosition( $("##{@prefix}-deck-position")[0], state)
		@deck_play_button = new MixboltUiButtonPlay( $("##{@prefix}-deck-play-button")[0], state.playing)
		@deck_sync_button = new MixboltUiButtonSync( $("##{@prefix}-deck-sync-button")[0], state)
		@deck_pitch = new MixboltUiDialPitch( $("##{@prefix}-deck-pitch")[0], state)
		@looper = new MixboltUiLooper($("##{@prefix}-looper")[0], state)

		$("##{@prefix}-deck").data('state', @state)

		deck_element = $("##{@prefix}-deck")[0]
		dragging = 0

		deck_element.addEventListener('dragenter', (ev) ->
			ev.stopPropagation()
			ev.preventDefault()
			ev.dataTransfer.dropEffect = 'copy'
			$(this).addClass('lightup')
			dragging += 1
		, false)

		deck_element.addEventListener('dragleave', (ev) ->
			ev.stopPropagation()
			ev.preventDefault()
			dragging -= 1
			$(this).removeClass('lightup') if (dragging == 0)
		, false)

		deck_element.addEventListener('drop', (ev) ->
			ev.stopPropagation()
			ev.preventDefault()
			if ev.dataTransfer.files.length > 0
				$(this).data('state').load(ev.dataTransfer.files[0])
			$(this).removeClass('lightup')
			dragging = 0
		, false)

		$(window).resize(@resize)
		$(window).load(@resize)

		@state.loaded.add_listener(this, @update_title)
	
	update_title: ->
		if @state.loaded.value
			$("##{@prefix}-deck-info").text(@state.tune.name.value)
		else
			$("##{@prefix}-deck-info").text('--')

	resize: =>
		new_width = Math.floor(($('#player').innerWidth() - 140) / 2)
		@deck_scope.update_width(new_width - 10)
		@deck_position.update_width(new_width - 10)
		$("##{@prefix}-deck").width(new_width)
