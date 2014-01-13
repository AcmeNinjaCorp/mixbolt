$(document).ready ->
	unless $('#player').length == 0
		if (typeof AudioContext isnt "undefined")
			audio_context = new AudioContext()
		else if (typeof webkitAudioContext isnt "undefined")
			audio_context = new webkitAudioContext()
		
		if audio_context
			window.audio_context = audio_context
			window.mixbolt_audio = new MixboltAudio(audio_context)
			window.mixbolt_ui = new MixboltUi()

			mixbolt_ui.createLeftDeck(mixbolt_audio.left_state)
			mixbolt_ui.createRightDeck(mixbolt_audio.right_state)
			mixbolt_ui.createEq(mixbolt_audio.left_eq, mixbolt_audio.right_eq)

			connectMixer()
			animateUi()

connectMixer = ->
	mixbolt_ui.xfader.options.on_change = (v) ->  mixbolt_audio.mixer.change_value(v/100) 

animateUi = ->
	mixbolt_ui.left_deck.deck_scope.draw()
	mixbolt_ui.left_deck.deck_position.draw()
	mixbolt_ui.right_deck.deck_scope.draw()
	mixbolt_ui.right_deck.deck_position.draw()
	requestAnimFrame(animateUi)

window.requestAnimFrame = ((callback) ->
	window.requestAnimationFrame || 
	window.webkitRequestAnimationFrame || 
	window.mozRequestAnimationFrame || 
	window.oRequestAnimationFrame || 
	window.msRequestAnimationFrame ||
	(callback) ->
		window.setTimeout(callback, 1000 / 60)
)()