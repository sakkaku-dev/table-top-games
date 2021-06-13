extends Card

class_name UnoCard

enum Colour {
	YELLOW,
	GREEN,
	PURPLE,
	RED,
	BLACK,
}

var value: int
var colour: int

func _to_string():
	return "UnoCard[value=%s, colour=%s]" % [value, colour]

func ref():
	return str(colour) + str(value)
