extends Control

signal card_clicked(card)
signal card_hold(card)

enum LayoutMode {GRID, PATH}
enum FineTuningMode {LINEAR, SYMMETRIC, RANDOM}
enum AspectMode {KEEP, IGNORE}

const CARD_NODE_FMT = "card_%s"

export var last_only = false
export var face_up = true
export var interactive = true setget _set_interactive
var layout_mode: int = LayoutMode.GRID

var card_visual: PackedScene = null

# Grid parameters
export var _grid_card_width: float = 80
export var _grid_fixed_width: bool = true
export var _grid_card_spacing: Vector2 = Vector2(0.5, 1)
var _grid_halign: int = HALIGN_CENTER
var _grid_valign: int = VALIGN_CENTER
var _grid_columns: int = -1
var _grid_expand: bool = false

# Position fine tuning
export var fine_pos: bool = true
export(FineTuningMode) var fine_pos_mode = FineTuningMode.SYMMETRIC
export var fine_pos_min: Vector2 = Vector2(0.0, -20)
export var fine_pos_max: Vector2 = Vector2(0.0, 20)

# Angle fine tuning
export var fine_angle: bool = true
export(FineTuningMode) var fine_angle_mode = FineTuningMode.LINEAR
export var fine_angle_value = 10.0
var fine_angle_min: float = deg2rad(-fine_angle_value)
var fine_angle_max: float = deg2rad(fine_angle_value)

# Scale fine tuning
var fine_scale: bool = false
var fine_scale_mode = FineTuningMode.LINEAR
var fine_scale_ratio = AspectMode.KEEP
var fine_scale_min: Vector2 = Vector2(0, 0)
var fine_scale_max: Vector2 = Vector2(0, 0)

export var max_active_cards = 0

var _cards = []
var _rng: PseudoRng = PseudoRng.new()


func update_cards(cards: Array) -> void:
	if card_visual == null:
		return

	_cards = cards
	_clear_unused(cards)

	# Adding missing cards
	for card in cards:
		if find_node(CARD_NODE_FMT % card.ref(), false, false) != null:
			continue

		var visual_inst := card_visual.instance()
		if not visual_inst is CardUI:
			printerr("Container visual instance must inherit Card")
			continue

		visual_inst.name = CARD_NODE_FMT % card.ref()
		add_child(visual_inst)
		if card == null:
			print("Null card")
		visual_inst.set_instance(card)
		visual_inst.set_interactive(interactive)
		visual_inst.connect("clicked", self, "_on_card_clicked", [visual_inst])
		visual_inst.connect("hold", self, "_on_card_hold", [visual_inst])

		if face_up:
			visual_inst.set_side(CardUI.CardSide.FRONT)
		else:
			visual_inst.set_side(CardUI.CardSide.BACK)

	# Sorting according to store order
	var index = 0
	for card in cards:
		var visual = find_node(CARD_NODE_FMT % card.ref(), false, false)
		move_child(visual, index)
		index += 1

	_setup_last_only()
	_layout_cards()

func _on_card_hold(card: CardUI) -> void:
	emit_signal("card_hold", card)


func _on_card_clicked(card: CardUI) -> void:
	emit_signal("card_clicked", card)


func _set_interactive(value: bool) -> void:
	interactive = value
	for c in get_children():
		c.set_interactive(value)

func _setup_last_only() -> void:
	if interactive and last_only:
		for child in get_children():
			child.set_interactive(false)

func _clear_unused(cards: Array):
	for child in get_children():
		if not _has_card(child.instance(), cards):
			remove_child(child)


func _has_card(card: Card, cards: Array):
	if card:
		for c in cards:
			if c.ref() == card.ref():
				return true
	return false


func _layout_cards():
	var card_index: int = 0

	for child in get_children():
		if child is CardUI:
			var trans = CardTransform.new()
			_grid_layout(trans, card_index, child.size)
			_fine_tune(trans, card_index, child.size)
			
			child.set_root_trans(trans)
			card_index += 1


