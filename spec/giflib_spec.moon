
import open_gif from require "giflib"

describe "giflib", ->
  it "opens a gif", ->
    gif = open_gif "spec/inputs/regular.gif"

  it "slurps entire gif", ->
    gif = open_gif "spec/inputs/regular.gif"
    gif\slurp!

    w, h = gif\dimensions!
    assert.same 550, w
    assert.same 309, h
    assert.same 68, gif\image_count!

  it "closes a gif after slurp", ->
    gif = open_gif "spec/inputs/regular.gif"
    gif\slurp!
    gif\close!

  it "slurps first frame", ->
    gif = open_gif "spec/inputs/regular.gif"

    assert gif\slurp_first_frame!

    w, h = gif\dimensions!
    assert.same 550, w
    assert.same 309, h
    assert.same 1, gif\image_count!

  it "slurps first frame of interlace gif", ->
    gif = open_gif "spec/inputs/interlace.gif"

    assert gif\slurp_first_frame!

    w, h = gif\dimensions!
    assert.same 512, w
    assert.same 406, h
    assert.same 1, gif\image_count!

