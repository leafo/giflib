
ffi = require "ffi"
lib = require "giflib.lib"

assert_error = (status) ->
  return true if status == 0
  error ffi.string lib.GifErrorString status

open_gif = (fname) ->
  err = ffi.new("int[1]", 0)
  -- TODO: ffi.gc
  with gif = lib.DGifOpenFileName fname, err
    assert_error err[0]
    lib.DGifSlurp gif


dimensions = (gif) ->
  {:Left, :Top, :Width, :Height} = gif.SavedImages[0].ImageDesc
  Left, Top, Width, Height

-- writes only the first frame
write_gif = (gif, fname) ->
  err = ffi.new("int[1]", 0)
  -- TODO: ffi.gc
  dest = lib.EGifOpenFileName "test.out.gif", false, err
  assert_error err[0]

  for f in *{"SWidth", "SHeight", "SColorResolution", "SBackGroundColor"}
    dest[f] = gif[f]

  dest.SColorMap = lib.GifMakeMapObject gif.SColorMap.ColorCount, gif.SColorMap.Colors

  lib.GifMakeSavedImage dest, gif.SavedImages[0]
  lib.EGifSpew dest

{:open_gif, :write_gif}
