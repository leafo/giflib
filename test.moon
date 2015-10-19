
socket = require "socket"
import open_gif, write_gif from require "giflib"

for i=1,1000
  start = socket.gettime!
  gif = open_gif "test.gif"
  gif\write_first_frame "test.out.gif"
  stop = socket.gettime!
  print "Elapsed: #{(stop - start) * 1000}"

