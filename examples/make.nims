import std/[os,strutils]

var projDirs = @[
"glfw_opengl3",
"glfw_opengl3_image_load",
"glfw_opengl3_implot",
"imDrawListParty",
"implot_jp",
"jpFont",
]


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
