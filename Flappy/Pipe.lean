import Flappy.Bird
import Flappy.Config

namespace Flappy

structure Pipe where
  x : Rat
  width : Rat
  gapTop : Rat
  gapBottom : Rat

namespace Pipe

variable
  {m}
  [Monad m]
  [MonadReader Config m]

def leftEdge (p : Pipe) : Rat := p.x

def rightEdge (p : Pipe) : Rat := p.x + p.width

def collides (p : Pipe) (b : Bird) : m Bool := do
  pure <|
    p.leftEdge <= (← b.rightEdge)
    && (← b.leftEdge) <= p.rightEdge
    && ((← b.topEdge) <= p.gapTop || (← b.bottomEdge) >= p.gapBottom)

def step (p : Pipe) : m Pipe := do
  let config ← read
  let dx := config.pipe.speed * config.tickDt
  pure { p with x := p.x - dx }

end Pipe

end Flappy
