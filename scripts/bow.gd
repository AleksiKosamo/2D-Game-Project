extends Area2D

# Preload the arrow scene
const ARROW = preload("res://scenes/arrow.tscn")

var cd = false
@onready var timer = $Timer

func _physics_process(_delta: float) -> void:
	
	look_at(get_global_mouse_position())  # Make the Area2D face the enemy
	
func shoot():
	# Instantiate a new arrow and position it at the ShootingPoint
	var new_arrow = ARROW.instantiate()
	new_arrow.global_position = %ShootingPoint.global_position
	new_arrow.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_arrow)
	

func _input(event):
	if event.is_action_pressed("shoot") and cd == false:
		shoot()
		timer.start()
		cd = true


func _on_timer_timeout() -> void:
	cd = false
