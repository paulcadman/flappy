import Flappy.Types

namespace Flappy

namespace Config

structure Window where
  /-- Window height in pixels -/
  height : Nat
  /-- Window width in pixels -/
  width : Nat
  /-- The color of the window background -/
  backgroundColor : Color
  /-- The color of the score text -/
  scoreTextColor : Color
  /-- The color of the end text -/
  endTextColor : Color

structure Bird where
  /-- Horizonal center position in pixels -/
  x : Rat
  /-- Rendered sprite width in pixels -/
  drawWidth : Nat := 50
  /-- Rendered sprite height in pixels -/
  drawHeight : Nat := 40
  /-- Sprite collision width in pixels -/
  width : Nat := 35
  /-- Sprite collision height in pixels -/
  height : Nat := 40
  /-- Velocity after a flap in y-scaled position units per tick.
  negative values move the bird upwards on the screen -/
  flapVelocity : Int := -13

structure Pipe where
  /-- Horizontal movement speed in pixels per second -/
  speed : Nat
  /-- Width in pixels -/
  width : Nat := 100
  /-- Horizontal spacing between consecutive pipes in pixels -/
  spacing : Nat
  /-- Gap size in pixels -/
  gapSize : Nat := 160
  /-- Minimum margin from the top and bottom of the window in pixels -/
  margin : Nat := 5
  /-- The color of the pipe --/
  color : Color

end Config

structure Config where
  /-- Physics tick duration in seconds -/
  tickDt : Rat := 1 / 60
  /-- Fixed-point scale used for bird dynamics. A bird y-position of `n`
  represents `n / yScale` pixels -/
  yScale : Nat
  /-- Configuration related to the window -/
  window : Config.Window
  /-- Configuration related to the bird -/
  bird : Config.Bird
  /-- Configuratinon related to pipes -/
  pipe : Config.Pipe
  /-- Downward acceleration added to the bird velocity each tick in
  y-scaled units per tick -/
  gravityStep : Int := 1

end Flappy
