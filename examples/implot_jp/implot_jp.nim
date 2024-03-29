# 2023/10 added: ImPlot demo
# 2023/07 modified
# 2023/02 first
# written by audin.
#
# For Linux Debian 11 Bullseye,
#   $ sudo apt install xorg-dev libopengl-dev ibgl1-mesa-glx libgl1-mesa-dev

import nimgl/[opengl, glfw]
import imgui, imgui/[impl_opengl, impl_glfw]
import implot
#
import std/[os, strutils, math, random, sequtils, sugar]
import tinydialogs
include "setupFonts.nim"

#---------------------
# Forward definitions
#---------------------
proc demo_LinePlots()
proc demo_SimplePlot()
proc demo_Histogram()

# メインウインドウのサイズ
const MainWinWidth = 1080
const MainWinHeight = 800

# Global variables

var
  show_demo: bool = true # デモ表示 可否
  glfwWin: GLFWWindow
  sActiveFontName, sActiveFontTitle: string
  fExistMultbytesFonts = false

var sBuf{.global.}: string = newString(200)

# Forward definition
proc winMain(hWin: GLFWWindow)
proc startSimpleWindow()

#--------------
# main
#--------------
proc main() =
  # GLFWの初期化 開始
  doAssert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

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

  # setup ImPlot
  var ipContext = ipCreateContext()
  defer: ipContext.ipDestroyContext()

  # バックエンドは  GLFW + OpenGL
  doAssert igGlfwInitForOpenGL(glfwWin, true)
  defer: igGlfwShutdown()
  doAssert igOpenGL3Init()
  defer: igOpenGL3Shutdown()
  #let io = igGetIO()
  #io.imeWindowHandle = glfwWin.getWin32Window()
  #
  glfwWin.winMain()

#--------------
# winMain
#--------------
proc winMain(hWin: GLFWWindow) =
  ## メイン

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
    #
    # 動的にフォント変更するならここ
    #
    igNewFrame()

    if show_demo: # デモ画面の表示
      igShowDemoWindow(show_demo.addr)
      ipShowDemoWindow(show_demo.addr)

    startSimpleWindow()

    igRender()
    glClearColor(0.45f, 0.55f, 0.60f, 1.00f) # 背景の色
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())
    hWin.swapBuffers()

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
# startSimpleWindow
#-------------------
proc startSimpleWindow() =
  ## 画面左の小さいWindowを描画

  var
    somefloat {.global.} = 0.0'f32
    counter {.global.} = 0'i32
    sFnameSelected {.global.}: string
  var pio = igGetIO()

  ### Window開始
  let sTitle = "[ImGui: v$#] テスト by Nim-lang 2023/10" % [$igGetVersion()]
  igBegin(sTitle.cstring)
  defer: igEnd()
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
  igCheckbox("デモ・ウインドウ表示", show_demo.addr)

  # ImPlot Demo
  igSeparator()
  demo_SimplePlot()
  igSeparator()
  demo_LinePlots()
  igSeparator()
  demo_Histogram()


#------------------
# demo_LinePlots()
#------------------
proc demo_LinePlots() =
  var
    xs1{.global.}: array[1001, float]
    ys1{.global.}: array[1001, float]
  for i in 0..<1001:
    xs1[i] = i.float * 0.001f
    ys1[i] = 0.5f + 0.5f * sin(50 * (xs1[i] + igGetTime().float / 10))
  var
    xs2{.global.}: array[20, float64]
    ys2{.global.}: array[20, float64]
  for i in 0..<20:
    xs2[i] = i.float * 1/19.0f
    ys2[i] = xs2[i] * xs2[i]
  if ipBeginPlot("周波数"):
    defer: ipEndPlot()
    ipSetupAxes("X軸", "Y軸")
    ipPlotLine("f(x)", xs1.ptz, ys1.ptz, 1001)
    ipSetNextMarkerStyle(Circle)
    ipPlotLine("g(x)", xs2.ptz, ys2.ptz, 20, Segments)

