/*
	This file is an abbreviated version of /modules/Windows.jai that is shipped with the compiler.
	It contains types and bindings (procedures) to Windows operating system functionality, more
	specifically the native Windows windowing system.
*/

#scope_export

HANDLE    :: *void;

HINSTANCE :: HANDLE;
HMODULE   :: HINSTANCE;
HWND      :: HANDLE;
HDC       :: HANDLE;
HICON     :: HANDLE;
HBRUSH    :: HANDLE;
HCURSOR   :: HANDLE;
HMENU     :: HANDLE;
HMONITOR  :: HANDLE;

// on 32-bit platforms this is actually a signed 32-bit integer.
LONG_PTR  :: s64;

RECT :: struct {
	left:   s32;
	top:    s32; 
	right:  s32;
	bottom: s32;
}

BOOL :: enum s32 {
	FALSE :: 0;
	TRUE  :: 1;

}

// Dynamic link library API
GetModuleHandleW :: (module_name: *u16) -> HANDLE #foreign kernel32;
LoadLibraryW     :: (filename: *u16) -> HMODULE #foreign kernel32;

WNDCLASSEXW :: struct {
    cbSize: u32;
    style: u32;
    lpfnWndProc: *void; // WNDPROC
    cbClsExtra: s32;
    cbWndExtra: s32;
    hInstance: HINSTANCE;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: *u16;
    lpszClassName: *u16;
    hIconSm: HICON;
}

// Window class procedures
RegisterClassExW :: (lpwcx: *WNDCLASSEXW) -> s16 #foreign user32;

WPARAM  :: u64;
LPARAM  :: s64;
LRESULT :: s64;

// Window class styles
CS_VREDRAW :: 0x0001;
CS_HREDRAW :: 0x0002;
CS_OWNDC   :: 0x0020;

// Window styles
WS_OVERLAPPED       :: 0x00000000;
WS_POPUP            :: 0x80000000;
WS_CHILD            :: 0x40000000;
WS_MINIMIZE         :: 0x20000000;
WS_VISIBLE          :: 0x10000000;
WS_DISABLED         :: 0x08000000;
WS_CLIPSIBLINGS     :: 0x04000000;
WS_CLIPCHILDREN     :: 0x02000000;
WS_MAXIMIZE         :: 0x01000000;
WS_CAPTION          :: 0x00C00000; // WS_BORDER | WS_DLGFRAME 
WS_BORDER           :: 0x00800000;
WS_DLGFRAME         :: 0x00400000;
WS_VSCROLL          :: 0x00200000;
WS_HSCROLL          :: 0x00100000;
WS_SYSMENU          :: 0x00080000;
WS_THICKFRAME       :: 0x00040000;
WS_GROUP            :: 0x00020000;
WS_TABSTOP          :: 0x00010000;
WS_MINIMIZEBOX      :: 0x00020000;
WS_MAXIMIZEBOX      :: 0x00010000;
WS_SIZEBOX          :: WS_THICKFRAME;
WS_OVERLAPPEDWINDOW :: WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;

// Window Ex styles
WS_EX_DLGMODALFRAME     :: 0x00000001;
WS_EX_NOPARENTNOTIFY    :: 0x00000004;
WS_EX_TOPMOST           :: 0x00000008;
WS_EX_ACCEPTFILES       :: 0x00000010;
WS_EX_TRANSPARENT       :: 0x00000020;
WS_EX_MDICHILD          :: 0x00000040;
WS_EX_TOOLWINDOW        :: 0x00000080;
WS_EX_WINDOWEDGE        :: 0x00000100;
WS_EX_CLIENTEDGE        :: 0x00000200;
WS_EX_CONTEXTHELP       :: 0x00000400;
WS_EX_RIGHT             :: 0x00001000;
WS_EX_LEFT              :: 0x00000000;
WS_EX_RTLREADING        :: 0x00002000;
WS_EX_LTRREADING        :: 0x00000000;
WS_EX_LEFTSCROLLBAR     :: 0x00004000;
WS_EX_RIGHTSCROLLBAR    :: 0x00000000;
WS_EX_CONTROLPARENT     :: 0x00010000;
WS_EX_STATICEDGE        :: 0x00020000;
WS_EX_APPWINDOW         :: 0x00040000;
WS_EX_OVERLAPPEDWINDOW  :: (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE);
WS_EX_PALETTEWINDOW     :: (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);
WS_EX_LAYERED           :: 0x00080000;
WS_EX_NOINHERITLAYOUT   :: 0x00100000; // Disable inheritence of mirroring by children
WS_EX_NOREDIRECTIONBITMAP :: 0x00200000;
WS_EX_LAYOUTRTL         :: 0x00400000; // Right to left mirroring
WS_EX_COMPOSITED        :: 0x02000000;
WS_EX_NOACTIVATE        :: 0x08000000;

