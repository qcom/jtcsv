## categorize and catalog available types
kinds = {
	simple : ['string','number','boolean','function'],
	composite : ['object','array','complex array'],
	empty : ['empty array','null','undefined']
}

## determine type of value according to `kinds`
## can also be purely complex array or pure object
## (for data set validation)
getType = (val, options) ->
	options = options or {}
	type = typeof val

	if type is 'object'
		# null if val "does not exist"
		if not val?
			'null'
		# composite (objects or arrays)
		else
			if Array.isArray val
				complex = false
				pure = true
				types = []
				# get types of all elements of val
				for el in val
					# recursion on each element to ensure we get appropriate type checking
					t = getType el
					if t not in types
						# val is complex if there exists at least one element
						# in val for which its type is composite
						complex = true if t in kinds.composite
						# val is pure if and only if each of its elements are of type object
						# though each val begins pure, so as to ensure equality for all at birth
						pure = false if t != 'object'
						types.push t
				if types.length is 0
					'empty array'
				else
					if options.pure
						if pure
							'purely complex array'
						else
							if complex then 'complex array' else 'array'
					else
						if complex then 'complex array' else 'array'
			# has to be object if not array
			else
				if options.pure
					complex = false
					pure = true
					for k, v of val
						t = getType v
						complex = true if t in kinds.composite
						pure = false if t isnt 'object'
					if options.pure
						if pure
							'purely complex object'
						else
							if complex then 'complex object' else 'object'
					else
						if complex then 'complex object' else 'object'
				else
					'object'
	# simple types
	else
		type

## simple util functions for type checking
exports.isSimple = (val) -> val in kinds.simple
exports.isComposite = (val) -> val in kinds.composite

exports.kinds = kinds
exports.getType = getType
