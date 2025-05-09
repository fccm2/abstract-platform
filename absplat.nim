import gpt_physics
import pages

let cnv = getElementById("cp")
let ctx = cnv.getContext2d()

proc draw_bg*() =
  ctx.beginPath()
  ctx.fillStyle("#444")
  ctx.rect(0, 0, 384, 256)
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

var c1 = Circle[void](center: Point(x: 120, y: 70), radius: 9.6, inertia: Vector(x: 0, y: 0), is_static: false)

let a = Point(x: 0, y: -10)
let b = Point(x: 0, y: 256)
let s1 = Segment(a: a, b: b)

let c = Point(x: 384, y: -10)
let d = Point(x: 384, y: 256)
let s2 = Segment(a: c, b: d)

let e = Point(x:   0, y: -10)
let f = Point(x: 384, y: -10)
let s3 = Segment(a: e, b: f)

var circles = @[c1]
var segments = @[s1, s2, s3]

let tex_filename: cstring = "./Abstract_Platformer_370_assets/Vector/vector_complete.svg"
var tex_loaded: bool = false

proc tex_onload() =
  tex_loaded = true

let tex = newImage()
setImgSrc(tex, tex_filename)
imgOnload(tex, tex_onload)

proc draw_ap2(c: Circle) =
  #let cx = cint(c.center.x)
  #let cy = cint(c.center.y)
  let cx = c.center.x
  let cy = c.center.y
  let dx = cx - 9
  let dy = cy - 11
  ctx.drawImage8(tex, 1788, 21, 38, 44, dx, dy, 19, 22)

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

let coll = @[1,2,3,4,38,39]  # collidables

for j, tm in map:
  if tm in coll:
    let dx = (j mod 12) * 32
    let dy = (j div 12) * 32
    addSquare(dx, dy, 32, 32)

proc animate() =
  update_circles(circles, segments, gravity, dt, restitution)
  circles[0].inertia.x *= 0.99
  draw_bg()
  if tex_loaded:
    for j, tm in map:
      if tm != 0:
        let i = (tm - 1)
        let sx = (i mod 32) * 74
        let sy = (i div 32) * 74
        let dx = (j mod 12) * 32
        let dy = (j div 12) * 32
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

