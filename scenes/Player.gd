extends KinematicBody2D

export (int) var speed
export (int) var dash_speed
export (int) var gravity
export (int) var jump_power

const ground = Vector2(0, -1) 
var velocity = Vector2()
var jump_counts = 1
var combo = ["first_attack", "second_attack", "third_attack"]
var combo_counter = 0
var is_dashing = false
var is_attacking = false
var x_direction = 0

func _physics_process(_delta):
	move()
	check_attack()
	check_jump()
	check_fall()
	check_dash()
	reset_jump_counts()
	
	velocity.x = clamp(velocity.x, -150, 150)
	velocity.y = clamp(velocity.y, -300, 300)
	velocity = move_and_slide(velocity, ground)

func busy():
	return is_dashing or is_attacking

func moving():
	return velocity.length() > 0

func move():
	if not busy():
		if Input.is_action_pressed("ui_right"):
			move_right()
		
		if Input.is_action_pressed("ui_left"):
			move_left()
		
		if not Input.is_action_pressed("ui_select") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
			velocity.x = 0
			x_direction = 0
			if is_on_floor():
				$AnimationPlayer.play('idle')
		
		if moving():
			$AnimationPlayer.play('run')
	
	if is_dashing:
		if Input.is_action_pressed("ui_right"):
			dash_right()
		elif Input.is_action_pressed("ui_left"):
			dash_left()

func move_left():
	if x_direction > 0:
		velocity.x = 0
		
	x_direction = -1
	velocity.x -= 1 * speed
	$Sprite.flip_h = true
	
	var sword_hitbox = $Sprite.get_node("Area2D").get_node("SwordHitbox") 
	if sword_hitbox.get_rotation() == 0:
		$IdleHitbox.translate(Vector2(4, 0))
		sword_hitbox.rotate(PI)
	
func move_right():
	if x_direction < 0:
		velocity.x = 0
	
	x_direction = 1
	velocity.x += 1 * speed
	$Sprite.flip_h = false
	
	var sword_hitbox = $Sprite.get_node("Area2D").get_node("SwordHitbox") 
	if sword_hitbox.get_rotation() > 0:
		$IdleHitbox.translate(Vector2(-4, 0))
		sword_hitbox.rotate(-PI)

func check_dash():
	if Input.is_action_just_pressed("char_dash"):
		dash()
		
func dash():
	$DashTimer.start()
	$AnimationPlayer.play("dash")
	is_dashing = true

func dash_left():
	velocity.x -= 1 * dash_speed
	$Sprite.flip_h = true

func dash_right():
	velocity.x += 1 * dash_speed
	$Sprite.flip_h = false

func stop_dash():
	is_dashing = false

func check_jump():
	if Input.is_action_just_pressed("ui_up") and jump_counts < 2:
		jump()

func jump():
	velocity.y = jump_power
	jump_counts += 1

func check_attack():
	if Input.is_action_just_pressed("ui_select") and not is_dashing:
		attack()

func attack():
	if combo_counter + 1 <= combo.size():
		is_attacking = true
		$AnimationPlayer.play(combo[combo_counter])
		$AttackTimer.start()
		$ComboTimer.start()
		combo_counter += 1

func stop_attack():
	is_attacking = false

func check_fall():

	fall()

	if not is_on_floor():
		if not busy():
			$AnimationPlayer.play("fall" if velocity.y > 0 else "jump")
		elif is_dashing:
			$AnimationPlayer.play("dash")

func fall():
	velocity.y += gravity
	
func reset_jump_counts():
	if is_on_floor():
		jump_counts = 1

func reset_combo():
	combo_counter = 0

func _on_AnimationPlayer_animation_started(_anim_name):
	#print(anim_name)
	pass

func on_sword_hit(area):
	print(area)
