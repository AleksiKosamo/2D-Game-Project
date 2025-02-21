extends Node2D

# Export variables for customization
@export var round_duration: int = 180  # 3 minutes per round
@export var total_rounds: int = 100
@export var spawn_interval: float = 0.1  # Time between enemy spawns
@export var base_enemies_per_round: int = 5  # Base number of enemies in the first round

@onready var enemy_scene = preload("res://scenes/mushroom.tscn")  # Regular enemy scene
@onready var boss_scene = preload("res://scenes/mushroomBoss.tscn")  # Boss enemy scene (larger enemy)

@onready var path_node = %Spawn  # Assign your Path2D in the editor
@onready var player = %Player  # Reference to the player node

# HUD Elements
@onready var round_label = %Hud/RoundLabel  # Assuming the label node is inside a HUD node
@onready var enemies_left_label = %Hud/EnemiesLeftLabel
@onready var time_left_label = %Hud/TimeLeftLabel

# State variables
var current_round: int = 0
var is_round_active: bool = false
var round_time_left: int = 0


func _ready() -> void:
	# Initialize HUD
	round_label.text = "Round: 1 / %d" % total_rounds
	enemies_left_label.text = "Enemies: 0"
	time_left_label.text = "Time Left: %d" % round_duration
	# Start the game
	start_next_round()


func update_hud() -> void:
	round_label.text = "Round: %d / %d" % [current_round, total_rounds]
	# Get the number of enemies left in the "enemies" group
	var enemies_left = get_tree().get_nodes_in_group("enemies").size()
	enemies_left_label.text = "Enemies: %d" % enemies_left
	time_left_label.text = "Time Left: %d" % round_time_left


# Manage rounds
func start_next_round() -> void:
	if current_round >= total_rounds:
		end_game()
		return

	current_round += 1
	is_round_active = true
	round_time_left = round_duration
	update_hud()

	print("Round %d / %d Start!" % [current_round, total_rounds])

	spawn_enemies_for_round()
	start_round_timer()


func start_round_timer() -> void:
	while round_time_left > 0 and is_round_active:
		await get_tree().create_timer(1.0).timeout
		round_time_left -= 1

		# Update time on the HUD
		update_hud()

		# Check if all enemies are dead
		if get_tree().get_nodes_in_group("enemies").is_empty():
			print("All enemies defeated before timer ended!")
			break

	if is_round_active:
		end_round()


# End Round
func end_round() -> void:
	is_round_active = false
	print("Round %d Complete!" % current_round)

	await get_tree().create_timer(2.0).timeout
	start_next_round()


# End Game
func end_game() -> void:
	print("All Rounds Complete! Congratulations!")
	get_tree().paused = true


# Spawn enemies for the current round
func spawn_enemies_for_round() -> void:
	print("Spawning enemies this round!")

	var enemies_to_spawn = base_enemies_per_round + (current_round - 1) * randi_range(3, 7)

	for i in range(enemies_to_spawn):
		if not is_round_active:
			break

		var enemy
		# Spawn boss enemy every 5th round and for the first enemy of each round
		if current_round % 5 == 0 or i == 0:
			enemy = boss_scene.instantiate()
			enemy.scale = Vector2(2, 2)
		else:
			enemy = enemy_scene.instantiate()

		# Get a random position along the path
		path_node.progress_ratio = randf()
		enemy.position = path_node.position

		# Add the enemy to the scene and group
		add_child(enemy)
		enemy.add_to_group("enemies")

		# Initialize enemy health, damage, and speed if needed
		if not enemy.has_meta("Health"):
			enemy.set_meta("Health", 100)
		if not enemy.has_meta("Damage"):
			enemy.set_meta("Damage", 10)
		if not enemy.has_meta("Speed"):
			enemy.set_meta("Speed", 100)

		# Connect the enemy killed signal
		enemy.connect("enemy_killed", _on_enemy_killed)

		# Wait before spawning the next enemy
		await get_tree().create_timer(spawn_interval).timeout


func _on_enemy_killed() -> void:
	update_hud()  # Update the HUD when an enemy is killed
	if get_tree().get_nodes_in_group("enemies").is_empty():
		print("All enemies defeated!")
		end_round()
