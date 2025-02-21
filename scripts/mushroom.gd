extends CharacterBody2D

# States
enum State {
	IDLE_LEFT,
	IDLE_RIGHT,
	RUN_LEFT,
	RUN_RIGHT,
	DEAD
}

# Variables
@onready var health = get_meta("Health")
var isDead = false
var last_direction = Vector2.ZERO
@onready var player = get_node("/root/Game/Player")
var current_state = State.IDLE_RIGHT

# Mob Flash Effect
func flash_red():
	var original_color = self.modulate
	self.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	self.modulate = original_color

# Mob Damage Handling
func take_damage():
	health -= player.get_meta("Damage")
	
	if health <= 0 and not isDead:
		die()
	else:
		flash_red()

# Handle Death
func die():
	print("Died")
	isDead = true
	change_state(State.DEAD)
	$Mushroom.set_meta("Speed", 0)
	$Mushroom.stop()
	$Mushroom.play("die_left")
	
	await get_tree().create_timer(1.4).timeout
<<<<<<< HEAD

	# Call the player's _on_mushroom_enemy_killed() directly
	if player:
		player._on_mushroom_enemy_killed()
		queue_free()

	emit_signal("enemy_killed")  # Emit the custom signal
=======
>>>>>>> parent of 306a77f (Update)
	queue_free()

# Change Animation State
func change_state(new_state):
	if new_state != current_state:
		current_state = new_state
		update_animation()

# Update Animation Based on State
func update_animation():
	match current_state:
		State.RUN_LEFT:
			$Mushroom.play("run_left")
		State.RUN_RIGHT:
			$Mushroom.play("run_right")
		State.IDLE_LEFT:
			$Mushroom.play("idle_left")
		State.IDLE_RIGHT:
			$Mushroom.play("idle_right")
		State.DEAD:
			# Death animation or logic can be handled here (optional)
			pass

# Movement Logic
func _physics_process(_delta: float) -> void:
	if health <= 0:  # Skip movement if dead
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * get_meta("Speed")
	move_and_slide()

	if velocity.length() > 0.0:
		update_movement_state(direction)
	else:
		update_idle_state()

# Update Movement State
func update_movement_state(direction):
	if direction.x < 0:
		last_direction.x = -1
		change_state(State.RUN_LEFT)
	elif direction.x > 0:
		last_direction.x = 1
		change_state(State.RUN_RIGHT)

# Update Idle State
func update_idle_state():
	if last_direction.x < 0:
		change_state(State.IDLE_LEFT)
	elif last_direction.x > 0:
		change_state(State.IDLE_RIGHT)