#------------------
# demo_Histogram()
#------------------
proc demo_Histogram() =
  const
    mu: double = 5
    sigma: double = 2
  var
    dist {.global.}: seq[cfloat64]
    hist_flags{.global.} = Density.int32
    bins {.global.}: ImPlotBin = cast[ImPlotBin](50)
  once:
    discard initRand()
    dist = collect(for i in 0..<10000: gauss(mu, sigma).cfloat64)

  igSetNextItemWidth(200)
  if igRadioButton("Sqrt", bins == Sqrt): bins = Sqrt; igSameLine()
  if igRadioButton("Sturges", bins == Sturges): bins = Sturges; igSameLine()
  if igRadioButton("Rice", bins == Rice): bins = Rice; igSameLine()
  if igRadioButton("Scott", bins == Scott): bins = Scott
  #igSameLine()
  if igRadioButton("N Bins", bins.int32 >= 0): bins = cast[ImPlotBin](50)
  if bins.int32 >= 0:
    igSameLine()
    igSetNextItemWidth(200)
    igSliderInt("##Bins", cast[ptr int32](addr bins), 1, 100)

  igCheckboxFlags("Horizontal", addr hist_flags, ImPlotHistogramFlags.Horizontal.int32)
  igSameLine()
  igCheckboxFlags("Density", addr hist_flags, Density.int32)
  igSameLine()
  igCheckboxFlags("Cumulative", addr hist_flags, Cumulative.int32)

  var frange{.global.} = false
  igCheckbox("Range", addr frange)
  var
    rmin{.global.}: cfloat = -3
    rmax{.global.}: cfloat = 13
    range1{.global.} = [rmin, rmax]
  if frange:
    igSameLine()
    igSetNextItemWidth(200)
    igDragFloat2("##Range", range1, 0.1f, -3, 13)
    rmin = range1[0]
    rmax = range1[1]
    igSameLine()
    igCheckboxFlags("Exclude Outliers", addr hist_flags, NoOutliers.int32)

  #static NormalDistribution<10000> dist(mu, sigma)
  var
    x{.global.}: array[100, double]
    y{.global.}: array[100, double]
  if 0 != (hist_flags and Density.int32):
    for i in 0..<100:
      x[i] = -3 + 16 * i.double / 99.0
      y[i] = exp( - (x[i] - mu) * (x[i] - mu) / (2 * sigma * sigma)) / (sigma * sqrt(2 * 3.141592653589793238))
    if 0 != (hist_flags and Cumulative.int32):
      for i in 1..<100:
        y[i] += y[i-1]
      for i in 0..<100:
        y[i] /= y[99]

  if ipBeginPlot("##Histograms"):
    defer: ipEndPlot()
    ipSetupAxes(nil, nil, AutoFit, AutoFit)
    const IMPLOT_AUTO_COL = ImVec4(x: 0, y: 0, z: 0, w: -1)
    ipSetNextFillStyle(IMPLOT_AUTO_COL, 0.5f)
    #ipSetNextFillStyle(ImVec4(x: 0, y: 0, z: 0, w: -1), 0.5f)
    ipPlotHistogram("Empirical", dist.ptz, 10000.int, bins.int,
                    1.0.cfloat64, (if frange: ImPlotRange(min: rmin, max: rmax) else: ImPlotRange()),
                    hist_flags.ImPlotHistogramFlags)
    if (0 != (hist_flags and Density.int32)) and not (0 != (hist_flags and NoOutliers.int32)):
      if 0 != (hist_flags and ImPlotHistogramFlags.Horizontal.int32):
        ipPlotLine("Theoretical", y.ptz, x.ptz, 100)
      else:
        ipPlotLine("Theoretical", x.ptz, y.ptz, 100)

#-------------------
# demo_SimplePlot()
#-------------------
proc demo_SimplePlot() =
  var
    bar_data{.global.}: seq[cint]
    x_data{.global.}: seq[cint]
    y_data{.global.}: seq[cint]
  once:
    discard initRand()
    bar_data = collect(for i in 0..10: rand(100).cint)
    x_data = collect(for i in 0..10: i.cint)
    y_data = x_data.mapIt((it * it).cint) # y = x^2

  if ipBeginPlot("グラフ表示実験"):
    defer: ipEndPlot()
    ipSetupAxes("平均体重 [kg]", "平均人口 [万人]")
    ipPlotBars("人口", bar_data.ptz, bar_data.len)
    ipPlotLine("構成", x_data.ptz, y_data.ptz, xdata.len)

#--------------
# main
#--------------
main()

