extends CharacterBody2D

@onready var health = get_meta("Health")

var last_direction = Vector2.ZERO
@onready var player = get_node("/root/Game/Player")

func take_damage():
	health -= player.get_meta("Damage")
	
	if health == 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * get_meta("Speed")
	move_and_slide()
	
	if velocity.length() > 0.0:
		if direction.x < 0:
			last_direction.x = -1
			$Mushroom.play("run_left")
		elif direction.x > 0:
			last_direction.x = 1
			$Mushroom.play("run_right")
		elif direction.y < 0:
			if last_direction.x < 0:
				$Mushroom.play("run_left")
			else:
				$Mushroom.play("run_right")
		elif direction.y > 0:
			if last_direction.x < 0:
				$Mushroom.play("run_left")
			else:
				$Mushroom.play("run_right")
