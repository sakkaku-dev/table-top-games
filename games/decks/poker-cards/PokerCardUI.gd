extends Sprite

var poker_card: PokerCard

func _ready():
	if not poker_card:
		print("Created Poker Card without value")
	else:
		frame_coords = Vector2(poker_card.value, poker_card.suit)
