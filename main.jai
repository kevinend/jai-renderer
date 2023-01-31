#scope_export 

main :: () {

	window_width:  s32 = 600;
	window_height: s32 = 400;

	success, window := Windows.create_window( 
		 title    = "App-Window"
		,width    = window_width
		,height   = window_height
		,callback = Windows.window_callback
	);

	if !success {
		Basic.log_error( "Unable to create window\n" );
		return;
	}

	render_context: Windows.Render_Context;
	Windows.init_render_context( *render_context, window );

	window_messages: Win32.MSG;
	while window_messages.message != Win32.WM_QUIT {
		if Win32.PeekMessageW( *window_messages, null, 0, 0, Win32.PM_REMOVE ) {
			Win32.TranslateMessage( *window_messages );
			Win32.DispatchMessageW( *window_messages );	
		}

		Windows.draw_solid_color( *render_context ); 

		Windows.display_frame( render_context );
	}
}

#scope_file

Basic   :: #import "Basic";
Win32   :: #import, file "Windows-Win32-Api.jai";
Windows :: #import, file "Windows-Platform-Layer.jai";
