; Finite-field construction: Nakamura, Kiyasu-Zen'iti and Ikeno (1980), pp. 7-10.
; See docs/references/solver-feasibility.md for provenance and checked coverage.

Procedure BuildField(q.i, *job.GenerationJob)
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
      *job\addTable(a, b) = 0
      For i = 0 To degree - 1
        *job\addTable(a, b) + Mod(coefficient(a, i) + coefficient(b, i), p) * powers(i)
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
      *job\multiplyTable(a, b) = value
    Next
  Next
  For a = 1 To q - 1
    For b = 1 To q - 1
      If *job\multiplyTable(a, b) = 1 : *job\inverse[a] = b : Break : EndIf
    Next
  Next
EndProcedure

Procedure.i PrepareProjective(*job.GenerationJob)
  Protected n.i = *job\result\people, q.i = n - 1
  Protected a.i, b.i, x.i, length.i, found.i, i.i, denominator.i
  Protected Dim seen.i(20)
  BuildField(q, *job)
  For a = 0 To q - 1
    For b = 1 To q - 1
      For i = 0 To q : seen(i) = 0 : Next
      length = 0 : x = q
      While seen(x) = 0
        seen(x) = 1 : *job\seed[length] = x : length + 1
        If x = q
          x = *job\multiplyTable(a, *job\inverse[b])
        ElseIf x = 0
          x = q
        Else
          denominator = *job\multiplyTable(b, x)
          x = *job\multiplyTable(*job\addTable(*job\multiplyTable(a, x), 1), *job\inverse[denominator])
        EndIf
      Wend
      If length = n And x = q : found = 1 : Break : EndIf
    Next
    If found : Break : EndIf
  Next
  ProcedureReturn found
EndProcedure

