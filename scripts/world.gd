extends Node2D

@onready var foodPathDot = preload("res://screens/foodDot.tscn") 
@onready var pathDot = preload("res://screens/pathDot.tscn")
@onready var food = preload("res://screens/food.tscn")

var randomPosition

var foodPositionList = [Vector2(1636, 867), Vector2(3050, 748), Vector2(3078, 1720), Vector2(1642, 1793)]


func DropFoodTimer():
	for location in foodPositionList:
		for i in range(1, 8):
			await get_tree().create_timer(0.5).timeout
			randomPosition = Vector2(location.x - randf_range(-50, 50), location.y - randf_range(-50, 50))
			var FD = food.instantiate()
			FD.position = randomPosition
			add_child(FD)


func DropPath(spawnPosition):
	var PTD = pathDot.instantiate()
	PTD.position = spawnPosition
	add_child(PTD)


func DropFoodPath(spawnPosition):
	var FPD = foodPathDot.instantiate()
	FPD.position = spawnPosition
	add_child(FPD)


func FoodReSpawn(location):
	await get_tree().create_timer(50.0).timeout
	var FD = food.instantiate()
	FD.position = location
	add_child(FD)
