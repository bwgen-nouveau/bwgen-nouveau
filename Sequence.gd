extends Object

var items: Dictionary

func _to_string() -> String:
	var counter = 0;
	var ret = "{"
	for key in items:
		ret += '"'+str(key)+'":'+items[key]._to_string()
		counter += 1
		if counter < len(items):
			ret += ','
	ret += "}"
	return ret
