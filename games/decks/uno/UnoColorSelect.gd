extends Control

var card = preload("res://games/decks/uno/UnoCardUI.tscn")

func _ready():
	for c in UnoCard.Colour.values():
		if c == UnoCard.Colour.BLACK: continue
		
		var uno_card = UnoCard.new()
		uno_card.colour = c

		var node = card.instance()
		add_child(node)
		node.set_instance(uno_card)
		
		node.position = Vector2(rect_size.x / 2, rect_size.y / 2)
