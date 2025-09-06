<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Nimgl / ImGui demo program](#nimgl--imgui-demo-program)
  - [Prerequisite](#prerequisite)
  - [Install dependencies](#install-dependencies)
  - [Examples](#examples)
    - [glfw_opengl3.nim](#glfw_opengl3nim)
    - [glfw_opengl3_image_load.nim](#glfw_opengl3_image_loadnim)
    - [glfw_opengl3_implot.nim](#glfw_opengl3_implotnim)
    - [imDrawListParty.nim](#imdrawlistpartynim)
    - [implot_jp.nim](#implot_jpnim)
    - [jpFont.nim](#jpfontnim)
  - [IME for Japanese / 日本語入力(IME)について](#ime-for-japanese--%E6%97%A5%E6%9C%AC%E8%AA%9E%E5%85%A5%E5%8A%9Bime%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)
  - [Referrence](#referrence)
  - [My tools version](#my-tools-version)
  - [Other ImGui / CImGui project](#other-imgui--cimgui-project)
  - [SDL game tutorial Platfromer](#sdl-game-tutorial-platfromer)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Nimgl / ImGui demo program

![alt](https://github.com/dinau/nimgl_test/actions/workflows/windows.yml/badge.svg) 
![alt](https://github.com/dinau/nimgl_test/actions/workflows/linux.yml/badge.svg)

**Note**: Using  **ImGui v1.89.9** (2023/09) [https://github.com/dinau/nimgl-imgui](https://github.com/dinau/nimgl-imgui)  
forked from https://github.com/daniel-j/nimgl-imgui .

#### Prerequisite

---

- nim-2.2.4 or later
- OS: Windows10 or later
- Download 

   ```sh
   $ git clone https://github.com/dinau/nimgl_test
   $ cd nimgl_test
   ```

- For Linux Debian13 or later

   ```sh
   $ sudo apt install libopengl-dev  libgl1-mesa-dev libglfw3-dev
   $ sudo apt install libxcursor-dev libx11-dev libxext-dev libxinerama-dev libxi-dev
   ```
#### Install dependencies

---

   ```sh
   $ pwd
   nimgl_test
   $ nimble build
   ```

#### Examples

---

#####  [glfw_opengl3.nim](examples/glfw_opengl3/glfw_opengl3.nim)

---

   ```sh
   $ pwd 
   nimgl_test
   $ cd examples/glfw_opengl3
   $ make run
   ```

![alt](img/glfw_opengl3.png)


#####  [glfw_opengl3_image_load.nim](examples/glfw_opengl3_image_load/glfw_opengl3_image_load.nim)

---

   ```sh
   $ pwd 
   nimgl_test
   $ cd examples/glfw_opengl3_image_load
   $ make run
   ```

![alt](img/glfw_opengl3_image_load.png)

#####  [glfw_opengl3_implot.nim](examples/glfw_opengl3_implot/glfw_opengl3_implot.nim)

---

   ```sh
   $ pwd 
   nimgl_test
   $ cd examples/glfw_opengl3_implot
   $ make run
   ```

![alt](img/glfw_opengl3_implot.png)

##### [imDrawListParty.nim](examples/imDrawListParty/imDrawListParty.nim)

---

```sh
$ pwd 
nimgl_test
cd examples/imDrawListParty
$ make run
```

[ImDrawList coding party - deadline Nov 30, 2020! #3606](https://github.com/ocornut/imgui/issues/3606)  
This demo has been converted to Nim lang from two programs,  
[Curve](https://github.com/ocornut/imgui/issues/3606#issuecomment-730648517)  
![alt](https://user-images.githubusercontent.com/8225057/99726102-5b5a6f80-2ab6-11eb-8785-8a7de588dd6e.gif)  
and [Real-time visualization of the interweb blogosphere](https://github.com/ocornut/imgui/issues/3606#issuecomment-730704909).  

![alt](https://user-images.githubusercontent.com/35172202/99803095-e2a4f300-2b49-11eb-8979-0bd475c1cfee.gif)
![alt](img/nimgl-imgui-coding-party-2023-08.png)  


##### [implot_jp.nim](examples/implot_jp/implot_jp.nim)

---

ImPlot demo with Japanese fonts

   ```sh
   $ pwd 
   nimgl_test
   $ cd examples/implot_jp
   $ make run
   ```

   ![alt](img/nimgl-implot-demo-jp-font-2023-10.png)  

##### [jpFont.nim](examples/jpFont/jpFont.nim)

---

```sh
$ pwd 
nimgl_test
$ cd examples/jpfont
$ make run
```

![alt](img/nimgl-screen-shot-jp-font-2023-07.png)

- Download: Windows10 sample exe file  
[nimgl-test-jp-font-imgui-v1.84.2-ime-ok-2023-07.exe.7z](https://bitbucket.org/dinau/storage/downloads/nimgl-test-jp-font-imgui-v1.84.2-ime-ok-2023-07.exe.7z) 

#### IME for Japanese / 日本語入力(IME)について

---

以下のNim言語コンパイル / リンク時オプションを加えることで日本語入力を可能としている  
オプションはバックエンドのC/C++コンパイラにのみ渡される

```sh
--passc:"-DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS"
--passL:"-limm32"
```

同じことをconfig.nims内に記述する場合は以下となる

```nim
switch "passC","-DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS"
switch "passL","-limm32"
```

#### Referrence

---

[Dear ImGuiで日本語入力時のIMEの位置をいい感じにする](https://qiita.com/babiron_i/items/759d80965b497384bc0e)  
[Viewport, Platform: Fixed IME positioning for multi-viewport. Moved API from...](http://dalab.se.sjtu.edu.cn/gitlab/xiaoyuwei/imgui/-/commit/cb78e62df93732b64afcc9d4cd02e378730b32af)  
[ImGui で日本語と記号♥と絵文字😺の表示](https://zenn.dev/tenka/articles/display_japanese_symbols_and_emoji_with_imgui)  

#### My tools version

---

- Windows
   - Nim Compiler Version 2.2.4 
   - gcc.exe 15.2.0
   - git version 2.46.0.windows.1
   - make: GNU Make 4.4.1


#### Other ImGui / CImGui project

---


| Language             |          | Project                                                                                                                                         |
| -------------------: | :---:    | :----------------------------------------------------------------:                                                                              |
| **Lua**              | Script   | [LuaJITImGui](https://github.com/dinau/luajitImGui)                                                                                             |
| **NeLua**            | Compiler | [NeLuaImGui](https://github.com/dinau/neluaImGui), [NeLuaImGui2](https://github.com/dinau/neluaImGui2)                                          |
| **Nim**              | Compiler | [ImGuin](https://github.com/dinau/imguin), [Nimgl_test](https://github.com/dinau/nimgl_test), [Nim_implot](https://github.com/dinau/nim_implot) |
| **Python**           | Script   | [DearPyGui for 32bit WindowsOS Binary](https://github.com/dinau/DearPyGui32/tree/win32)                                                         |
| **Ruby**             | Script   | [igRuby_Examples](https://github.com/dinau/igruby_examples)                                                                                     |
| **Zig**, C lang.     | Compiler | [Dear_Bindings_Build](https://github.com/dinau/dear_bindings_build)                                                                             |
| **Zig**              | Compiler | [ImGuinZ](https://github.com/dinau/imguinz)                                                                                                     |


#### SDL game tutorial Platfromer

---

![ald](https://github.com/dinau/nelua-platformer/raw/main/img/platformer-nelua-sdl2.gif)


| Language             |          | SDL         | Project                                                                                                                                               |
| -------------------: | :---:    | :---:       | :----------------------------------------------------------------:                                                                                    |
| **LuaJIT**           | Script   | SDL2        | [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer)
| **Nelua**            | Compiler | SDL2        | [NeLua-Platformer](https://github.com/dinau/nelua-platformer)
| **Nim**              | Compiler | SDL3 / SDL2 | [Nim-Platformer-sdl2](https://github.com/def-/nim-platformer)/ [Nim-Platformer-sdl3](https://github.com/dinau/sdl3_nim/tree/main/examples/platformer) |
| **Ruby**             | Script   | SDL3        | [Ruby-Platformer](https://github.com/dinau/ruby-platformer)                                                                                           |
| **Zig**              | Compiler | SDL3 / SDL2 | [Zig-Platformer](https://github.com/dinau/zig-platformer)                                                                                             |
