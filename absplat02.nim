# You are free to share, copy, transform and redistribute this file.
import gpt_physics
import pages

let cnv = getElementById("cp")
let ctx = cnv.getContext2d()

proc draw_bg*() =
  ctx.beginPath()
  ctx.fillStyle("#444")
  ctx.rect(0, 0, 416, 288)
  ctx.fill()

proc draw_ap*(c: Circle) =
  ctx.beginPath()
  ctx.lineWidth(2)
  ctx.fillStyle("#666")
  ctx.circle(c.center.x, c.center.y, c.radius)
  ctx.fill()

# main

let gravity = Vector(x: 0, y: 1.8)
let restitution: cdouble = 0.6  # Coefficient of restitution (0.6 means 40% energy loss)
let dt: cdouble = 0.2

var c1 = Circle[void](center: Point(x: 120, y: 95), radius: 9.8, inertia: Vector(x: 0, y: 0), is_static: false)

var circles = @[c1]
var segments: seq[Segment] = @[]

let tex_filename: cstring = "./Abstract_Platformer_370_assets/Vector/vector_complete.svg"
var tex_loaded: bool = false

proc tex_onload() =
  tex_loaded = true

let tex = newImage()
setImgSrc(tex, tex_filename)
imgOnload(tex, tex_onload)

proc draw_ap2(c: Circle) =
  let cx = c.center.x
  let cy = c.center.y
  let dx = cx - 10
  let dy = cy - 12
  ctx.drawImage8(tex, 1786, 676, 44, 54, dx, dy, 20, 23)

proc addSegment(x1, y1, x2, y2: int) =
  let a = Point(x: cdouble(x1), y: cdouble(y1))
  let b = Point(x: cdouble(x2), y: cdouble(y2))
  let seg = Segment(a: a, b: b)
  segments.add(seg)

proc addSquare(dx, dy, dw, dh: int) =
  addSegment(dx, dy, dx + dw, dy)
  addSegment(dx, dy + dh, dx + dw, dy + dh)
  addSegment(dx, dy, dx, dy + dh)
  addSegment(dx + dw, dy, dx + dw, dy + dh)

let map = @[
  0,0,0,0,0,0,0,0,0,0,0,0,204,
  0,0,194,196,0,0,0,203,0,0,0,0,194,
  202,0,0,0,0,194,195,195,196,0,0,0,193,
  195,196,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,194,195,195,
  0,0,0,194,195,196,0,0,0,0,0,0,0,
  196,0,0,0,0,0,0,234,0,0,0,0,0,
  231,195,195,195,195,195,195,195,196,0,0,235,194,
  193,225,257,193,225,193,193,193,231,195,195,195,195
]

let coll = @[193,194,195,196]  # collidables

for j, tm in map:
  if tm in coll:
    let dx = (j mod 13) * 32
    let dy = (j div 13) * 32
    addSquare(dx, dy, 32, 32)

proc bounds(circles: var seq[Circle[void]]) =
  var c = addr circles[0]
  c[].center.x = max(c[].center.x,  -2 + 9.8)
  c[].center.x = min(c[].center.x, 416 - 4.8)
  c[].center.y = max(c[].center.y, -6 + 9.8)

proc animate() =
  update_circles(circles, segments, gravity, dt, restitution)
  bounds(circles)
  circles[0].inertia.x *= 0.99
  draw_bg()
  if tex_loaded:
    for j, tm in map:
      if tm != 0:
        let i = (tm - 1)
        let sx = (i mod 32) * 74
        let sy = (i div 32) * 74
        let dx = (j mod 13) * 32
        let dy = (j div 13) * 32
        ctx.drawImage8(tex, sx, sy, 64, 64, dx, dy, 32, 32)
    for c in circles:
      draw_ap2(c)

proc key_event(k: KeyEvent) =
  var c = addr circles[0]
  let ck = getKeyCode(k)
  case ck
  of 37: # left
    c[].inertia.x -= 1.2
    c[].inertia.y -= 1.8
    c[].inertia.x = max(c[].inertia.x, -10.0)
    c[].inertia.y = max(c[].inertia.y, -14.0)
  of 39: # right
    c[].inertia.x += 1.2
    c[].inertia.y -= 1.8
    c[].inertia.x = min(c[].inertia.x, 10.0)
    c[].inertia.y = max(c[].inertia.y, -14.0)
  of 38: # up
    c[].inertia.y -= 2.2
    c[].inertia.y = max(c[].inertia.y, -14.0)
  else: discard
  #log("inertia: ", c[].inertia.x, c[].inertia.y)

addKeyDownEventListener(key_event)
setInterval(animate, 1000 div 18)

