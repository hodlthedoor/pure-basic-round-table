; Feasibility probe only. Algorithm: Nakamura et al. (1980), pp. 7-10,
; plus attributed compact starters in starters.py. No production GUI code.
EnableExplicit

Global Dim AddTable.i(20, 20)
Global Dim MultiplyTable.i(20, 20)
Global Dim Inverse.i(20)
Global Dim Schedule.i(189, 20)
Global RowCount.i

Procedure BuildField(q.i)
  Protected p.i, degree.i, a.i, b.i, i.i, j.i, digit.i, value.i
  Protected Dim coefficient.i(20, 4)
  Protected Dim polynomial.i(4)
  Protected Dim powers.i(4)
  Protected Dim product.i(8)
  Select q
    Case 4 : p = 2 : degree = 2
    Case 8 : p = 2 : degree = 3
    Case 9 : p = 3 : degree = 2
    Case 16 : p = 2 : degree = 4
    Default : p = q : degree = 1
  EndSelect
  powers(0) = 1
  For i = 1 To degree
    powers(i) = powers(i - 1) * p
  Next
  polynomial(0) = 1
  If p = 2 And degree > 1 : polynomial(1) = 1 : EndIf
  polynomial(degree) = 1
  For a = 0 To q - 1
    For i = 0 To degree - 1
      digit = a / powers(i)
      coefficient(a, i) = Mod(digit, p)
    Next
  Next
  For a = 0 To q - 1
    For b = 0 To q - 1
      AddTable(a, b) = 0
      For i = 0 To degree - 1
        AddTable(a, b) + Mod(coefficient(a, i) + coefficient(b, i), p) * powers(i)
      Next
      For i = 0 To 8 : product(i) = 0 : Next
      For i = 0 To degree - 1
        For j = 0 To degree - 1
          product(i + j) + coefficient(a, i) * coefficient(b, j)
        Next
      Next
      For j = 2 * degree - 2 To degree Step -1
        For i = 0 To degree - 1
          product(j - degree + i) - product(j) * polynomial(i)
        Next
      Next
      value = 0
      For i = 0 To degree - 1
        value + Mod(Mod(product(i), p) + p, p) * powers(i)
      Next
      MultiplyTable(a, b) = value
    Next
  Next
  For a = 1 To q - 1
    For b = 1 To q - 1
      If MultiplyTable(a, b) = 1 : Inverse(a) = b : Break : EndIf
    Next
  Next
EndProcedure

Procedure.i GenerateProjective(n.i)
  Protected q.i = n - 1, a.i, b.i, x.i, length.i, found.i
  Protected s.i, t.i, i.i, reverse.i, key.s
  Protected Dim seed.i(20)
  Protected Dim seen.i(20)
  Protected Dim candidate.i(20)
  Protected NewMap used.i()
  BuildField(q)
  For a = 0 To q - 1
    For b = 1 To q - 1
      For i = 0 To q : seen(i) = 0 : Next
      length = 0 : x = q
      While seen(x) = 0
        seen(x) = 1 : seed(length) = x : length + 1
        If x = q
          x = MultiplyTable(a, Inverse(b))
        ElseIf x = 0
          x = q
        Else
          x = MultiplyTable(AddTable(MultiplyTable(a, x), 1), Inverse(MultiplyTable(b, x)))
        EndIf
      Wend
      If length = n And x = q : found = 1 : Break : EndIf
    Next
    If found : Break : EndIf
  Next
  If Not found : ProcedureReturn 0 : EndIf
  For s = 1 To q - 1
    For t = 0 To q - 1
      candidate(0) = n
      For i = 1 To q
        candidate(i) = AddTable(MultiplyTable(s, seed(i)), t) + 1
      Next
      reverse = 0
      For i = 1 To q
        If candidate(i) < candidate(n - i) : Break : EndIf
        If candidate(i) > candidate(n - i) : reverse = 1 : Break : EndIf
      Next
      key = Str(n) + ","
      For i = 1 To q
        If reverse : key + Str(candidate(n - i)) + "," : Else : key + Str(candidate(i)) + "," : EndIf
      Next
      If Not FindMapElement(used(), key)
        AddMapElement(used(), key)
        If RowCount > 189 : ProcedureReturn 0 : EndIf
        For i = 0 To q : Schedule(RowCount, i) = candidate(i) : Next
        RowCount + 1
      EndIf
    Next
  Next
  ProcedureReturn 1
EndProcedure

Procedure.i GenerateStarters(n.i)
  Protected order.i, groups.i, period.i, i.i, g.i, turn.i, discard.i
  Protected Dim successor.i(21)
  Protected Dim row.i(20)
  Restore StarterData
  Repeat
    Read.i order
    If order = 0 : ProcedureReturn 0 : EndIf
    Read.i groups : Read.i period
    If order <> n
      For i = 1 To order * (groups + 1) : Read.i discard : Next
    Else
      For i = 1 To n : Read.i successor(i) : Next
      For g = 1 To groups
        For i = 0 To n - 1 : Read.i row(i) : Next
        For turn = 1 To period
          For i = 0 To n - 1
            Schedule(RowCount, i) = row(i)
            row(i) = successor(row(i))
          Next
          RowCount + 1
        Next
      Next
      ProcedureReturn 1
    EndIf
  ForEver
EndProcedure

Define input.s, n.i, i.i, r.i, line.s
If CountProgramParameters() <> 1 : End 1 : EndIf
input = Trim(ProgramParameter())
If Len(input) = 0 : End 1 : EndIf
For i = 1 To Len(input)
  If Mid(input, i, 1) < "0" Or Mid(input, i, 1) > "9" : End 1 : EndIf
Next
While Len(input) > 1 And Left(input, 1) = "0" : input = Mid(input, 2) : Wend
If Len(input) > 2 : End 1 : EndIf
n = Val(input)
If n < 3 Or n > 21 : End 1 : EndIf
Select n
  Case 7, 11, 13, 15, 16, 19, 21
    If Not GenerateStarters(n) : End 2 : EndIf
  Default
    If Not GenerateProjective(n) : End 2 : EndIf
EndSelect
If RowCount <> (n - 1) * (n - 2) / 2 : End 2 : EndIf
OpenConsole()
For r = 0 To RowCount - 1
  line = ""
  For i = 0 To n - 1
    If i > 0 : line + " " : EndIf
    line + Str(Schedule(r, i))
  Next
  PrintN(line)
Next
End 0

IncludeFile "build/starter_data.pbi"
