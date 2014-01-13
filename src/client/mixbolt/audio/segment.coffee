#_require ../parameter.coffee

class @MixboltAudioSegment
	constructor: (@url) ->
		@file = null # ArrayBuffer to hold downloaded segment
		@buffer = null # ArrayBuffer to hold decoded audio
		@progress = new MixboltParameter(0)
		@downloaded = new MixboltParameter(false)
		@decoded = new MixboltParameter(false)
		@decoding = false
		@xhr = null

	download_file: ->
		segment = this
		segment.downloaded.change_value(false)
		segment.xhr = new XMLHttpRequest()
		segment.xhr.withCredentials = "true"
		segment.xhr.open('GET', segment.url, true)
		segment.xhr.responseType = 'arraybuffer'

		segment.xhr.onprogress = (e) ->
			segment.progress.change_value(Math.round((e.loaded / e.total) * 100))

		segment.xhr.onload = (e) ->
			if (segment.xhr.readyState != 4)
				return
			else
				segment.file = segment.xhr.response
				segment.downloaded.change_value(true)
				segment.xhr = null
		segment.xhr.send()
	
	decode: ->
		segment = this
		segment.decoding = true
		window.audio_context.decodeAudioData(
			segment.file,
			(buffer) ->
				segment.buffer = buffer
				segment.decoded.change_value(true)
				segment.decoding = false
		)

	clear_buffer: ->		
		@decoded.change_value(false)
		@buffer = null

	clear: ->
		@downloaded.change_value(false)
		@progress.change_value(0)
		@file = null
		@clear_buffer()