; Static numerical construction data; source labels have been converted to 1..n.
; n=7,11: Dudeney, Amusements in Mathematics, solution 273 (1917).
; n=13,15,16,19,21: Nakamura, Kiyasu-Zen'iti & Ikeno (1980), pp. 17-19.
; https://rikkyo.repo.nii.ac.jp/record/10276/files/AA00610867_29-01_02.pdf
; Format: n, group count, cycle period, successor[1..n], starting rows.
; These are 49 starting rows, not complete schedules.
DataSection
  StarterData:
  Data.i 7, 5, 3
  Data.i 1, 3, 4, 2, 6, 7, 5
  Data.i 1, 2, 3, 4, 5, 7, 6
  Data.i 1, 6, 2, 7, 5, 3, 4
  Data.i 1, 3, 5, 2, 6, 7, 4
  Data.i 1, 5, 7, 4, 3, 6, 2
  Data.i 1, 5, 2, 7, 3, 4, 6
  Data.i 11, 5, 9
  Data.i 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 3
  Data.i 2, 11, 9, 4, 7, 6, 5, 1, 8, 3, 10
  Data.i 2, 1, 11, 7, 6, 3, 10, 8, 5, 4, 9
  Data.i 2, 11, 10, 3, 9, 4, 8, 5, 1, 7, 6
  Data.i 2, 11, 5, 8, 1, 3, 10, 6, 7, 9, 4
  Data.i 2, 11, 1, 10, 3, 4, 9, 6, 7, 5, 8
  Data.i 13, 6, 11
  Data.i 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 3
  Data.i 1, 3, 2, 5, 12, 7, 10, 9, 8, 11, 6, 13, 4
  Data.i 1, 3, 6, 11, 9, 8, 12, 5, 4, 13, 2, 7, 10
  Data.i 1, 3, 7, 10, 11, 6, 4, 13, 8, 9, 2, 12, 5
  Data.i 1, 3, 9, 8, 2, 4, 13, 10, 7, 5, 12, 11, 6
  Data.i 1, 3, 5, 12, 6, 11, 2, 10, 7, 13, 4, 8, 9
  Data.i 1, 3, 4, 13, 5, 12, 9, 8, 10, 7, 11, 6, 2
  Data.i 15, 7, 13
  Data.i 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 3
  Data.i 2, 3, 4, 15, 5, 14, 6, 13, 7, 12, 8, 11, 9, 10, 1
  Data.i 2, 3, 1, 4, 15, 7, 12, 14, 5, 8, 11, 13, 6, 9, 10
  Data.i 2, 3, 12, 7, 10, 9, 8, 11, 6, 13, 4, 15, 1, 5, 14
  Data.i 2, 3, 10, 9, 4, 15, 11, 8, 7, 12, 5, 14, 1, 6, 13
  Data.i 2, 3, 6, 13, 1, 7, 12, 10, 9, 15, 4, 5, 14, 8, 11
  Data.i 2, 3, 14, 5, 10, 9, 13, 6, 7, 12, 1, 8, 11, 4, 15
  Data.i 2, 3, 8, 11, 1, 9, 10, 14, 5, 6, 13, 15, 4, 7, 12
  Data.i 16, 7, 15
  Data.i 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 2
  Data.i 1, 2, 15, 4, 13, 6, 11, 8, 9, 10, 7, 12, 5, 14, 3, 16
  Data.i 1, 3, 14, 7, 10, 6, 11, 5, 12, 9, 8, 13, 4, 2, 15, 16
  Data.i 1, 4, 13, 3, 14, 2, 15, 6, 11, 10, 7, 9, 8, 12, 5, 16
  Data.i 1, 5, 12, 13, 4, 6, 11, 14, 3, 7, 10, 15, 2, 8, 9, 16
  Data.i 1, 6, 11, 12, 5, 7, 10, 2, 15, 8, 9, 3, 14, 13, 4, 16
  Data.i 1, 7, 2, 12, 8, 6, 3, 11, 9, 5, 15, 14, 10, 4, 13, 16
  Data.i 1, 8, 9, 11, 6, 14, 3, 2, 15, 5, 12, 4, 13, 10, 7, 16
  Data.i 19, 9, 17
  Data.i 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 3
  Data.i 2, 3, 1, 4, 19, 15, 8, 13, 10, 9, 14, 7, 16, 18, 5, 6, 17, 11, 12
  Data.i 2, 3, 6, 17, 9, 14, 12, 11, 15, 8, 1, 16, 7, 19, 4, 5, 18, 10, 13
  Data.i 2, 3, 8, 15, 17, 6, 1, 18, 5, 16, 7, 10, 13, 19, 4, 11, 12, 9, 14
  Data.i 2, 3, 10, 13, 17, 6, 7, 16, 14, 9, 4, 19, 1, 5, 18, 12, 11, 8, 15
  Data.i 2, 3, 12, 11, 1, 13, 10, 5, 18, 14, 9, 6, 17, 19, 4, 15, 8, 7, 16
  Data.i 2, 3, 14, 9, 1, 15, 8, 18, 5, 12, 11, 19, 4, 7, 16, 10, 13, 6, 17
  Data.i 2, 3, 16, 7, 12, 11, 6, 17, 4, 19, 9, 14, 1, 10, 13, 15, 8, 5, 18
  Data.i 2, 3, 18, 5, 14, 9, 8, 15, 6, 17, 1, 7, 16, 12, 11, 10, 13, 4, 19
  Data.i 2, 3, 4, 19, 5, 18, 6, 17, 7, 16, 8, 15, 9, 14, 10, 13, 11, 12, 1
  Data.i 21, 10, 19
  Data.i 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 2, 21
  Data.i 1, 20, 3, 18, 5, 16, 4, 17, 6, 15, 8, 13, 10, 11, 12, 9, 21, 7, 14, 19, 2
  Data.i 1, 20, 11, 10, 21, 6, 15, 12, 9, 14, 7, 16, 5, 13, 8, 2, 19, 4, 17, 18, 3
  Data.i 1, 20, 5, 16, 9, 12, 13, 8, 17, 4, 2, 19, 6, 15, 10, 11, 14, 7, 18, 3, 21
  Data.i 1, 20, 7, 14, 13, 8, 19, 2, 6, 15, 21, 12, 9, 18, 3, 5, 16, 11, 10, 17, 4
  Data.i 1, 20, 9, 12, 17, 4, 6, 15, 14, 7, 3, 18, 11, 10, 19, 2, 21, 8, 13, 16, 5
  Data.i 1, 20, 21, 11, 10, 2, 19, 12, 9, 3, 18, 13, 8, 4, 17, 14, 7, 5, 16, 15, 6
  Data.i 1, 20, 13, 8, 6, 15, 18, 3, 11, 10, 4, 17, 16, 5, 9, 12, 2, 19, 21, 14, 7
  Data.i 1, 20, 15, 6, 10, 11, 5, 16, 19, 2, 14, 7, 9, 12, 4, 17, 21, 18, 3, 13, 8
  Data.i 1, 20, 17, 4, 14, 7, 11, 10, 8, 13, 21, 5, 16, 2, 19, 18, 3, 15, 6, 12, 9
  Data.i 1, 20, 19, 2, 18, 3, 17, 4, 21, 16, 5, 15, 6, 14, 7, 13, 8, 12, 9, 11, 10
  Data.i 0
EndDataSection
