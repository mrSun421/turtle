extends Node3D

const MAIN_AXES_SIZE = 1000;
const GRID_AXES_SIZE = 1000;
const AXES_COUNT = 20;
const AXES_SPACING = 5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(-AXES_COUNT, AXES_COUNT):
		if i == 0:
			continue
		
		Draw3D.line(Vector3(i * AXES_SPACING, -GRID_AXES_SIZE, 0), Vector3(i * AXES_SPACING, GRID_AXES_SIZE, 0), Color.LIGHT_GRAY)
		Draw3D.line(Vector3(i * AXES_SPACING, 0, -GRID_AXES_SIZE), Vector3(i * AXES_SPACING, 0, GRID_AXES_SIZE), Color.LIGHT_GRAY)
		Draw3D.line(Vector3(-GRID_AXES_SIZE, i * AXES_SPACING, 0), Vector3(GRID_AXES_SIZE, i * AXES_SPACING, 0), Color.LIGHT_GRAY)
		Draw3D.line(Vector3(0, i * AXES_SPACING, -GRID_AXES_SIZE), Vector3(0, i * AXES_SPACING, GRID_AXES_SIZE), Color.LIGHT_GRAY)
		Draw3D.line(Vector3(-GRID_AXES_SIZE, 0, i * AXES_SPACING), Vector3(-GRID_AXES_SIZE, 0, i * AXES_SPACING), Color.LIGHT_GRAY)
		Draw3D.line(Vector3(0, -GRID_AXES_SIZE, i * AXES_SPACING), Vector3(0, GRID_AXES_SIZE, i * AXES_SPACING), Color.LIGHT_GRAY)
	Draw3D.line(Vector3(-MAIN_AXES_SIZE, 0, 0), Vector3(MAIN_AXES_SIZE, 0, 0), Color.RED)
	Draw3D.line(Vector3(0, -MAIN_AXES_SIZE, 0), Vector3(0, MAIN_AXES_SIZE, 0), Color.GREEN)
	Draw3D.line(Vector3(0, 0, -MAIN_AXES_SIZE), Vector3(0, 0, MAIN_AXES_SIZE), Color.BLUE)
