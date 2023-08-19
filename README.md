<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Nimgl test program for japanese fonts](#nimgl-test-program-for-japanese-fonts)
  - [Prerequisite](#prerequisite)
  - [Compile and run](#compile-and-run)
  - [Download: Windows10 sample exe file](#download-windows10-sample-exe-file)
  - [フォント追加方法](#%E3%83%95%E3%82%A9%E3%83%B3%E3%83%88%E8%BF%BD%E5%8A%A0%E6%96%B9%E6%B3%95)
  - [日本語入力(IME)について](#%E6%97%A5%E6%9C%AC%E8%AA%9E%E5%85%A5%E5%8A%9Bime%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)
  - [参考](#%E5%8F%82%E8%80%83)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Nimgl test program for japanese fonts

Nimgl: ImGui demo program test for Japanese fonts  
Written by audin 2023/02

Nim言語

ImGui/Nimglで日本語表示・入力のテスト

詳細は[ここ](https://mpu.seesaa.net/article/498328270.html)を参照

#### Prerequisite

---
- nim-1.6.14 at this moment
- For Linux Debian 11 Bullseye

   ```sh
   $ sudo apt install xorg-dev libopengl-dev ibgl1-mesa-glx libgl1-mesa-dev
   ```

#### Compile and run

---

適当な作業フォルダで

```sh
$ git clone https://github.com/dinau/nimgl_test
$ cd nimgl_test
```

```sh
$ make
```

or

```sh
$ nimble build 
```

実行は、

```sh
$ ./nimgl_test
```

以下は実行結果  
- 2023/07
テーマ3色とフォント4種(Windows10)を選択できるようにした  
   ![alt](img/nimgl-screen-shot-jp-font-2023-07.png)

#### Download: Windows10 sample exe file

---

[nimgl-test-jp-font-imgui-v1.84.2-ime-ok-2023-07.exe.7z](https://bitbucket.org/dinau/storage/downloads/nimgl-test-jp-font-imgui-v1.84.2-ime-ok-2023-07.exe.7z) 


#### フォント追加方法

---

ソース [setupFonts.nim](https://github.com/dinau/nimgl_test/blob/main/src/setupFonts.nim)

- Nim

  プロトタイプ宣言

   ```nim
   proc addFontFromFileTTF*(self: ptr ImFontAtlas
       , filename: cstring
       , size_pixels: float32
       , font_cfg: ptr ImFontConfig = nil
       , glyph_ranges: ptr ImWchar = nil): ptr ImFont
       {.importc: "ImFontAtlas_AddFontFromFileTTF".}
   ```

- C++

  ```cpp
  io.Fonts->AddFontDefault();
  io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\segoeui.ttf", 18.0f);
  ```

#### 日本語入力(IME)について

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

#### 参考

---

[Dear ImGuiで日本語入力時のIMEの位置をいい感じにする](https://qiita.com/babiron_i/items/759d80965b497384bc0e)  
[Viewport, Platform: Fixed IME positioning for multi-viewport. Moved API from...](http://dalab.se.sjtu.edu.cn/gitlab/xiaoyuwei/imgui/-/commit/cb78e62df93732b64afcc9d4cd02e378730b32af)  
[ImGui で日本語と記号♥と絵文字😺の表示](https://zenn.dev/tenka/articles/display_japanese_symbols_and_emoji_with_imgui)  