// Window messages:
POINT :: struct {
	x,y: s32;
}
MSG :: struct {
	hwnd:     HWND;
	message:  u32;
    wParam:   WPARAM;
    lParam:   LPARAM;
    time:     s32;
    pt:       POINT;
    lPrivate: s32; 
}

WM_NULL 	::0x0000;
WM_CREATE 	:: 0x0001;
WM_DESTROY 	:: 0x0002;
WM_MOVE 	:: 0x0003;

WM_SIZE                         :: 0x0005;
WM_SETFOCUS                     :: 0x0007;
WM_KILLFOCUS                    :: 0x0008;
WM_ENABLE                       :: 0x000A;
WM_SETREDRAW                    :: 0x000B;
WM_SETTEXT                      :: 0x000C;
WM_GETTEXT                      :: 0x000D;
WM_GETTEXTLENGTH                :: 0x000E;
WM_PAINT                        :: 0x000F;
WM_CLOSE                        :: 0x0010;
WM_QUERYENDSESSION              :: 0x0011;
WM_QUERYOPEN                    :: 0x0013;
WM_ENDSESSION                   :: 0x0016;
WM_QUIT                         :: 0x0012;
WM_ERASEBKGND                   :: 0x0014;
WM_SYSCOLORCHANGE               :: 0x0015;
WM_SHOWWINDOW                   :: 0x0018;
WM_WININICHANGE                 :: 0x001A;
WM_SETTINGCHANGE                :: WM_WININICHANGE;
WM_DEVMODECHANGE                :: 0x001B;
WM_ACTIVATEAPP                  :: 0x001C;
WM_FONTCHANGE                   :: 0x001D;
WM_TIMECHANGE                   :: 0x001E;
WM_CANCELMODE                   :: 0x001F;
WM_SETCURSOR                    :: 0x0020;
WM_MOUSEACTIVATE                :: 0x0021;
WM_CHILDACTIVATE                :: 0x0022;
WM_QUEUESYNC                    :: 0x0023;
WM_GETMINMAXINFO                :: 0x0024;

