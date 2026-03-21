import Raylean

open Raylean
open Raylean.Types

namespace FlappyRaylean

variable
  {m}
  [Monad m]
  [MonadLiftT IO m]

structure Asset where
  texture : Texture2D

namespace Asset

/-- Returns a rectangle that can be used as the source rectangle for drawTexturePro to cover the whole texture-/
def fullImageSource (t : Texture2D) : Rectangle where
  x := 0
  y := 0
  width := t.width.toFloat
  height := t.height.toFloat

def load (name : String) : m Asset := do
  let image ← loadImage name
  loadTextureFromImage image |>.map mk

def render (asset : Asset) (dest : Rectangle) : m Unit := do
  let t := asset.texture
  drawTexturePro t (fullImageSource t) dest ⟨0,0⟩ 0 Color.white

end Asset

structure Assets where
  birdyUp: Asset
  birdyDown : Asset

namespace Assets

def load : m Assets := do
  let birdyUp ← Asset.load "assets/birdy_up_forall.svg"
  let birdyDown ← Asset.load "assets/birdy_down_forall.svg"
  pure { birdyUp, birdyDown }

end Assets

end FlappyRaylean
