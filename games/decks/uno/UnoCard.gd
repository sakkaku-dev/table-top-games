extends Card

class_name UnoCard

enum Colour {
	GREEN,
	BLUE,
	RED,
	YELLOW,
	BLACK,
}

var value = 0
var colour = Colour.RED
var copy = 0

func _to_string():
	return "UnoCard[copy=%s, colour=%s, value=%s]" % [copy, colour, value]

func ref():
	return str(copy) + str(colour) + str(value)

func is_special_card() -> bool:
	return value >= 10 or is_black_card()
	
func is_black_card() -> bool:
	return colour == Colour.BLACK

func is_color_switch() -> bool:
	return is_black_card() and value == 0

func is_plus_4() -> bool:
	return is_black_card() and value == 1

func is_plus_2() -> bool:
	return value == 10

func is_reverse() -> bool:
	return value == 11
	
func is_stop() -> bool:
	return value == 12
