Procedure DrawSeating(canvas.i, *row.SeatingRow, people.i)
  Protected width.i = GadgetWidth(canvas), height.i = GadgetHeight(canvas)
  Protected centreX.d = width / 2.0, centreY.d = height / 2.0
  Protected orbit.d, angle.d, x.i, y.i, i.i, text.s, marker.i = 16
  Protected ink.i = RGB(33, 55, 63), paper.i = RGB(248, 247, 244)
  If Not StartDrawing(CanvasOutput(canvas)) : ProcedureReturn : EndIf
  Box(0, 0, width, height, paper)
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(#FontBody))
  If *row = 0 Or people < 3
    text = "Generate a solution to see the table."
    DrawText((width - TextWidth(text)) / 2, centreY - 10, text, RGB(110, 117, 116))
    StopDrawing()
    ProcedureReturn
  EndIf
  orbit = width
  If height < orbit : orbit = height : EndIf
  orbit = orbit / 2 - 24
  Circle(centreX, centreY, orbit - 32, RGB(234, 225, 207))
  DrawingMode(#PB_2DDrawing_Outlined)
  Circle(centreX, centreY, orbit - 32, RGB(214, 200, 178))
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(#FontHeading))
  text = Str(people) + " people"
  DrawText(centreX - TextWidth(text) / 2, centreY - 14, text, ink)
  DrawingFont(FontID(#FontBody))
  text = "around the table"
  DrawText(centreX - TextWidth(text) / 2, centreY + 13, text, RGB(105, 102, 90))
  For i = 0 To people - 1
    angle = -#PI / 2 + 2 * #PI * i / people
    x = centreX + orbit * Cos(angle) : y = centreY + orbit * Sin(angle)
    DrawingMode(#PB_2DDrawing_Default)
    If i = 0
      Circle(x, y, marker, ink)
    Else
      Circle(x, y, marker, RGB(255, 255, 255))
      DrawingMode(#PB_2DDrawing_Outlined)
      Circle(x, y, marker, RGB(162, 175, 173))
    EndIf
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(#FontNumbers))
    text = Str(*row\person[i])
    If i = 0
      DrawText(x - TextWidth(text) / 2, y - TextHeight(text) / 2, text, RGB(255, 255, 255))
    Else
      DrawText(x - TextWidth(text) / 2, y - TextHeight(text) / 2, text, ink)
    EndIf
  Next
  StopDrawing()
EndProcedure
