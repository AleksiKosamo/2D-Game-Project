extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var mushroom = $"." 
var last_direction = Vector2.ZERO

func _physics_process(_delta):
	var player_pos = player.global_position
	var mushroom_pos = mushroom.global_position
	
	# Reset velocity at the start of the process
	velocity = Vector2.ZERO

	# Calculate velocity based on player position
	if player_pos.y > mushroom_pos.y:
		velocity.y = 200
	elif player_pos.y < mushroom_pos.y:
		velocity.y = -200
	
	if player_pos.x > mushroom_pos.x:
		velocity.x = 200
		last_direction = Vector2.RIGHT
	elif player_pos.x < mushroom_pos.x:
		velocity.x = -200
		last_direction = Vector2.LEFT
	
	# Move the character based on the calculated velocity
	move_and_slide()

	if velocity.length() > 0.0:
		print(player_pos.x, ", ", mushroom_pos.x)
		
		# Only play the run animation if not directly aligned on the x-axis
		if abs(mushroom_pos.x - player_pos.x) >= 10:
			%Mushroom.play("run_left" if last_direction == Vector2.LEFT else "run_right")
		else:
			# If very close in x but not moving, ensure we don't play running animation
			%Mushroom.play("idle_right" if last_direction == Vector2.RIGHT else "idle_left")
	else:
		%Mushroom.play("attack_right" if last_direction == Vector2.RIGHT else "attack_left")
