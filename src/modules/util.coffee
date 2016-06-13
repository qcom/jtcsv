## massage a string into camelCased term format
## (capitalize first letter and leave the rest)
camelPrep = (s) -> s[0].toUpperCase() + s.slice(1)

## add every key/val pair from source into
## dest, overriding when necessary
exports.join = (dest, source) ->
	for key, val of source
		dest[key] = val
	dest

getSteps = (path) ->
	steps = path.split '/'
	steps[1...steps.length - 1]

resolve = (obj, path) ->
	steps = getSteps path
	r = (obj, steps, done) ->
		if done
			null
		else if steps.length is 0
			obj
		else
			key = steps.shift()
			if obj[key]?
				r(obj[key], steps)
			else
				r(obj, steps, true)
	r(obj, steps)

increment = (arr) ->
	a = (n for n in arr)
	for n, i in a
		if not isNaN n
			a[i] = (+n + 1).toString()
	a

getName = (path) ->
	steps = increment getSteps path
	r = (s, steps) ->
		if steps.length is 0
			s
		else
			r(s + camelPrep(steps.shift()), steps)
	r(steps.shift(), steps)

getMissing = (total, partial) ->
	result = []
	for el in total
		result.push el if el not in partial
	result

exports.camelPrep = camelPrep

exports.resolve = resolve
exports.getName = getName
exports.getMissing = getMissing
