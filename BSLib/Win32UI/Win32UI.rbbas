#tag Module
Protected Module Win32UI
	#tag Method, Flags = &h21
		Private Function AnimateWindow(HWND As Integer, Style As Integer, duration As Integer) As Boolean
		  Declare Function MyAnimateWindow Lib "User32" Alias "AnimateWindow" (HWND As Integer, duration As Integer, animation As Integer) As Boolean
		  Return MyAnimateWindow(HWND, duration, Style)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CaptureControl(Control As RectControl) As Picture
		  //Returns a picture of the specified Control.
		  
		  Return CaptureWindow(Control.Handle)  //Under Windows, controls are windows.
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CaptureScreen() As Picture
		  //Calls GetPartialScreenShot with a rectangle comprising all of the desktop rectangle. If a user
		  //has more than one screen, the returned picture will show all of them at the correct relative
		  //position.
		  
		  #If TargetWin32 Then Return GetPartialScreenShot(0, ScreenVirtualWidth, 0, ScreenVirtualHeight)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CaptureWindow(HWND As Integer) As Picture
		  //Returns a picture of the specified window. Pass window.Handle or any Win32 window handle
		  
		  #If TargetWin32 And TargetHasGUI Then
		    Declare Sub GetWindowRect Lib "User32" (HWND As Integer, ByRef sm As RECT)
		    Dim r as RECT
		    GetWindowRect(HWND, r)
		    Return GetPartialScreenShot(r.Left, r.Right, r.Top, r.Bottom)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FadeIn(Extends w As Window) As Boolean
		  Dim ret As Boolean = AnimateWindow(w.Handle, AW_ACTIVATE Or AW_BLEND, 200)
		  w.Show
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FadeOut(Extends w As Window) As Boolean
		  Dim ret As Boolean = AnimateWindow(w.Handle, AW_BLEND Or AW_HIDE, 200)
		  w.Hide
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Flash(Extends win As Window)
		  //Flashes the specified Window once
		  //See: http://msdn.microsoft.com/en-us/library/windows/desktop/ms679346%28v=vs.85%29.aspx
		  
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("FlashWindow", "User32") Then
		      Soft Declare Function FlashWindow Lib "User32" (HWND As Integer, invert As Boolean) As Boolean
		      Call FlashWindow(win.Handle, True)
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPartialScreenShot(left As Integer, right As Integer, top As Integer, bottom As Integer) As Picture
		  //Returns a Picture of the defined rectangle from current desktop.
		  //Rectangle coordinates are relative to the upper left corner of the user's leftmost screen, in pixels
		  
		  #If TargetWin32 Then
		    Declare Function GetDesktopWindow Lib "User32" () As Integer
		    Declare Function GetDC Lib "User32" (HWND As Integer) As Integer
		    Declare Function BitBlt Lib "GDI32" (DCdest As Integer, xDest As Integer, yDest As Integer, nWidth As Integer, nHeight As Integer, _
		    DCdource As Integer, xSource As Integer, ySource As Integer, rasterOp As Integer) As Boolean
		    Declare Function ReleaseDC Lib "User32" (HWND As Integer, DC As Integer) As Integer
		    
		    Dim screenWidth, screenHeight As Integer
		    screenHeight = bottom - top
		    screenWidth = right - left
		    Dim HWND As Integer = GetDesktopWindow()
		    Dim screenCap As New Picture(screenWidth, screenHeight, 24)
		    Dim deskHDC As Integer = GetDC(HWND)
		    Call BitBlt(screenCap.Graphics.Handle(Graphics.HandleTypeHDC), 0, 0, ScreenWidth, ScreenHeight, DeskHDC, left, top, SRCCOPY Or CAPTUREBLT)
		    Call ReleaseDC(HWND, deskHDC)
		    
		    Return screenCap
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SystemParametersInfo(action as UInt32, param1 as UInt32, param2 as Ptr, change as UInt32)
		  #If TargetWin32 Then
		    Declare Function SystemParametersInfoW Lib "User32" (action as UInt32, param1 as UInt32, param2 as Ptr, change as UInt32) As Boolean
		    Call SystemParametersInfoW(action, param1, param2, Change )
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ZoomIn(Extends w As Window) As Boolean
		  Dim ret As Boolean = AnimateWindow(w.Handle, AW_ACTIVATE Or AW_CENTER, 200)
		  w.Show
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ZoomOut(Extends w As Window) As Boolean
		  Dim ret As Boolean = AnimateWindow(w.Handle, AW_CENTER Or AW_HIDE, 200)
		  w.Hide
		  Return ret
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim mb as new MemoryBlock( 1024 )
			  Const SPI_GETDESKWALLPAPER = &h73
			  SystemParametersInfo(SPI_GETDESKWALLPAPER, mb.Size, mb, 0)
			  Return GetFolderItem(mb.WString(0))
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If Value = Nil Then Return
			  Const SPI_SETDESKWALLPAPER = &h14
			  Dim mb As New MemoryBlock(2048)
			  Dim wallpaper As String = Value.AbsolutePath
			  mb.WString(0) = wallpaper
			  SystemParametersInfo(SPI_SETDESKWALLPAPER, mb.Size, mb, 0)
			End Set
		#tag EndSetter
		CurrentWallpaper As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns True if the user has configured the Right mouse button as the primary
			  //rather than secondary mouse button (i.e. a left-handed user)
			  Return Platform.GetMetric(23) <> 0
			End Get
		#tag EndGetter
		LeftHandedMouse As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns the number of mouse buttons
			  Return Platform.GetMetric(43)
			End Get
		#tag EndGetter
		MouseButtonCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns the height of the main screen, in pixels
			  Return Platform.GetMetric(1)
			End Get
		#tag EndGetter
		ScreenHeight As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns the height of the bounding rectangle around all monitors. On single-screen systems this is identical to ScreenHeight
			  Return Platform.GetMetric(79)
			End Get
		#tag EndGetter
		ScreenVirtualHeight As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns the width of the bounding rectangle around all monitors. On single-screen systems this is identical to ScreenWidth
			  Return Platform.GetMetric(78)
			End Get
		#tag EndGetter
		ScreenVirtualWidth As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns the width of the main screen, in pixels
			  Return Platform.GetMetric(0)
			End Get
		#tag EndGetter
		ScreenWidth As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //True if the user requires an application to present information visually in situations where it would otherwise
			  //present the information only in audible form. e.g. for deaf users.
			  Return Platform.GetMetric(70) <> 0
			End Get
		#tag EndGetter
		ShowSounds As Boolean
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LeftHandedMouse"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MouseButtonCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenHeight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenVirtualHeight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenVirtualWidth"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenWidth"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowSounds"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
