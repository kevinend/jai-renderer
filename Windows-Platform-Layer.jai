#scope_export

init_window_class :: ( window_class: *Win32.WNDCLASSEXW, class_name: string, window_callback: win32_window_callback ) {
	
	window_class.cbSize 	   = size_of(Win32.WNDCLASSEXW);
	window_class.lpszClassName = Windows_Utf8.utf8_to_wide( class_name ); 
	window_class.hInstance     = Win32.GetModuleHandleW( null );
	window_class.style 		   = Win32.CS_HREDRAW | Win32.CS_VREDRAW | Win32.CS_OWNDC;
	window_class.lpfnWndProc   = cast(*void)window_callback;
	window_class.hCursor       = Win32.LoadCursorW( null, Win32.IDC_ARROW );

	window_class_registered := Win32.RegisterClassExW( window_class );
	if !window_class_registered {
		Basic.log_error( "Unable to register window class with name %, no windows can be created using this class\n", class_name );
		Basic.exit( -1 );
	}

	return;
}

init_window :: ( window: *Win32.HWND, class: Win32.WNDCLASSEXW, title: string, width: s32, height: s32, user_data: *void ) {
	
	window = Win32.CreateWindowExW( 
		 0
		,class.lpszClassName
		,Windows_Utf8.utf8_to_wide( title )
		,Win32.WS_OVERLAPPEDWINDOW | Win32.WS_CAPTION | Win32.WS_VISIBLE
		,0, 0
		,width, height
		,null
		,null
		,Win32.GetModuleHandleW( null )
		,user_data
	);

	if !window {
		Basic.log_error( "Unable to create a new window named % with window class %\n", title, class );
		Basic.exit( -1 );
	}

	return;
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
		case Win32.WM_CLOSE; #through;
		case Win32.WM_QUIT; {
			Win32.DestroyWindow( window );
			Basic.exit (-1); // for now
			// keep_window_open = false; // this needs to be accessible from the other function or through the window data
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
