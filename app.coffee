eliminate = (input) ->

	rows = input.length
	columns = input[0].length

	output = for row in [0...rows]
		for col in [0...columns]
			bigRat input[row][col]

	for pass in [0, 1]
		for row in [(pass + 1)...rows]
			multiplier = output[row][pass].divide output[pass][pass]
			for col in [0...columns]
				output[row][col] = output[pass][col].times(multiplier).minus(output[row][col])

	output

solve = (input) ->

	rows = input.length
	columns = input[0].length

	solutions = Array rows

	for row in [(rows - 1)..0] by -1
		solutions[row] = input[row][columns - 1]

		for col in [(row + 1)...(columns - 1)]
			solutions[row] = solutions[row].minus input[row][col].times(solutions[col])

		solutions[row] = solutions[row].divide input[row][row]

	solutions


toMathML = (rat) ->
	num =
		int: rat.denom.equals 1
		neg: rat.isNegative()
		num: rat.abs().num
		den: rat.denom

	math = "<math>"
	math += "<mo>-</mo>" if num.neg

	if num.int
		math += "<mn>#{num.num}</mn>"
	else
		math += "<mfrac><mn>#{num.num}</mn><mn>#{num.den}</mn></mfrac>"

	math += "</math>"


document.getElementById('calculate-button').addEventListener 'click', ->
	input = for tr in document.querySelectorAll '#input-table tbody tr'
		td.children[0].value for td in tr.children

	try
		output = eliminate input
	catch e
		alert "Matrix cannot be eliminated"
		return

	document.body.setAttribute 'class', 'card flipped'
	history.pushState?()

	for row, x in output
		for value, y in row
			selector = "#output-table tr:nth-child(#{x + 1}) td:nth-child(#{y + 1})"
			document.querySelector(selector).innerHTML = toMathML value
			# MathJax.Hub.Queue ["Typeset", MathJax.Hub]

	names = ['x', 'y', 'z']
	for value, i in solve output
		name = names[i]
		document.getElementById(name).innerHTML = "<math><mi>#{name}</mi> <mo>=</mo> <mn>#{value}</mn></math>"

reset = ->
	document.body.setAttribute 'class', 'card'

	# input.value = 0 for input in document.querySelectorAll "input"
	setTimeout (-> document.querySelector('#input-table input').focus()), 1000

window.addEventListener 'popstate', reset
document.getElementById('reset-button').addEventListener 'click', ->
	if history.pushState? then history.back() else reset()
