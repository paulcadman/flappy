import Flappy.Bird
import Flappy.Config
import Flappy.Pipe
import Flappy.State
import Flappy.Types

namespace Flappy

inductive AssetName where
  | birdyUp
  | birdyDown

class MonadRender (m : Type → Type) where
  drawRectangle : Rectangle → Color → m Unit
  clearBackground : Color → m Unit
  drawAsset : (name : AssetName) → (dest : Rectangle) → m Unit
  drawText : String → (x : Nat) → (y : Nat) → (size : Nat) → Color → m Unit

variable
  {m}
  [Monad m]
  [MonadReaderOf Config m]
  [MonadRender m]

def Pipe.render
  (pipe : Pipe) : m Unit := do
  MonadRender.drawRectangle
    { x := pipe.leftEdge
      y := 0
      width := pipe.width
      height := pipe.gapTop }
    (← readThe Config).pipe.color
  let windowHeight : Rat := (← readThe Config).window.height
  MonadRender.drawRectangle
    { x := pipe.leftEdge
      y := pipe.gapBottom
      width := pipe.width
      height := windowHeight - pipe.gapBottom }
    (← readThe Config).pipe.color

def Bird.render
  (bird : Bird) : m Unit := do
  let dest : Rectangle :=
         { x := ← bird.leftEdge
           y := ← bird.topEdge
           width := ← bird.drawWidth
           height := ← bird.drawHeight }
  if bird.velocity < 0
    then MonadRender.drawAsset .birdyUp dest
    else MonadRender.drawAsset .birdyDown dest

def State.render
  (s : State) : m Unit := do
  let config ← readThe Config
  MonadRender.clearBackground config.window.backgroundColor
  for p in s.pipes do p.render
  s.bird.render
  MonadRender.drawText s!"score : {s.score}" 20 20 20 config.window.scoreTextColor
  if (← s.hasCollision) then
    MonadRender.drawText
      config.gameOver.text
      config.gameOver.position.fst
      config.gameOver.position.snd
      config.gameOver.size
      config.gameOver.color

end Flappy