WM_NOTIFY                       :: 0x004E;
WM_INPUTLANGCHANGEREQUEST       :: 0x0050;
WM_INPUTLANGCHANGE              :: 0x0051;
WM_TCARD                        :: 0x0052;
WM_HELP                         :: 0x0053;
WM_USERCHANGED                  :: 0x0054;
WM_NOTIFYFORMAT                 :: 0x0055;
WM_CONTEXTMENU                  :: 0x007B;
WM_STYLECHANGING                :: 0x007C;
WM_STYLECHANGED                 :: 0x007D;
WM_DISPLAYCHANGE                :: 0x007E;
WM_GETICON                      :: 0x007F;
WM_SETICON                      :: 0x0080;
WM_NCCREATE                     :: 0x0081;
WM_NCDESTROY                    :: 0x0082;
WM_NCCALCSIZE                   :: 0x0083;
WM_NCHITTEST                    :: 0x0084;
WM_NCPAINT                      :: 0x0085;
WM_NCACTIVATE                   :: 0x0086;
WM_GETDLGCODE                   :: 0x0087;
WM_SYNCPAINT                    :: 0x0088;
WM_NCMOUSEMOVE                  :: 0x00A0;
WM_NCLBUTTONDOWN                :: 0x00A1;
WM_NCLBUTTONUP                  :: 0x00A2;
WM_NCLBUTTONDBLCLK              :: 0x00A3;
WM_NCRBUTTONDOWN                :: 0x00A4;
WM_NCRBUTTONUP                  :: 0x00A5;
WM_NCRBUTTONDBLCLK              :: 0x00A6;
WM_NCMBUTTONDOWN                :: 0x00A7;
WM_NCMBUTTONUP                  :: 0x00A8;
WM_NCMBUTTONDBLCLK              :: 0x00A9;
WM_NCXBUTTONDOWN                :: 0x00AB;
WM_NCXBUTTONUP                  :: 0x00AC;
WM_NCXBUTTONDBLCLK              :: 0x00AD;
WM_INPUT_DEVICE_CHANGE          :: 0x00FE;
WM_INPUT                        :: 0x00FF;
WM_KEYFIRST                     :: 0x0100;
WM_KEYDOWN                      :: 0x0100;
WM_KEYUP                        :: 0x0101;
WM_CHAR                         :: 0x0102;
WM_DEADCHAR                     :: 0x0103;
WM_SYSKEYDOWN                   :: 0x0104;
WM_SYSKEYUP                     :: 0x0105;
WM_SYSCHAR                      :: 0x0106;
WM_SYSDEADCHAR                  :: 0x0107;
WM_UNICHAR                      :: 0x0109;
WM_KEYLAST                      :: 0x0109;
UNICODE_NOCHAR                  :: 0xFFFF;
WM_IME_STARTCOMPOSITION         :: 0x010D;
WM_IME_ENDCOMPOSITION           :: 0x010E;
WM_IME_COMPOSITION              :: 0x010F;
WM_IME_KEYLAST                  :: 0x010F;
WM_INITDIALOG                   :: 0x0110;
WM_COMMAND                      :: 0x0111;
WM_SYSCOMMAND                   :: 0x0112;
WM_TIMER                        :: 0x0113;
WM_HSCROLL                      :: 0x0114;
WM_VSCROLL                      :: 0x0115;
WM_INITMENU                     :: 0x0116;
WM_INITMENUPOPUP                :: 0x0117;
WM_GESTURE                      :: 0x0119;
WM_GESTURENOTIFY                :: 0x011A;
WM_MENUSELECT                   :: 0x011F;
WM_MENUCHAR                     :: 0x0120;
WM_ENTERIDLE                    :: 0x0121;
WM_MENURBUTTONUP                :: 0x0122;
WM_MENUDRAG                     :: 0x0123;
WM_MENUGETOBJECT                :: 0x0124;
WM_UNINITMENUPOPUP              :: 0x0125;
WM_MENUCOMMAND                  :: 0x0126;
WM_CHANGEUISTATE                :: 0x0127;
WM_UPDATEUISTATE                :: 0x0128;
WM_QUERYUISTATE                 :: 0x0129;

WM_CTLCOLORMSGBOX               :: 0x0132;
WM_CTLCOLOREDIT                 :: 0x0133;
WM_CTLCOLORLISTBOX              :: 0x0134;
WM_CTLCOLORBTN                  :: 0x0135;
WM_CTLCOLORDLG                  :: 0x0136;
WM_CTLCOLORSCROLLBAR            :: 0x0137;
WM_CTLCOLORSTATIC               :: 0x0138;
MN_GETHMENU                     :: 0x01E1;
WM_MOUSEFIRST                   :: 0x0200;
WM_MOUSEMOVE                    :: 0x0200;
WM_LBUTTONDOWN                  :: 0x0201;
WM_LBUTTONUP                    :: 0x0202;
WM_LBUTTONDBLCLK                :: 0x0203;
WM_RBUTTONDOWN                  :: 0x0204;
WM_RBUTTONUP                    :: 0x0205;
WM_RBUTTONDBLCLK                :: 0x0206;
WM_MBUTTONDOWN                  :: 0x0207;
WM_MBUTTONUP                    :: 0x0208;
WM_MBUTTONDBLCLK                :: 0x0209;
WM_MOUSEWHEEL                   :: 0x020A;
WM_XBUTTONDOWN                  :: 0x020B;
WM_XBUTTONUP                    :: 0x020C;
WM_XBUTTONDBLCLK                :: 0x020D;
WM_MOUSEHWHEEL                  :: 0x020E;
WM_MOUSELAST                    :: 0x020E;

