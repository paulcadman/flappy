import Flappy.Config
import Batteries.Data.Rat

namespace Flappy

structure Bird where
  y : Rat
  velocity : Rat
  didFlap := false

namespace Bird

variable
  {m}
  [Monad m]
  [MonadReader Config m]

def topEdge (b : Bird) : m Rat := do
  b.y - (← read).bird.height / 2 |> pure

def bottomEdge (b : Bird) : m Rat := do
  b.y + (← read).bird.height / 2 |> pure

def leftEdge (_ : Bird) : m Rat := do
  (← read).bird.x - (← read).bird.width / 2 |> pure

def rightEdge (_ : Bird) : m Rat := do
  (← read).bird.x + (← read).bird.width / 2 |> pure

def width (_ : Bird) : m Rat := do
  (← read).bird.width |> pure

def height (_ : Bird) : m Rat := do
  (← read).bird.height |> pure

def drawWidth (_ : Bird) : m Rat := do
  (← read).bird.drawWidth |> pure

def drawHeight (_ : Bird) : m Rat := do
  (← read).bird.drawHeight |> pure

def step (b : Bird) (shouldFlap : Bool) : m Bird := do
  let config ← read
  let impulse := config.bird.flapImpulse
  let gravity := config.gravity
  let tickDt := config.tickDt
  let velocity := if shouldFlap then impulse else b.velocity + gravity * tickDt
  pure <| { b with velocity := velocity, y := b.y + velocity * tickDt }

def isInBounds (b : Bird) : m Bool := do
  let windowHeight : Rat := (← read).window.height
  (← b.topEdge) <= 0 || (← b.bottomEdge) >= windowHeight |> pure

/-- Clamp the bird y position to the bounds of the screen -/
def clamp (b : Bird) : m Bird := do
  let config ← read
  let minY := config.bird.height / 2
  let maxY := config.window.height - config.bird.height / 2
  let clampedY : Rat :=
    if b.y < minY then minY
    else if b.y > maxY then maxY
    else b.y
  pure { b with y := clampedY }

/-- The maximum top edge achieved on the birds current trajectory -/
def maxTopEdge (b : Bird) : m Rat := do
  let config ← read
  let gravity := config.gravity
  let tickDt := config.tickDt
  let apexSteps : Int := Rat.ceil (-b.velocity / (gravity * tickDt))
  let n : Nat := if apexSteps <= 0 then 0 else apexSteps.natAbs
  let b' : Bird ← n.foldM (fun _ _ acc => acc.step false) b
  b'.topEdge

/-- Returns true if the bird can flap without hitting the ceiling at its apex -/
def canFlap (b : Bird) : m Bool := do
  let bird' ← b.step true
  (← bird'.maxTopEdge) > 0 |> pure

/-- Returns true if the bird must flap to avoid hitting the floor -/
def mustFlap (b : Bird) : m Bool := do
  let config ← read
  let bird' ← b.step false
  (← bird'.bottomEdge) >= config.window.height |> pure

abbrev PureM := ReaderT Config Id

theorem readerApp {α} (p : ReaderT Config Id α) (c : Config) : p.run c = p c := rfl

theorem readerBind {α β} (p : ReaderT Config Id α) (f : α → ReaderT Config Id β) (c : Config) :
  (p >>= f) c = f (p c) c := rfl

theorem readerRead (c : Config) :
  let r : ReaderT Config Id Config := ReaderT.read
  r.run c = c := rfl

theorem readerRead' (c : Config) :
  let r : ReaderT Config Id Config := ReaderT.read
  r c = c := rfl

theorem readerPure {α} (a : α) (c : Config) :
  let r : ReaderT Config Id α := ReaderT.pure a
  r c = a := rfl

theorem readerBind' {α β} (p : ReaderT Config Id α) (f : α → ReaderT Config Id β) (c : Config) :
  (do
    let a ← p
    f a).run c = f (p c) c := rfl

theorem readerBind'' {α β} (p : ReaderT Config Id α) (f : α → ReaderT Config Id β) (c : Config) :
  (ReaderT.bind p f) c = f (p c) c := rfl

theorem bottomEdge_run
  (config : Config) (b : Bird) :
  (Bird.bottomEdge (m := PureM) b).run config =
    b.y + (config.bird.height : Rat) / 2 := by rfl

theorem mustFlap_iff
  (config : Config) (b : Bird) :
  (Bird.mustFlap (m := PureM) b).run config = true ↔
    let b' := (Bird.step (m := PureM) b false).run config
    b'.y + (config.bird.height : Rat) / 2 >= (config.window.height : Rat) := by
  unfold Bird.mustFlap
  rw [readerApp]
  simp [readerBind, pure]
  rw [readerPure]
  simp [read, readThe, MonadReaderOf.read, ReaderT.read, pure, ReaderT.run, bottomEdge, readerBind, ReaderT.pure]
  rw [@Id.ext_iff]
  simp [Id.run]

end Bird

end Flappy
