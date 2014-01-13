#_require ../button.coffee

class @MixboltUiButtonTap extends MixboltUiButton
  constructor: (@container, @state) ->
    @count = 0
    @time_first = 0
    @time_last = 0

    $(@container).bind("contextmenu", @reset)
    super(@container, 40, 30)
  
  click: (e) =>
    e.preventDefault()
    date = new Date
    time = date.getTime()
    # Reset value if nothing happened for a while
    if((time - @time_last) > 1000 * 5)
      @count = 0
    if @count == 0
      @time_first = time
      @count = 1
    else
      bpm_avg = 60000 * @count / (time - @time_first)
      if @state.loaded.value
        @state.tune.bpm.change_value(bpm_avg)
      @count++
    @time_last = time

  reset: =>
    @count = 0
    false

  draw: ->
    super()

    # Draw label
    @graphic_context.font = style.label_font
    @graphic_context.textAlign = 'center'
    @graphic_context.textBaseline = 'middle'
    @graphic_context.fillStyle = @foreground
    @graphic_context.fillText('Tap', @width/2, @height/2)