#scope_export 

main :: () {

	window_width:  s32 = 600;
	window_height: s32 = 400;

	num_frame_buffers: int = 2;

	window_class: Win32.WNDCLASSEXW;
	Windows.init_window_class( *window_class, "App-Window-Class", Windows.window_callback );

/*
	window_user_data: Window_User_Data;
	Windows.init_window_user_data( num_frame_buffers, user_input );
*/

	window: Win32.HWND;
	Windows.init_window( *window, window_class, "App-Window", window_width, window_height, null );

	keep_window_open := true; // add this to the user data!
	while keep_window_open {
		window_messages: Win32.MSG;
		while Win32.PeekMessageW( *window_messages, window, 0, 0, Win32.PM_REMOVE ) {
			Win32.TranslateMessage( *window_messages );
			Win32.DispatchMessageW(  *window_messages );

			// update program state in here
			// render into the frame buffer
		}
	}	
}

#scope_file

Basic   :: #import "Basic";
Win32   :: #import, file "Windows-Win32-Api.jai";
Windows :: #import, file "Windows-Platform-Layer.jai";
