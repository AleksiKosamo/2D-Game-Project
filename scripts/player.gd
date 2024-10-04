extends CharacterBody2D

var last_direction = Vector2.ZERO

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		if direction.x < 0:
			last_direction.x = -1
			$Wizard.play("run_left")
		elif direction.x > 0:
			last_direction.x = 1
			$Wizard.play("run_right")
		elif direction.y < 0:
			if last_direction.x < 0:
				$Wizard.play("run_left")
			else:
				$Wizard.play("run_right")
		elif direction.y > 0:
			if last_direction.x < 0:
				$Wizard.play("run_left")
			else:
				$Wizard.play("run_right")
	else:
		if last_direction.x < 0:
			$Wizard.play("idle_left")
		elif last_direction.x > 0:
			$Wizard.play("idle_right")
