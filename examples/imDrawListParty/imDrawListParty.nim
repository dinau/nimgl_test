# For Linux Debian 11 Bullseye,
#   $ sudo apt install xorg-dev libopengl-dev ibgl1-mesa-glx libgl1-mesa-dev
import imgui,imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]

import std/[math, random]

type
  ImU32 = cuint
  V2 = ImVec2

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


#include "fx.inl" // <--- your effect

#---------
# fxCurve
#---------
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

#----------
# fxVisual
#----------
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

#-----------
# fxTestBed
#-----------
# Shared testbed
proc fxTestBed(title: string, showdemo: ptr bool,fx: proc(d: ptr ImDrawList, a, b, sz: ImVec2, mouse: ImVec4, tx: cfloat)) =
  let io = igGetIO()
  igBegin(title, showdemo, ImGuiWindowFlags.AlwaysAutoResize)
  defer: igEnd()

  let size = ImVec2(x: 320.0f, y: 180.0f)
  igInvisibleButton("canvas", size)
  var p0, p1: ImVec2
  igGetItemRectMinNonUDT(p0.addr)
  igGetItemRectMaxNonUDT(p1.addr)
  let draw_list = igGetWindowDrawList()
  block:
    draw_list.pushClipRect(p0, p1)
    defer: draw_list.popClipRect()

    var mouse_data: ImVec4
    mouse_data.x = (io.mousePos.x - p0.x) / size.x
    mouse_data.y = (io.mousePos.y - p0.y) / size.y
    mouse_data.z = io.mouseDownDuration[0]
    mouse_data.w = io.mouseDownDuration[1]

    fx(draw_list, p0, p1, size, mouse_data, igGetTime())

#-------
# fxWin
#-------
var
  showCurveDemo = true
  showVisulaDemo = true

proc fxWin() =
  if showCurveDemo:
    fxTestBed("Curve", showCurveDemo.addr,fxCurve)
  if showVisulaDemo:
    fxTestBed("Visual",showVisulaDemo.addr,fxVisual)

#---------
# mainWin
#---------
proc mainWin() =
  fxWin()

type ccolor* {.union.} = object
  elm*:tuple[x,y,z,w: cfloat]
  array3*: array[3, cfloat]
  #vec4*:ImVec4

# メインウインドウのサイズ
const MainWinWidth =  960
const MainWinHeight = 860
var
  glfwWin: GLFWWindow
  #fExistMultibytesFonts = false
  #sActiveFontName, sActiveFontTitle: string
  showDemoWindow : bool = true # デモ表示 可否

#--------------------
# Forward definition
#--------------------
proc winMain(hWin: glfw.GLFWWindow)

#--------------
# Configration
#--------------

#  .--------------------------------------------..---------.-----------------------.------------
#  |         Combination of flags               ||         |     Viewport          |
#  |--------------------------------------------||---------|-----------------------|------------
#  | fViewport | fDocking | TransparentViewport || Docking | Transparent | Outside | Description
#  |:---------:|:--------:|:-------------------:||:-------:|:-----------:|:-------:| -----------
#  |  false    | false    |     false           ||    -    |     -       |   -     |
#  |  false    | true     |     false           ||    v    |     -       |   -     | (Default): Only docking
#  |  true     | -        |     false           ||    v    |     -       |   v     | Doncking and outside of viewport
#  |    -      | -        |     true            ||    v    |     v       |   -     | Transparent Viewport and docking
#  `-----------'----------'---------------------'`---------'-------------'---------'-------------
var
 fDocking = true
 fViewport = false
 TransparentViewport = false
 #
block:
  if TransparentViewport:
    fViewport = true
  if fViewport:
    fDocking = true

#------
# main
#------
proc main() =
  # GLFWの初期化 開始
  doAssert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)
  glfwWindowHint(GLFWVisible, GLFW_FALSE) # Hide main window at start up time. See TODO 1

  #
  glfwWin = glfwCreateWindow(MainWinWidth, MainWinHeight)
  if glfwWin.isNil:
    quit(-1)
  glfwWin.makeContextCurrent()
  defer: glfwWin.destroyWindow()

  glfwSwapInterval(1) # Enable vsync 画面の更新頻度 CPU負荷を低減

  doAssert glInit()
  # ImGuiの初期化 開始
  let context = igCreateContext()
  defer: context.igDestroyContext()

  if fDocking:
    var pio = igGetIO()
    pio.configFlags = (pio.configFlags.cint or DockingEnable.cint).ImGuiConfigFlags
    if fViewport:
      pio.configFlags = (pio.configFlags.cint or ViewportsEnable.cint).ImGuiConfigFlags
      pio.configViewports_NoAutomerge = true

  # バックエンドは  GLFW + OpenGL
  doAssert igGlfwInitForOpenGL(glfwWin, true)
  defer: igGlfwShutdown()
  doAssert igOpenGL3Init() # Default is OpenGL 3.0 + GLSL 130
  defer: igOpenGL3Shutdown()

  glfwWin.winMain()

#---------
# winMain
#---------
proc winMain(hWin: GLFWWindow) =
  ## メイン
  var
    clearColor:ccolor
    showWindowDelay = 1 # TODO 1
  if TransparentViewport:
    clearColor = ccolor(elm:(x:0f, y:0f, z:0f, w:0.0f)) # Transparent
  else:
    clearColor = ccolor(elm:(x:0.25f, y:0.65f, z:0.85f, w:1.0f))

  # テーマの起動時配色 選択 theme
  #igStyleColorsLight()   # Windows風
  igStyleColorsDark() # ダーク系1
  #igStyleColorsClassic() # ダーク系2
  #igStyleColorsCherry()  # ダーク系3

  # 日本語フォントを追加
  #(fExistMultibytesFonts,sActiveFontName, sActiveFontTitle) = setupFonts()
  #
  # メインループ
  while not hWin.windowShouldClose:
    glfwPollEvents()
    # start imgui frame
    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if showDemoWindow: # デモ画面の表示
      igShowDemoWindow(showDemoWindow.addr)

    mainWin()

    igRender()
    when false:
      var displayW,displayH:cint
      hwin.getFramebufferSize(displayW.addr,displayH.addr)
      glViewPort(0, 0, displayW, displayH)
    glClearColor(clearColor.elm.x, clearColor.elm.y, clearColor.elm.z, clearColor.elm.w)
    glClear(GL_COLOR_BUFFER_BIT)
    igOpenGL3RenderDrawData(igGetDrawData())
    #
    var pio = igGetIO()
    if 0 != (pio.configFlags.cint and ViewportsEnable.cint):
      var backup_current_window = glfwGetCurrentContext()
      igUpdatePlatformWindows()
      igRenderPlatformWindowsDefault(nil, nil)
      backup_current_window.makeContextCurrent()

    hWin.swapBuffers()
    if not showCurveDemo and not showVisulaDemo and not showDemoWindow:
      hwin.setWindowShouldClose(true) # End program

    if showWindowDelay > 0:
      dec showWindowDelay
    else:
      once: # Avoid flickering screen at startup.
        hWin.showWindow()
#------
# mian
#------
main()
