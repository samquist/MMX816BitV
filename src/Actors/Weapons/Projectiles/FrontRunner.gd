extends Lemon
class_name FrontRunner

var character : Character
var shot_angle := 0.0
var shot_speed := 300.0

onready var collision: CollisionShape2D = $collisionShape2D

func _ready() -> void:
	._ready()
	Event.listen("damage",self,"finish")
	Event.listen("player_death",self,"finish")
	if GameManager.is_player_in_scene():
		character = GameManager.player
		character.listen("cutscene_deactivate",self,"finish")
	lock_angle_based_on_input()
	set_velocity_based_on_angle()
	
	# Apply rotation immediately
	if get_facing_direction() < 0:
		rotation_degrees = -shot_angle
	else:
		rotation_degrees = shot_angle

func _physics_process(delta: float) -> void:
	._physics_process(delta)
	
	# Apply the rotation to the sprite; flip when facing left
	if get_facing_direction() < 0:
		rotation_degrees = -shot_angle
	else:
		rotation_degrees = shot_angle
	
func set_velocity_based_on_angle() -> void:
	# Convert the angle from degrees to radians for trig functions
	var angle_rad = deg2rad(shot_angle)
	# Calculate horizontal velocity: cos(angle) * speed
	# Positive = right, Negative = left
	var h_speed = cos(angle_rad) * shot_speed
	# Calculate vertical velocity: sin(angle) * speed
	# Positive = down, Negative = up
	var v_speed = sin(angle_rad) * shot_speed
	
	set_horizontal_speed(h_speed)
	set_vertical_speed(v_speed)
	
func lock_angle_based_on_input() -> void:
	if GameManager.is_player_in_scene():
		character = GameManager.player
		
		# Set projectile facing direction to match player
		set_direction(character.get_facing_direction())
		if character.get_facing_direction() > 0:
			collision.position.x = 21
		elif character.get_facing_direction() < 0:
			collision.position.x = 21
		# Mirror if facing left
		collision.position.x = collision.position.x * character.get_facing_direction()
		
		# Check if the player input
		var is_holding_up = Input.is_action_pressed("move_up") or Input.is_action_pressed("up_emulated")
		var is_holding_down = Input.is_action_pressed("move_down") or Input.is_action_pressed("down_emulated")
		
		# Set angle; rotation will be negated in _physics_process when facing left
		if get_facing_direction() > 0 and is_holding_up:
			shot_angle = -45
		elif get_facing_direction() > 0 and is_holding_down:
			shot_angle = 45
		elif get_facing_direction() < 0 and is_holding_up:
			shot_angle = -45
		elif get_facing_direction() < 0 and is_holding_down:
			shot_angle = 45
		else:
			shot_angle = 0

func _on_visibilityNotifier2D_screen_exited() -> void:
	countdown_to_destruction = 0.01

func call_screenexit_event():
	pass
	
func hit(target):
	if target.damage(damage,self) > 0:
		hit_time = 0.01
		emit_hit_particle()
		countdown_to_destruction = 0.01
		disable_projectile_visual()
		remove_from_group("Player Projectile")
		call_screenexit_event()
		if target.is_in_group("Enemies"):
			Event.emit_signal("charge_hit_enemy")

func deflect(_body) -> void:
	if is_in_group("Player Projectile"):
		.deflect(_body)
