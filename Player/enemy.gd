extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0
var health = 10;

@onready var ap = $AnimationPlayer;
@onready var sprite = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D

var is_crouching = false;


# G  et the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("AnimationPlayer");

func callback():
	anim.play("death")
	await get_tree().create_timer(1.0).timeout
	return self

func check_health():
	print(health);
	if(health <= 0):
		
		await callback();
		
		print("die")
		self.queue_free()
		
		#await sprite.animation_finished()
		
		

func _physics_process(delta):
	check_health();
	
	# Add the gravity.
	if health > 0:
		if not is_on_floor() :
			velocity.y += gravity * delta
			print(velocity.y)
			
		
		# Handle jump.
		if Input.is_action_just_pressed("death"):
			health = 0;
		
		if Input.is_action_just_pressed("ui_accept"):
			if is_on_floor() :
				velocity.y = JUMP_VELOCITY
				anim.play("jump");
				
			
			
		if Input.is_action_just_pressed("shift") and is_on_floor():
			anim.play("crouch");
			cshape.position.y = 10;
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true;
		elif direction == 1:
			get_node("AnimatedSprite2D").flip_h = false;
		if direction:
			velocity.x = direction * SPEED
			
					
					
					
					
		else:
			if velocity.y == 0 :
				if health >0:
					anim.play("idle");
				
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		var fall_speed = velocity.y;
		move_and_slide()
		
		



