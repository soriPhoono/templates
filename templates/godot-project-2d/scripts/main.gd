extends Node2D

## Rotation speed of the icon, in radians per second.
@export var spin_speed: float = 1.0

@onready var icon: Sprite2D = $Icon


func _process(delta: float) -> void:
	icon.rotation += spin_speed * delta
