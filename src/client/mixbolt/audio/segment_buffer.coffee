#_require segment.coffee

class @MixboltAudioSegmentBuffer
	constructor: (data) ->
		@segments = []
		for segment_data in data
			local_segment = {
				segment: new MixboltAudioSegment(segment_data.url)
				length: segment_data.length
			}
			local_segment.segment.download_file()
			@segments.push(local_segment)
		first_segment = @segments[0].segment
		sb = this
		finished_loading_callback = ->
			first_segment.downloaded.remove_listener(sb, finished_loading_callback)
			first_segment.decode()
		first_segment.downloaded.add_listener(sb, finished_loading_callback)

	get_range: (start_position, end_position) ->
		current_chunk = @get_chunk_number(start_position)
		current_chunk_position = @get_chunk_position(start_position)

		end_chunk = @get_chunk_number(end_position)
		end_chunk_position = @get_chunk_position(end_position)

		# Decode next chunk if we reach half way through current one
		if end_chunk == current_chunk and end_chunk_position > (@segments[current_chunk].length / 2)
			next_chunk = current_chunk + 1
			if @segments.length > next_chunk
				unless @segments[next_chunk].segment.decoded.value or @segments[next_chunk].segment.decoding
					@segments[next_chunk].segment.decode()
					# Clear old segments
					if current_chunk > 0
						for i in [0..current_chunk - 1] by 1
							if @segments[i].segment.decoded.value
								@segments[i].segment.clear_buffer()
			else
				unless @segments[0].segment.decoded.value or @segments[0].segment.decoding
					@segments[0].segment.decode()


		return_length = end_position - start_position
		left_buffer = new Float32Array(return_length)
		right_buffer = new Float32Array(return_length)

		if @segments[current_chunk].segment.decoded.value
			left_input_channel = @segments[current_chunk].segment.buffer.getChannelData(0)
			right_input_channel = @segments[current_chunk].segment.buffer.getChannelData(1)

			subarray_end = current_chunk_position + return_length
			if subarray_end > left_input_channel.length
				subarray_end = left_input_channel.length

			left_buffer.set(left_input_channel.subarray(current_chunk_position, subarray_end))
			right_buffer.set(right_input_channel.subarray(current_chunk_position, subarray_end))
			
			if current_chunk != end_chunk
				left_input_channel = @segments[end_chunk].segment.buffer.getChannelData(0)
				right_input_channel = @segments[end_chunk].segment.buffer.getChannelData(1)
				
				left_buffer.set(left_input_channel.subarray(0, end_chunk_position))
				right_buffer.set(right_input_channel.subarray(0, end_chunk_position))
			
			left_input_channel = null
			right_input_channel = null

		return_buffer = new Array(2)
		return_buffer[0] = left_buffer
		return_buffer[1] = right_buffer
		left_buffer = null
		right_buffer = null
		return return_buffer

	get_chunk_position: (position) ->
		segment_offset = 0
		segment_end = 0
		chunk_offset = 0
		for segment, offset in @segments
			segment_offset = segment_end
			segment_end = segment_end + segment.length
			if position > segment_offset and position < segment_end
				chunk_offset = position - segment_offset
				break
		return chunk_offset

	get_chunk_number: (position) ->
		segment_offset = 0
		segment_end = 0
		chunk = 0
		for segment, offset in @segments
			segment_offset = segment_end
			segment_end = segment_end + segment.length
			if position > segment_offset and position < segment_end
				chunk = offset
				break
		return chunk