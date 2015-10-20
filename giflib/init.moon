
ffi = require "ffi"
lib = require "giflib.lib"

GIF_ERROR = 0
GIF_OK = 1

raise_error = (status) ->
  if status == 0
    error "There was an error"
  else
    error ffi.string lib.GifErrorString status

assert_error = (status) ->
  return true if status == 0
  raise_error status

close_dgif = (gif) ->
  err = ffi.new "int[1]", 0
  if lib.DGifCloseFile(gif, err) == GIF_ERROR
    raise_error err[0]
  else
    true

close_egif = (gif) ->
  print "closing egif..."
  err = ffi.new "int[1]", 0
  if lib.EGifCloseFile(gif, err) == GIF_ERROR
    raise_error err[0]
  else
    true

class DecodedGif
  new: (gif) =>
    @gif = ffi.gc gif, close_dgif

  slurp: =>
    @slurped = true
    lib.DGifSlurp @gif

  close: =>
    ffi.gc @gif, nil
    close_dgif @gif

  dimensions: =>
    {:Width, :Height} = @gif.SavedImages[0].ImageDesc
    Width, Height

  -- write the first frame of image to file
  write_first_frame: (fname) =>
    return nil, "no images in gif" unless @gif.ImageCount > 0

    err = ffi.new "int[1]", 0
    dest = lib.EGifOpenFileName fname, false, err
    assert_error err[0]
    dest = ffi.gc dest, close_egif

    for f in *{"SWidth", "SHeight", "SColorResolution", "SBackGroundColor"}
      dest[f] = @gif[f]

    dest.SColorMap = lib.GifMakeMapObject @gif.SColorMap.ColorCount, @gif.SColorMap.Colors

    saved_images = ffi.new "SavedImage[1]"
    saved_images[0] = @gif.SavedImages[0]

    dest.SavedImages = saved_images
    dest.ImageCount = 1

    if lib.EGifSpew(dest) == GIF_OK
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


{ :open_gif, :DecodedGif }
