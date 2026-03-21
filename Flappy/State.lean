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
  randGen : StdGen

namespace State

section rand

def randFin (g : StdGen) (n : Nat) (h : 0 < n) : StdGen × Fin n :=
  let (x, g) := RandomGen.next g
  ⟨g, x % n, Nat.mod_lt x h⟩

def randRange (g : StdGen) (lo hi : Nat) (h : lo < hi) :
  StdGen × { x : Nat // lo <= x ∧ x <= hi } :=
  let n := hi - lo + 1
  let ⟨g, k, _⟩ := randFin g n (Nat.zero_lt_succ (hi - lo))
  let x := lo + k
  let hxLo : lo <= x := Nat.le_add_right lo k
  let hxHi : x <= hi := by omega
  ⟨g, x, hxLo, hxHi⟩

end rand

section step

variable
  {m}
  [Monad m]
  [MonadReaderOf Config m]

def spawnPipe (g : StdGen) : m (StdGen × Pipe) := do
  let config ← readThe Config
  let minGapTop := config.pipe.margin
  let maxGapTop := config.window.height - config.pipe.margin - config.pipe.gapSize
  let (g, gapTop) ←
    if h : minGapTop < maxGapTop then
      let ⟨g, y, _⟩ := State.randRange g minGapTop maxGapTop h
      pure (g, y)
    else
      pure (g, minGapTop)
  pure
    (g, { x := config.window.width,
          width := config.pipe.width
          gapTop := gapTop
          gapBottom := gapTop + config.pipe.gapSize })

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
  (state : State)
  (isSpaceDown : Bool)
  : m State := do
  let mut randGen := state.randGen
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
        let res ← spawnPipe randGen
        randGen := res.1
        nextPipes ++ [res.2] |> pure
      else nextPipes |> pure
  let shouldFlap := isSpaceDown && state.ticksSinceFlap > 0
  let bird' ← state.bird.step shouldFlap

  pure {
    state with
      bird := (← bird'.clamp),
      ticksSinceFlap := if isSpaceDown then 0 else state.ticksSinceFlap + 1,
      tick := state.tick + 1,
      pipes,
      randGen,
      score := state.score + scoreInc
  }

def hasCollision (s : State) : m Bool := do
  let collidesPipe ← s.pipes.anyM (fun p => p.collides s.bird)
  (← s.bird.isInBounds) || collidesPipe |> pure

end step

end State

end Flappy
