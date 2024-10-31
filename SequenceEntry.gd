extends Object

class_name SequenceEntry

var timeDurationSec: int
var isTransition: bool
var newBaseFreq: float
var newTargetFreq: float

func _to_string() -> String:
	var as_dict : Dictionary
	as_dict.get_or_add("timeDurationSec", timeDurationSec)
	as_dict.get_or_add("isTransition", isTransition)
	as_dict.get_or_add("newBaseFreq", newBaseFreq)
	as_dict.get_or_add("newTargetFreq", newTargetFreq)
	return JSON.stringify(as_dict)

static func from_string(s: String) -> SequenceEntry:
	var j = JSON.new()
	var res = j.parse(s)
	if res == OK:
		var data = j.data
		var ret = SequenceEntry.new()
		ret.timeDurationSec = data.timeDurationSec
		ret.isTransition = data.isTransition
		ret.newBaseFreq = data.newBaseFreq
		ret.newTargetFreq = data.newTargetFreq
		return ret
	else:
		return null
		
static func from_dict(d: Dictionary) -> SequenceEntry:
	var ret = SequenceEntry.new()
	ret.timeDurationSec = d.timeDurationSec
	ret.isTransition = d.isTransition
	ret.newBaseFreq = d.newBaseFreq
	ret.newTargetFreq = d.newTargetFreq
	return ret
