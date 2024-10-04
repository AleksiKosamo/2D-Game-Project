extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var mushroom = $"."
var last_direction = Vector2.ZERO

func _physics_process(_delta):
	var direction = player.global_position.y
	var directionx = player.global_position.x
	print(direction,",  ",directionx)
	
	if direction > mushroom.global_position.y:
		velocity.y = 200
	else:
		velocity.y = -200
		
	if directionx > mushroom.global_position.x:
		velocity.x = 200
	else:
		velocity.x = -200
	move_and_slide()
	
	if velocity.length() > 0.0:
		if mushroom.global_position.x > directionx:
			%Mushroom.play("run_left")
		elif mushroom.global_position.x < directionx:
			%Mushroom.play("run_right")
			
			
