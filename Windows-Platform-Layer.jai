#scope_export

// Presentation of rendered images is tied to the window system used by the application.
// Keyboard input is tied to the operating system as well.
// Thus Image/Framebuffer and User Input types are added to this file.

// Bookmarked but pertinent to these data structures: 
// https://stackoverflow.com/questions/15194002/why-does-opengl-be-designed-as-a-state-machine-originally 

Pixel :: struct {
	// assumes simple RGBA format where each value is a byte
	blue, green, red, alpha: u8;
}

Swapchain :: struct {

	NUMBER_OF_FRAMEBUFFERS :: 2;

	framebuffers: [Swapchain.NUMBER_OF_FRAMEBUFFERS] [] Pixel;
	image_format:  Win32.BITMAPINFO;

	render_\target_index: int;
	present_target_index: int;
}

Render_State :: struct {
	// this is the active state used for draw/render and presentation calls
	viewport: 	    *void;
	render_target:  *void;
	present_target: *void;
	depth_buffer:   *void;
	stencil_buffer: *void;
	vertex_buffer:  *void;
	index_buffer:   *void;
}

Render_Context :: struct {

	device_context: Win32.HDC;   // required for 'paint' operations 
	window:	    	Win32.HWND;	 // render context is associated 1:1 to the main application window
	swapchain: 		Swapchain;
	state:     		Render_State;
}

/*

	State fields
	render_context.resources.framebuffers[i];

	render_context.state.viewport() 
	render_context.state.render_target()
	render_context.state.present_target()
	render_context.state.vertex_buffer()
	render_context.state.index_buffer()

	Setting the State fields
	render_context_bind_vertex_buffer();
	render_context_bind_index_buffer();
	render_context_bind_viewport()

*/

create_window :: ( title: string, width: s32, height: s32, callback: win32_window_callback ) -> (success: bool, Win32.HWND) {

	// create the window class with sensible defaults 
	window_class: Win32.WNDCLASSEXW;
	window_class.cbSize 	   = size_of(Win32.WNDCLASSEXW);
	window_class.lpszClassName = Windows_Utf8.utf8_to_wide( "App-Window-Class" ); 
	window_class.hInstance     = Win32.GetModuleHandleW( null );
	window_class.style 		   = Win32.CS_HREDRAW | Win32.CS_VREDRAW | Win32.CS_OWNDC;
	window_class.lpfnWndProc   = cast(*void)callback;
	window_class.hCursor       = Win32.LoadCursorW( null, Win32.IDC_ARROW );

	// register the window class 	
	registered_window_class := Win32.RegisterClassExW( *window_class );
	if !registered_window_class {
		Basic.log_error( "Unable to register window class, no windows can be created using this class.\n" );
		return false, null;
	}

	window := Win32.CreateWindowExW( 
		 0
		,window_class.lpszClassName
		,Windows_Utf8.utf8_to_wide( title )
		,Win32.WS_OVERLAPPEDWINDOW | Win32.WS_CAPTION | Win32.WS_VISIBLE
		,0, 0
		,width, height
		,null
		,null
		,Win32.GetModuleHandleW( null )
		,null
	);

	if !window {
		Basic.log_error( "Unable to create a new window named % with window class %\n", title, window_class.lpszClassName );
		return false, null;
	}

	return true, window;
}

init_render_context :: ( render_context: *Render_Context, window: Win32.HWND ) {

	render_context.device_context = Win32.GetDC( window );
	render_context.window         = window;
	render_context.swapchain      = create_swapchain( render_context, window );
	
	create_swapchain :: ( render_context: *Render_Context, window: Win32.HWND ) -> Swapchain {
		
		swapchain: Swapchain;
		swapchain.render_target_index  = 0;
		swapchain.present_target_index = 0;	

		// allocate framebuffer memory matching the width and height of the PRIMARY MONITOR, not the WINDOW's extents
		// code does not resize the framebuffers during runtime and does not handle multiple monitor scenarios
		// if a window is resized the bitmap's width and height metadata are adjusted but memory is not reallocated
		{
			// Raymond Chen's blog post about finding primary monitor: https://devblogs.microsoft.com/oldnewthing/20070809-00/?p=25643
			point_zero: Win32.POINT = .{ x = 0, y = 0 };
			monitor := Win32.MonitorFromPoint( point_zero, Win32.MONITOR_DEFAULTTOPRIMARY );

			info := Win32.MONITORINFOEX.{ cbSize = size_of(Win32.MONITORINFOEX) };
			Win32.GetMonitorInfoA( monitor, cast(*Win32.MONITORINFO)*info );

			monitor_width  := info.rcMonitor.right  - info.rcMonitor.left;
			monitor_height := info.rcMonitor.bottom - info.rcMonitor.top;

			for i: 0..Swapchain.NUMBER_OF_FRAMEBUFFERS-1 {
				swapchain.framebuffers[i].data = Basic.alloc( monitor_width * monitor_height * size_of(Pixel) );
				if !swapchain.framebuffers[i].data {
					Basic.log_error( "Unable to allocate space for the image/frame buffers matching the monitor's dimensions (width,height) == (%,%)\n", monitor_width, monitor_height );
				}
				swapchain.framebuffers[i].count = monitor_width * monitor_height;
			}
		}

		// initialize the 'BITMAPINFO' structure which defines the format of the data in the framebuffers/images
		// Bitmap width and height match the client area of the window, not the initial requested window size 
		{
			client_area: Win32.RECT;
			Win32.GetClientRect( window, *client_area );
		
			window_width  := client_area.right  - client_area.left;
			window_height := client_area.bottom - client_area.top;

			swapchain.image_format.bmiHeader.biSize     	= size_of(type_of(swapchain.image_format.bmiHeader));
			swapchain.image_format.bmiHeader.biWidth        =  window_width;
			swapchain.image_format.bmiHeader.biHeight		= -window_height; // top-down 'device-independent-bitmap' (DIB)
			swapchain.image_format.bmiHeader.biPlanes   	= 1;
			swapchain.image_format.bmiHeader.biBitCount 	= 32;
			swapchain.image_format.bmiHeader.biCompression  = Win32.BI_RGB;
		}

		return swapchain;
	}

	Win32.SetWindowLongPtrW( window, Win32.GWLP_USERDATA, cast(Win32.LONG_PTR)render_context );

	return;
}

