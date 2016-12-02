// ============================================================================
//
// = CONTEXT
//   XDK
//
// = FILENAME
//   XDK_Configuration.h
//
// = AUTHOR
//   Nicolas Leclercq
//
// ============================================================================
#ifndef _XDK_CONFIGURATION_H_
#define _XDK_CONFIGURATION_H_ 

//=============================================================================
//                                XOP PLATFORM
//=============================================================================
#if defined(WIN32) || defined(WIN64) || defined(_WIN32) || defined(_WIN64)
#  define WINIGOR	
#  if defined(WIN64) || defined(_WIN64)
#    define IGOR64	
#    define WINIGOR64
#  else
#    define IGOR32	
#    define WINIGOR32
#  endif
#else
#  define MACIGOR
#  ifdef __LP64__
#    define IGOR64	
#    define MACIGOR64	
#  else
#    define IGOR32
#   define MACIGOR32
#  endif
#endif

//=============================================================================
//                                CONTEXT 
//=============================================================================
#define _XDK_XOP_ 

//=============================================================================
//                                XOP NAME 
//=============================================================================
#define kXOP_NAME "TangoClient"

//=============================================================================
//               XDK OPTIONS : TARGET PLATFORM (WIN32 or MACOS) 
//=============================================================================
#if defined(WINIGOR)
# define _XDK_WINDOWS_ 
#else
# define _XDK_MACOSX_ 
#endif

//=============================================================================
//                             XDK OPTIONS
//=============================================================================
//#define _XOP_ADDS_OPERATIONS_
//-----------------------------------------------------------------------------
#define _XOP_ADDS_FUNCTIONS_
//-----------------------------------------------------------------------------
#define _XOP_NEEDS_IDLE_
//-----------------------------------------------------------------------------
//#define _XOP_ADDS_ITEMS_TO_IGOR_MENUS_  //status: TO DO
//-----------------------------------------------------------------------------  
//#define _XOP_ADDS_MENUS_                //status: TO DO
//-----------------------------------------------------------------------------
//#define _XOP_MENU_HAS_SUBMENUS_         //status: TO DO
//-----------------------------------------------------------------------------
#define _XOP_HAS_ERROR_MESSAGES_
//-----------------------------------------------------------------------------
//#define _XOP_AUTO_QUIT_
//=============================================================================
#define _MIN_IGOR_VERSION_ 620 
//-----------------------------------------------------------------------------

#endif // _XDK_CONFIGURATION_H_ 

