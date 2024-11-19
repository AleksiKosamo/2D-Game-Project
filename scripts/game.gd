extends Node2D

# Export variables for customization
@export var round_duration: float = 3  # 2 minutes per round
@export var total_rounds: int = 100
@export var spawn_interval: float = 0.1  # Time between enemy spawns
@export var base_enemies_per_round: int = 5  # Base number of enemies in the first round
@onready var enemy_scene = preload("res://scenes/mushroom.tscn")
@onready var path_node = %Spawn  # Assign your Path2D in the editor
@onready var game_over_ui = %GameOver  # Reference to the Game Over UI
@onready var play_again_button = %Restart  # Reference to the Play Again button

# State variables
var current_round: int = 0
var is_round_active: bool = false

func _ready() -> void:
	
	# Start the game
	start_next_round()

# Manage rounds
func start_next_round() -> void:
	if current_round >= total_rounds:
		end_game()
		return

	current_round += 1
	is_round_active = true
	print("Round %d / %d Start!" % [current_round, total_rounds])

	spawn_enemies_for_round()
	start_round_timer()

func start_round_timer() -> void:
	var round_time_left = round_duration
	while round_time_left > 0 and is_round_active:
		await get_tree().create_timer(1.0).timeout
		round_time_left -= 1

		# Check if all enemies are dead
		if get_tree().get_nodes_in_group("enemies").is_empty():
			print("All enemies defeated before timer ended!")
			break

	if is_round_active:
		end_round()

func end_round() -> void:
	is_round_active = false
	print("Round %d Complete!" % current_round)

	# Wait a moment before starting the next round
	await get_tree().create_timer(2.0).timeout
	start_next_round()

func end_game() -> void:
	print("All Rounds Complete! Congratulations!")

	# Show the Game Over UI
	get_tree().paused = true  # Pause the game on Game Over

# Enemy spawning
func spawn_enemies_for_round() -> void:
	var enemies_to_spawn = base_enemies_per_round + (current_round - 1) * randi_range(3, 7)  # Scale enemy count per round
	print("Spawning %d enemies this round!" % enemies_to_spawn)

	for i in range(enemies_to_spawn):
		if not is_round_active:
			break  # Stop spawning if the round ends prematurely

		var enemy = enemy_scene.instantiate()

		# Place the enemy at a random position along the path
		path_node.progress_ratio = randf()
		enemy.position = path_node.position

		# Add enemy to the scene
		add_child(enemy)

		# Add the enemy to the "enemies" group
		enemy.add_to_group("enemies")

		# Wait before spawning the next enemy
		await get_tree().create_timer(spawn_interval).timeout

# Function to handle when the player health is depleted (Game Over)
func _on_player_health_depleted() -> void:
	get_tree().paused = true  # Pause the game on Game Over
	%GameOver.visible = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
