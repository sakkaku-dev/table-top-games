extends Control

var store: AbstractStore = null setget _set_store
var deck: Deck = null

var card_scene = preload("res://games/boards/Cards.tscn")

var _rng: PseudoRng = PseudoRng.new()
var fine_angle_min = deg2rad(-20)
var fine_angle_max = deg2rad(20)

func create_cards(cards: Array) -> void:
	var card_node = card_scene.instance()
	card_node.face_up = true
	card_node.interactive = false
	card_node.card_visual = deck.get_ui()
	card_node.rect_rotation += _rng.randomf_range(fine_angle_min, fine_angle_max)
	
	add_child(card_node)
	card_node.update_cards(cards)
	
func _set_store(value: AbstractStore) -> void:
	store = value
	store.connect("cards_added", self, "_add_cards")

func _get_custom_rpc_methods() -> Array:
	return [
		'_add_cards_sync',
	]

func _add_cards(refs: Array) -> void:
	OnlineMatch.custom_rpc_sync(self, "_add_cards_sync", [refs])

func _add_cards_sync(refs: Array):
	var cards = []
	for ref in refs:
		cards.append(deck.create_from_ref(ref))
	
	create_cards(cards)
