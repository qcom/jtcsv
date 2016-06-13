types = require './types'
kinds = types.kinds

## conditionals to test that a value does not belong to a particular empty case
exports.emptyValidators = {
	'empty array' : (val) ->
		not Array.isArray(val) or val.length > 0
	'null' : (val) ->
		val? or (typeof val) isnt 'object'
	'undefined' : (val) ->
		val? or typeof val isnt 'undefined'
}

## given an array of types, return an array of validation functions testing
## from the available functions in validators for the absence of the empty case 
exports.getValidators = (types, validators) ->
	fns = []
	for type in types
		if type in kinds.empty
			fns.push validators[type]
	if fns.length is 0 then null else fns

## consolidate an array of validators into one validate function
## that iterates over each original validator, checking a particular value
## to ensure that it does not meet any of the empty cases
exports.makeValidator = (fns) ->
	if fns?
		(val) ->
			valid = false
			for fn in fns
				valid = true if fn(val)
			valid
	# if no array is passed, e.g. if getValidators returns null,
	# then simply return a function that always returns true
	else
		(val) -> true
