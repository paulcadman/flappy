import Flappy.Bird
import Flappy.Config
import Flappy.Pipe

namespace Flappy

structure State where
  bird : Bird
  pipes : List Pipe := []
  didFlap : Bool := false
  ticksSinceFlap : Nat := 0
  tick : Nat := 0
  score : Nat := 0

namespace State

section rand

variable
  {m}
  [Monad m]
  [MonadStateOf StdGen m]

def randFin (n : Nat) (h : 0 < n) : m (Fin n) := do
  let g ← getThe StdGen
  let (x, g) := RandomGen.next g
  set g
  pure ⟨x % n, Nat.mod_lt x h⟩

def randRange (lo hi : Nat) (h : lo < hi) : m { x : Nat // lo <= x ∧ x <= hi } := do
  let g ← getThe StdGen
  let n := hi - lo + 1
  let ⟨k, _⟩ ← randFin n (Nat.zero_lt_succ (hi - lo))
  let x := lo + k
  let hxLo : lo <= x := Nat.le_add_right lo k
  let hxHi : x <= hi := by omega
  pure ⟨x, hxLo, hxHi⟩

end rand

section step

variable
  {m}
  [Monad m]
  [MonadReaderOf Config m]

def spawnPipe [MonadStateOf StdGen m] : m Pipe := do
  let config ← readThe Config
  let minGapTop := config.pipe.margin
  let maxGapTop := config.window.height - config.pipe.margin - config.pipe.gapSize
  let gapTop ←
    if h : minGapTop < maxGapTop then
      let ⟨y, _⟩ ← State.randRange minGapTop maxGapTop h
      pure y
    else
      pure minGapTop
  pure
    { x := config.window.width,
      width := config.pipe.width
      gapTop := gapTop
      gapBottom := gapTop + config.pipe.gapSize }

def shouldSpawnPipe (pipes : List Pipe) : m Bool := do
  let config ← readThe Config
  let rightmostX : Option Rat :=
    pipes.foldl
      (fun acc p =>
        match acc with
        | none => some p.x
        | some x => some (max x p.x))
      none
  match rightmostX with
  | none => pure true
  | some rightmostX => rightmostX <= config.window.width - config.pipe.spacing |> pure

def stepPipes
  (s : State)
  : m (List Pipe) := do
  let pipes' ← s.pipes.mapM' (fun p => p.step)
  pipes'.filter (fun p => p.rightEdge > 0) |> pure

def step
  [MonadStateOf StdGen m]
  (state : State)
  (isSpaceDown : Bool)
  : m State := do
  let steppedPipes ← state.pipes.mapM' (fun p => p.step)
  let birdX ← state.bird.leftEdge
  let scoreInc :=
    match state.pipes.head?, steppedPipes.head? with
    | some oldPipe, some newPipe =>
        if oldPipe.rightEdge >= birdX && newPipe.rightEdge < birdX then 1 else 0
    | _, _ => 0
  let pipes ← do
    let nextPipes := steppedPipes.filter (fun p => p.rightEdge > 0)
    if ← shouldSpawnPipe nextPipes
      then do
        let res ← spawnPipe
        nextPipes ++ [res] |> pure
      else nextPipes |> pure
  let shouldFlap := isSpaceDown && state.ticksSinceFlap > 0
  let bird' ← state.bird.step shouldFlap

  pure {
    state with
      bird := (← bird'.clamp),
      ticksSinceFlap := if isSpaceDown then 0 else state.ticksSinceFlap + 1,
      tick := state.tick + 1,
      pipes,
      score := state.score + scoreInc
  }

def hasCollision (s : State) : m Bool := do
  let collidesPipe ← s.pipes.anyM (fun p => p.collides s.bird)
  (← s.bird.isInBounds) || collidesPipe |> pure

end step

end State

end Flappy
