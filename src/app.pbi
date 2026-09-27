XIncludeFile "solver.pbi"
XIncludeFile "input.pbi"
XIncludeFile "presentation.pbi"

Enumeration
  #MainWindow
EndEnumeration
Enumeration
  #Title
  #Subtitle
  #PeopleLabel
  #PeopleInput
  #Generate
  #Cancel
  #Status
  #RowsHeading
  #RowsHint
  #Compact
  #Rows
  #SelectedHeading
  #SelectedHint
  #Table
  #DetailsHeading
  #Details
EndEnumeration
Enumeration
  #FontTitle
  #FontHeading
  #FontBody
  #FontRows
  #FontNumbers
EndEnumeration
#GenerationTimer = 1
#ActionGenerate = 1
#ActionCancel = 2

XIncludeFile "drawing.pbi"

Global AppJob.GenerationJob, CurrentJobId.i, PublishedJobId.i
Global SelectedRow.i = -1, SelectedItem.i = -1, TimerRunning.i

Procedure StopGenerationTimer()
  If TimerRunning
    RemoveWindowTimer(#MainWindow, #GenerationTimer)
    TimerRunning = #False
  EndIf
EndProcedure

Procedure RefreshDrawing()
  If PublishedJobId = CurrentJobId And AppJob\state = #Verified And SelectedRow >= 0
    DrawSeating(#Table, @AppJob\result\rows[SelectedRow], AppJob\result\people)
  Else
    DrawSeating(#Table, 0, 0)
  EndIf
EndProcedure

Procedure LayoutWindow()
  Protected width.i = WindowWidth(#MainWindow), height.i = WindowHeight(#MainWindow)
  Protected rightWidth.i = width * 0.35, canvasHeight.i = height - 452
  If rightWidth < 340 : rightWidth = 340 : EndIf
  If rightWidth > 440 : rightWidth = 440 : EndIf
  Protected leftWidth.i = width - rightWidth - 72, rightX.i = leftWidth + 48
  If canvasHeight > rightWidth : canvasHeight = rightWidth : EndIf
  ResizeGadget(#Title, 24, 18, width - 48, 40)
  ResizeGadget(#Subtitle, 25, 60, width - 48, 24)
  ResizeGadget(#PeopleLabel, 24, 106, 96, 26)
  ResizeGadget(#PeopleInput, 124, 99, 72, 36)
  ResizeGadget(#Generate, 208, 99, 118, 36)
  ResizeGadget(#Cancel, 334, 99, 94, 36)
  ResizeGadget(#Status, 450, 103, width - 474, 44)
  ResizeGadget(#RowsHeading, 24, 158, leftWidth - 175, 27)
  ResizeGadget(#Compact, 24 + leftWidth - 174, 157, 174, 27)
  ResizeGadget(#RowsHint, 24, 187, leftWidth, 40)
  ResizeGadget(#Rows, 24, 232, leftWidth, height - 256)
  ResizeGadget(#SelectedHeading, rightX, 158, rightWidth, 27)
  ResizeGadget(#SelectedHint, rightX, 187, rightWidth, 26)
  ResizeGadget(#Table, rightX, 232, rightWidth, canvasHeight)
  ResizeGadget(#DetailsHeading, rightX, 246 + canvasHeight, rightWidth, 27)
  ResizeGadget(#Details, rightX, 278 + canvasHeight, rightWidth, height - canvasHeight - 302)
  RefreshDrawing()
EndProcedure

Procedure ClearDisplay(message.s)
  PublishedJobId = 0 : SelectedRow = -1 : SelectedItem = -1
  ClearGadgetItems(#Rows)
  SetGadgetState(#Compact, 0) : DisableGadget(#Compact, #True)
  SetGadgetText(#RowsHeading, "Seating schedule")
  SetGadgetText(#RowsHint, "One row per sitting. The last person sits next to the first.")
  SetGadgetText(#SelectedHeading, "The circular seating")
  SetGadgetText(#SelectedHint, "Select a row to view its seating order.")
  SetGadgetText(#DetailsHeading, "The rule")
  SetGadgetText(#Details, "Each person sits between every possible pair of other people exactly once.")
  SetGadgetText(#Status, message)
  RefreshDrawing()
EndProcedure

Procedure InvalidateGeneration(message.s)
  CurrentJobId + 1
  StopGenerationTimer()
  CancelGeneration(@AppJob)
  DisableGadget(#Cancel, #True)
  ClearDisplay(message)
EndProcedure

Procedure SelectRowItem(item.i)
  Protected index.i, direction.i = 1
  If item < 0 Or item >= CountGadgetItems(#Rows) : ProcedureReturn : EndIf
  index = GetGadgetItemData(#Rows, item) - 1
  If index < 0
    If item < SelectedItem : direction = -1 : EndIf
    Repeat
      item + direction
      If item < 0 Or item >= CountGadgetItems(#Rows)
        SetGadgetState(#Rows, SelectedItem)
        ProcedureReturn
      EndIf
      index = GetGadgetItemData(#Rows, item) - 1
    Until index >= 0
  EndIf
  SelectedItem = item : SelectedRow = index
  SetGadgetState(#Rows, item)
  If GetGadgetState(#Compact)
    SetGadgetText(#SelectedHeading, "Starting row " + Str(AppJob\result\rows[index]\group))
  Else
    SetGadgetText(#SelectedHeading, "Sitting " + Str(index + 1) + " of " + Str(AppJob\result\rowCount))
  EndIf
  SetGadgetText(#SelectedHint, "Start at " + Str(AppJob\result\rows[index]\person[0]) + "; read clockwise.")
  RefreshDrawing()
EndProcedure

Procedure PopulateRows()
  Protected r.i, item.i, lastGroup.i, compact.i = GetGadgetState(#Compact)
  Protected wanted.i = SelectedRow, target.i = -1
  ClearGadgetItems(#Rows)
  If compact : wanted = StartingRowIndex(@AppJob, wanted) : EndIf
  If wanted < 0 : wanted = 0 : EndIf
  For r = 0 To AppJob\result\rowCount - 1
    If compact And StartingRowIndex(@AppJob, r) <> r : Continue : EndIf
    If Not compact And lastGroup <> 0 And lastGroup <> AppJob\result\rows[r]\group
      AddGadgetItem(#Rows, -1, "-------------------- next group --------------------")
      SetGadgetItemData(#Rows, CountGadgetItems(#Rows) - 1, 0)
    EndIf
    lastGroup = AppJob\result\rows[r]\group
    AddGadgetItem(#Rows, -1, FormatSeating(@AppJob\result\rows[r], AppJob\result\people))
    item = CountGadgetItems(#Rows) - 1
    SetGadgetItemData(#Rows, item, r + 1)
    If r = wanted : target = item : EndIf
  Next
  If compact
    SetGadgetText(#RowsHeading, Str(AppJob\groupCount) + " starting rows")
    SetGadgetText(#RowsHint, Str(AppJob\result\rowCount) + " sittings after expansion. Follow the cycles on the right.")
  Else
    SetGadgetText(#RowsHeading, Str(AppJob\result\rowCount) + " sittings for " + Str(AppJob\result\people) + " people")
    SetGadgetText(#RowsHint, "One row per sitting. The last person sits next to the first.")
  EndIf
  If target < 0 : target = 0 : EndIf
  SelectRowItem(target)
EndProcedure

Procedure StartGeneration()
  Protected people.i = ParsePeople(GetGadgetText(#PeopleInput))
  InvalidateGeneration("")
  If people = 0
    SetGadgetText(#Status, "Enter a whole number from 3 to 21.")
    SetActiveGadget(#PeopleInput)
    ProcedureReturn
  EndIf
  If Not BeginGeneration(people, CurrentJobId, @AppJob)
    SetGadgetText(#Status, AppJob\error)
    ProcedureReturn
  EndIf
  DisableGadget(#Cancel, #False)
  SetGadgetText(#Status, "Generating a schedule for " + Str(people) + " people...")
  AddWindowTimer(#MainWindow, #GenerationTimer, 10)
  TimerRunning = #True
EndProcedure

Procedure GenerationTick()
  If AppJob\id <> CurrentJobId Or AppJob\state <> #Running : ProcedureReturn : EndIf
  AdvanceGeneration(@AppJob, 16)
  Select AppJob\state
    Case #Verified
      StopGenerationTimer() : DisableGadget(#Cancel, #True)
      If AppJob\id <> CurrentJobId : ProcedureReturn : EndIf
      PublishedJobId = CurrentJobId
      SetGadgetText(#Status, "Verified: every neighbour pair appears once.")
      DisableGadget(#Compact, Bool(Not AppJob\cyclic))
      SetGadgetText(#DetailsHeading, "How to read this solution")
      SetGadgetText(#Details, ConstructionDetails(@AppJob))
      PopulateRows()
    Case #Failed
      StopGenerationTimer() : DisableGadget(#Cancel, #True)
      ClearDisplay(AppJob\error)
  EndSelect
EndProcedure

Procedure.i HandleWindowEvent(event.i)
  Select event
    Case #PB_Event_CloseWindow
      InvalidateGeneration("")
      ProcedureReturn #False
    Case #PB_Event_SizeWindow
      LayoutWindow()
    Case #PB_Event_Timer
      If EventTimer() = #GenerationTimer : GenerationTick() : EndIf
    Case #PB_Event_Menu
      Select EventMenu()
        Case #ActionGenerate : StartGeneration()
        Case #ActionCancel : InvalidateGeneration("Generation cancelled.")
      EndSelect
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #PeopleInput
          If EventType() = #PB_EventType_Change : InvalidateGeneration("Ready to generate.") : EndIf
        Case #Generate : StartGeneration()
        Case #Cancel : InvalidateGeneration("Generation cancelled.")
        Case #Compact
          If PublishedJobId = CurrentJobId And AppJob\state = #Verified : PopulateRows() : EndIf
        Case #Rows
          If EventType() = #PB_EventType_Change Or EventType() = #PB_EventType_LeftClick
            SelectRowItem(GetGadgetState(#Rows))
          EndIf
      EndSelect
  EndSelect
  ProcedureReturn #True
EndProcedure

Procedure.i OpenApplication()
  Protected gadget.i, appearance.i
  If Not OpenWindow(#MainWindow, 0, 0, 1280, 860, "The Round Table", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
    ProcedureReturn #False
  EndIf
  ; The paper-coloured drawing and window use one consistent light appearance.
  appearance = CocoaMessage(0, 0, "NSAppearance appearanceNamed:$", @"NSAppearanceNameAqua")
  CocoaMessage(0, WindowID(#MainWindow), "setAppearance:", appearance)
  WindowBounds(#MainWindow, 900, 760, #PB_Ignore, #PB_Ignore)
  SetWindowColor(#MainWindow, RGB(248, 247, 244))
  LoadFont(#FontTitle, "Georgia", 31)
  LoadFont(#FontHeading, "Helvetica Neue", 19, #PB_Font_Bold)
  LoadFont(#FontBody, "Helvetica Neue", 15)
  LoadFont(#FontRows, "Menlo", 15)
  LoadFont(#FontNumbers, "Menlo", 14, #PB_Font_Bold)
  TextGadget(#Title, 0, 0, 1, 1, "The Round Table")
  TextGadget(#Subtitle, 0, 0, 1, 1, "H. E. Dudeney's problem 273  /  Amusements in Mathematics")
  TextGadget(#PeopleLabel, 0, 0, 1, 1, "People (3-21)")
  StringGadget(#PeopleInput, 0, 0, 1, 1, "5")
  ButtonGadget(#Generate, 0, 0, 1, 1, "Generate", #PB_Button_Default)
  ButtonGadget(#Cancel, 0, 0, 1, 1, "Cancel")
  TextGadget(#Status, 0, 0, 1, 1, "")
  TextGadget(#RowsHeading, 0, 0, 1, 1, "")
  TextGadget(#RowsHint, 0, 0, 1, 1, "")
  CheckBoxGadget(#Compact, 0, 0, 1, 1, "Starting rows")
  ListIconGadget(#Rows, 0, 0, 1, 1, "Seating order", 700, #PB_ListIcon_NoHeaders)
  TextGadget(#SelectedHeading, 0, 0, 1, 1, "")
  TextGadget(#SelectedHint, 0, 0, 1, 1, "")
  CanvasGadget(#Table, 0, 0, 1, 1)
  TextGadget(#DetailsHeading, 0, 0, 1, 1, "")
  TextGadget(#Details, 0, 0, 1, 1, "")
  For gadget = #Title To #Details : SetGadgetFont(gadget, FontID(#FontBody)) : Next
  SetGadgetFont(#Title, FontID(#FontTitle))
  SetGadgetFont(#RowsHeading, FontID(#FontHeading))
  SetGadgetFont(#SelectedHeading, FontID(#FontHeading))
  SetGadgetFont(#DetailsHeading, FontID(#FontHeading))
  SetGadgetFont(#Rows, FontID(#FontRows))
  GadgetToolTip(#PeopleInput, "Enter the number of distinct people, from 3 to 21.")
  GadgetToolTip(#Compact, "Show starting rows and the cycles that expand them into the full schedule.")
  GadgetToolTip(#Rows, "Each row wraps around: its last and first people are neighbours.")
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #ActionGenerate)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Escape, #ActionCancel)
  ClearDisplay("")
  LayoutWindow()
  SetActiveGadget(#PeopleInput)
  StartGeneration()
  ProcedureReturn #True
EndProcedure
