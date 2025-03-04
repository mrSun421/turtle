extends Node3D

const MAIN_AXES_SIZE = 1000;
const GRID_AXES_SIZE = 1000;
const AXES_COUNT = 20;
const AXES_SPACING = 5;

@export var gridMeshInstance: MeshInstance3D
@export var pathMeshInstances: Array[MeshInstance3D]

@export var movingMeshInstance: MeshInstance3D
@export var turtle: Turtle

var pathMeshInstanceScene = preload("res://path_mesh_instance.tscn")

func _ready() -> void:
	EventBus.connect("reset_turtle", self._on_reset_button_pressed)
	for i in range(- AXES_COUNT, AXES_COUNT):
		if i == 0:
			continue
		
		_draw_line(gridMeshInstance, Vector3(i * AXES_SPACING, - GRID_AXES_SIZE, 0), Vector3(i * AXES_SPACING, GRID_AXES_SIZE, 0), Color.LIGHT_GRAY)
		_draw_line(gridMeshInstance, Vector3(i * AXES_SPACING, 0, - GRID_AXES_SIZE), Vector3(i * AXES_SPACING, 0, GRID_AXES_SIZE), Color.LIGHT_GRAY)
		_draw_line(gridMeshInstance, Vector3(- GRID_AXES_SIZE, i * AXES_SPACING, 0), Vector3(GRID_AXES_SIZE, i * AXES_SPACING, 0), Color.LIGHT_GRAY)
		_draw_line(gridMeshInstance, Vector3(0, i * AXES_SPACING, - GRID_AXES_SIZE), Vector3(0, i * AXES_SPACING, GRID_AXES_SIZE), Color.LIGHT_GRAY)
		_draw_line(gridMeshInstance, Vector3(- GRID_AXES_SIZE, 0, i * AXES_SPACING), Vector3(- GRID_AXES_SIZE, 0, i * AXES_SPACING), Color.LIGHT_GRAY)
		_draw_line(gridMeshInstance, Vector3(0, - GRID_AXES_SIZE, i * AXES_SPACING), Vector3(0, GRID_AXES_SIZE, i * AXES_SPACING), Color.LIGHT_GRAY)
	_draw_line(gridMeshInstance, Vector3(- MAIN_AXES_SIZE, 0, 0), Vector3(MAIN_AXES_SIZE, 0, 0), Color.RED)
	_draw_line(gridMeshInstance, Vector3(0, - MAIN_AXES_SIZE, 0), Vector3(0, MAIN_AXES_SIZE, 0), Color.GREEN)
	_draw_line(gridMeshInstance, Vector3(0, 0, - MAIN_AXES_SIZE), Vector3(0, 0, MAIN_AXES_SIZE), Color.BLUE)

func _draw_line(mesh_instance: MeshInstance3D, pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	var immediate_mesh := mesh_instance.mesh as ImmediateMesh
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()


func _on_turtle_finished_move(pos1: Vector3, pos2: Vector3) -> void:
	if !turtle.pen_is_down:
		return

	if pathMeshInstances.is_empty():
		var pathMesh: MeshInstance3D = pathMeshInstanceScene.instantiate()
		pathMeshInstances.append(pathMesh)
		add_child(pathMesh)
	else:
		var latest_path_mesh: MeshInstance3D = pathMeshInstances.back()
		if latest_path_mesh.mesh.get_surface_count() + 1 >= RenderingServer.MAX_MESH_SURFACES:
			var new_pathMesh: MeshInstance3D = pathMeshInstanceScene.instantiate()
			pathMeshInstances.append(new_pathMesh)
			add_child(new_pathMesh)

	_draw_line(pathMeshInstances.back(), pos1, pos2, turtle.line_color)


func _on_reset_button_pressed() -> void:
	for pathMeshInstance in pathMeshInstances:
		var path_im_mesh := pathMeshInstance.mesh as ImmediateMesh
		path_im_mesh.clear_surfaces()
		pathMeshInstance.queue_free()
	pathMeshInstances.clear()
	
	var moving_im_mesh := movingMeshInstance.mesh as ImmediateMesh
	moving_im_mesh.clear_surfaces()


func _on_turtle_moving(current_pos: Vector3) -> void:
	if !turtle.pen_is_down:
		return
	var im_mesh := movingMeshInstance.mesh as ImmediateMesh
	while turtle.is_moving:
		_draw_line(movingMeshInstance, current_pos, turtle.position, turtle.line_color)
		await get_tree().physics_frame
		im_mesh.clear_surfaces()
	im_mesh.clear_surfaces()
