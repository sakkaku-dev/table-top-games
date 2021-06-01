extends Sprite

class_name PokerCard

enum Suit {
	HEART,
	DIAMOND,
	CLUB,
	SPADE
}

var value: int
var suit: int

func _init(value: int, suit: int):
	self.value = value
	self.suit = suit

func _ready():
	frame_coords = Vector2(value, suit)

func create_node() -> Node2D:
	var node = load("res://games/decks/poker-cards/PokerCard.tscn").instance()
	node.value = value
	node.suit = suit
	return node

func _to_string():
	return "PokerCard[value=%s, suit=%s]" % [value, suit]
