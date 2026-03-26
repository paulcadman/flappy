import Flappy.Config

namespace Flappy

structure Bird where
  /-- The bird y position in y-scaled units. This is
  `y / config.yScale` pixels on screen -/
  y : Int
  /-- The velocity of the bird in y-scaled position units per tick
  positive is downard -/
  velocity : Int

namespace Bird

variable
  {m}
  [Monad m]
  [MonadReaderOf Config m]

def topEdge (b : Bird) : m Rat := do
  let config ← readThe Config
  let y : Rat := b.y / config.yScale
  y - (← readThe Config).bird.height / 2 |> pure

def bottomEdge (b : Bird) : m Rat := do
  let config ← readThe Config
  let y : Rat := b.y / config.yScale
  y + (← readThe Config).bird.height / 2 |> pure

def leftEdge (_ : Bird) : m Rat := do
  (← readThe Config).bird.x - (← readThe Config).bird.width / 2 |> pure

def rightEdge (_ : Bird) : m Rat := do
  (← readThe Config).bird.x + (← readThe Config).bird.width / 2 |> pure

def width (_ : Bird) : m Rat := do
  (← readThe Config).bird.width |> pure

def height (_ : Bird) : m Rat := do
  (← readThe Config).bird.height |> pure

def drawWidth (_ : Bird) : m Rat := do
  (← readThe Config).bird.drawWidth |> pure

def drawHeight (_ : Bird) : m Rat := do
  (← readThe Config).bird.drawHeight |> pure

def step (b : Bird) (shouldFlap : Bool) : m Bird := do
  let config ← readThe Config
  let flapVelocity := config.bird.flapVelocity
  let gravityStep := config.gravityStep
  let velocity := if shouldFlap then flapVelocity else b.velocity + gravityStep
  pure <| { b with velocity := velocity, y := b.y + velocity }

def isInBounds (b : Bird) : m Bool := do
  let windowHeight : Rat := (← readThe Config).window.height
  (← b.topEdge) <= 0 || (← b.bottomEdge) >= windowHeight |> pure

/-- Clamp the bird y position to the bounds of the screen -/
def clamp (b : Bird) : m Bird := do
  let config ← readThe Config
  let minY := config.yScale * config.bird.height / 2
  let maxY := config.yScale * (config.window.height - config.bird.height / 2)
  let clampedY : Int :=
    if b.y < minY then minY
    else if b.y > maxY then maxY
    else b.y
  pure { b with y := clampedY }

/-- The maximum top edge achieved on the birds current trajectory -/
def maxTopEdge (b : Bird) : m Rat := do
  let config ← readThe Config
  let gravityStep := config.gravityStep
  let apexSteps : Int := if b.velocity < 0
    then Rat.ceil (-b.velocity / gravityStep)
    else 0
  let n : Nat := if apexSteps <= 0 then 0 else apexSteps.natAbs
  let b' : Bird ← n.foldM (fun _ _ acc => acc.step false) b
  b'.topEdge

/-- Returns true if the bird can flap without hitting the ceiling at its apex -/
def canFlap (b : Bird) : m Bool := do
  let bird' ← b.step true
  (← bird'.maxTopEdge) > 0 |> pure

/-- Returns true if the bird must flap to avoid hitting the floor -/
def mustFlap (b : Bird) : m Bool := do
  let config ← readThe Config
  let bird' ← b.step false
  (← bird'.bottomEdge) >= config.window.height |> pure

end Bird

end Flappy
