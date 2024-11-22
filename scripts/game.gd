extends Node2D

# Upgrades
enum UpgradeType {
	DAMAGE,
	HEALTH,
	ATTACK_SPEED,
	MOVEMENT_SPEED,
	SPAWN_RATE
}

class Upgrade:
	var upgrade_type: UpgradeType
	var value: float

	func _init(upgrade_type: UpgradeType, value: float) -> void:
		self.upgrade_type = upgrade_type
		self.value = value

# Export variables for customization
@export var round_duration: int = 180  # 3 minutes per round
@export var total_rounds: int = 100
@export var spawn_interval: float = 0.1  # Time between enemy spawns
@export var base_enemies_per_round: int = 5  # Base number of enemies in the first round
@onready var enemy_scene = preload("res://scenes/mushroom.tscn")
@onready var path_node = %Spawn  # Assign your Path2D in the editor
@onready var player = %Player  # Reference to the player node

# HUD Elements
@onready var round_label = %Hud/RoundLabel  # Assuming the label node is inside a HUD node
@onready var enemies_left_label = %Hud/EnemiesLeftLabel
@onready var time_left_label = %Hud/TimeLeftLabel
@onready var upgrade_popup = %Hud/UpgradePopup  # The upgrade popup for UI
@onready var upgrade_button_1 = %UpgradePopup/Button1
@onready var upgrade_button_2 = %UpgradePopup/Button2
@onready var upgrade_button_3 = %UpgradePopup/Button3

# State variables
var current_round: int = 0
var is_round_active: bool = false
var round_time_left: int = 0
var upgrades_earned: Array = []  # Array to hold earned upgrades
var current_upgrade_choices: Array = []  # Store current upgrades for each button

# Upgrade pool
var upgrade_pool: Array = [
	Upgrade.new(UpgradeType.DAMAGE, 5),
	Upgrade.new(UpgradeType.HEALTH, 20),
	Upgrade.new(UpgradeType.ATTACK_SPEED, 0.1),
	Upgrade.new(UpgradeType.MOVEMENT_SPEED, 0.1),
	Upgrade.new(UpgradeType.SPAWN_RATE, -0.02)
]

func _ready() -> void:
	# Initialize HUD
	round_label.text = "Round: 1 / %d" % total_rounds
	enemies_left_label.text = "Enemies: 0"
	time_left_label.text = "Time Left: 180"
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

	# Show upgrades every 5 rounds as an example
	if current_round % 5 == 0:
		show_upgrade_choices()

	# Adjust the upgrade pool after certain rounds for more challenge
	adjust_upgrade_pool()

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

func end_round() -> void:
	is_round_active = false
	print("Round %d Complete!" % current_round)

	# Wait a moment before starting the next round
	await get_tree().create_timer(2.0).timeout
	start_next_round()

func end_game() -> void:
	print("All Rounds Complete! Congratulations!")
	get_tree().paused = true  # Pause the game on Game Over

func spawn_enemies_for_round() -> void:
	print("Spawning enemies this round!")
	
	var enemies_to_spawn = base_enemies_per_round + (current_round - 1) * randi_range(3, 7)
	
	for i in range(enemies_to_spawn):
		if not is_round_active:
			break  # Stop spawning if the round ends prematurely
			
		var enemy = enemy_scene.instantiate()

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

# Show upgrade choices to the player
func show_upgrade_choices() -> void:
	var upgrade_choices = []
	for i in range(3):
		var upgrade = get_random_upgrade()
		upgrade_choices.append(upgrade)

	current_upgrade_choices = upgrade_choices  # Store choices for use in the button handlers

	upgrade_button_1.text = get_upgrade_display_text(upgrade_choices[0])
	upgrade_button_2.text = get_upgrade_display_text(upgrade_choices[1])
	upgrade_button_3.text = get_upgrade_display_text(upgrade_choices[2])

	upgrade_popup.popup_centered()  # Show the upgrade popup

# Get a random upgrade from the pool
func get_random_upgrade() -> Upgrade:
	if upgrade_pool.size() > 0:
		return upgrade_pool[randi_range(0, upgrade_pool.size() - 1)]
	else:
		# Return a default upgrade if the pool is empty
		return Upgrade.new(UpgradeType.DAMAGE, 5)  # Example default upgrade

# Get the display text for each upgrade
func get_upgrade_display_text(upgrade: Upgrade) -> String:
	if upgrade.upgrade_type == UpgradeType.DAMAGE:
		return "Damage +%d" % upgrade.value
	elif upgrade.upgrade_type == UpgradeType.HEALTH:	
		return "Health +%d" % upgrade.value
	elif upgrade.upgrade_type == UpgradeType.ATTACK_SPEED:
		return "Attack Speed +%.2f" % upgrade.value
	elif upgrade.upgrade_type == UpgradeType.MOVEMENT_SPEED:
		return "Movement Speed +%.2f" % upgrade.value
	elif upgrade.upgrade_type == UpgradeType.SPAWN_RATE:
		return "Spawn Rate +%.2f" % upgrade.value
	else:
		return "Unknown Upgrade"

# Apply the selected upgrade
func _on_button_1_pressed() -> void:
	var selected_upgrade = current_upgrade_choices[0]
	apply_upgrade(selected_upgrade)

func _on_button_2_pressed() -> void:
	var selected_upgrade = current_upgrade_choices[1]
	apply_upgrade(selected_upgrade)

func _on_button_3_pressed() -> void:
	var selected_upgrade = current_upgrade_choices[2]
	apply_upgrade(selected_upgrade)

# Function to apply an upgrade to the player
func apply_upgrade(upgrade: Upgrade) -> void:
	match upgrade.upgrade_type:
		UpgradeType.DAMAGE:
			player.set_meta("Damage", player.get_meta("Damage") + upgrade.value)
		UpgradeType.HEALTH:
			player.set_meta("Health", player.get_meta("Health") + upgrade.value)
		UpgradeType.ATTACK_SPEED:
			player.set_meta("AttackSpeed", player.get_meta("AttackSpeed") + upgrade.value)
		UpgradeType.MOVEMENT_SPEED:
			player.set_meta("MovementSpeed", player.get_meta("MovementSpeed") + upgrade.value)
		UpgradeType.SPAWN_RATE:
			# Adjust spawn rate if needed, for example:
			spawn_interval = max(spawn_interval + upgrade.value, 0.01)  # Avoid negative spawn rate

# Adjust the upgrade pool after certain rounds for more challenge
func adjust_upgrade_pool() -> void:
	if current_round > 10:
		upgrade_pool.append(Upgrade.new(UpgradeType.DAMAGE, 10))
		upgrade_pool.append(Upgrade.new(UpgradeType.HEALTH, 50))
