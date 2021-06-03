class_name PokerCard

enum Suit {
	HEART,
	DIAMOND,
	CLUB,
	SPADE
}

var value: int
var suit: int

func _to_string():
	return "PokerCard[value=%s, suit=%s]" % [value, suit]
