class @MixboltUiEq
	constructor: (left_eq, right_eq) ->
		@createLeftEq(left_eq)
		@createRightEq(right_eq)
		@mid_eq = new MixboltUiEqMidPannel( $('#mid-eq')[0])
		@mid_eq_gain = new MixboltUiEqGainMidPannel( $('#mid-eq-gain')[0])

	createLeftEq: (eq) ->
		@left_eq_gain = new MixboltUiKnob( $('#left-eq-gain')[0], eq.gain)
		@left_eq_high = new MixboltUiKnob( $('#left-eq-high')[0], eq.high_gain)
		@left_eq_mid = new MixboltUiKnob( $('#left-eq-mid')[0], eq.mid_gain)
		@left_eq_low = new MixboltUiKnob( $('#left-eq-low')[0], eq.low_gain)
	
	createRightEq: (eq) ->
		@right_eq_gain = new MixboltUiKnob( $('#right-eq-gain')[0], eq.gain)
		@right_eq_high = new MixboltUiKnob( $('#right-eq-high')[0], eq.high_gain)
		@right_eq_mid = new MixboltUiKnob( $('#right-eq-mid')[0], eq.mid_gain)
		@right_eq_low = new MixboltUiKnob( $('#right-eq-low')[0], eq.low_gain)