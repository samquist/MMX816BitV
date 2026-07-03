extends Weapon
class_name ShoulderWeapon

var is_attacking := false
var attack_duration := 0.5  # Match your animation length

func _ready() -> void:
	._ready()
	Event.listen("shot_lemon", self, "on_lemon_shot_created")

func on_lemon_shot_created(emitter, shot):
	if emitter != self:
		connect_shot_event(shot)

func add_projectile_to_scene(charge_level) -> void:
	var shot = .add_projectile_to_scene(charge_level)
	if charge_level < 1:
		Event.emit_signal("shot_lemon", self, shot)

func has_ammo() -> bool:
	return shots_currently_alive < max_shots_alive

func connect_charged_shot_event(_shot):
	_shot.connect("projectile_started", self, "on_charged_shot_created")
	_shot.connect("projectile_end", self, "on_charged_shot_end")
	if _shot.has_method("set_creator"):
		_shot.set_creator(arm_cannon.character)
	if _shot.has_method("initialize"):
		_shot.call_deferred("initialize", arm_cannon.character.get_facing_direction())

func fire(charge_level := 0) -> void:
	if is_attacking:
		return
	
	is_attacking = true
	
	# Get character reference
	var character = get_parent().get_parent()
	
	# Stop player movement and inputs
	character.stop_listening_to_inputs()
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	
	# Play attack animation
	character.play_animation_once("shot_strong")
	
	# Call parent fire to spawn projectile (this will call add_projectile_to_scene)
	.fire(charge_level)
	
	# Start timer to unlock
	Tools.timer(attack_duration, "_unlock_player", self)

func _unlock_player():
	is_attacking = false
	var character = get_parent().get_parent()
	character.start_listening_to_inputs()
	character.play_animation("idle")
