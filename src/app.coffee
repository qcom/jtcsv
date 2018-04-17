fs = require 'fs'
api = require '../data/2-22-18_prod_parsed.json'

## modules
types = require './modules/types'
getType = types.getType
isSimple = types.isSimple
isComposite = types.isComposite

validation = require './modules/validation'
emptyValidators = validation.emptyValidators
getValidators = validation.getValidators
makeValidator = validation.makeValidator

util = require './modules/util'
camelPrep = util.camelPrep
join = util.join
resolve = util.resolve
getName = util.getName
getMissing = util.getMissing

## Attribute class that will construct an object
## with a name, an array of types (initially from a single type)
## a count of the number of simple types, and
## a path either from the passed path or the default
class Attribute
	constructor: (@name, type, path) ->
		@types = [type]
		@simpleTypes = if isSimple type then 1 else 0
		@path = if path? then path else '/'
		@validator = makeValidator(getValidators(@types, emptyValidators))
	addTypes: (types) ->
		for type in types
			if type not in @types
				@types.push type
				++@simpleTypes if isSimple type
				@validator = makeValidator(getValidators(@types, emptyValidators))
	addPath: (step) ->
		@path += "#{step}/"
	validate: (val) ->
		@validator val

class Attributes
	constructor: () -> @attrs = {}
	add: (attr) ->
		existed = true
		if @attrs[attr.name]
			@attrs[attr.name].addTypes attr.types
		else
			existed = false
			@attrs[attr.name] = attr
		existed
	get: () -> @attrs
	getKeys: () -> Object.keys @attrs

## get all unique attributes and their possible types
## (one attribute can have multiple types)
## serves as general documentation on the types of
## each attribute in the given data set
establish = (data) ->
	wrongTypes = "no support for data sets that are not objects or complex arrays"
	dataType = getType data, pure : true
	attributes = new Attributes
	if dataType is 'purely complex object'
		# if data is supplied as an object, it is assumed that
		# each key/val pair represents a "record" in csv format
		# and thus that val is an object
		for key, obj of data
			for name, val of obj
				attributes.add new Attribute(name, getType(val))
		attributes
	else if dataType is 'purely complex array'
		# a similar assumption (as with object data sets)
		# are made for complex array data sets in that
		# each element in the array must be an object
		# to correspond to a csv record
		obj = {}
		data.forEach (o) ->
			obj[o.name] = o
		establish(obj)
		# throw new Error("cannot handle purely complex array")
	else
		throw new Error(wrongTypes)

arrMax = (name, attribute, data) ->
	max = 1
	for key, obj of data
		a = obj[name]
		if a? and attribute.validate a
			max = a.length if a.length > max
	max

expand = (attributes, data) ->
	header = []
	for name, attribute of attributes
		for type in attribute.types
			if type is 'object'
				keys = []
				for key, obj of data
					o = obj[name]
					if o? and attribute.validate o
						for k, v of o
							if k not in keys
								keys.push k
								header.push display : name + camelPrep(k), name : k, validate : attribute.validator, object : true, parent : name
			else if type is 'array'
				max = arrMax name, attribute, data
				for i in [1..max]
					header.push name : "#{name}#{i}", validate : attribute.validator, array : true, parent : name, index : i - 1
			else if type is 'complex array'
				max = arrMax name, attribute, data
				keys = {}
				for key, obj of data
					a = obj[name]
					if a? and attribute.validate a
						for el, i in a
							for k, v of el
								if keys[i]
									keys[i].push k if k not in keys[i]
								else
									keys[i] = [k]
				# console.log "complex array:\n#{name}: #{Object.keys(keys)}"
				for i, ks of keys
					for k in ks
						header.push display : "#{name}#{+(i) + 1}#{camelPrep(k)}", name : k, validate : attribute.validator, complexArray : true, parent : name, index : i
				# console.log "complex array:\n#{name}: #{max}\n#{keys}"
			else if type in types.kinds.simple
				header.push name : name, validate : attribute.validator, simple : true
	header

attributes = establish api
# console.log attributes.get()

header = expand attributes.get(), api
# console.log 'header:'
# console.log header

clean = (s) ->
	t = getType s
	if t is 'string' then s.replace(/[\r\n]/g, '') else s

superClean = (s) -> if getType(s) is 'string' then s.replace(/[\r\n]/g, '').replace(/\n/g, '').replace(/\t/g, '') else s

exp = (header, data) ->
	s = ''
	for h in header
		s = "#{s}#{if h.display? then superClean(h.display) else superClean(h.name)}\t"
	fs.writeFileSync './header.txt', s
	s += '\n'
	for key, obj of data
		for h in header
			if h.simple
				if obj[h.name]? and h.validate obj[h.name]
					val = superClean(obj[h.name])
					s = "#{s}#{if val? then clean val else ''}\t"
				else
					s = "#{s}\t"
			else if h.object
				if obj[h.parent]? and h.validate obj[h.parent]
					val = superClean(obj[h.parent][h.name])
					s = "#{s}#{if val? then clean val else ''}\t"
				else
					s = "#{s}\t"
			else if h.array
				if obj[h.parent]? and h.validate obj[h.parent]
					val = superClean(obj[h.parent][h.index])
					s = "#{s}#{if val? then clean val else ''}\t"
				else
					s = "#{s}\t"
			else if h.complexArray
				if obj[h.parent]? and h.validate obj[h.parent]
					val = obj[h.parent][h.index]
					val = superClean(val[h.name]) if val?
					s = "#{s}#{if val? then clean val else ''}\t"
				else
					s = "#{s}\t"
		s += '\n'
	s

result = exp header, api
fs.writeFileSync './out.txt', result
