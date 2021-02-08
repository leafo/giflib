local VERSION = "1.0.0"
local ffi = require("ffi")
local lib = require("giflib.lib")
local GIF_ERROR = 0
local GIF_OK = 1
local CONTINUE_EXT_FUNC_CODE = 0x00
local INT_MAX = 2147483647
local get_error
get_error = function(status)
  if status == 0 then
    return "There was an error"
  else
    return ffi.string(lib.GifErrorString(status))
  end
end
local raise_error
raise_error = function(status)
  return error(get_error(status))
end
local close_dgif
close_dgif = function(gif)
  local err = ffi.new("int[1]", 0)
  if lib.DGifCloseFile(gif, err) == GIF_ERROR then
    return raise_error(err[0])
  else
    return true
  end
end
local close_egif
close_egif = function(gif)
  local err = ffi.new("int[1]", 0)
  if lib.EGifCloseFile(gif, err) == GIF_ERROR then
    return raise_error(err[0])
  else
    return true
  end
end
local DecodedGif
do
  local _class_0
  local _base_0 = {
    slurp = function(self)
      self.slurped = true
      if GIF_ERROR == lib.DGifSlurp(self.gif) then
        return nil, get_error(self.gif.Error)
      end
      return true
    end,
    slurp_first_frame = function(self)
      self.slurped = true
      self.gif.ExtensionBlocks = nil
      self.gif.ExtensionBlockCount = 0
      local record_type = ffi.new("GifRecordType[1]")
      local ext_function = ffi.new("int[1]")
      local ext_data = ffi.new("GifByteType*[1]")
      while true do
        if GIF_ERROR == lib.DGifGetRecordType(self.gif, record_type) then
          return nil, "failed to get record type"
        end
        local _exp_0 = record_type[0]
        if lib.IMAGE_DESC_RECORD_TYPE == _exp_0 then
          if GIF_ERROR == lib.DGifGetImageDesc(self.gif) then
            return nil, "failed to get image desc"
          end
          local saved_image = self.gif.SavedImages + (self.gif.ImageCount - 1)
          if saved_image.ImageDesc.Width < 0 or saved_image.ImageDesc.Height < 0 then
            return nil, "image has negative dimensions"
          end
          if saved_image.ImageDesc.Width > INT_MAX / saved_image.ImageDesc.Height then
            return nil, "image dimensions too large"
          end
          local image_size = saved_image.ImageDesc.Width * saved_image.ImageDesc.Height
          saved_image.RasterBits = ffi.C.malloc(image_size * ffi.sizeof("GifPixelType"))
          if saved_image.RasterBits == nil then
            return nil, "failed to alloc memory"
          end
          if saved_image.ImageDesc.Interlace then
            local interlaced_offset = {
              0,
              4,
              2,
              1
            }
            local interlaced_jumps = {
              8,
              8,
              4,
              2
            }
            for i = 1, 4 do
              for j = interlaced_offset[i], saved_image.ImageDesc.Height - 1, interlaced_jumps[i] do
                if GIF_ERROR == lib.DGifGetLine(self.gif, saved_image.RasterBits + j * saved_image.ImageDesc.Width, saved_image.ImageDesc.Width) then
                  return nil, "failed reading interlaced image"
                end
              end
            end
          else
            if GIF_ERROR == lib.DGifGetLine(self.gif, saved_image.RasterBits, image_size) then
              return nil, "failed to read raster bits"
            end
          end
          if self.gif.ExtensionBlocks ~= nil then
            saved_image.ExtensionBlocks = self.gif.ExtensionBlocks
            saved_image.ExtensionBlockCount = self.gif.ExtensionBlockCount
            self.gif.ExtensionBlocks = nil
            self.gif.ExtensionBlockCount = 0
          end
          return true
        elseif lib.EXTENSION_RECORD_TYPE == _exp_0 then
          if GIF_ERROR == lib.DGifGetExtension(self.gif, ext_function, ext_data) then
            return nil, "failed to get extension"
          end
          local extension_block_count = ffi.new("int[1]", self.gif.ExtensionBlockCount)
          local extension_blocks = ffi.new("ExtensionBlock*[1]", self.gif.ExtensionBlocks)
          if ext_data[0] ~= nil then
            local res = lib.GifAddExtensionBlock(extension_block_count, extension_blocks, ext_function[0], ext_data[0][0], ext_data[0] + 1)
            self.gif.ExtensionBlockCount = extension_block_count[0]
            self.gif.ExtensionBlocks = extension_blocks[0]
            if res == GIF_ERROR then
              return nil, "failed to get extension block"
            end
          end
          while ext_data[0] ~= nil do
            if GIF_ERROR == lib.DGifGetExtensionNext(self.gif, ext_data) then
              return nil, "failed to get next extension"
            end
            if ext_data[0] ~= nil then
              local res = lib.GifAddExtensionBlock(extension_block_count, extension_blocks, CONTINUE_EXT_FUNC_CODE, ext_data[0][0], ext_data[0] + 1)
              self.gif.ExtensionBlockCount = extension_block_count[0]
              self.gif.ExtensionBlocks = extension_blocks[0]
              if res == GIF_ERROR then
                return nil, "failed to get extension block continue"
              end
            end
          end
        elseif lib.TERMINATE_RECORD_TYPE == _exp_0 then
          break
        end
      end
      return true
    end,
    close = function(self)
      ffi.gc(self.gif, nil)
      return close_dgif(self.gif)
    end,
    image_count = function(self)
      return self.gif.ImageCount
    end,
    dimensions = function(self)
      local Width, Height
      do
        local _obj_0 = self.gif.SavedImages[0].ImageDesc
        Width, Height = _obj_0.Width, _obj_0.Height
      end
      return Width, Height
    end,
    write_first_frame = function(self, fname)
      if not (self.slurped) then
        self:slurp_first_frame()
      end
      if not (self.gif.ImageCount > 0) then
        return nil, "no images in gif"
      end
      local err = ffi.new("int[1]", 0)
      local dest = lib.EGifOpenFileName(fname, false, err)
      if dest == nil then
        return nil, get_error(err[0])
      end
      dest = ffi.gc(dest, close_egif)
      local _list_0 = {
        "SWidth",
        "SHeight",
        "SColorResolution",
        "SBackGroundColor"
      }
      for _index_0 = 1, #_list_0 do
        local f = _list_0[_index_0]
        dest[f] = self.gif[f]
      end
      if not (self.gif.SColorMap == nil) then
        dest.SColorMap = lib.GifMakeMapObject(self.gif.SColorMap.ColorCount, self.gif.SColorMap.Colors)
      end
      local copy_images = 1
      local saved_images = ffi.new("SavedImage[?]", copy_images)
      for i = 0, copy_images - 1, 1 do
        saved_images[i] = self.gif.SavedImages[i]
      end
      dest.SavedImages = saved_images
      dest.ImageCount = copy_images
      if lib.EGifSpew(dest) == GIF_OK then
        ffi.gc(dest, nil)
        return true
      else
        return nil, "failed to spew gif"
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, gif)
      self.gif = ffi.gc(gif, close_dgif)
    end,
    __base = _base_0,
    __name = "DecodedGif"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  DecodedGif = _class_0
end
local load_gif
load_gif = function(fname)
  local err = ffi.new("int[1]", 0)
  local gif = lib.DGifOpenFileName(fname, err)
  if gif == nil then
    return nil, get_error(err[0])
  end
  gif = DecodedGif(gif)
  return gif
end
return {
  load_gif = load_gif,
  DecodedGif = DecodedGif,
  VERSION = VERSION
}