WM_EXITSIZEMOVE                 :: 0x0232;
WM_DROPFILES                    :: 0x0233;
WM_DPICHANGED                   :: 0x02E0;

// PeekMessage flags
PM_NOREMOVE :: 0x0000;
PM_REMOVE   :: 0x0001;
PM_NOYIELD  :: 0x0002;

PeekMessageW     :: (msg: *MSG, hwnd: HWND, wMsgFilterMin: u32, wMsgFilterMax: u32, wRemoveMsg: u32) -> s32 #foreign user32;
DispatchMessageW :: (msg: *MSG) -> s32 #foreign user32;
TranslateMessage :: (msg: *MSG) -> s32 #foreign user32;
PostQuitMessage  :: (nExitcode: s64)   #foreign user32;

CREATESTRUCTW :: struct {
	lpCreateParams: *void;
	hInstance: HINSTANCE;
	hMenu: HMENU;    
	hwndParent: HWND;        
	cy:    s32;
    cx:    s32;
    y: 	   s32;
    x: 	   s32;
    style: s32;
  	lpszName:  *u16;
  	lpszClass: *u16;
	dwExStyle:  u32;
}

// Window field offsets for GetWindowLongPtr()
// some of these use GWL for the prefix while others use GWLP, not sure why.
// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongptrw
GWL_EXSTYLE			:: -20;
GWLP_HINSTANCE		::  -6;
GWLP_HWNDPARENT		::  -8;
GWLP_ID				:: -12;
GWL_STYLE			:: -16;
GWLP_USERDATA		:: -21;
GWLP_WNDPROC		::  -4;

// Window procedures
CreateWindowExW :: (
	 dwExStyle: s32
	,lpClassName: *u16
	,lpWindowName: *u16
	,dwStyle: u32
	,x: s32
	,y: s32
	,nWidth: s32
	,nHeight: s32
	,hwndParent: HWND
	,hMenu: HMENU
	,hInstance: HINSTANCE
	,lpParam: *void
) -> HWND #foreign user32;

GetDC :: ( hWnd: HWND ) -> HDC #foreign user32;

SetWindowLongPtrW :: (hWnd: HWND, nIndex: s32, dwNewLong: LONG_PTR ) -> LONG_PTR #foreign user32;
GetWindowLongPtrW :: (hWnd: HWND, nIndex: s32) -> LONG_PTR #foreign user32; 

DefWindowProcW  :: (hWnd: HWND, Msg: u32, wParam: WPARAM, lParam: LPARAM) -> s64 #foreign user32;
GetClientRect   :: (hWnd: HWND, lpRect: *RECT) -> BOOL #foreign user32; 

InvalidateRect  :: (hWnd: HWND, lpRect: *RECT, erase: BOOL ) -> BOOL #foreign user32;
UpdateWindow    :: (hwnd: HWND) -> s32  #foreign user32;

DestroyWindow   :: (hWnd: HWND) -> BOOL #foreign user32;

// Windows Monitor Detection
MONITORINFO :: struct {
	cbSize: 	u32;
	rcMonitor:  RECT;
	rcWork:     RECT;
	dwFlags:    u32;
}

CCHDEVICENAME: u32: 32;
MONITORINFOEX :: struct {
	// this struct inherits from the MONITORINFO class above.
	// not sure if this type definition will work!
	cbSize: 	u32;
	rcMonitor:  RECT;
	rcWork:     RECT;
	dwFlags:    u32;
	szDevice:   [CCHDEVICENAME] u8;	
}

MONITOR_DEFAULTTONULL    :: 0x00000000;
MONITOR_DEFAULTTOPRIMARY :: 0x00000001;
MONITOR_DEFAULTTONEAREST :: 0x00000002;

MonitorFromPoint :: ( pt: POINT, dwFlags: u32 ) -> HMONITOR #foreign user32;
GetMonitorInfoA  :: ( hMonitor: HMONITOR, lpmi: *MONITORINFO ) -> BOOL #foreign user32;

