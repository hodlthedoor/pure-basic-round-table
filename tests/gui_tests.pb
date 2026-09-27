; Test-only native GUI driver; no automation hooks are included in the app.
XIncludeFile "../src/app.pbi"

Global QAFailures.i, QAChecks.i, QALog.i, QAOpen.i = #True, QAOutput.s

Structure QAPoint
  x.d
  y.d
EndStructure
Structure QARect
  x.d
  y.d
  width.d
  height.d
EndStructure

Procedure GUICheck(condition.i, description.s)
  QAChecks + 1
  If condition
    WriteStringN(QALog, "PASS: " + description)
  Else
    QAFailures + 1
    WriteStringN(QALog, "FAIL: " + description)
  EndIf
  FlushFileBuffers(QALog)
EndProcedure

Procedure Pump(milliseconds.i)
  Protected deadline.q = ElapsedMilliseconds() + milliseconds, event.i
  Repeat
    event = WaitWindowEvent(5)
    If event And Not HandleWindowEvent(event) : QAOpen = #False : Break : EndIf
  Until ElapsedMilliseconds() >= deadline
EndProcedure

Procedure WaitForSolution()
  Protected deadline.q = ElapsedMilliseconds() + 5000
  While (AppJob\state <> #Verified Or PublishedJobId <> CurrentJobId) And QAOpen And ElapsedMilliseconds() < deadline
    Pump(5)
  Wend
  Pump(40)
  GUICheck(Bool(AppJob\state = #Verified And PublishedJobId = CurrentJobId), "current job publishes verified output")
EndProcedure

Procedure EditCount(text.s)
  SetGadgetText(#PeopleInput, text)
  PostEvent(#PB_Event_Gadget, #MainWindow, #PeopleInput, #PB_EventType_Change)
  Pump(30)
  GUICheck(Bool(PublishedJobId = 0 And CountGadgetItems(#Rows) = 0 And SelectedRow = -1), "editing clears old answer and diagram selection")
EndProcedure

Procedure GenerateFor(people.i)
  EditCount(Str(people))
  CocoaMessage(0, GadgetID(#Generate), "performClick:", 0)
  WaitForSolution()
  GUICheck(Bool(AppJob\result\people = people And VerifySchedule(@AppJob\result)), "visible result matches input " + Str(people))
EndProcedure

Procedure Capture(name.s)
  Protected windowNumber.i = CocoaMessage(0, WindowID(#MainWindow), "windowNumber")
  Protected file.s = QAOutput + "/" + name + ".png"
  Protected captured.i, x.i, y.i, pixel.i, scale.d, titleHeight.i
  Pump(80)
  RunProgram("/usr/sbin/screencapture", "-x -o -l " + Str(windowNumber) + " " + Chr(34) + file + Chr(34), "", #PB_Program_Wait)
  GUICheck(Bool(FileSize(file) > 0), "window capture " + name)
  captured = LoadImage(#PB_Any, file)
  If captured
    scale = ImageWidth(captured) / WindowWidth(#MainWindow)
    titleHeight = ImageHeight(captured) - WindowHeight(#MainWindow) * scale
    x = (GadgetX(#Table) + GadgetWidth(#Table) / 2 + 40) * scale
    y = (GadgetY(#Table) + GadgetHeight(#Table) / 2 + 40) * scale + titleHeight
    If StartDrawing(ImageOutput(captured))
      pixel = Point(x, y) & $FFFFFF
      StopDrawing()
      ; Window captures pass through ColorSync; allow small profile differences.
      GUICheck(Bool(Abs(Red(pixel) - 234) <= 5 And Abs(Green(pixel) - 225) <= 5 And Abs(Blue(pixel) - 207) <= 5), "table remains painted in " + name + " (pixel " + Hex(pixel) + ")")
    EndIf
    FreeImage(captured)
  Else
    GUICheck(#False, "read captured window")
  EndIf
EndProcedure

Procedure PickRow(rowIndex.i)
  Protected item.i
  For item = 0 To CountGadgetItems(#Rows) - 1
    If GetGadgetItemData(#Rows, item) = rowIndex + 1
      SetGadgetState(#Rows, item)
      PostEvent(#PB_Event_Gadget, #MainWindow, #Rows, #PB_EventType_Change)
      Pump(30)
      GUICheck(Bool(SelectedRow = rowIndex), "row selection " + Str(rowIndex + 1))
      ProcedureReturn
    EndIf
  Next
  GUICheck(#False, "row is present " + Str(rowIndex + 1))
EndProcedure

Define n.i, item.i, count.i, appearance.i, name.i, deadline.q, scroll.i, clip.i, table.i
Define bounds.QARect, position.QAPoint
UsePNGImageDecoder()
If CountProgramParameters() <> 1 : End 2 : EndIf
QAOutput = ProgramParameter()
QALog = CreateFile(#PB_Any, QAOutput + "/gui-checks.log")
If QALog = 0 Or Not OpenApplication() : End 2 : EndIf
CocoaMessage(0, CocoaMessage(0, 0, "NSApplication sharedApplication"), "activateIgnoringOtherApps:", #True)
WaitForSolution()
GUICheck(Bool(AppJob\result\people = 5 And AppJob\result\rowCount = 6), "startup five-person solution")
appearance = CocoaMessage(0, WindowID(#MainWindow), "effectiveAppearance")
name = CocoaMessage(0, appearance, "name")
GUICheck(CocoaMessage(0, name, "isEqualToString:$", @"NSAppearanceNameAqua"), "paper background uses readable light controls")
GUICheck(Bool(GetGadgetState(#ViewMode) = #ShortenedView And CountGadgetItems(#Rows) = 2), "startup defaults to two shortened rows")
Capture("05-default")
SetGadgetState(#ViewMode, #ExtendedView)
PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode) : Pump(30)
GUICheck(Bool(CountGadgetItems(#Rows) = 7), "five-person extended view includes six sittings and separator")
GenerateFor(3) : Capture("03-minimum-people")
GenerateFor(13) : PickRow(65) : Capture("13-last-sitting")
GenerateFor(21)
count = 0
For item = 0 To CountGadgetItems(#Rows) - 1
  If GetGadgetItemData(#Rows, item) > 0 : count + 1 : EndIf
Next
GUICheck(Bool(count = 190), "all 190 sittings are represented")
PickRow(189) : Capture("21-last-sitting")
PickRow(37)
SetGadgetState(#ViewMode, #ShortenedView)
PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode)
Pump(40)
GUICheck(Bool(CountGadgetItems(#Rows) = 10 And SelectedRow = 19), "compact view selects matching starting row")
GUICheck(Bool(FindString(GetGadgetText(#Details), "Repeaters (fixed): 1, 21.") > 0), "correct fixed labels shown")
Capture("21-starting-rows")
SetGadgetState(#ViewMode, #ExtendedView)
PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode)
Pump(40)
GUICheck(Bool(SelectedRow = 19), "expanded view retains first sitting of selected group")
SetGadgetState(#Rows, 19)
PostEvent(#PB_Event_Gadget, #MainWindow, #Rows, #PB_EventType_Change)
Pump(40)
GUICheck(Bool(SelectedRow = 18 And GetGadgetItemData(#Rows, GetGadgetState(#Rows)) = 19), "upward selection skips group separator")
SetGadgetState(#Rows, 19)
PostEvent(#PB_Event_Gadget, #MainWindow, #Rows, #PB_EventType_Change)
Pump(40)
GUICheck(Bool(SelectedRow = 19 And GetGadgetItemData(#Rows, GetGadgetState(#Rows)) = 20), "downward selection skips group separator")
ResizeWindow(#MainWindow, #PB_Ignore, #PB_Ignore, 900, 760)
Pump(80) : Capture("21-minimum-window")
scroll = GadgetID(#Rows)
While scroll And Not CocoaMessage(0, scroll, "isKindOfClass:", CocoaMessage(0, 0, "NSScrollView class"))
  scroll = CocoaMessage(0, scroll, "superview")
Wend
GUICheck(Bool(scroll <> 0), "native scroll container exists")
If scroll
  GUICheck(CocoaMessage(0, scroll, "hasHorizontalScroller"), "narrow window supports horizontal scrolling")
  table = CocoaMessage(0, scroll, "documentView")
  clip = CocoaMessage(0, scroll, "contentView")
  CocoaMessage(@bounds, clip, "bounds")
  position\x = 170 : position\y = bounds\y
  CocoaMessage(0, clip, "scrollToPoint:@", @position)
  CocoaMessage(0, scroll, "reflectScrolledClipView:", clip)
  Pump(40)
  CocoaMessage(@bounds, clip, "bounds")
  GUICheck(Bool(bounds\x > 0), "last columns can be reached by scrolling")
  Capture("21-minimum-window-scrolled")
EndIf
GenerateFor(7)
CocoaMessage(@bounds, clip, "bounds")
GUICheck(Bool(bounds\x = 0), "new solution starts at first label after horizontal scrolling")
SetGadgetState(#ViewMode, #ShortenedView) : PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode) : Pump(30)
GUICheck(Bool(CountString(GetGadgetText(#Details), "Cycle:") = 2), "seven-person solution explains both cycles")
EditCount("22")
PostEvent(#PB_Event_Menu, #MainWindow, #ActionGenerate)
Pump(40)
GUICheck(Bool(GetGadgetText(#Status) = "Enter a whole number from 3 to 21." And PublishedJobId = 0), "Enter action rejects invalid input")
EditCount("21")
CocoaMessage(0, GadgetID(#Generate), "performClick:", 0)
deadline = ElapsedMilliseconds() + 1000
While (AppJob\state <> #Running Or AppJob\result\rowCount = 0) And ElapsedMilliseconds() < deadline : Pump(5) : Wend
CocoaMessage(0, GadgetID(#Cancel), "performClick:", 0)
Pump(50)
GUICheck(Bool(AppJob\state = #Cancelled And PublishedJobId = 0 And AppJob\result\rowCount = 0), "native Cancel clears partial generation")
GenerateFor(5)
GUICheck(Bool(GetGadgetState(#ViewMode) = #ShortenedView), "shortened preference survives cancellation and replacement")
For n = 3 To 21
  GenerateFor(n)
  GUICheck(Bool(GetGadgetState(#ViewMode) = #ShortenedView And CountGadgetItems(#Rows) = AppJob\groupCount), "shortened view for " + Str(n))
  SetGadgetState(#ViewMode, #ExtendedView)
  PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode) : Pump(30)
  count = 0
  For item = 0 To CountGadgetItems(#Rows) - 1
    If GetGadgetItemData(#Rows, item) > 0 : count + 1 : EndIf
  Next
  GUICheck(Bool(count = AppJob\result\rowCount), "extended view for " + Str(n))
  PickRow(AppJob\result\rowCount - 1)
  SetGadgetState(#ViewMode, #ShortenedView)
  PostEvent(#PB_Event_Gadget, #MainWindow, #ViewMode) : Pump(30)
  GUICheck(Bool(SelectedRow = (AppJob\groupCount - 1) * AppJob\period), "last sitting maps to shortened group " + Str(n))
  If n = 10 : Capture("10-shortened-cycles") : EndIf
Next
PostEvent(#PB_Event_CloseWindow, #MainWindow, 0)
Pump(30)
GUICheck(Bool(Not QAOpen And Not TimerRunning), "window closes and stops timer")
WriteStringN(QALog, Str(QAChecks) + " checks, " + Str(QAFailures) + " failures")
CloseFile(QALog)
CloseWindow(#MainWindow)
If QAFailures : End 1 : EndIf
End 0
