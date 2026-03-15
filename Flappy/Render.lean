import Raylean
import Flappy.Assets
import Flappy.Bird
import Flappy.Config
import Flappy.Pipe
import Flappy.State

open Raylean
open Raylean.Types

namespace Flappy

variable
  {m}
  [Monad m]
  [MonadReader Config m]
  [MonadReaderOf Assets m]
  [MonadLiftT IO m]

def Pipe.render
  (pipe : Pipe) : m Unit := do
  drawRectangleRec
    { x := pipe.leftEdge
      y := 0
      width := pipe.width
      height := pipe.gapTop }
    Color.Raylean.darkgreen
  let windowHeight : Rat := (← read).window.height
  drawRectangleRec
    { x := pipe.leftEdge
      y := pipe.gapBottom
      width := pipe.width
      height := windowHeight - pipe.gapBottom }
    Color.Raylean.darkgreen

def Bird.render
  (bird : Bird) : m Unit := do
  let birdyUpAsset := (← readThe Assets).birdyUp
  let birdyDownAsset := (← readThe Assets).birdyDown
  let dest : Rectangle :=
         { x := ← bird.leftEdge
           y := ← bird.topEdge
           width := ← bird.drawWidth
           height := ← bird.drawHeight }
  let asset := if bird.velocity < 0 then birdyUpAsset else birdyDownAsset
  asset.render dest

def State.render
  (s : State) : m Unit := do
  clearBackground Color.Raylean.skyblue
  for p in s.pipes do p.render
  s.bird.render
  drawText s!"score : {s.score}" 20 20 20 Color.black
  if (← s.hasCollision) then drawText s!"GAME OVER - SCORE: {s.score} - press R to restart" ((← read).window.width / 2 - 200) ((← read).window.height / 2 - 20) 20 Color.red

end Flappy
