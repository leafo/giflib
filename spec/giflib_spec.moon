
import load_gif from require "giflib"

describe "giflib", ->
  it "opens a gif", ->
    gif = load_gif "spec/inputs/regular.gif"

  it "slurps entire gif", ->
    gif = load_gif "spec/inputs/regular.gif"
    gif\slurp!

    w, h = gif\dimensions!
    assert.same 550, w
    assert.same 309, h
    assert.same 68, gif\image_count!

  it "closes a gif after slurp", ->
    gif = load_gif "spec/inputs/regular.gif"
    gif\slurp!
    gif\close!

  it "slurps first frame", ->
    gif = load_gif "spec/inputs/regular.gif"

    assert gif\slurp_first_frame!

    w, h = gif\dimensions!
    assert.same 550, w
    assert.same 309, h
    assert.same 1, gif\image_count!

  it "slurps first frame of interlace gif", ->
    gif = load_gif "spec/inputs/interlace.gif"

    assert gif\slurp_first_frame!

    w, h = gif\dimensions!
    assert.same 512, w
    assert.same 406, h
    assert.same 1, gif\image_count!

  it "fails to open invalid file", ->
    res = { load_gif "spec/giflib_spec.moon" }
    assert.same {
      nil
      "Data is not in GIF format"
    }, res


  it "fails to boken file when slurping", ->
    gif = load_gif "spec/inputs/broke.gif"
    assert.same {
      nil
      "Failed to read from given file"
    }, { gif\slurp! }

    gif\close!

  it "fails to boken file when slurping first frame", ->
    gif = load_gif "spec/inputs/broke.gif"
    assert.same {
      nil
      "failed to read raster bits"
    }, { gif\slurp_first_frame! }

    gif\close! -- ensure we can still close even with partial load

