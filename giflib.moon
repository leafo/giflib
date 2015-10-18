
ffi = require "ffi"

ffi.cdef [[
  typedef void ExtensionBlock;
  typedef void GifColorType;

  typedef unsigned char GifPixelType;
  typedef unsigned char *GifRowType;
  typedef unsigned char GifByteType;
  typedef unsigned int GifPrefixType;
  typedef int GifWord;

  typedef struct ColorMapObject {
    int ColorCount;
    int BitsPerPixel;
    bool SortFlag;
    GifColorType *Colors;    /* on malloc(3) heap */
  } ColorMapObject;


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

  GifFileType *EGifOpenFileName(const char *GifFileName, const bool GifTestExistence, int *Error);
  ColorMapObject *GifMakeMapObject(int ColorCount, const GifColorType *ColorMap);
  SavedImage *GifMakeSavedImage(GifFileType *GifFile, const SavedImage *CopyFrom);
  int EGifSpew(GifFileType * GifFile);
]]

lib = ffi.load "libgif"

assert_error = (status) ->
  return true if status == 0
  error ffi.string lib.GifErrorString status

err = ffi.new("int[1]", 0)
source = lib.DGifOpenFileName "test.gif", err
assert_error err[0]

lib.DGifSlurp source

print "source ImageCount", source.ImageCount
print "source ExtensionBlockCount", source.ExtensionBlockCount

{:Left, :Top, :Width, :Height} = source.SavedImages[0].ImageDesc
print "left: #{Left}, top: #{Top}, width: #{Width}, height: #{Height}"

dest = lib.EGifOpenFileName "test.out.gif", false, err
assert_error err[0]

for f in *{"SWidth", "SHeight", "SColorResolution", "SBackGroundColor"}
  dest[f] = source[f]

dest.SColorMap = lib.GifMakeMapObject source.SColorMap.ColorCount, source.SColorMap.Colors

lib.GifMakeSavedImage dest, source.SavedImages[0]

print "dest ImageCount", dest.ImageCount
print "dest ExtensionBlockCount", dest.ExtensionBlockCount

print lib.EGifSpew dest


