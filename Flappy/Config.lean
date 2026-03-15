import Raylean

namespace Flappy

namespace Config

structure Window where
  height : Nat
  width : Nat

structure Bird where
  x : Rat
  drawWidth := 50
  drawHeight := 40
  width := 35
  height := 40
  flapImpulse : Rat := -420

structure Pipe where
  speed : Nat
  width : Nat := 100
  spacing : Nat
  gapSize : Nat := 160
  margin : Nat := 5

end Config

structure Config where
  tickDt : Rat := 1 / 60
  window : Config.Window
  bird : Config.Bird
  pipe : Config.Pipe
  gravity : Rat

end Flappy
