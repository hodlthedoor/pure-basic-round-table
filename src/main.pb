XIncludeFile "app.pbi"
If Not OpenApplication() : End 1 : EndIf
While HandleWindowEvent(WaitWindowEvent()) : Wend
CloseWindow(#MainWindow)
