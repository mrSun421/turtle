extends SubViewport

var xRInterface: XRInterface

func _init() -> void:
	XRServer.find_interface("OpenXR")
	if xRInterface and xRInterface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		print("OpenXR not initialized, running in desktop mode.")
