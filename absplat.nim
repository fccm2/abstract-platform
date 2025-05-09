#import gpt_physics
import pages

let cnv = getElementById("cp")
let ctx = cnv.getContext2d()

proc draw_bg() =
  ctx.beginPath()
  ctx.fillStyle("#444")
  ctx.rect(0, 0, 384, 256)
  ctx.fill()

# main

#let gravity = Vector(x: 0, y: 1.6)
#let restitution: cdouble = 0.8  # Coefficient of restitution (0.8 means 20% energy loss)
#let dt: cdouble = 0.2

#var circles = @[]
#var segments = @[]

let tex_filename: cstring = "./Abstract_Platformer_370_assets/Vector/vector_complete.svg"
var tex_loaded: bool = false

proc tex_onload() =
  tex_loaded = true

let tex = newImage()
setImgSrc(tex, tex_filename)
imgOnload(tex, tex_onload)

proc animate() =
  #update_circles(circles, segments, gravity, dt, restitution)
  draw_bg()
  let map = @[
    0,0,0,0,0,0,0,0,0,0,0,0,
    10,0,0,0,0,0,0,0,0,0,0,0,
    3,4,0,0,0,0,0,0,0,0,0,0,
    1,1,0,0,0,0,0,0,0,0,0,44,
    3,3,4,0,0,0,0,0,0,0,2,3,
    1,1,1,0,0,0,42,0,2,3,38,1,
    1,39,3,3,3,3,3,3,3,38,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1
  ]
  if tex_loaded:
    for j, tm in map:
      if tm != 0:
        let i = (tm - 1)
        let sx = (i mod 32) * 74
        let sy = (i div 32) * 74
        let dx = (j mod 12) * 32
        let dy = (j div 12) * 32
        ctx.drawImage8(tex, sx, sy, 64, 64, dx, dy, 32, 32)

setInterval(animate, 1000 div 2)

