import FlappyRaylean.Assets
import Raylean
import Flappy

namespace FlappyRaylean

instance : Coe Raylean.Types.Color Flappy.Color where
  coe c := { r := c.r, g := c.g, b := c.b, a := c.a }

instance : Coe Flappy.Color Raylean.Types.Color where
  coe c := { r := c.r, g := c.g, b := c.b, a := c.a }

instance : Coe Flappy.Rectangle Raylean.Types.Rectangle where
  coe r := { x := r.x, y := r.y, width := r.width, height := r.height }

variable
  {m}
  [Monad m]
  [MonadReaderOf Assets m]
  [MonadLiftT IO m]

instance : Flappy.MonadRender m where
  drawRectangle r c := Raylean.drawRectangleRec r c
  clearBackground c := Raylean.clearBackground c
  drawAsset name dest := do
    let assets ← readThe Assets
    let asset := match name with
      | .birdyUp => assets.birdyUp
      | .birdyDown => assets.birdyDown
    asset.render dest
  drawText s x y size c := Raylean.drawText s x y size c

end FlappyRaylean
