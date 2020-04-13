extends KinematicBody2D

export (int) var gravity
export (int) var speed

const ground = Vector2(0, -1)
var velocity = Vector2()
var direction = -1

func _ready():
	$AnimationPlayer.play('walk')
	
func _physics_process(_delta):
	velocity.x = speed * direction
	velocity.y += gravity

	velocity = move_and_slide(velocity, ground)
	$Sprite.flip_h = true if direction > 0 else false
	
	if is_on_wall():
		direction *= -1
