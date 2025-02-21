extends Node2D

# Export variables for customization
@export var round_duration: float = 3  # 2 minutes per round
@export var total_rounds: int = 100
@export var spawn_interval: float = 0.1  # Time between enemy spawns
@export var base_enemies_per_round: int = 5  # Base number of enemies in the first round

@onready var enemy_scene = preload("res://scenes/mushroom.tscn")  # Regular enemy scene
@onready var boss_scene = preload("res://scenes/mushroomBoss.tscn")  # Boss enemy scene (larger enemy)

@onready var path_node = %Spawn  # Assign your Path2D in the editor
<<<<<<< HEAD
@onready var player = %Player  # Reference to the player node

# HUD Elements
@onready var round_label = %Hud/RoundLabel  # Assuming the label node is inside a HUD node
@onready var enemies_left_label = %Hud/EnemiesLeftLabel
@onready var time_left_label = %Hud/TimeLeftLabel
=======
@onready var game_over_ui = %GameOver  # Reference to the Game Over UI
@onready var play_again_button = %Restart  # Reference to the Play Again button
>>>>>>> parent of 306a77f (Update)

# State variables
var current_round: int = 0
var is_round_active: bool = false
<<<<<<< HEAD
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


=======

func _ready() -> void:
	
	# Start the game
	start_next_round()

>>>>>>> parent of 306a77f (Update)
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

<<<<<<< HEAD

=======
>>>>>>> parent of 306a77f (Update)
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


# End Round
func end_round() -> void:
	is_round_active = false
	print("Round %d Complete!" % current_round)

	await get_tree().create_timer(2.0).timeout
	start_next_round()


# End Game
func end_game() -> void:
	print("All Rounds Complete! Congratulations!")
<<<<<<< HEAD
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
=======

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
>>>>>>> parent of 306a77f (Update)

		# Place the enemy at a random position along the path
		path_node.progress_ratio = randf()
		enemy.position = path_node.position

		# Add enemy to the scene
		add_child(enemy)

		# Add the enemy to the "enemies" group
		enemy.add_to_group("enemies")

		# Wait before spawning the next enemy
		await get_tree().create_timer(spawn_interval).timeout

<<<<<<< HEAD

func _on_enemy_killed() -> void:
	update_hud()  # Update the HUD when an enemy is killed
	if get_tree().get_nodes_in_group("enemies").is_empty():
		print("All enemies defeated!")
		end_round()
=======
# Function to handle when the player health is depleted (Game Over)
func _on_player_health_depleted() -> void:
	get_tree().paused = true  # Pause the game on Game Over
	%GameOver.visible = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
>>>>>>> parent of 306a77f (Update)
