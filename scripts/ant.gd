extends CharacterBody2D


var speed = 150.0
var randomPositionDistanceX = randf_range(-20, 20)
var randomPositionDistanceY = randf_range(-20, 20)

var currentDir
var food
var path
var foodPath
var antHill

var hasFood = false
var randomMove = false
var foodInRange = false
var foodDotInRange = false
var pathDotInRange = false
var antHillInRange = false
var getLocation = true
var DropPathToggle = true
var DropFoodPathToggle = true

var listMaxCapacity = 10
var food_dots_in_range = []
var foodPath_dots_in_range = []
var antHills_in_range = []
var visitedFoodDots = []
var path_dots_in_range = []
var visitedPathDots = []
var totalList = [food_dots_in_range, foodPath_dots_in_range, antHills_in_range, visitedFoodDots, path_dots_in_range, visitedPathDots]



func _ready():
	$AnimatedSprite2D.play("idle_walk")

func _physics_process(delta):
	# ObjectInRange()
	movement(delta)
	getFoodLocation()
	getAntHillLocation()
	getFoodPathLocation()
	getPathLocation()
	botMove(delta)
	DropAntPath()
	
	if hasFood:
		$AnimatedSprite2D.play("food_walk")
	elif !hasFood:
		$AnimatedSprite2D.play("idle_walk")


# Maintain List Capacity
func MaintainListCapacity():
	for list in totalList:
		if list.size() > listMaxCapacity:
			list = list.slice(list.size() - listMaxCapacity, list.size())


# Creating the parth
func DropAntPath():
	if hasFood:
		if DropFoodPathToggle:
			DropFoodPathToggle = !DropFoodPathToggle
			await get_tree().create_timer(0.35).timeout
			World.DropFoodPath(self.position)
			DropFoodPathToggle = !DropFoodPathToggle
	elif !hasFood:
		if DropPathToggle:
			DropPathToggle = !DropPathToggle
			await get_tree().create_timer(0.35).timeout
			World.DropPath(self.position)
			DropPathToggle = !DropPathToggle


# Bot movement
func botMove(delta):
	if !hasFood:
		if foodPath_dots_in_range.is_empty():
			randomMove = true
		else:
			randomMove = false
	elif hasFood:
		if path_dots_in_range.is_empty():
			randomMove = true
		else:
			randomMove = false
	
	if antHillInRange and (typeof(antHill) != TYPE_NIL) and hasFood:
		position += (antHill.position - position).normalized() * (speed*2.5) * delta
		move_and_collide(Vector2(0,0))
	elif foodInRange and (typeof(food) != TYPE_NIL) and !hasFood:
		position += (food.position - position).normalized() * (speed*2.5) * delta
		move_and_collide(Vector2(0,0))
	elif foodDotInRange and (typeof(foodPath) != TYPE_NIL) and !hasFood:
		position += (foodPath.position - position).normalized() * (speed*2) * delta
		move_and_collide(Vector2(0,0))
	elif pathDotInRange and (typeof(path) != TYPE_NIL) and hasFood:
		position += (path.position - position).normalized() * (speed*2) * delta
		move_and_collide(Vector2(0,0))
	elif randomMove:
		position += (Vector2(position.x - randomPositionDistanceX, position.y - randomPositionDistanceY) - position).normalized() * speed*1.5 * delta
		move_and_collide(Vector2(0,0))


# Debug Function
func ObjectInRange():
	if foodDotInRange:
		print("Food in Range")
	if pathDotInRange:
		print("Path in Range")

# Debug function
func movement(delta):
	if Input.is_action_pressed("ui_up"):
		currentDir = "up"
		velocity.x = 0
		velocity.y = -speed
	elif Input.is_action_pressed("ui_down"):
		currentDir = "down"
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_left"):
		currentDir = "left"
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_right"):
		currentDir = "right"
		velocity.x = speed
		velocity.y = 0
	else:
		currentDir = "idle"
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide() 


# Function to get what is the next position to go
func lowest_value_dot(list, oType):
	# Removing already visited dots
	if oType == "foodPath":
		for element in visitedFoodDots:
			if element in list:
				list.erase(element)
	elif oType == "path":
		for element in visitedPathDots:
			if element in list:
				list.erase(element)
	
	if list.is_empty():
		return null
	
	var lowestValue = list[0]
	for dots in list:
		if (dots.value < lowestValue.value) and (dots.value != null):
			lowestValue = dots
	
	return lowestValue


# Getting the food location
func getFoodLocation():
	if !hasFood:
		food = lowest_value_dot(food_dots_in_range, "food")
		foodInRange = !foodInRange

# Getting the foodPath location
func getFoodPathLocation():
	if getLocation:
		foodPath = lowest_value_dot(foodPath_dots_in_range, "foodPath")
		foodDotInRange = !foodDotInRange

# Getting the path location
func getPathLocation():
	if getLocation:
		path = lowest_value_dot(path_dots_in_range, "path")
		#print(path)
		pathDotInRange = !pathDotInRange

# Getting the antHill location
func getAntHillLocation():
	if getLocation:
		antHill = lowest_value_dot(antHills_in_range, "antHill")
		antHillInRange = !antHillInRange


# When food or path enters the ditection area
func _on_dection_area_body_entered(body):
	if body.has_method("AntHill"):
		antHills_in_range.append(body)
	
	if body.has_method("Food"):
		if (body not in food_dots_in_range):
			food_dots_in_range.append(body)
		
	if body.has_method("FoodDot"):
		if (body not in foodPath_dots_in_range):
			foodPath_dots_in_range.append(body)
		
	if body.has_method("PathDot"):
		if body not in path_dots_in_range:
			path_dots_in_range.append(body)


# When food or path exits the ditection area
func _on_dection_area_body_exited(body):
	if body.has_method("Food"):
		food_dots_in_range.erase(body)
	if body.has_method("AntHill"):
		antHills_in_range.erase(body)
		antHillInRange = !antHillInRange
	if body.has_method("FoodDot"):
		foodPath_dots_in_range.erase(body)
		foodDotInRange = !foodDotInRange
	if body.has_method("PathDot"):
		path_dots_in_range.erase(body)
		pathDotInRange = !pathDotInRange
	
	if body.has_method("FoodDot") and !hasFood:
		visitedFoodDots.append(body)
		pass
	if body.has_method("PathDot") and hasFood:
		visitedPathDots.append(body)
		pass


# Geting a random location when the time outs
func _on_random_move_timer_timeout():
	randomPositionDistanceX = randf_range(-50, 50)
	randomPositionDistanceY = randf_range(-50, 50)


# What to do when a food or path is in consume range
func _on_in_consume_range_body_entered(body):
	if body.has_method("Food") and !hasFood:
		body.EateFood()
		food_dots_in_range = []
		hasFood = !hasFood
		#print("FOOD IN RANGE")
	
	if body.has_method("FoodDot"):
		if !hasFood:
			visitedFoodDots.append(body)
	
	if body.has_method("PathDot"):
		if hasFood:
			visitedPathDots.append(body)
	
	if body.has_method("AntHill") and hasFood:
		antHillInRange = !antHillInRange
		hasFood = !hasFood
