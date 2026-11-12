extends Node3D

## Rotation speed of the cube, in radians per second.
@export var spin_speed: float = 1.0

@onready var cube: MeshInstance3D = $Cube


func _process(delta: float) -> void:
	cube.rotate_y(spin_speed * delta)
