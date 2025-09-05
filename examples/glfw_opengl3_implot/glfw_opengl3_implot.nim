import std/[random,sugar,strutils]

import nimgl/[opengl,glfw]
import imgui, imgui/[impl_opengl, impl_glfw]
import implot

include ../utils/setupFonts
include ../utils/simple

const MainWinWidth = 1024
const MainWinHeight = 800

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
#  |  true     | -        |     false           ||    v    |     -       |   v     | Docking and outside of viewport
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

#---------------------
# Forward definitions
#---------------------
proc winMain(hWin: glfw.GLFWWindow)

#-----------
# templates
#-----------
template ptz(val:untyped): untyped =
  val[0].addr
type
  Ims32 = cint

#--------------
# imPlotWindow
#--------------
proc imPlotWindow(fshow:var bool) =
  var
    bar_data{.global.}:seq[Ims32]
    x_data  {.global.}:seq[Ims32]
    y_data  {.global.}:seq[Ims32]
  once: # This needs when set up compilation option to --mm:arc,--mm:orc and use nim-2.0.0 later,
        # workaround {.global.} pragma issue.
    bar_data= collect(for i in 0..10: rand(100).Ims32)
    x_data  = collect(for i in 0..10: i.Ims32)
    y_data  = collect(for i in 0..10: (i * i).Ims32)

  if igBegin("Plot Window".cstring, addr fshow):
    defer: igEnd()
    #
    if ipBeginPlot("My Plot",ImVec2(x:0.0f,y:0.0f),0.ImplotFlags):
      defer: ipEndPlot()
      #
      ipPlotBars("My Bar Plot".cstring
                              ,bar_data.ptz
                              ,bar_data.len.cint
                              ,0.67.cdouble # bar_size
                              ,0.0.cdouble  # shift
                              ,0.ImPlotBarsFlags
                              ,0.cint # offset
                              ,sizeof(Ims32).cint) # stride
      ipPlotLine("My Line Plot".cstring
                              , x_data.ptz
                              , y_data.ptz
                              , xdata.len.cint
                              ,0.ImPlotLineFlags
                              ,0.cint # offset
                              ,sizeof(Ims32).cint) # stride

#------
# main
#------
proc main() =
  doAssert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)
  glfwWindowHint(GLFWVisible, GLFW_FALSE) # Hide main window at start up time. See TODO 1
  #
  var glfwWin = glfwCreateWindow(MainWinWidth, MainWinHeight)
  if glfwWin.isNil:
    quit(-1)
  glfwWin.makeContextCurrent()
  defer: glfwWin.destroyWindow()

  glfwSwapInterval(1) # Enable vsync

  doAssert glInit() # OpenGL init

  # setup ImGui
  let context = igCreateContext(nil)
  defer: context.igDestroyContext()

  # setup ImPlot
  var imPlotContext = ipCreateContext()
  defer: ipDestroyContext(imPlotContext)

  if fDocking:
    var pio = igGetIO()
    pio.configFlags = cast[ImGuiConfigFlags](pio.configFlags.int or ImGuiConfigFlags.DockingEnable.int)
    if fViewport:
      pio.configFlags = cast[ImGuiConfigFlags](pio.configFlags.int or ImGuiConfigFlags.ViewportsEnable.int)
      pio.configViewportsNoAutomerge = true

  # GLFW + OpenGL
  const glsl_version = "#version 130" # GL 3.0 + GLSL 130
  doAssert igGlfw_InitForOpenGL(glfwwin, true)
  defer: igGlfw_Shutdown()
  doAssert igOpenGL3_Init(glsl_version)
  defer: igOpenGL3_Shutdown()
  glfwWin.winMain()

