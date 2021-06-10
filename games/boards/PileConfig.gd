extends Resource

class_name PileConfig

export var name: String = "Pile"

#export(Pile.LayoutMode) var layout_mode: int = Pile.LayoutMode.GRID
export var face_up = true

# Grid parameters
export var grid_card_width: float = 80
export var grid_fixed_width: bool = true
export var grid_card_spacing: Vector2 = Vector2(0.5, 1)
var grid_halign: int = HALIGN_CENTER
var grid_valign: int = VALIGN_CENTER
var grid_columns: int = -1
var grid_expand: bool = false

# Interaction parameters
export var interactive: bool = true
export var exclusive: bool = false
export var last_only: bool = false
var drag_enabled: bool = false
var drop_enabled: bool = false

# Path parameters
var path_card_width: float = 200
var path_fixed_width: bool = true
var path_spacing: float = 0.5

# Position fine tuning
export var fine_pos: bool = true
#export(Pile.FineTuningMode) var fine_pos_mode = Pile.FineTuningMode.SYMMETRIC
export var fine_pos_min: Vector2 = Vector2(0.0, -20)
export var fine_pos_max: Vector2 = Vector2(0.0, 20)

# Angle fine tuning
export var fine_angle: bool = true
#export(Pile.FineTuningMode) var fine_angle_mode = Pile.FineTuningMode.LINEAR
export var fine_angle_value = 10.0
var fine_angle_min: float = deg2rad(-fine_angle_value)
var fine_angle_max: float = deg2rad(fine_angle_value)

# Scale fine tuning
export var fine_scale: bool = false
#export(Pile.FineTuningMode) var fine_scale_mode = Pile.FineTuningMode.LINEAR
#export(Pile.AspectMode) var fine_scale_ratio = Pile.AspectMode.KEEP
export var fine_scale_min: Vector2 = Vector2(0, 0)
export var fine_scale_max: Vector2 = Vector2(0, 0)

# Animation
export var anim: String = "hand"
export var adjust_mode: String = "focused"
export var adjust_pos_x_mode: String = "disabled"
export var adjust_pos_y_mode: String = "absolute"
export var adjust_pos: Vector2 = Vector2(0.0, 0.0)
export var adjust_scale_x_mode: String = "disabled"
export var adjust_scale_y_mode: String = "disabled"
export var adjust_scale: Vector2 = Vector2(0.0, 0.0)
export var adjust_rot_mode: String = "absolute"
export var adjust_rot: float = 0.0
