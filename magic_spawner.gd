extends Spatial

onready var objects_to_animate = $weapon_stand
onready var animation_origin = $point
onready var particle_system_scene = preload("res://particle_system.tscn")

var objects = [];

var scales = [];
var rotations = [];
var y_positions = [];

var animation_range = 8;
var current_range = 0;

var animation_speed = 6;

var rotation_amount = 200;

var particle_systems = []
var has_emmitted_particles = [];
var is_done = []

var running = false;

func _ready():
	objects = objects_to_animate.get_child(0).get_children();
	
	for object in objects:
		
		scales.push_back(object.scale)
		rotations.push_back(object.rotation)
		y_positions.push_back(object.global_transform.origin.y);
		has_emmitted_particles.push_back(false)
		is_done.push_back(false);
		
		object.scale = Vector3.ZERO

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		if(running):
			animation_speed = -animation_speed;
		running = true;

func _process(delta):
	if(!running):return
	
	if(running):
		
		var index = 0;
		
		for object in objects:
			if(animation_origin.transform.origin.distance_to(object.transform.origin) > current_range):
				var current_point = current_range - animation_origin.transform.origin.distance_to(object.global_transform.origin);
				if(current_point > 0):
					if(current_point > animation_range):
						
						object.scale = scales[index];
						is_done[index] = true;
						
					else:
						
						var x = current_point/animation_range;
						var y = sin(-13.0*(x+1)*(PI/2))*pow(2.0,-10*x)+1 # Bounce out function 
						
						object.rotation.y = rotations[index].y+ deg2rad(y*rotation_amount) + deg2rad(360-rotation_amount)
						object.scale = scales[index]*y;
						object.global_transform.origin.y = y_positions[index]*y
						
						if(!has_emmitted_particles[index]):
							
							var new_poof = particle_system_scene.instance();
							new_poof.transform.origin = object.global_transform.origin;
							new_poof.transform.origin += Vector3.UP*y_positions[index]
							particle_systems.push_front(new_poof);
							new_poof.emitting = true;
							add_child(new_poof)
							
							has_emmitted_particles[index] = true;
							
			index+=1;
			
		current_range += delta*animation_speed;
		
		var done = true
		
		for value in is_done:
			if !value : done = false;
				
		if(done):
			running = false;
			for particle_system in particle_systems:
				particle_system.queue_free();
		
	
