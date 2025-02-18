extends SubViewport

var xRInterface: XRInterface
@export var vrPlayer: Node3D

func _init() -> void:
	xRInterface = XRServer.find_interface("OpenXR")
	if xRInterface and xRInterface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		print("OpenXR not initialized, running in desktop mode.")

func _ready() -> void:
	if !xRInterface.is_initialized():
		vrPlayer.visible = false
