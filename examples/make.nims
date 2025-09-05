import std/[os,strutils]

var projDirs = @[
"glfw_opengl3",
"glfw_opengl3_image_load",
"imDrawListParty",
"jpFont",
"implot_jp",
]

if hostOS == "windows":
  projDirs.add "sdl2_opengl3"

projDirs.add "fontx2v"

#-------------
# compileProj
#-------------
proc compileProj(cmd:string) =
  var options = ""
  #options =  join([options,"--no-print-directory"]," ")

  for dir in projDirs:
    if dir.dirExists:
      withDir(dir):
        if false:
          try:
            exec("make $# $#" % [options,cmd])
          except OSError:
            discard
        else:
          exec("make $# $#" % [options,cmd])


#------
# main
#------
var cmd:string
if commandLineParams().len >= 2:
  cmd = commandLineParams()[1]
compileProj(cmd)
