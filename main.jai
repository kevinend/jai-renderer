#scope_export 

main :: () {

	window_width:  int = 600;
	window_height: int = 400;

	num_frame_buffers: int = 2;

	window_class: Win32.WNDCLASSEXW;
/*
	Windows.init_window_class( *window_class, "name", instance, style, callback );

	window_user_data: Window_User_Data;
	Windows.init_window_user_data( num_frame_buffers, user_input );

	window: Windows.HWND;
	Win32.init_window( instance, class, "window_name", window_width, window_height, window_user_data );

	keep_window_open = true; // add this to the user data!
	while keep_window_open {
		window_messages: Windows.MSG;
		while Windows.PeekMessage( *window_message, window, 0, 0, Windows.PM_REMOVE ) {
			Windows.TranslateMessage( *window_messages );
			Windows.DispatchMessage(  *window_messages );

			// update program state in here
			// render into the frame buffer
			Windows.InvalidateRect(
		}
	}
*/
	
}

#scope_file

Basic :: #import "Basic";
Win32 :: #import, file "Windows-Win32-Api.jai";
