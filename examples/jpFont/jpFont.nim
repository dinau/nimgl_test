# 2023/10 Updated "impl_glfw.nim" to latest version.
# 2023/07 Modified
# 2023/02 First
# written by audin.
#
# For Windows10.
# For Linux Debian 11 Bullseye,
#   $ sudo apt install xorg-dev libopengl-dev ibgl1-mesa-glx libgl1-mesa-dev

import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
#
import std/[os, strutils]
import tinydialogs
include "setupFonts.nim"

# メインウインドウのサイズ
const MainWinWidth = 1080
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

type ccolor* {.union.} = object
  elm*:tuple[x,y,z,w: cfloat]
  array3*: array[3, cfloat]

# Global variables
var
  showDemoWindow: bool = true # デモ表示 可否
  showFirstWindow = true
  glfwWin: GLFWWindow
  sActiveFontName, sActiveFontTitle: string
  fExistMultbytesFonts = false
var sBuf{.global.}: string = newString(200)

# Forward definition
proc winMain(hWin: GLFWWindow)
proc firstWindow()

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
  if TransparentViewport:
    glfwWindowHint(GLFWVisible, GLFW_FALSE)

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
  var clearColor:ccolor
  if TransparentViewport:
    clearColor = ccolor(elm:(x:0f, y:0f, z:0f, w:0.0f)) # Transparent
  else:
    clearColor = ccolor(elm:(x:0.25f, y:0.65f, z:0.85f, w:1.0f))
  # テーマの起動時配色 選択 theme
  #igStyleColorsLight()   # Windows風
  igStyleColorsDark() # ダーク系1
  #igStyleColorsClassic() # ダーク系2
  #igStyleColorsCherry()  # ダーク系3
  #
  # 日本語フォントを追加
  (fExistMultbytesFonts, sActiveFontName, sActiveFontTitle) = setupFonts()
  # メインループ
  while not hWin.windowShouldClose:
    glfwPollEvents()
    # start imgui frame
    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if showDemoWindow: # デモ画面の表示
      igShowDemoWindow(showDemoWindow.addr)
    if showFirstWindow:
      firstWindow() # Simple window start

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
    if not showFirstWindow and not showDemoWindow :
      hwin.setWindowShouldClose(true) # End program

#-------------------
# helpMaker
#-------------------
proc helpMarker(desc: string) =
  igTextDisabled("(?)")
  if (igIsItemHovered()):
    igBeginTooltip()
    igPushTextWrapPos(igGetFontSize() * 35.0f)
    igTextUnformatted(desc)
    igPopTextWrapPos()
    igEndTooltip()

#-------------------
# showStyleSelector
#-------------------
proc showStyleSelector(label: string): bool =
  var style_idx {.global.}: int32 = -1
  if igCombo(label, addr style_idx, "Dark\0Light\0Classic\0"):
    case style_idx
    of 0: igStyleColorsDark()
    of 1: igStyleColorsLight()
    of 2: igStyleColorsClassic()
    else: discard
    return true
  return false

#-------------------
# firstWindow
#-------------------
proc firstWindow() =
  ## 画面左の小さいWindowを描画
  var
    somefloat {.global.} = 0.0'f32
    counter {.global.} = 0'i32
    sFnameSelected {.global.}: string
  var pio = igGetIO()

  ### Window開始
  let sTitle = "[ImGui: v$#] テスト by Nim-lang 2023/07" % [$igGetVersion()]
  if igBegin(sTitle.cstring, addr showFirstWindow):
    defer: igEnd()
    #
    var s = "GLFW v" & $glfwGetVersionString()
    igText(s.cstring)
    s = "OpenGL v" & ($cast[cstring](glGetString(GL_VERSION))).split[0]
    igText(s.cstring)
    ### テーマの選択
    discard showStyleSelector("テーマ色の選択")
    ### フォント選択 コンボボックス
    igSeparator()
    var fontCurrent = igGetfont()
    if igBeginCombo("フォント選択", fontCurrent.getDebugName()):
      defer: igEndCombo()
      for n in 0..<pio.fonts.fonts.size:
        let font = pio.fonts.fonts.data[n]
        igPushID(font)
        if igSelectable(font.getDebugName(), font == fontCurrent):
          pio.fontDefault = font
        igPopID()
    igSameLine()
    helpMarker("""
- フォントの追加は io.Fonts->AddFontFromFileTTF().
- フォントマップは io.Fonts->GetTexDataAsXXXX() 又は io.Fonts->Build()が実行された時に追加される.
- 詳細はFAQ と docs/FONTS.md を読んで下さいs.
- 実行時にフォントの追加と削除が必要なら(例:DPIの変更等) NewFrame()の呼び出し前に行って下さい."""
    )
    ###
    igSeparator()
    igText("これは日本語テキスト")
    igInputText("ここに日本語入力".cstring, sBuf.cstring, sBuf.len.csize_t, 0.ImguiInputTextFlags, nil, nil)
    igText("出力: ")
    igSameLine()
    igText(sBuf.cstring)
    igSeparator()
    igSliderFloat("浮動小数", somefloat.addr, 0.0f, 1.0f)
    #
    igSeparator()
    when defined(windows):
      if igButton("ファイルを開く", ImVec2(x: 0, y: 0)):
        sFnameSelected = openFileDialog("Fileを開く", getCurrentDir() / "\0", ["*.nim", "*.nims"], "Text file")
      igSameLine()
    igText("選択ファイル名 = %s", sFnameSelected.cstring)
    #
    igSeparator()
    igText("描画フレームレート  %.3f ms/frame (%.1f FPS)"
      , 1000.0f / pio.framerate, pio.framerate)
    igText("経過時間 = %.1f [s]", counter.float32 / pio.framerate)
    counter.inc
    let delay = 600 * 3
    somefloat = (counter mod delay).float32 / delay.float32
    #
    igSeparator()
    igCheckbox("デモ・ウインドウ表示", showDemoWindow.addr)

#------
# main
#------
main()
