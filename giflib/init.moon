
ffi = require "ffi"
lib = require "giflib.lib"

GIF_ERROR = 0
GIF_OK = 1
CONTINUE_EXT_FUNC_CODE = 0x00
INT_MAX = 2147483647

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




-- 	int
-- DGifSlurp(GifFileType *GifFile)
-- {
-- 	size_t ImageSize;
-- 	GifRecordType RecordType;
-- 	SavedImage *sp;
-- 	GifByteType *ExtData;
-- 	int ExtFunction;
--
-- 	GifFile->ExtensionBlocks = NULL;
-- 	GifFile->ExtensionBlockCount = 0;
--
-- 	do {
-- 		if (DGifGetRecordType(GifFile, &RecordType) == GIF_ERROR)
-- 			return (GIF_ERROR);
--
-- 		switch (RecordType) {
-- 			case IMAGE_DESC_RECORD_TYPE:
-- 				if (DGifGetImageDesc(GifFile) == GIF_ERROR)
-- 					return (GIF_ERROR);
--
-- 				sp = &GifFile->SavedImages[GifFile->ImageCount - 1];
-- 				/* Allocate memory for the image */
-- 				if (sp->ImageDesc.Width < 0 && sp->ImageDesc.Height < 0 &&
-- 						sp->ImageDesc.Width > (INT_MAX / sp->ImageDesc.Height)) {
-- 					return GIF_ERROR;
-- 				}
-- 				ImageSize = sp->ImageDesc.Width * sp->ImageDesc.Height;
--
-- 				if (ImageSize > (SIZE_MAX / sizeof(GifPixelType))) {
-- 					return GIF_ERROR;
-- 				}
-- 				sp->RasterBits = (unsigned char *)malloc(ImageSize *
-- 						sizeof(GifPixelType));
--
-- 				if (sp->RasterBits == NULL) {
-- 					return GIF_ERROR;
-- 				}
--
-- 				if (sp->ImageDesc.Interlace) {
-- 					int i, j;
-- 					/*
-- 					 * The way an interlaced image should be read -
-- 					 * offsets and jumps...
-- 					 */
-- 					int InterlacedOffset[] = { 0, 4, 2, 1 };
-- 					int InterlacedJumps[] = { 8, 8, 4, 2 };
-- 					/* Need to perform 4 passes on the image */
-- 					for (i = 0; i < 4; i++)
-- 						for (j = InterlacedOffset[i];
-- 								j < sp->ImageDesc.Height;
-- 								j += InterlacedJumps[i]) {
-- 							if (DGifGetLine(GifFile,
-- 										sp->RasterBits+j*sp->ImageDesc.Width,
-- 										sp->ImageDesc.Width) == GIF_ERROR)
-- 								return GIF_ERROR;
-- 						}
-- 				}
-- 				else {
-- 					if (DGifGetLine(GifFile,sp->RasterBits,ImageSize)==GIF_ERROR)
-- 						return (GIF_ERROR);
-- 				}
--
-- 				if (GifFile->ExtensionBlocks) {
-- 					sp->ExtensionBlocks = GifFile->ExtensionBlocks;
-- 					sp->ExtensionBlockCount = GifFile->ExtensionBlockCount;
--
-- 					GifFile->ExtensionBlocks = NULL;
-- 					GifFile->ExtensionBlockCount = 0;
-- 				}
-- 				break;
--
-- 			case EXTENSION_RECORD_TYPE:
-- 				if (DGifGetExtension(GifFile,&ExtFunction,&ExtData) == GIF_ERROR)
-- 					return (GIF_ERROR);
-- 				/* Create an extension block with our data */
-- 				if (ExtData != NULL) {
-- 					if (GifAddExtensionBlock(&GifFile->ExtensionBlockCount,
-- 								&GifFile->ExtensionBlocks,
-- 								ExtFunction, ExtData[0], &ExtData[1])
-- 							== GIF_ERROR)
-- 						return (GIF_ERROR);
-- 				}
-- 				while (ExtData != NULL) {
-- 					if (DGifGetExtensionNext(GifFile, &ExtData) == GIF_ERROR)
-- 						return (GIF_ERROR);
-- 					/* Continue the extension block */
-- 					if (ExtData != NULL)
-- 						if (GifAddExtensionBlock(&GifFile->ExtensionBlockCount,
-- 									&GifFile->ExtensionBlocks,
-- 									CONTINUE_EXT_FUNC_CODE,
-- 									ExtData[0], &ExtData[1]) == GIF_ERROR)
-- 							return (GIF_ERROR);
-- 				}
-- 				break;
--
-- 			case TERMINATE_RECORD_TYPE:
-- 				break;
--
-- 			default:    /* Should be trapped by DGifGetRecordType */
-- 				break;
-- 		}
-- 	} while (RecordType != TERMINATE_RECORD_TYPE);
--
-- 					return (GIF_OK);




class DecodedGif
  new: (gif) =>
    @gif = ffi.gc gif, close_dgif

  slurp: =>
    @slurped = true
    lib.DGifSlurp @gif

  -- only read enought to get first frame
  slurp_first_frame: =>
    @gif.ExtensionBlocks = nil
    @gif.ExtensionBlockCount = 0

    record_type = ffi.new "GifRecordType[1]"
    ext_function = ffi.new "int[1]"
    ext_data = ffi.new "GifByteType*[1]"

    while true
      if GIF_ERROR == lib.DGifGetRecordType @gif, record_type
        return nil, "failed to get record type"

      switch record_type[0]
        when lib.IMAGE_DESC_RECORD_TYPE
          print "Got image desc record type..."

          if GIF_ERROR == lib.DGifGetImageDesc @gif
            return nil, "failed to get image desc"

          -- pointer to new saved image
          saved_image = @gif.SavedImages + (@gif.ImageCount - 1)

          if saved_image.ImageDesc.Width < 0 or saved_image.ImageDesc.Height < 0
            return nil, "image has negative dimensions"

          if saved_image.ImageDesc.Width > INT_MAX / saved_image.ImageDesc.Height
            return nil, "image dimensions too large"

          image_size = saved_image.ImageDesc.Width * saved_image.ImageDesc.Height
          saved_image.RasterBits = ffi.C.malloc image_size * ffi.sizeof "GifPixelType"

          if saved_image.RasterBits == nil
            return nil, "failed to alloc memory"

          if saved_image.ImageDesc.Interlace
            error "TODO: handle intelace gif"
          else
            if GIF_ERROR == lib.DGifGetLine @gif, saved_image.RasterBits, image_size
              return nil, "failed to read raster bits"

            if @gif.ExtensionBlocks != nil
              saved_image.ExtensionBlocks = @gif.ExtensionBlocks
              saved_image.ExtensionBlockCount = @gif.ExtensionBlockCount

              @gif.ExtensionBlocks = nil
              @gif.ExtensionBlockCount = 0

          return true -- got first frame

        when lib.EXTENSION_RECORD_TYPE
          if GIF_ERROR == lib.DGifGetExtension @gif, ext_function, ext_data
            return nil, "failed to get extension"

          if ext_data[0] != nil
            -- we can't get access to address of struct fields so we create 1 item arrays, and copy into struct later
            extension_block_count = ffi.new "int[1]", @gif.ExtensionBlockCount
            extension_blocks = ffi.new "ExtensionBlock*[1]", @gif.ExtensionBlocks

            res = lib.GifAddExtensionBlock extension_block_count, extension_blocks,
              ext_function[1], ext_data[0][0], ext_data[0] + 1

            @gif.ExtensionBlockCount = extension_block_count[0]
            @gif.ExtensionBlocks = extension_blocks[0]

            if res == GIF_ERROR
              return nil, "failed to get extension block"

            while ext_data[0] != nil
              if GIF_ERROR == lib.DGifGetExtensionNext @gif, ext_data
                return nil, "failed to get next extension"

              if ext_data[0] != nil
                res = lib.GifAddExtensionBlock extension_block_count, extension_blocks,
                  CONTINUE_EXT_FUNC_CODE, ext_data[0][0], ext_data[0] + 1

                @gif.ExtensionBlockCount = extension_block_count[0]
                @gif.ExtensionBlocks = extension_blocks[0]

                if res == GIF_ERROR
                  return nil, "failed to get extension block continue"

                nil

          print "got extension record type"

        when lib.TERMINATE_RECORD_TYPE
          nil


  close: =>
    ffi.gc @gif, nil
    close_dgif @gif

  dimensions: =>
    {:Width, :Height} = @gif.SavedImages[0].ImageDesc
    Width, Height

  -- write the first frame of image to file
  write_first_frame: (fname) =>
    @slurp! unless @slurped

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
  gif


{ :open_gif, :DecodedGif }