#---------
# winMain
#---------
proc winMain(hWin: glfw.GLFWWindow) =
  var
    showDemoWindow = true
    showAnotherWindow = false
    showImPlotWindow = true
    showFirstWindow = true
    fval = 0.5f
    counter = 0
    sBuf = newString(200)
    clearColor:ccolor
    showWindowDelay = 1 # TODO 1

  if TransparentViewport:
    clearColor = ccolor(elm:(x:0f, y:0f, z:0f, w:0.0f)) # Transparent
  else:
    clearColor = ccolor(elm:(x:0.25f, y:0.65f, z:0.85f, w:1.0f))

  igStyleColorsClassic(nil)

  # Add multibytes font
  discard setupFonts()

  # for ImPlot
  discard initRand()

  var pio = igGetIO()

  # main loop
  while not hWin.windowShouldClose:
    glfwPollEvents()

    # start imgui frame
    igOpenGL3_NewFrame()
    igGlfw_NewFrame()
    igNewFrame()

    if showDemoWindow:
      igShowDemoWindow(addr showDemoWindow)
      ipShowDemoWindow(addr showDemoWindow)

    # show a simple window that we created ourselves.
    if showFirstWindow:
      igBegin("Nim: Dear ImGui test with Futhark".cstring, addr showFirstWindow)
      defer: igEnd()
      var s = "GLFW v" & $glfwGetVersionString()
      igText(s.cstring)
      s = "OpenGL v" & ($cast[cstring](glGetString(GL_VERSION))).split[0]
      igText(s.cstring)
      igInputTextWithHint("InputText".cstring ,"Input text here".cstring ,sBuf.cstring,sBuf.len.uint)
      igCheckbox("Demo window", addr showDemoWindow)
      igCheckbox("Another window", addr showAnotherWindow)
      igSliderFloat("Float", addr fval, 0.0f, 1.0f, "%.3f")
      igColorEdit3("Background color", clearColor.array3)

      if igButton("Button", ImVec2(x: 0.0f, y: 0.0f)):
        inc counter
      igSameLine(0.0f, -1.0f)
      igText("counter = %d", counter)
      igText("Application average %.3f ms/frame (%.1f FPS)".cstring, (1000.0f / igGetIO().framerate.float).cfloat, igGetIO().framerate)
      igSeparatorText(ICON_FA_WRENCH & " Icon font test ")
      igText(ICON_FA_TRASH_CAN & " Trash")
      igText(ICON_FA_MAGNIFYING_GLASS_PLUS &
        " " & ICON_FA_POWER_OFF &
        " " & ICON_FA_MICROPHONE &
        " " & ICON_FA_MICROCHIP &
        " " & ICON_FA_VOLUME_HIGH &
        " " & ICON_FA_SCISSORS &
        " " & ICON_FA_SCREWDRIVER_WRENCH &
        " " & ICON_FA_BLOG)

    # show further samll window
    if showAnotherWindow:
      igBegin("imgui Another Window", addr showAnotherWindow)
      igText("Hello from imgui")
      if igButton("Close me", ImVec2(x: 0.0f, y: 0.0f)):
        showAnotherWindow = false
      igEnd()

    # ImPlot test
    if showImPlotWindow:
      imPlotWindow(showImPlotWindow)

    # render
    igRender()
    glClearColor(clearColor.elm.x, clearColor.elm.y, clearColor.elm.z, clearColor.elm.w)
    glClear(GL_COLOR_BUFFER_BIT)
    igOpenGL3_RenderDrawData(igGetDrawData())

    if 0 != (pio.configFlags.int and ImGuiConfigFlags.ViewportsEnable.int):
      var backup_current_window = glfwGetCurrentContext()
      igUpdatePlatformWindows()
      igRenderPlatformWindowsDefault(nil, nil)
      backup_current_window.makeContextCurrent()

    hWin.swapBuffers()
    if not showFirstWindow and not showDemoWindow and not showAnotherWindow and
       not showImPlotWindow:
      hwin.setWindowShouldClose(true) # End program

    if showWindowDelay > 0:
      dec showWindowDelay
    else:
      once: # Avoid flickering screen at startup.
        hWin.showWindow()

#------
# main
#------
main()
