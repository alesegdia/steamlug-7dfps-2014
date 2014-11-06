
extends RigidBody

# Game stuff
var win_hsize
var exit_game = false

# Movement
var walk_speed = 1
var jump_force = 10
var max_speed = 10

# Camera
var camera
var rotation = Vector2(0,0)
var max_pitch = deg2rad(80)

# Lantern
var lantern
var lantern_now = false
var lantern_then = false

func _ready():
	camera = get_node("Cam")
	lantern = get_node("Cam/Lantern")
	win_hsize = OS.get_video_mode_size()/2
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass


func _integrate_forces(state):

	# Reset mouse
	Input.warp_mouse_pos(win_hsize)

	# Get directions
	var forward = camera.get_transform().basis[2]
	forward = Vector3(forward.x, 0, forward.z).normalized()
	var strafe = camera.get_transform().basis[0]
	strafe = Vector3(strafe.x, 0, strafe.z).normalized()

	# Quit game
	if exit_game:
		OS.get_main_loop().quit()
	if Input.is_action_pressed("game_quit"):
		print("quit")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		exit_game = true

	# Handle lantern
	lantern_now = Input.is_action_pressed("player_lantern")
	var lantern_press = false
	if lantern_now:
		if lantern_then == false:
			lantern_press = true
	lantern_then = lantern_now

	if lantern_press:
		if lantern.is_visible():
			lantern.hide()
		else:
			lantern.show()

	# Handle movement
	var lv = state.get_linear_velocity()
	if Input.is_action_pressed("player_forward"):
		lv -= forward * walk_speed
	elif Input.is_action_pressed("player_backwards"):
		lv += forward * walk_speed
	if Input.is_action_pressed("player_left"):
		lv -= strafe * walk_speed
	elif Input.is_action_pressed("player_right"):
		lv += strafe * walk_speed

	# Clamp speed
	var tmp = Vector3( lv.x, 0, lv.z )
	if tmp.length() > max_speed:
		tmp = tmp.normalized() * max_speed
		lv.x = tmp.x
		lv.z = tmp.z

	# Handle jump
	var onfloor = state.get_contact_count()
	if onfloor and Input.is_action_pressed("player_jump"):
		lv.y = jump_force
		# if we use forces, jump_force should be over 9000
		#state.add_force(Vector3(0,jump_force,0), Vector3(0,1,0))

	# Apply walk velocity
	state.set_linear_velocity(lv)

	# Clamp pitch
	rotation.y = min( max_pitch, abs(rotation.y) ) * sign( rotation.y )

	# Rotate camera by using transform
	var rot = Matrix3().rotated(Vector3(0,1,0), rotation.x).rotated(Vector3(1,0,0),rotation.y)
	var transf = camera.get_transform()
	transf.basis = rot
	camera.set_transform(transf)

	# Commit!
	state.integrate_forces()


func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		rotation += (ev.pos - win_hsize) * 0.001
