extends Node2D

@export var speed : float = 1
@onready var platform_iterator: PathFollow2D = %PlatformIterator
@onready var platform_body: AnimatableBody2D = $PlatformPath/PlatformIterator/PlatformBody

var flipped : bool = false
var flip_lock : bool = false


func _physics_process(_delta: float) -> void:
	platform_iterator.progress += speed
	
	
	
		
