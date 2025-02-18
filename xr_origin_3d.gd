extends XROrigin3D

@export var xrCamera: XRCamera3D
@export var xrViewport2DIn3D: XRToolsViewport2DIn3D

func _toggle_vr_controls_visibility() -> void:
	if xrViewport2DIn3D.visible:
		xrViewport2DIn3D.visible = false
	else:
		xrViewport2DIn3D.position = xrCamera.position + (-4 * xrCamera.basis.z)
		xrViewport2DIn3D.quaternion = xrCamera.quaternion
		xrViewport2DIn3D.visible = true

func _ready() -> void:
	EventBus.connect("toggle_vr_controls_visibility", self._toggle_vr_controls_visibility)