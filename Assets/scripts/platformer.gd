extends Node2D
# By the Tutorial Doctor
# Sun Oct 18 22:22:10 EDT 2015

var current_level

#------------------------------------------------------------
# First, make variables for all of the things that will be in your game
var tutorial1_is_done
var player
var player_animation
var random_jumpingsound
var player_samples
var paint_sign
var ray
export var move_speed = 200
var ground
var water
var timer
var player_sprite
export var height_speed = -1000
# This variable is exported so we can change it for each level
export var next_level = ''
#------------------------------------------------------------

func get_random_number():
    randomize()
    return randi()%4

# The _ready() function is where we will set up everything.
#------------------------------------------------------------
func _ready():
	# Make sure to always enable the _process() function. This is your game loop.
	set_process(true)
	current_level = get_tree().get_current_scene().get_filename()
	# Now we set nodes to those variables we created:
	# Get the player node. It is a RigidBody node.
	# The player node should have Sprite,CollisionShape2D, and RayCast2D nodes as children
	player = get_node("Player")
	# Get the player's animation node. It is an AnimationPlayer node
	player_animation = get_node("AnimationPlayer")
	# Make the player able to monitor collision
	player.set_contact_monitor(true)
	# Also you have to make sure all collisions are reported
	player.set_max_contacts_reported(true)
	# The two steps above could be eliminated, but you need them both to do collision detection for Rigidbodies
	# Setting the mode of the player rigidbody to 2 makes it not rotate unecessarily 
	player.set_mode(2)
	# If you want the player to have sound effects, you have to store them in a sample player node
	player_samples = get_node("SamplePlayer")
	
	# The paint sign indicates that the painter can paint.
	paint_sign = get_node("Paint_Sign")
	
	# The player's Raycast2D node checks for collision in a certain direction
	ray = get_node("Player/RayCast2D")
	# So that the RayCast doesn't detect collisions with the player we need to make the player an exception.
	# Now the ray will not detect collision with the player node.
	ray.add_exception(player)

	# This node is a StaticBody. We will check collisions with it to restart the level.
	water = get_node("Water")
	ground = get_node("Ground")

	# Timer nodes are used to do things once a certain amount of time has passed. 
	timer = get_node("Timer")
	
	# Player Sprite
	player_sprite = get_node("Player/Sprite")
	#player_sprite = get_node("Player/Sprite 2")
#------------------------------------------------------------


# Custom functions make life easier sometimes
#------------------------------------------------------------
# This function returns true if the RayCast2D node is colliding with something, otherwise it returns false
func on_ground():
	return ray.is_colliding()

# This function goes to the next level. You can use the connect() function to connect a signal to this function
func next_level():
	get_tree().change_scene(next_level)
# END CUSTOM FUNCTIONS
#------------------------------------------------------------


# This is the game loop or draw() function of Godot.
#------------------------------------------------------------
func _process(delta):
	# If the RayCast2D is colliding with something (if it is on_ground()...
	if on_ground():
		# And if the "up" action is pressed...
		if Input.is_action_pressed("ui_up"):
			# And if the player_animation AnimationPlayer is not playing (already)...
			if not player_animation.is_playing():
				# Then play the "squash" animation,
				#player_animation.play('squash') #not created yet
				# Set the axis_velocity on the y axis to -1000,
				player.set_axis_velocity(Vector2(0,height_speed))
				# And play the "jump" sample sound
				
				random_jumpingsound = get_random_number()
				if random_jumpingsound == 1:
					player_samples.play('jump')
				if random_jumpingsound == 2:
					player_samples.play('jump2')
				if random_jumpingsound == 3:
					player_samples.play('jump3')
	
	# Also, if the RayCast2D is colliding with something (if it is on_ground()...
	if on_ground():
		# And if the "left" action is pressed...
		if Input.is_action_pressed('ui_left'):
			# Set the axis_velocity on the x axis to minus the speed variable.
			player.set_axis_velocity(Vector2(-move_speed,0))
			#player_sprite.set('flip_h',true)
		# And if the "right" action is pressed...
		if Input.is_action_pressed('ui_right'):
			# Set the axis_velocity on the x axis the speed variable.
			player.set_axis_velocity(Vector2(move_speed,0))
			#player_sprite.set('flip_h',false)
		
	# If the artist is next to the Paint Sign
	if(paint_sign in player.get_colliding_bodies() && tutorial1_is_done != true):
		get_node("Artist_Tutorial").show()
		get_tree().set_pause(true)
		if Input.is_action_pressed('enter'):
			get_tree().set_pause(false)
			get_node('Artist_Tutorial').hide()
			tutorial1_is_done=true
	if(paint_sign in player.get_colliding_bodies() && tutorial1_is_done == true && Input.is_action_pressed('ctrl')):
		get_node("Painted_Platform").show()
		get_node("Painted_Platform/CollisionShape2D").set_trigger(false)
	
	# If the water is part of the player's colliding bodies...
	if water in player.get_colliding_bodies():
		player_samples.play('splash')
	
			# If the ground is part of the player's colliding bodies...
	if ground in player.get_colliding_bodies():
		# reload the current scene
		player_samples.play('jump')
		get_tree().reload_current_scene()
	
	# If the "esc" or "Q" buttons are pressed...
	if Input.is_key_pressed(16777217) or Input.is_key_pressed(81): 
	#16777217 is the scancode for the escape key under @GlobalScope in the API
		# Quit the game
		get_tree().quit()
	# If the "R" key is pressed... 
	if Input.is_key_pressed(82):
	#82 is the scancode for the 'R' key under @GlobalScope in the API
		# Reload the scene
		get_tree().reload_current_scene()
		
			
# AND THAT IS ALL YOU NEED FOR A PLATFORMER BASE GAME!!!

# Duplicate this level and move the platforms around and you have a new level. 
# Be sure to change the Next Level property we exported for each level.