extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0
var health = 10;

@onready var ap = $AnimationPlayer;
@onready var sprite = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D
@onready var crcast1 = $RayCast2D_1
@onready var crcast2 = $RayCast2D_2
@onready var ctimer = $Timer
@onready var hp = get_node("CanvasLayer/hp")

var is_crouching = false;

var s_cshape = preload("res://resources/player_stand.tres");
var c_cshape = preload("res://resources/player_crouch.tres");
@onready var time = get_node("CanvasLayer/time")
@onready var timer = get_node("Timer2")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_coyote_jump = false;
@onready var anim = get_node("AnimationPlayer");

func above() -> bool:
	var result = !crcast1.is_colliding() && !crcast2.is_colliding();
	return result;

func text_update():
	time.text = str(snapped(timer.time_left, 0.01))

func _on_timer_timeout():
	can_coyote_jump = false;

func callback():
	anim.play("death")
	await get_tree().create_timer(1.0).timeout
	return self

func check_health():
	
	hp.text = str(health)
	if(health <= 0):
		
		await callback();
		
		print("die")
		self.queue_free()
		
		#await sprite.animation_finished()
		
		

func _physics_process(delta):
	text_update()
	check_health();
	
	# Add the gravity.
	if health > 0:
		if not is_on_floor() && not can_coyote_jump:
			velocity.y += gravity * delta
			
			
		
		# Handle jump.
		if Input.is_action_just_pressed("death"):
			health = 0;
		
		if Input.is_action_just_pressed("up"):
			if is_on_floor() or can_coyote_jump:
				velocity.y = JUMP_VELOCITY
				anim.play("jump");
				cshape.shape = s_cshape
				cshape.position.y = 0;
				if can_coyote_jump:
					can_coyote_jump = false;
			
			
		if Input.is_action_just_pressed("shift") and is_on_floor():
			anim.play("crouch");
			cshape.position.y = 10;
			cshape.shape = c_cshape;

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")
		print(direction)
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true;
		elif direction >= 0.97:
			get_node("AnimatedSprite2D").flip_h = false;
		if direction:
			velocity.x = direction * SPEED
			if velocity.y ==0 :
				if not Input.is_action_pressed("shift") and is_on_floor():
					anim.play("run");
					cshape.shape = s_cshape
					cshape.position.y = 0;
				elif  Input.is_action_pressed("shift+walk") and is_on_floor():
					
					velocity.x = direction*(100);
					
					
					cshape.shape = c_cshape;
					cshape.position.y = 10;
					anim.play("crouch_walk");
					
		else:
			if velocity.y == 0 && above():
				if health >0:
					anim.play("idle");
				cshape.shape = s_cshape
				cshape.position.y = 0;
			velocity.x = move_toward(velocity.x, 0, SPEED)
		var was_on_floor = is_on_floor();
		var fall_speed = velocity.y;
		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name == "RigidBody2D":
				get_tree().change_scene_to_file("res://win.tscn");
		
		if was_on_floor && !is_on_floor() && velocity.y >= 0:
			
			can_coyote_jump = true;
			ctimer.start()
		if !was_on_floor and is_on_floor():
			if fall_speed > 900:
				
				var damage = int(fall_speed/100 - 8);
				health -= damage;
	





func _on_timer_2_timeout():
	get_tree().change_scene_to_file("res://menu.tscn"); # Replace with function body. # Replace with function body.
