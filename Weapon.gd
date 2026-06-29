extends Node2D
class_name Weapon

export var active := true
export var logs = false
export var chargeable_without_ammo := false
export var shots : Array
export var max_shots_alive := 5
export var max_charged_shots_alive := 3
var shots_currently_alive := 0
var charged_shots_currently_alive := 0
export var max_ammo := 100.0
export var ammo_per_shot := 1.0
onready var arm_cannon = get_parent()
onready var character := get_parent().get_parent()
var current_ammo := 100.0

export var MainColor1 : Color
export var MainColor2 : Color
export var MainColor3 : Color
export var MainColor4 : Color
export var MainColor5 : Color
export var MainColor6 : Color

func _ready() -> void:
	current_ammo = max_ammo
	#Event.listen("shot_lemon_expent_ammo", self,"expent_ammo")

func get_charge_color() -> Color:
	Log("Getting Charge Color")
	Log(MainColor2)
	return MainColor2
	
func get_palette() -> Array:
	Log("Getting Palette")
	Log([MainColor1,MainColor2,MainColor3,MainColor4,MainColor5,MainColor6])
	return [MainColor1,MainColor2,MainColor3,MainColor4,MainColor5,MainColor6]

func get_ammo() -> float:
	return current_ammo

func can_shoot() -> bool:
	return get_ammo() > 0 and shots_currently_alive < max_shots_alive

func fire(charge_level := 0) -> void:
	clamp_to_max_charge(charge_level)
	add_projectile_to_scene(charge_level)
	reduce_ammo(ammo_per_shot)
	Event.emit_signal("shot", self)

func has_ammo() -> bool:
	return true

func is_cooling_down() -> bool:
	return false

func reduce_ammo(expent):
	current_ammo -= expent
	Log ("expent ammo. Current: " + str(current_ammo))

func add_projectile_to_scene(charge_level : int):
	var _shot
	_shot = shots[charge_level].instance()
	get_tree().current_scene.add_child(_shot,true)
	position_shot(_shot)
	if charge_level != 0:
		connect_charged_shot_event(_shot)
	else:
		connect_shot_event(_shot)
	Log("fired a " + _shot.name + "at " + str(_shot.position))
	return _shot

func connect_shot_event(_shot):
	_shot.connect("projectile_started", self,"on_shot_created")
	_shot.connect("projectile_end", self,"on_shot_end")

func connect_charged_shot_event(_shot):
	_shot.connect("projectile_started", self,"on_charged_shot_created")
	_shot.connect("projectile_end", self,"on_charged_shot_end")

func on_shot_created():
	shots_currently_alive += 1

func on_charged_shot_created():
	charged_shots_currently_alive += 1

func on_shot_end(_shot):
	shots_currently_alive -= 1

func on_charged_shot_end(_shot):
	charged_shots_currently_alive -= 1

func clamp_to_max_charge(charge_level):
	if charge_level > shots.size()-1:
		charge_level = shots.size()-1

func position_shot(shot) -> void:
	shot.global_position = character.global_position
	shot.projectile_setup(character.get_facing_direction(), character.shot_position.position)

func recharge_ammo(value:= ammo_per_shot):
	current_ammo = current_ammo + value
	if current_ammo == max_ammo:
		Log ("recharged to Max Ammo. \n")
	if current_ammo > max_ammo:
		current_ammo = max_ammo
		Log ("Error! Ammo over the limit.")
	
func expent_ammo(_weapon, emitter):
	if emitter != self:
		Log ("expent ammo, heard event. Current: " + str(current_ammo))
		current_ammo = current_ammo - ammo_per_shot

func Log(msg):
	if logs:
		print (get_parent().name + "." + name + ": " + str(msg))
