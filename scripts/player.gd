extends CharacterBody2D

# Variables
@onready var health = %Player.get_meta("Health")
var last_direction = Vector2.ZERO
<<<<<<< HEAD
# Player Stats
var player_level = 1
var health_base = 100  # Starting health value (adjust this as needed)
@onready var damage_base = %Player.get_meta("Damage")   # Starting damage value (adjust this as needed)
var health_growth_per_level = 15  # How much health increases with each level
var damage_growth_per_level = 2   # How much damage increases with each level

# Experience System
var exp = 0  # Current EXP
var exp_to_next_level = 100  # EXP required to level up
var exp_gain_per_kill = 50  # EXP gained per enemy kill
=======
>>>>>>> 306a77f3d74a621e7447a1d32db8e8bad6d7d912

# States
enum State {
	IDLE,
	RUNNING
}

# Current state
var current_state = State.IDLE

signal health_depleted

<<<<<<< HEAD
=======
const DAMAGE_RATE = 10
>>>>>>> 306a77f3d74a621e7447a1d32db8e8bad6d7d912
const MOVE_SPEED = 600.0

# Apply damage and update health
func apply_damage(delta):
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()

	if overlapping_mobs.size() > 0:
<<<<<<< HEAD
		health -= damage_base * overlapping_mobs.size() * delta
=======
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
>>>>>>> 306a77f3d74a621e7447a1d32db8e8bad6d7d912
		%ProgressBar.value = health
		
		if health <= 0.0:
			health = 0.0  # Prevent going negative
<<<<<<< HEAD
			get_tree().paused = true
=======
>>>>>>> 306a77f3d74a621e7447a1d32db8e8bad6d7d912
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

<<<<<<< HEAD
# Level Up Function
func level_up():
	# Increase level by 1
	player_level += 1
	
	# Increase health and damage based on the level
	health_base += health_growth_per_level
	damage_base += damage_growth_per_level
	
	# Update the player's health and damage
	health = health_base
	%ProgressBar.max_value = health_base
	
	# Reset EXP to 0 for the next level and set new EXP required for the next level
	exp = 0
	exp_to_next_level = int(exp_to_next_level * 1.2)  # Increase the amount of EXP needed for the next level
	
	# Optionally, display level-up message or animation here
	%LevelUp.visible = true
	%LevelUp/LevelUp.text = "Level up! New Level: " + str(player_level)
	%LevelUp/DamageIncrease.text = "New Health: " + str(health_base)
	%LevelUp/HealthIncrease.text = "New Damage: " + str(damage_base)
	%Hud/Level.text = "Level " + str(player_level)
	await get_tree().create_timer(2).timeout
	%LevelUp.visible = false
	
	# You can also implement a UI update here to reflect the new level, health, and damage stats.

		
# Example of how to trigger level-up when needed (you could use experience points or a specific condition)
func _on_mushroom_enemy_killed() -> void:
	print("Enemy defeated! Granting EXP...")
	exp += exp_gain_per_kill
	
	# Check if the player has enough EXP to level up
	if exp >= exp_to_next_level:
		level_up()
	
	# Update the EXP bar UI
	update_exp_bar()

# Update the EXP bar UI
func update_exp_bar():
	%ExpBar.value = exp
	%ExpBar.max_value = exp_to_next_level
=======

func _on_health_depleted() -> void:
	get_tree().paused = true
	%Gameover.Visible = true
>>>>>>> 306a77f3d74a621e7447a1d32db8e8bad6d7d912
