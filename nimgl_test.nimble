# Package

version       = "0.1.0"
author        = "dinau"
description   = "nimgl test program with file open dialog"
license       = "MIT"
srcDir        = "src"
bin           = @["nimgl_test"]

# Dependencies

requires "nimgl >= 1.0.0"
requires "https://github.com/dinau/nim-osdialog >= 0.1.4"  # req: nim-1.6.6 or later

let TARGET = "nimgl_test"

import std/[strutils]

# See "version.nims" included in "config.nims".
const releaseDate = "2023/02"
var seqOpts = @[""]
seqOpts.add  "-d:VERSION:$# -d:REL_DATE:$#" % [version,releaseDate]

backend = "cpp"

task make,"make":
    let cmd = "nim $# -d:strip -o:$# $# $#.nim" % [backend,TARGET.toEXE,seqOpts.join(" "),"src/" & TARGET]
    echo "make: ",cmd
    exec(cmd)

task clean,"clean":
    exec("rm -fr .nimcache")
    rmFile TARGET.toEXE()


