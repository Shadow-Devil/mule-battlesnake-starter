%dw 2.0
output application/json

var body = payload.you.body
var board = payload.board
var head = body[0] // First body part is always head
var neck = body[1] // Second body part is always neck

var moves = ["up", "down", "left", "right"]

fun getCollision(head, other: {| x: Number, y: Number|}) = 
         if ((other.x + 1) == head.x and other.y == head.y) "left"
	else if ((other.x - 1) == head.x and other.y == head.y) "right"
	else if ((other.y + 1) == head.y and other.x == head.x) "down" 
	else if ((other.y - 1) == head.y and other.x == head.x) "up"	
	else ''


// Step 0: Find my neck location so I don't eat myself
var myNeckLocation = getCollision(head, neck)

// TODO: Step 1 - Don't hit walls.
// Use information from `board` and `head` to not move beyond the game board.
var wallLocations = [
	("left")  if 0 == head.x,
	("right") if board.width - 1 == head.x,
	("down")  if 0 == head.y,
	("up")    if board.height - 1 == head.y
]

// TODO: Step 2 - Don't hit yourself.
// Use information from `body` to avoid moves that would collide with yourself.
var bodyLocations = body map getCollision(head, $) filter $ != "" distinctBy $

// TODO: Step 3 - Don't collide with others.
// Use information from `payload` to prevent your Battlesnake from colliding with others.

// TODO: Step 4 - Find food.
// Use information in `payload` to seek out and find food.
// food = board.food


// Find safe moves by eliminating neck location and any other locations computed in above steps
var safeMoves = ((moves - myNeckLocation) -- wallLocations) -- bodyLocations // - remove other dangerous locations

// Next random move from safe moves
var nextMove = safeMoves[randomInt(sizeOf(safeMoves))]

---
{
	move: nextMove,
	shout: "Moving $(nextMove)"
}