import Raylean
import Batteries.Data.Rat
import Flappy
import FlappyRaylean

open Raylean
open Raylean.Types
open Flappy
open FlappyRaylean

abbrev AppM := StateT StdGen (StateT State (ReaderT Config (ReaderT Assets IO)))

def config : Config :=
  let width : Nat := 800
  let height : Nat := 600
  let pipeConfig := {
    speed := 180,
    width := 80,
    spacing := 280,
    gapSize := 180,
    margin := 20
    color := Color.Raylean.darkgreen
  }

  let windowConfig := {
    width,
    height,
    backgroundColor := Color.Raylean.skyblue,
    scoreTextColor := Color.black,
  }

  let gameOver := {
    text := "GAME Over - press R to restart"
    color := Color.red
    size := 20
    position := (windowConfig.width / 2 - 160, windowConfig.height / 2 - 20)
  }

  {
    yScale := 2
    window := windowConfig,
    bird := {x := width / 3, flapVelocity := -13},
    gravityStep := 1,
    pipe := pipeConfig,
    gameOver
  }

def renderLoop
  (initStdGen : IO StdGen)
  (initState : State)
  : AppM Unit := do
  let tickDt : Float := (← readThe Config).tickDt
  let mut acc : Float := 0
  while (not (← windowShouldClose)) do
    let frameDt ← getFrameTime
    acc := acc + min frameDt 0.25
    while acc >= tickDt do
      let click ← isKeyDown Key.space
      let s ← getThe State
      if !(← s.hasCollision)
        then set (← s.step click)
        else if (← isKeyDown Key.r) then do
          set initState
          set (← initStdGen)
      acc := acc - tickDt
    renderFrame (← (getThe State)).render

def render
  (initStdGen : IO StdGen)
  (initState : State)
  : ReaderT Config (ReaderT Assets IO) Unit := do
  renderLoop initStdGen initState |>.run' (← initStdGen) |>.run' initState
  closeWindow

def main : IO Unit := do
  initWindow 800 600 "Flappy"
  setConfigFlags Flags.vsyncHint

  let initStdGen : IO StdGen := do
    let bytes ← IO.getRandomBytes 8
    let seed : Nat := bytes.toUInt64BE! |>.toNat
    pure (mkStdGen seed)

  let initState : State :=
    {
      bird :=  {
          y := config.yScale * config.window.height / 3,
          velocity := config.bird.flapVelocity
        }
      pipes := [],
    }

  let assets ← Assets.load

  render initStdGen initState |>.run config |>.run assets
