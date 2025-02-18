extends Camera3D

var desiredFov = 75
var maxFov = 90
var minFov = 30

var holdingMiddleMouse = false
var holdingRightMouse = false
var rotation_sensitivity = 0.5
var translation_sensitivity = 0.01

func _process(_delta: float) -> void:
	holdingMiddleMouse = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	holdingRightMouse = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mb = event as InputEventMouseButton
		if event_mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			desiredFov -= 3
			self.fov = clamp(desiredFov, minFov, maxFov)
			return
		if event_mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			desiredFov += 3
			self.fov = clamp(desiredFov, minFov, maxFov)
			return
	
	if event is InputEventMouseMotion:
		var event_mm = event as InputEventMouseMotion
		if holdingMiddleMouse:
			var mouse_translation = Vector3(-event_mm.relative.x, event_mm.relative.y, 0)
			self.position += (self.basis * mouse_translation) * translation_sensitivity

		if holdingRightMouse:
			var mouse_translation = event_mm.relative
			self.rotation_degrees.x -= mouse_translation.y * rotation_sensitivity
			self.rotation_degrees.y -= mouse_translation.x * rotation_sensitivity
			self.rotation.x = clamp(self.rotation.x, -PI / 2, PI / 2)


func _on_camera_reset_button_pressed() -> void:
	self.position = Vector3(0, 0, 5)
	self.quaternion = Quaternion.IDENTITY

func _ready() -> void:
	EventBus.connect("reset_camera", self._on_camera_reset_button_pressed)