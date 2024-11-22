extends CharacterBody2D

# Variables
@onready var health = %Player.get_meta("Health")
var last_direction = Vector2.ZERO

# States
enum State {
	IDLE,
	RUNNING
}

# Current state
var current_state = State.IDLE

signal health_depleted

const DAMAGE_RATE = 10
const MOVE_SPEED = 600.0

# Apply damage and update health
func apply_damage(delta):
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()

	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = health
		
		if health <= 0.0:
			health = 0.0  # Prevent going negative
			%GameOver.visible = true

# Update the player's animations based on the state and direction
func update_animation():
	var animation_name = ""

	# Determine the base animation name based on the current state
	match current_state:
		State.IDLE:
			animation_name = "idle"
		State.RUNNING:
			animation_name = "run"

	# Flip the character horizontally based on the movement direction
	if last_direction.x < 0:
		$Wizard.flip_h = true  # Flip to the left
	elif last_direction.x > 0:
		$Wizard.flip_h = false  # Flip to the right

	# Play the correct animation
	$Wizard.play(animation_name)

# Handle movement and state updates
func _physics_process(delta):
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * MOVE_SPEED
	move_and_slide()

	# Update movement state
	if direction.length() > 0.0:
		current_state = State.RUNNING
		last_direction.x = direction.x  # Set last_direction based on current input
	else:
		current_state = State.IDLE

	# Apply damage based on overlapping bodies
	apply_damage(delta)

	# Update animation
	update_animation()


func _on_health_depleted() -> void:
	get_tree().paused = true
	%Gameover.Visible = true
