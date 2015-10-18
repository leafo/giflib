
import open_gif, write_gif from require "giflib"

gif = open_gif "test.gif"
write_gif gif, "test.out.gif"

