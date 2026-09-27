Procedure.i ParsePeople(text.s)
  Protected first.i = 1, last.i = Len(text), i.i, character.i, number.i
  While first <= last
    character = Asc(Mid(text, first, 1))
    If character <> 32 And (character < 9 Or character > 13) : Break : EndIf
    first + 1
  Wend
  While last >= first
    character = Asc(Mid(text, last, 1))
    If character <> 32 And (character < 9 Or character > 13) : Break : EndIf
    last - 1
  Wend
  If first > last : ProcedureReturn 0 : EndIf
  For i = first To last
    character = Asc(Mid(text, i, 1))
    If character < 48 Or character > 57 : ProcedureReturn 0 : EndIf
    number = number * 10 + character - 48
    If number > #MaximumPeople : ProcedureReturn 0 : EndIf
  Next
  If number < #MinimumPeople : ProcedureReturn 0 : EndIf
  ProcedureReturn number
EndProcedure
