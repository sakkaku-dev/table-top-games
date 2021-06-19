extends Control

signal color_selected(color)

var card = preload("res://games/decks/uno/UnoCardUI.tscn")

func _ready():
	for c in UnoCard.Colour.values():
		if c == UnoCard.Colour.BLACK: continue
		
		var uno_card = UnoCard.new()
		uno_card.colour = c

		var node: CardUI = card.instance()
		add_child(node)
		node.set_instance(uno_card)
		node.connect("clicked", self, "_color_clicked", [c])
		
		node.position = Vector2(rect_size.x / 2, rect_size.y / 2)
		node.scale *= 4
		
		var offset = 100
		if c == 0:
			node.position.y -= offset
		elif c == 1:
			node.position.x += offset
		elif c == 2:
			node.position.y += offset
		elif c == 3:
			node.position.x -= offset

func _color_clicked(c: int) -> void:
	emit_signal("color_selected", c)
	queue_free()
