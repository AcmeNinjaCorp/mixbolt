#_require ../parameter.coffee

class @MixboltModelTune
	constructor: (file) ->
		@hash = null
		@original_bpm = 85
		@bpm = new MixboltParameter(85)
		@bpm.add_listener(this, @check_minimum_bpm)

		@original_first_beat = 0
		@first_beat = new MixboltParameter(0)
		@buffer = null
		@length = 0
		@loaded = new MixboltParameter(false)

		@sha_worker = new Worker('/js/rusha.js')

		tune = this

		@sha_worker.addEventListener('message', (e) ->
			tune.hash = e.data.hash
			tune.load()
		, false)

		@name = new MixboltParameter(file.name)
		@saved = new MixboltParameter(true)
		
		reader = new FileReader()
		reader.onload = (evt) ->
			tune.sha_worker.postMessage({id: 'test', data: evt.target.result})
			tune.buffer = evt.target.result
		reader.readAsArrayBuffer(file)

	check_minimum_bpm: ->
		if @bpm.value < 5.0
			@bpm.change_value(5.0)

	length_to_time: ->
    minutes = (@length / 44100) / 60
    seconds = Math.round((minutes - Math.floor(minutes)) * 60).toString()
    if seconds.length == 1
     	seconds = '0' + seconds
    "#{Math.floor(minutes)}:#{seconds}"

	save: ->
		@saved.change_value(false)
		
		data = 
			first_beat: @first_beat.value
			bpm: @bpm.value
		localStorage[@hash] = JSON.stringify(data)
		
		@original_bpm = @bpm.value
		@original_first_beat = @first_beat.value
		
		@saved.change_value(true)

	load: ->
		if localStorage[@hash]
			data = JSON.parse(localStorage[@hash])
			@bpm.change_value(data.bpm)
			@first_beat.change_value(data.first_beat)
			@original_bpm = data.bpm
			@original_first_beat = data.first_beat
		@loaded.change_value(true)