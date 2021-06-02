extends Node

class_name Serializer

func serialize(value) -> String:
	var result = ""
	
	if value is Array:
		result += "["
		for i in range(0, value.size()):
			var v = value[i]
			result += _serialize_obj(v)
			if i != value.size() - 1:
				result += ","
		result += "]"
	else:
		result += _serialize_obj(value)
	
	return result
	
	

func _serialize_obj(obj) -> String:
	if obj != null and obj is Object:
		var script: GDScript = obj.get("script")
		if script:
			var values = {}
			values["script"] = script.resource_path
			for prop in script.get_script_property_list():
				values[prop.name] = obj.get(prop.name)
			return var2str(values)

	return var2str(obj)


func deserialize(value):
	var values = str2var(value)
	
	if values is Array:
		var result = []
		for v in values:
			result.append(_deserialize_obj(v))
		return result
	elif values is Dictionary:
		return _deserialize_obj(values)
	
	return values


func _deserialize_obj(values):
	if values != null and values is Dictionary and values.has("script"):
		var instance: Object = load(values["script"]).new()
		for prop in values:
			if prop != "script":
				instance.set(prop, values[prop])
		return instance
	return values
