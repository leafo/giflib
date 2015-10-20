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
  int EGifCloseFile(GifFileType *GifFile, int *ErrorCode);

  void GifFreeSavedImages(GifFileType *GifFile);
]]

ffi.load "libgif"


