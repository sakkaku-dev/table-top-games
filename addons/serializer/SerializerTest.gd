extends "res://addons/gut/test.gd"

var serializer: Serializer

func before_each():
	serializer = autofree(Serializer.new())


func create_obj(value: int) -> SerializeTestObj:
	var obj = autofree(SerializeTestObj.new())
	obj.value = 1
	return obj


func serialize_deserialize(obj):
	var value = serializer.serialize(obj)
	return autofree(serializer.deserialize(value))


func test_null():
	var actual = serialize_deserialize(null)
	assert_null(actual)


func test_object():
	var actual = serialize_deserialize(create_obj(1))
	assert_true(actual is SerializeTestObj)
	assert_eq(actual.value, 1)


func test_int():
	var actual = serialize_deserialize(100)
	assert_eq(actual, 100)


func test_array():
	var actual: Array = serialize_deserialize([create_obj(1)])
	assert_eq(actual.size(), 1)
	assert_eq(actual[0].value, 1)


func test_int_array():
	var actual: Array = serialize_deserialize([1, 2])
	assert_eq(actual, [1, 2])
