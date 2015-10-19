
ffi = require "ffi"
lib = require "giflib.lib"

free_dgif = (gif) ->
  print "Freeing dgif"
  err = ffi.new "int[1]", 0
  lib.DGifCloseFile gif, err

assert_error = (status) ->
  return true if status == 0
  error ffi.string lib.GifErrorString status

class DecodedGif
  new: (gif) =>
    @gif = ffi.gc gif, free_dgif

  slurp: =>
    @slurped = true
    lib.DGifSlurp @gif

  close: =>
    ffi.gc @gif, nil
    free_dgif gif

  dimensions: =>
    {:Width, :Height} = gif.SavedImages[0].ImageDesc
    Width, Height

  -- write the first frame of image to file
  write_first_frame: (fname) =>
    return nil, "no images in gif" unless @gif.ImageCount > 0

    err = ffi.new "int[1]", 0
    dest = lib.EGifOpenFileName fname, false, err
    assert_error err[0]
    dest = ffi.gc dest, lib.EGifCloseFile

    for f in *{"SWidth", "SHeight", "SColorResolution", "SBackGroundColor"}
      dest[f] = @gif[f]

    dest.SColorMap = lib.GifMakeMapObject @gif.SColorMap.ColorCount, @gif.SColorMap.Colors

    lib.GifMakeSavedImage dest, @gif.SavedImages[0]

    if 1 == lib.EGifSpew dest
      -- spew closes file and cleans memory
      ffi.gc dest, nil
      true
    else
      nil, "failed to spew gif"


open_gif = (fname) ->
  err = ffi.new "int[1]", 0
  gif = lib.DGifOpenFileName fname, err
  assert_error err[0]
  gif = DecodedGif gif
  gif\slurp!
  gif


{:open_gif}