// Window Cursors:
IDC_APPSTARTING :: cast(*void) 32650;
IDC_ARROW    :: cast(*void) 32512;
IDC_CROSS    :: cast(*void) 32515;
IDC_HAND     :: cast(*void) 32649;
IDC_HELP     :: cast(*void) 32651;
IDC_IBEAM    :: cast(*void) 32513;
IDC_ICON     :: cast(*void) 32641;
IDC_NO       :: cast(*void) 32648;
IDC_SIZE     :: cast(*void) 32640;
IDC_SIZEALL  :: cast(*void) 32646;
IDC_SIZENESW :: cast(*void) 32643;
IDC_SIZENS   :: cast(*void) 32645;
IDC_SIZENWSE :: cast(*void) 32642;
IDC_SIZEWE   :: cast(*void) 32644;
IDC_UPARROW  :: cast(*void) 32516;
IDC_WAIT     :: cast(*void) 32514;

LoadCursorW  :: (hInstance: HINSTANCE, lpCursorName: *s16) -> HCURSOR #foreign user32;

// Bitmap specific types
BITMAPINFOHEADER :: struct {
    biSize:          u32;
    biWidth:         s32;
    biHeight:        s32;
    biPlanes:        u16;
    biBitCount:      u16;
    biCompression:   u32;
    biSizeImage:     u32;
    biXPelsPerMeter: s32;
    biYPelsPerMeter: s32;
    biClrUsed:       u32;
    biClrImportant:  u32;
}

// Constants for biCompression field.
BI_RGB       :: 0;
BI_RLE8      :: 1;
BI_RLE4      :: 2;
BI_BITFIELDS :: 3;
BI_JPEG      :: 4;
BI_PNG       :: 5;

RGBQUAD :: struct {
	rgbBlue: 		u8;
	rgbGreen: 		u8;
	rgbRed:   		u8;
	rgbReserved: 	u8;
}

BITMAPINFO :: struct {
	bmiHeader: BITMAPINFOHEADER;
	bmiColors: [1] RGBQUAD;
}

DIBColors :: enum u32 {

	DIB_RGB_COLORS  :: 0x00;
   	DIB_PAL_COLORS  :: 0x01;
   	DIB_PAL_INDICES :: 0x02;
}

// GDI raster operation codes (rop)
SRCCOPY :: 0xcc0020;

StretchDIBits :: (
   hdc:   	  	HDC
  ,xDest: 	  	s64
  ,yDest: 	  	s64
  ,destWidth: 	s64
  ,destHeight: 	s64
  ,xSrc: 		s64
  ,ySrc:        s64
  ,srcWidth: 	s64
  ,srcHeight:	s64
  ,lpBits:		*void
  ,lpbmi:		*BITMAPINFO
  ,iUsage:		DIBColors
  ,rop:			u32	
) -> s64 #foreign gdi32;

SetDIBitsToDevice :: (
   hdc: 	  HDC
  ,xDest: 	  s64
  ,yDest: 	  s64
  ,w:     	  u32
  ,h:     	  u32
  ,xSrc:  	  s64
  ,ySrc:  	  s64
  ,startScan: u32
  ,cLines:    u32
  ,lpvBits:   *void
  ,lpbmi:     *BITMAPINFO
  ,colorUse:  DIBColors
) -> s64 #foreign gdi32;

// Windows paint types and procedures
PAINTSTRUCT :: struct {
 	hdc: 	  	HDC; 
  	fErase:   	BOOL;
  	rcPaint:  	RECT;
  	fRestore: 	BOOL;
  	fIncUpdate: BOOL;
  	rgbReserved: [32] u8;
}

BeginPaint :: ( hWnd: HWND, lpPaint: *PAINTSTRUCT ) -> HDC  #foreign user32;
EndPaint   :: ( hWnd: HWND, lpPaint: *PAINTSTRUCT ) -> BOOL #foreign user32;

#scope_file

gdi32    :: #system_library "gdi32";
kernel32 :: #system_library "kernel32";
user32   :: #system_library "user32";

