@style = {
	track_style: '#333'
	button_background: '#333'
	button_active_background: '#666'
	button_alternate_background: '#555'
	button_foreground: '#ababab'
	button_active_foreground: '#F7F7F7'
	dial_foreground: '#222'
	dial_background: '#444'
	label_font: "normal 12px sans-serif"
	adjust: (color, percent) ->
		if color.length == 4
			R = parseInt(color.substring(1,2) + color.substring(1,2),16)
			G = parseInt(color.substring(2,3) + color.substring(2,3),16)
			B = parseInt(color.substring(3,4) + color.substring(3,4),16)
		else
			R = parseInt(color.substring(1,3),16)
			G = parseInt(color.substring(3,5),16)
			B = parseInt(color.substring(5,7),16)
		
		R = parseInt(R * (100 + percent) / 100)
		G = parseInt(G * (100 + percent) / 100)
		B = parseInt(B * (100 + percent) / 100)
		
		R = if R < 255 then R else 255
		G = if G < 255 then G else 255
		B = if B < 255 then B else 255
		
		RR = if R.toString(16).length == 1 then "0" + R.toString(16) else R.toString(16)
		GG = if G.toString(16).length == 1 then "0" + G.toString(16) else G.toString(16)
		BB = if B.toString(16).length == 1 then "0" + B.toString(16) else B.toString(16)
		return "#"+RR+GG+BB
}