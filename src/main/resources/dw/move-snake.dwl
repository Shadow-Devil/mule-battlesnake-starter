%dw 2.0
output application/json
import * from dw::Runtime

type Direction = "up" | "down" | "left" | "right"
type Coord = {| x: Number, y: Number|}

var body = payload.you.body
var board = payload.board
var head = body[0] // First body part is always head
var neck = body[1] // Second body part is always neck

var moves = ["up", "down", "left", "right"]

fun getCollision(head, other: Coord): Direction | Null = 
         if (other.x == (head.x - 1) and other.y == head.y) "left"
	else if (other.x == (head.x + 1) and other.y == head.y) "right"
	else if (other.y == (head.y - 1) and other.x == head.x) "down" 
	else if (other.y == (head.y + 1) and other.x == head.x) "up"	
	else null


// Step 1 - Don't hit walls.
// Use information from `board` and `head` to not move beyond the game board.
fun wallCollisions(head: Coord = head) = [
	("left")  if 0 == head.x,
	("right") if board.width - 1 == head.x,
	("down")  if 0 == head.y,
	("up")    if board.height - 1 == head.y
]

// Step 2 - Don't hit yourself.
// Use information from `body` to avoid moves that would collide with yourself.
fun bodyCollisions(head: Coord = head, body: Array<Coord> = body): Array<Direction> = (body 
    map getCollision(head, $) 
    filter !isEmpty($) 
    distinctBy $
) as Array<Direction>

// TODO: Step 3 - Don't collide with others.
// Use information from `payload` to prevent your Battlesnake from colliding with others.
var otherSnakes = null


// TODO: Step 4 - Find food.
// Use information in `payload` to seek out and find food.
// food = board.food


// Find safe moves by eliminating neck location and any other locations computed in above steps
fun safeDirections(head: Coord = head, body: Array<Coord> = body) = moves -- (wallCollisions(head) ++ bodyCollisions(head, body))

fun move(direction: Direction, head: Coord, body: Array<Coord>): 
{| head: Coord, dir: Direction, body: Array<Coord> |} = do {
    var newHead: Coord = direction match {
        case is "up" -> head update { case .y -> $ + 1 }
        case is "down" -> head update { case .y -> $ - 1 }
        case is "left" -> head update { case .x -> $ - 1 }
        case is "right" -> head update { case .x -> $ + 1 }
    }
    var newBody = newHead >> body[0 to -2]
    ---
    if (wallCollisions(head) contains direction) 
        fail("Collided with wall $direction from $(head.x)/$(head.y)") 
    else if (bodyCollisions(head, body) contains direction) 
        fail("Collided with body: $direction from $(head.x)/$(head.y)") 
    else {
        head: newHead,
        dir: direction,
        body: newBody
    }
}

fun findMostArea(directions: Array<Direction>, head: Coord = head, body: Array<Coord> = body, rec: Number = 2) = do {
    var predictions = directions map move($, head, body)
    ---
    if (rec == 0) 
        sizeOf(predictions)
    else 
        sum(predictions map findMostArea(safeDirections($.head, $.body), $.head, $.body, rec - 1))
}

// Next move from safe moves
var nextMove = (safeDirections() orderBy -findMostArea([$]))[0]
---
{
    move: nextMove,
    //head: head
	//move: nextMove,
	//shout: "Moving $(nextMove default 'null') from $(head.x)/$(head.y)",
    //wallCollisions: wallCollisions(),
    //bodyCollisions: bodyCollisions()
}