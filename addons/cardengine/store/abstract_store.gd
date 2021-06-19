class_name AbstractStore
extends Reference
# Base class for in-memory card handling


class StoreSorter:
	var _info: Dictionary = {}

	func _init(sort_info: Dictionary) -> void:
		_info = sort_info

	func sort(left: CardInstance, right: CardInstance) -> bool:
		return _recurive_sort(left.data(), right.data())


	func _recurive_sort(ldata: CardData, rdata: CardData, depth: int = 0) -> bool:
		if depth >= _info.size():
			return false

		var key = _info.keys()[depth]
		var split: Array = key.split(":", false)

		if split[0] == "category":
			var order: Array = _info[key]
			var lval = ldata.get_category(split[1])
			var rval = rdata.get_category(split[1])
			var lidx: int = -1
			var ridx: int = -1
			var idx: int = 0

			for categ in order:
				if categ == lval:
					lidx = idx
				if categ == rval:
					ridx = idx
				idx += 1

			if lidx == ridx:
				return _recurive_sort(ldata, rdata, depth+1)
			elif lidx < ridx:
				return true
		else:
			var asc: bool = _info[key]

			if split[0] == "meta" && split[1] == "id":
				if ldata.id.casecmp_to(rdata.id) == 0:
					return _recurive_sort(ldata, rdata, depth+1)
				elif asc and ldata.id.casecmp_to(rdata.id) == -1:
					return true
				elif not asc and ldata.id.casecmp_to(rdata.id) == 1:
					return true

			elif split[0] == "value":
				if ldata.get_value(split[1]) == rdata.get_value(split[1]):
					return _recurive_sort(ldata, rdata, depth+1)
				elif asc and ldata.get_value(split[1]) < rdata.get_value(split[1]):
					return true
				elif not asc and ldata.get_value(split[1]) > rdata.get_value(split[1]):
					return true

			elif split[0] == "text":
				if ldata.get_text(split[1]).casecmp_to(rdata.get_text(split[1])) == 0:
					return _recurive_sort(ldata, rdata, depth+1)
				elif asc and ldata.get_text(split[1]).casecmp_to(rdata.get_text(split[1])) == -1:
					return true
				elif not asc and ldata.get_text(split[1]).casecmp_to(rdata.get_text(split[1])) == 1:
					return true

		return false


signal changed()
signal card_added(ref)
signal cards_added(refs)
signal card_removed(ref)
signal cards_removed(refs)
signal filtered()
signal sorted()
signal cleared()

var _cards: Array = []


func cards() -> Array:
	return _cards


func clear(emit = true) -> void:
	_cards.clear()
	if emit:
		emit_signal("cleared")
		emit_signal("changed")


func populate(cards: Array, emit = true) -> void:
	clear(emit)
	
	_cards = cards.duplicate()
	if emit:
		emit_signal("changed")


#func sort(sort_info: Dictionary) -> void:
#	pass
#	var sorter = StoreSorter.new(sort_info)
#	if _filter == null:
#		_cards.sort_custom(sorter, "sort")
#	else:
#		_filtered.sort_custom(sorter, "sort")
#	emit_signal("sorted")
#	emit_signal("changed")


func count() -> int:
	return _cards.size()


func is_empty() -> bool:
	return _cards.empty()


func get_last() -> CardInstance:
	return _cards.back()


func find_first(ref) -> CardInstance:
	for card in _cards:
		if card.ref() == ref:
			return card

	return null


func find_last(ref) -> CardInstance:
	var result: CardInstance = null

	for card in _cards:
		if card.ref() == ref:
			result = card

	return result


func add_cards(cards: Array) -> void:
	var refs = []
	for card in cards:
		add_card(card)
		refs.append(card.ref())
		
	emit_signal("cards_added", refs)
	emit_signal("changed")

func add_card(card) -> Card:
	_cards.append(card)
	emit_signal("card_added", card.ref())
	emit_signal("changed")
	return card


func remove_card(ref) -> Card:
	var index: int = _ref2idx(ref)

	if index >= 0:
		var card = _cards[index]
		_cards.remove(index)
		emit_signal("card_removed", ref)
		emit_signal("changed")
		return card
	return null

func remove_cards(refs) -> Array:
	var cards = []
	for ref in refs:
		var card = remove_card(ref)
		if card:
			cards.append(card)
	emit_signal("cards_removed", refs)
	return cards


func remove_first(ref = "") -> void:
	if ref == "":
		var card = _cards.pop_front()
		emit_signal("card_removed", card.ref())
		emit_signal("changed")
	else:
		var card = find_first(ref)
		if card == null:
			return

		remove_card(card.ref())


func remove_last(ref = "") -> void:
	if ref == "":
		var card = _cards.pop_back()
		emit_signal("card_removed", card.ref())
		emit_signal("changed")
	else:
		var card = find_last(ref)
		if card == null:
			return

		remove_card(card.ref())


func move_cards(refs, to: AbstractStore) -> void:
	var cards = remove_cards(refs)
	to.add_cards(cards)


func _ref2idx(ref) -> int:
	var search: int = 0

	for card in _cards:
		if card.ref() == ref:
			return search
		search += 1
	return -1

func get_cards(refs: Array) -> Array:
	var result = []
	for ref in refs:
		var idx = _ref2idx(ref)
		if idx != -1:
			result.append(_cards[idx])
	return result

func most_recent_cards(count: int) -> Array:
	var result = []
	for i in range(_cards.size() - count, _cards.size()):
		result.append(_cards[i])
	return result
