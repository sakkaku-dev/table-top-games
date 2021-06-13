extends Control

signal clicked()

export var interactive = true

var store: AbstractStore = null setget _set_store
var deck: Deck = null

var card_scene = preload("res://games/boards/Cards.tscn")

var _rng: PseudoRng = PseudoRng.new()
var fine_angle_min = deg2rad(-20)
var fine_angle_max = deg2rad(20)

func _set_interactive(value: bool) -> void:
	interactive = value
	_set_last_interactive(value)

func _set_last_interactive(value: bool) -> void:
	var child = _get_last_child()
	if child:
		child.interactive = value

func _get_last_child() -> Node:
	if get_child_count() == 0: return null
	return get_child(get_child_count() - 1)

func create_cards(cards: Array) -> void:
	var card_node = card_scene.instance()
	card_node.face_up = true
	card_node.interactive = interactive
	card_node.card_visual = deck.get_ui()
	card_node.rect_rotation += _rng.randomf_range(fine_angle_min, fine_angle_max)
	card_node.connect("card_clicked", self, "_on_card_clicked")
	
	_set_last_interactive(false)
	
	add_child(card_node)
	card_node.update_cards(cards)


func _on_card_clicked(card) -> void:
	emit_signal("clicked")


func get_last_discarded() -> Array:
	var child = _get_last_child()
	if child:
		return child.get_card_refs()
	return []


func _set_store(value: AbstractStore) -> void:
	store = value
	store.connect("cards_added", self, "_add_cards")
	store.connect("cards_removed", self, "_remove_cards")

func _get_custom_rpc_methods() -> Array:
	return [
		'_add_cards_sync',
		'_remove_cards_sync',
	]


func _remove_cards(refs: Array) -> void:
	OnlineMatch.custom_rpc_sync(self, "_remove_cards_sync", [refs])
	
func _remove_cards_sync(refs: Array) -> void:
	var child = _get_last_child()
	if child:
		remove_child(child)
		_set_last_interactive(interactive)


func _add_cards(refs: Array) -> void:
	OnlineMatch.custom_rpc_sync(self, "_add_cards_sync", [refs])

func _add_cards_sync(refs: Array):
	var cards = []
	for ref in refs:
		cards.append(deck.create_from_ref(ref))
	
	create_cards(cards)
