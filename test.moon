
socket = require "socket"

import open_gif, DecodedGif from require "giflib"

get_memory = ->
  f = io.open "/proc/self/status", "r"
  out = f\read "*a"
  f\close!
  mem = out\match "VmSize:%s+([^\n]+)"
  kb = mem\match "(%d+)"
  ("%.3f mb")\format (tonumber(kb) / 1024)

-- while true
start = socket.gettime!
gif = open_gif "test.gif"
gif\slurp_first_frame!


--gif\write_first_frame "test.out.gif"
--gif\close!
stop = socket.gettime!
print "Elapsed: #{(stop - start) * 1000}, #{get_memory!}"

