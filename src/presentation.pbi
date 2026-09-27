Procedure.s FormatSeating(*row.SeatingRow, people.i)
  Protected text.s, i.i
  For i = 0 To people - 1
    If i : text + " " : EndIf
    text + RSet(Str(*row\person[i]), 2, " ")
  Next
  ProcedureReturn text
EndProcedure

Procedure.i StartingRowIndex(*job.GenerationJob, rowIndex.i)
  If *job\state <> #Verified Or rowIndex < 0 Or rowIndex >= *job\result\rowCount
    ProcedureReturn -1
  EndIf
  If *job\cyclic : ProcedureReturn rowIndex - Mod(rowIndex, *job\period) : EndIf
  ProcedureReturn rowIndex
EndProcedure

Procedure.s ConstructionDetails(*job.GenerationJob)
  Protected text.s, fixed.s, cycle.s, i.i, person.i, arrow.s = " " + Chr(8594) + " "
  Protected Dim visited.b(21)
  If Not *job\cyclic
    ProcedureReturn "An algebraic relabelling rule generates this schedule. Reversed duplicates are removed." + #LF$ + #LF$ + "Every person sits between each possible pair of neighbours exactly once."
  EndIf
  For i = 1 To *job\result\people
    If *job\successor[i] = i
      If fixed <> "" : fixed + ", " : EndIf
      fixed + Str(i) : visited(i) = 1
    EndIf
  Next
  text = "Fixed labels: " + fixed + "." + #LF$
  For i = 1 To *job\result\people
    If Not visited(i)
      person = i : cycle = Str(i)
      Repeat
        visited(person) = 1
        person = *job\successor[person]
        cycle + arrow + Str(person)
      Until person = i
      text + "Cycle: " + cycle + #LF$
    EndIf
  Next
  ProcedureReturn text + #LF$ + "Advance all cycles together. Each starting row gives " + Str(*job\period) + " sittings."
EndProcedure
