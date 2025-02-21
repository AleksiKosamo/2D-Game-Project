extends Control

func _ready() -> void:
	$".".visible = false
	%AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	%AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	%AnimationPlayer.play("blur")
	
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		$".".visible = true
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		$".".visible = false
		resume()
		

func _on_resume_pressed() -> void:
	$".".visible = false
	resume()


func _on_restart_pressed() -> void:
	$".".visible = false
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _process(_delta: float) -> void:
	testEsc()
