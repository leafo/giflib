
socket = require "socket"

import load_gif, DecodedGif from require "giflib"

get_memory = ->
  f = io.open "/proc/self/status", "r"
  out = f\read "*a"
  f\close!
  mem = out\match "VmSize:%s+([^\n]+)"
  kb = mem\match "(%d+)"
  ("%.3f mb")\format (tonumber(kb) / 1024)


get_memory = ->
  f = io.open "/proc/self/statm", "r"
  out = f\read "*a"
  f\close!
  out

-- while true
start = socket.gettime!
gif = load_gif "interlace.gif"
assert gif\slurp_first_frame!
-- gif\slurp!

gif\write_first_frame "test.out.gif"
gif\close!

stop = socket.gettime!
print "Elapsed: #{(stop - start) * 1000}, #{get_memory!}"

