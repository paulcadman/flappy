namespace Flappy

structure Color where
  /-- Color red value -/
  r : UInt8
  /-- Color green value -/
  g : UInt8
  /-- Color blue value -/
  b : UInt8
  /-- Color alpha value -/
  a : UInt8 := 255

structure Rectangle where
  /-- Rectangle top-left corner position x -/
  x : Rat
  /-- Rectangle top-left corner position y -/
  y : Rat
  /-- Rectangle width -/
  width : Rat
  /-- Rectangle height -/
  height : Rat

end Flappy
