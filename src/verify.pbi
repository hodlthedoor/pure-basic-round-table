Procedure.i VerifySchedule(*schedule.Schedule)
  Protected n.i = *schedule\people, r.i, i.i, person.i, left.i, right.i, before.i, after.i
  Protected Dim pairs.b(21, 21, 21)
  Protected Dim present.b(21)
  If n < #MinimumPeople Or n > #MaximumPeople : ProcedureReturn #False : EndIf
  If *schedule\rowCount <> (n - 1) * (n - 2) / 2 : ProcedureReturn #False : EndIf
  For r = 0 To *schedule\rowCount - 1
    For person = 1 To n : present(person) = 0 : Next
    For i = 0 To n - 1
      person = *schedule\rows[r]\person[i]
      If person < 1 Or person > n : ProcedureReturn #False : EndIf
      If present(person) : ProcedureReturn #False : EndIf
      present(person) = 1
    Next
    For i = 0 To n - 1
      person = *schedule\rows[r]\person[i]
      before = Mod(i + n - 1, n) : after = Mod(i + 1, n)
      left = *schedule\rows[r]\person[before]
      right = *schedule\rows[r]\person[after]
      If left > right : Swap left, right : EndIf
      If pairs(person, left, right) : ProcedureReturn #False : EndIf
      pairs(person, left, right) = 1
    Next
  Next
  ; Verify coverage directly, independently of the construction's groups.
  For person = 1 To n
    For left = 1 To n
      For right = left + 1 To n
        If left <> person And right <> person And pairs(person, left, right) = 0
          ProcedureReturn #False
        EndIf
      Next
    Next
  Next
  ProcedureReturn #True
EndProcedure
