import Raylean
import Batteries.Data.Rat
import Flappy
import FlappyRaylean

open Raylean
open Raylean.Types
open Flappy
open FlappyRaylean

abbrev AppM := StateT State (ReaderT Config (ReaderT Assets IO))

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
    endTextColor := Color.red
  }

  {
    yScale := 2
    window := windowConfig,
    bird := {x := width / 3, flapVelocity := -13},
    gravityStep := 1,
    pipe := pipeConfig,
  }

def renderLoop
  (initState : IO State) : AppM Unit := do
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
        else if (← isKeyDown Key.r) then set (← initState)
      acc := acc - tickDt
    renderFrame (← (getThe State)).render

def render
  (initState : IO State) : ReaderT Config (ReaderT Assets IO) Unit := do
  renderLoop initState |>.run' (← initState)
  closeWindow

def main : IO Unit := do
  initWindow 800 600 "Flappy"
  setConfigFlags Flags.vsyncHint

  let initState : IO State := do
    let bytes ← IO.getRandomBytes 8
    let seed : Nat := bytes.toUInt64BE! |>.toNat
    pure {
      bird :=  {
          y := config.yScale * config.window.height / 3,
          velocity := config.bird.flapVelocity
        }
      pipes := [],
      randGen := mkStdGen seed
    }

  let assets ← Assets.load

  render initState |>.run config |>.run assets
