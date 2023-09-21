import imgui

proc mainWin()

type ImU32 = cuint

# convert RR,GG,BB,AA -> AA,BB,GG,RR
template ImCol32(r, g, b, a: untyped): ImU32 =
  (a.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or r.uint32
# convert RR,GG,BB -> AA,BB,GG,RR
template ImCol32(r, g, b: untyped): ImU32{.used.} =
  (0xff.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or r.uint32

#// Function signature:
#//  void FX(ImDrawList* d, ImVec2 a, ImVec2 b, ImVec2 sz, ImVec4 mouse, float t);
#//     d : draw list
#//     a : upper-left corner
#//     b : lower-right corner
#//    sz : size (== b - a)
#// mouse : x,y = mouse position (normalized so 0,0 over 'a'; 1,1 is over 'b', not clamped)
#//         z,w = left/right button held. <-1.0f not pressed, 0.0f just pressed, >0.0f time held.
#//    t  : time
#// If not using a given parameter, you can omit its name in your function to save a few characters.

type V2 = ImVec2

#include "fx.inl" // <--- your effect
import math
proc fxCurve(d: ptr ImDrawList, a, b, sz: ImVec2, mouse: ImVec4, tx: cfloat) =
  var t = tx
  while t < tx + 1.0f:
    t += 1.0f / 100.0f
    var
      cp0 = V2(x: a.x, y: b.y)
      cp1 = b
    let ts = t - tx
    cp0.x += (0.4f + sin(t) * 0.3f) * sz.x
    cp0.y -= (0.5f + cos(ts * ts) * 0.4f) * sz.y
    cp1.x -= (0.4f + cos(t) * 0.4f) * sz.x
    cp1.y -= (0.5f + sin(ts * t) * 0.3f) * sz.y
    d.addBezierCubic(V2(x: a.x, y: b.y), cp0, cp1, b, IM_COL32((100 + ts*150).uint
      , (255 - ts*150).uint
      , 60.uint
      , (ts * 200).uint)
    , 5.0f)

import random
randomize()

let sd = 0x7fff
const N = 300
var v: array[N, tuple[first: V2, second: V2]]
for p in v.mitems:
  let rnd = V2(x: (rand(sd) mod 320).cfloat, y: (rand(sd) mod 180).cfloat)
  p.first = rnd
  p.second = rnd
proc l2(x: V2): cfloat = x.x * x.x + x.y * x.y
proc `+`(a, b: V2): V2 = V2(x: a.x+b.x, y: a.y+b.y)
proc `-`(a, b: V2): V2 = V2(x: a.x-b.x, y: a.y-b.y)
proc `/`(a: V2, d: cfloat): V2 = V2(x: a.x / d, y: a.y / d)
proc `+=`(a: var V2, b: V2) = a = a + b

proc fxVisual(d: ptr ImDrawList, a, b, s: ImVec2, mouse: ImVec4, tx: cfloat) =
  var D, T: cfloat
  for p in v.mitems:
    D = sqrt(l2(p.first - p.second))
    if D > 0:
      p.first += (p.second - p.first) / D
    if D < 4:
      p.second = V2(x: (rand(sd) mod 320).cfloat, y: (rand(sd) mod 180).cfloat)

  for i in 0..<N:
    var j = i + 1
    while j < N:
      D = l2(v[i].first - v[j].first)
      T = l2(v[i].first + v[j].first - s) / 200
      if T > 255:
        T = 255
      if D < 400:
        d.addLine(a + v[i].first, a + v[j].first,
                   IM_COL32(T, 255 - T, 255, 70), 2)
      inc j

# Shared testbed
proc fxTestBed(title: string, fx: proc(d: ptr ImDrawList, a, b, sz: ImVec2, mouse: ImVec4, tx: cfloat)) =
  let io = igGetIO()
  igBegin(title, nil, ImGuiWindowFlags.AlwaysAutoResize)
  defer: igEnd()

  let size = ImVec2(x: 320.0f, y: 180.0f)
  igInvisibleButton("canvas", size)
  var p0, p1: ImVec2
  igGetItemRectMinNonUDT(p0.addr)
  igGetItemRectMaxNonUDT(p1.addr)
  let draw_list = igGetWindowDrawList()
  draw_list.pushClipRect(p0, p1)

  var mouse_data: ImVec4
  mouse_data.x = (io.mousePos.x - p0.x) / size.x
  mouse_data.y = (io.mousePos.y - p0.y) / size.y
  mouse_data.z = io.mouseDownDuration[0]
  mouse_data.w = io.mouseDownDuration[1]

  fx(draw_list, p0, p1, size, mouse_data, igGetTime())
  draw_list.popClipRect()

proc fxWin() =
  fxTestBed("Curve", fxCurve)
  fxTestBed("Visual", fxVisual)

proc mainWin() =
  fxWin()

include startup
