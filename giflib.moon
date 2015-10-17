
ffi = require "ffi"

ffi.cdef [[
  typedef void ColorMapObject;
  typedef void ExtensionBlock;

  typedef unsigned char GifPixelType;
  typedef unsigned char *GifRowType;
  typedef unsigned char GifByteType;
  typedef unsigned int GifPrefixType;
  typedef int GifWord;

  typedef struct GifImageDesc {
      GifWord Left, Top, Width, Height;   /* Current image dimensions. */
      bool Interlace;                     /* Sequential/Interlaced lines. */
      ColorMapObject *ColorMap;           /* The local color map */
  } GifImageDesc;

  typedef struct SavedImage {
    GifImageDesc ImageDesc;
    GifByteType *RasterBits;         /* on malloc(3) heap */
    int ExtensionBlockCount;         /* Count of extensions before image */    
    ExtensionBlock *ExtensionBlocks; /* Extensions before image */    
  } SavedImage;

  typedef struct GifFileType {
    GifWord SWidth, SHeight;         /* Size of virtual canvas */
    GifWord SColorResolution;        /* How many colors can we generate? */
    GifWord SBackGroundColor;        /* Background color for virtual canvas */
    GifByteType AspectByte;	     /* Used to compute pixel aspect ratio */
    ColorMapObject *SColorMap;       /* Global colormap, NULL if nonexistent. */
    int ImageCount;                  /* Number of current image (both APIs) */
    GifImageDesc Image;              /* Current image (low-level API) */
    SavedImage *SavedImages;         /* Image sequence (high-level API) */
    int ExtensionBlockCount;         /* Count extensions past last image */
    ExtensionBlock *ExtensionBlocks; /* Extensions past last image */    
    int Error;			     /* Last error condition reported */
    void *UserData;                  /* hook to attach user data (TVT) */
    void *Private;                   /* Don't mess with this! */
  } GifFileType;


  const char *GifErrorString(int ErrorCode);
  GifFileType *DGifOpenFileName(const char *GifFileName, int *Error);
  int DGifCloseFile(GifFileType * GifFile, int *ErrorCode);

  int DGifSlurp(GifFileType * GifFile);
]]

lib = ffi.load "libgif"

assert_error = (status) ->
  return true if status == 0
  error ffi.string lib.GifErrorString status

err = ffi.new("int[1]", 0)
gif = lib.DGifOpenFileName "tiny.gif", err
assert_error err[0]

lib.DGifSlurp gif

{:Left, :Top, :Width, :Height} = gif.SavedImages[0].ImageDesc
print "left: #{Left}, top: #{Top}, width: #{Width}, height: #{Height}"

frame = gif.SavedImages[0]
print frame.RasterBits[0], frame.RasterBits[1], frame.RasterBits[2], frame.RasterBits[3]