resize_framebuffers :: ( render_context: *Render_Context ) {

	// Memory for the framebuffers/images is set to a fixed-size (max of the primary display during window creation).
	// When the window is resized, we update the bitmap header's width and height to match the new client area of the window.
	//
	// This prevents constantly resizing the framebuffer/image on window resizes; allocate it once then don't worry about it
	//
	// If a window is not full-screen then we are wasting memory but it is a choice, may need revised later.

	client_area: Win32.RECT;
	Win32.GetClientRect( render_context.window, *client_area );

	width  := client_area.right  - client_area.left;
	height := client_area.bottom - client_area.top;

	render_context.swapchain.image_format.bmiHeader.biWidth  =  width;
	render_context.swapchain.image_format.bmiHeader.biHeight = -height; // top-down DIB
	
	return;
}

draw_solid_color :: ( render_context: *Render_Context ) {

	width  := render_context.swapchain.image_format.bmiHeader.biWidth;
	height := render_context.swapchain.image_format.bmiHeader.biHeight * -1;

	render_target_index := render_context.swapchain.render_target_index;
	image               := render_context.swapchain.framebuffers[render_target_index];

	pixel: *Pixel;
	for y: 0..height-1 {
	for x: 0..width-1 {
		pixel = *(image[(y*width)+x]);
		pixel.red 	=   255;
		pixel.green =   0;
		pixel.blue  = 	0;
	}
	}
}
	
display_frame :: inline ( render_context: Render_Context ) {
	
	// trigger WM_PAINT message to be scheduled and handled; actual presentation done in the message handler
	Win32.InvalidateRect( render_context.window, null, Win32.BOOL.FALSE );
	Win32.UpdateWindow( render_context.window );
}

	
window_callback :: ( window: Win32.HWND, message: u32, w_param: Win32.WPARAM, l_param: Win32.LPARAM ) -> Win32.LRESULT #c_call {

	result: Win32.LRESULT = 0;

	// remember this is being called from our window so we have no context
	// need to recreate it (context is part of Preload.jai I believe)

	new_context: Context;
	new_context.allocator = Context.default_allocator;
	new_context.logger    = Context.default_logger;

	push_context new_context {

	if message == {
		case Win32.WM_SIZE; {
			render_context := cast(*Render_Context)Win32.GetWindowLongPtrW( window, Win32.GWLP_USERDATA );
			if render_context {
				// render context is initialized AFTER window creation and we could receive WM_SIZE messages before the context is initialized
				// and set as the window data. Probably should refactor this
				resize_framebuffers( render_context );
			}
		}
		case Win32.WM_PAINT; {
			render_context := cast(*Render_Context)Win32.GetWindowLongPtrW( window, Win32.GWLP_USERDATA );
			present_frame( render_context );
			swap_render_targets( render_context );
		}
		case Win32.WM_CLOSE; {
			Win32.DestroyWindow( window );
		}
		case Win32.WM_DESTROY; {
			Win32.PostQuitMessage(0);
		}
		case; {
			result = Win32.DefWindowProcW( window, message, w_param, l_param );
		}
	}

	} // end context

	return result;
}

#scope_file

Basic        :: #import "Basic";
Windows_Utf8 :: #import "Windows_Utf8";
Win32 		 :: #import, file "Windows-Win32-Api.jai";

win32_window_callback :: #type (Win32.HWND, u32, Win32.WPARAM, Win32.LPARAM ) -> Win32.LRESULT #c_call;

present_frame :: ( render_context: *Render_Context ) {

	present_target_index := render_context.swapchain.present_target_index;
	image  				 := render_context.swapchain.framebuffers[present_target_index];

	width  := cast(u32)render_context.swapchain.image_format.bmiHeader.biWidth;
	height := cast(u32)(render_context.swapchain.image_format.bmiHeader.biHeight * -1);
	
	bitmap_info := *render_context.swapchain.image_format;

	paint: Win32.PAINTSTRUCT;
	Win32.BeginPaint( render_context.window, *paint );
	scanlines := Win32.SetDIBitsToDevice(
		render_context.device_context
	   ,0,0,width,height
	   ,0,0
	   ,0
	   ,height
	   ,image.data
	   ,bitmap_info
	   ,Win32.DIBColors.DIB_RGB_COLORS
	);

	Win32.EndPaint( render_context.window, *paint );	

	return;
}


swap_render_targets :: ( render_context: *Render_Context ) {

	// swap the framebuffers so that the current render target becomes the next image to be presented and
	// the existing presentation buffer is used for the next frame's draw calls
	// 
	// this code assumes a double-buffered approach

	render_context.swapchain.present_target_index =  render_context.swapchain.render_target_index;
	render_context.swapchain.render_\target_index = (render_context.swapchain.render_target_index + 1) % Swapchain.NUMBER_OF_FRAMEBUFFERS;

	return;

}

