extends Area2D

# Constants
const SPEED = 1000
const RANGE = 1200

# Variables
var travelled_distance = 0.0

func _ready():
	# Initialize the travelled distance based on position at start
	travelled_distance = 0

func _physics_process(delta: float) -> void:
	# Calculate the direction and move the object
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta

	# Check if the object has traveled beyond the defined range and free the object
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Immediately free the object upon collision
	queue_free()

	# Check if the body has a take_damage method and apply damage
	if body is Node2D and body.has_method("take_damage"):
		body.take_damage()
