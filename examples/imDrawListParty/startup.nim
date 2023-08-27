# For Linux Debian 11 Bullseye,
#   $ sudo apt install xorg-dev libopengl-dev ibgl1-mesa-glx libgl1-mesa-dev

import nimgl/[opengl, glfw]
import imgui/[impl_opengl, impl_glfw]

type ccolor* {.union.} = object
  elm*:tuple[x,y,z,w: cfloat]
  array3*: array[3, cfloat]
  #vec4*:ImVec4

# メインウインドウのサイズ
const MainWinWidth =  960
const MainWinHeight = 860
var
  glfwWin: GLFWWindow
  fExistMultibytesFonts = false
  sActiveFontName, sActiveFontTitle: string
  show_demo: bool = true # デモ表示 可否
  clearColor = ccolor(elm:(x:0.45f, y:0.55f, z:0.60f, w:1.0f)) # 背景の色

proc winMain(hWin: glfw.GLFWWindow)


#--------------
# main
#--------------
proc main*() =

  # GLFWの初期化 開始
  doAssert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  glfwWin = glfwCreateWindow(MainWinWidth, MainWinHeight,"main")
  if glfwWin.isNil:
    quit(-1)
  glfwWin.makeContextCurrent()
  defer: glfwWin.destroyWindow()

  glfwSwapInterval(1) # Enable vsync 画面の更新頻度 CPU負荷を低減

  doAssert glInit()
  # ImGuiの初期化 開始
  let context = igCreateContext(nil)
  defer: context.igDestroyContext()
  #
  var style = igGetStyle()
  style.frameBorderSize = 1.0f # ボーダーを濃く
  #
  let pio = igGetIO()
  pio.configflags = (pio.configflags.int32 or ImguiConfigflags.NavEnableKeyboard.int32).ImGuiConfigFlags
  when true:
    pio.configflags = (pio.configflags.int32 or ImguiConfigflags.NavEnableGamepad.int32).ImGuiConfigFlags
    pio.configflags = (pio.configflags.int32 or ImguiConfigflags.DockingEnable.int32).ImGuiConfigFlags
    #pio.configflags = pio.Configflags or ImguiConfigflags_ViewportsEnable.cint
    #io.configViewportsNoAutoMerge = true;
    pio.configViewportsNoTaskBarIcon = true;

  # setup ImPlot
  #var imPlotContext = ImPlotCreateContext()
  #defer: ImPlotDestroyContext(imPlotContext)

  # バックエンドは  GLFW + OpenGL
  doAssert igGlfwInitForOpenGL(glfwwin, true)
  defer: igGlfwShutdown()
  #
  doAssert igOpenGL3_Init()
  defer: igOpenGL3_Shutdown()
  #
  glfwWin.winMain()


#--------------
# winMain
#--------------
proc winMain(hWin: glfw.GLFWWindow) =
  ## メイン

  # テーマの起動時配色 選択 theme
  #igStyleColorsLight(nil)   # Windows風
  igStyleColorsDark(nil) # ダーク系1
  #igStyleColorsClassic(nil) # ダーク系2
  #igStyleColorsCherry(nil)  # ダーク系3


  # 日本語フォントを追加
  #(fExistMultibytesFonts,sActiveFontName, sActiveFontTitle) = setupFonts()
  #
  # メインループ
  while not hWin.windowShouldClose:
    glfwPollEvents()

    # start imgui frame
    igOpenGL3_NewFrame()
    igGlfw_NewFrame()
    igNewFrame()

    if show_demo: igShowDemoWindow(show_demo.addr)

    mainWin()

    igRender()
    glClearColor(clearColor.elm.x, clearColor.elm.y, clearColor.elm.z, clearColor.elm.w) # 背景の色
    glClear(GL_COLOR_BUFFER_BIT)
    igOpenGL3_RenderDrawData(igGetDrawData())
    hWin.swapBuffers()

main()