func _grid_layout(trans: CardTransform, grid_cell: int, card_size: Vector2):
	var width_ratio: float = 0.0
	var height_adjusted: float = 0.0
	var row_width: float = 0.0
	var col_height: float = 0.0
	var grid_offset: Vector2 = Vector2(0.0, 0.0)
	var spacing_offset: Vector2 = Vector2(0.0, 0.0)
	
	var _size = _cards.size()

	# Card size
	if not _grid_fixed_width:
		if _grid_columns > 0:
			_grid_card_width = rect_size.x / (_grid_columns * _grid_card_spacing.x)
		else:
			_grid_card_width = rect_size.x / (_size * _grid_card_spacing.x)

	width_ratio = _grid_card_width / card_size.x
	height_adjusted = card_size.y * width_ratio

	# Grid offset
	if _grid_columns > 0:
		row_width = _grid_columns * _grid_card_width * _grid_card_spacing.x
		col_height = ceil(_size / float(_grid_columns)) * height_adjusted * _grid_card_spacing.y
	else:
		row_width = _size * _grid_card_width * _grid_card_spacing.x
		col_height = height_adjusted * _grid_card_spacing.y

	if _grid_expand:
		if row_width > rect_size.x:
			rect_min_size.x = row_width

		if col_height > rect_size.y || _grid_columns > 0:
			rect_min_size.y = col_height

	spacing_offset.x = (_grid_card_width * _grid_card_spacing.x - _grid_card_width) / 2.0
	spacing_offset.y = (height_adjusted * _grid_card_spacing.y - height_adjusted) / 2.0

	match _grid_halign:
		HALIGN_LEFT:
			grid_offset.x = spacing_offset.x
		HALIGN_CENTER:
			grid_offset.x = spacing_offset.x + (rect_size.x - row_width) / 2.0
		HALIGN_RIGHT:
			grid_offset.x = spacing_offset.x + (rect_size.x - row_width)

	match _grid_valign:
		VALIGN_TOP:
			grid_offset.y = spacing_offset.y
		VALIGN_CENTER:
			grid_offset.y = spacing_offset.y + (rect_size.y - col_height) / 2.0
		VALIGN_BOTTOM:
			grid_offset.y = spacing_offset.y + (rect_size.y - col_height)

	var pos: Vector2 = Vector2(0.0 , 0.0)
	# Initial pos
	pos.x = _grid_card_width / 2.0
	pos.y = height_adjusted / 2.0

	# Cell align pos
	if _grid_columns > 0:
		pos.x += _grid_card_width * _grid_card_spacing.x * (grid_cell % _grid_columns)
		pos.y += height_adjusted * _grid_card_spacing.y * ceil(grid_cell / _grid_columns)
	else:
		pos.x += _grid_card_width * _grid_card_spacing.x * grid_cell

	# Grid align pos
	pos.x += grid_offset.x
	pos.y += grid_offset.y

	trans.scale = Vector2(width_ratio, width_ratio)
	trans.pos = pos


func _fine_tune(trans: CardTransform, card_index: int, card_size: Vector2):
	var card_count: float = _cards.size() - 1.0

	if fine_pos:
		match fine_pos_mode:
			FineTuningMode.LINEAR:
				if card_count > 0:
					trans.pos += lerp(
						fine_pos_min,
						fine_pos_max,
						card_index / card_count)
			FineTuningMode.SYMMETRIC:
				if card_count > 0:
					trans.pos += lerp(
						fine_pos_min,
						fine_pos_max,
						abs(((card_index * 2.0) / card_count) - 1.0))
			FineTuningMode.RANDOM:
				trans.pos += _rng.random_vec2_range(fine_pos_min, fine_pos_max)

	if fine_angle:
		match fine_angle_mode:
			FineTuningMode.LINEAR:
				if card_count > 0:
					trans.rot += lerp_angle(
						fine_angle_min,
						fine_angle_max,
						card_index / card_count)
			FineTuningMode.SYMMETRIC:
				if card_count > 0:
					trans.rot += lerp_angle(
						fine_angle_min,
						fine_angle_max,
						abs(((card_index * 2.0) / card_count) - 1.0))
			FineTuningMode.RANDOM:
				trans.rot += _rng.randomf_range(fine_angle_min, fine_angle_max)

	if fine_scale:
		match fine_scale_mode:
			FineTuningMode.LINEAR:
				if card_count > 0:
					trans.scale *= lerp(
						fine_scale_min,
						fine_scale_max,
						card_index / card_count)
			FineTuningMode.SYMMETRIC:
				if card_count > 0:
					trans.scale *= lerp(
						fine_scale_min,
						fine_scale_max,
						abs(((card_index * 2.0) / card_count) - 1.0))
			FineTuningMode.RANDOM:
				match fine_scale_ratio:
					AspectMode.IGNORE:
						trans.scale *= _rng.random_vec2_range(fine_scale_min, fine_scale_max)
					AspectMode.KEEP:
						var random_scale = _rng.randomf_range(fine_scale_min.x, fine_scale_max.x)
						trans.scale *= Vector2(random_scale, random_scale)
