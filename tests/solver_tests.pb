XIncludeFile "../src/model.pbi"
XIncludeFile "../src/input.pbi"
XIncludeFile "../src/verify.pbi"
XIncludeFile "../src/solver.pbi"
XIncludeFile "../src/presentation.pbi"

Global Checks.i, Failures.i

Procedure Check(condition.i, message.s)
  Checks + 1
  If Not condition
    Failures + 1
    PrintN("FAIL: " + message)
  EndIf
EndProcedure

Procedure SetRow(*schedule.Schedule, index.i, text.s)
  Protected i.i
  For i = 0 To *schedule\people - 1
    *schedule\rows[index]\person[i] = Val(StringField(text, i + 1, " "))
  Next
EndProcedure

Procedure FivePeople(*schedule.Schedule)
  ResetStructure(*schedule, Schedule)
  *schedule\people = 5 : *schedule\rowCount = 6
  SetRow(*schedule, 0, "1 2 3 4 5")
  SetRow(*schedule, 1, "1 2 4 5 3")
  SetRow(*schedule, 2, "1 2 5 3 4")
  SetRow(*schedule, 3, "1 3 2 5 4")
  SetRow(*schedule, 4, "1 4 2 3 5")
  SetRow(*schedule, 5, "1 5 2 4 3")
EndProcedure

Procedure TestVerification()
  Protected sample.Schedule, row.i, i.i, temp.i
  sample\people = 3 : sample\rowCount = 1
  SetRow(@sample, 0, "1 2 3")
  Check(VerifySchedule(@sample), "three people")
  sample\people = 4 : sample\rowCount = 3
  SetRow(@sample, 0, "1 2 3 4")
  SetRow(@sample, 1, "1 3 4 2")
  SetRow(@sample, 2, "1 4 2 3")
  Check(VerifySchedule(@sample), "four people")
  FivePeople(@sample)
  Check(VerifySchedule(@sample), "author's five-person solution")
  For row = 0 To 5
    For i = 0 To 1
      Swap sample\rows[row]\person[i], sample\rows[row]\person[4 - i]
    Next
    temp = sample\rows[row]\person[0]
    For i = 0 To 3 : sample\rows[row]\person[i] = sample\rows[row]\person[i + 1] : Next
    sample\rows[row]\person[4] = temp
  Next
  Check(VerifySchedule(@sample), "rotations and reversals preserve validity")
  sample\rowCount = 5
  Check(Bool(Not VerifySchedule(@sample)), "missing sitting")
  sample\rowCount = 7
  Check(Bool(Not VerifySchedule(@sample)), "extra sitting")
  FivePeople(@sample) : sample\rows[0]\person[4] = 6
  Check(Bool(Not VerifySchedule(@sample)), "out-of-range person")
  FivePeople(@sample) : sample\rows[0]\person[4] = 4
  Check(Bool(Not VerifySchedule(@sample)), "duplicate person")
  FivePeople(@sample) : SetRow(@sample, 5, "5 4 3 2 1")
  Check(Bool(Not VerifySchedule(@sample)), "reversed duplicate sitting")
  sample\people = 4 : sample\rowCount = 3
  SetRow(@sample, 0, "1 2 3 4")
  SetRow(@sample, 1, "1 2 4 3")
  SetRow(@sample, 2, "2 1 3 4")
  Check(Bool(Not VerifySchedule(@sample)), "wraparound neighbour collision")
  sample\people = 22
  Check(Bool(Not VerifySchedule(@sample)), "out-of-range schedule")
EndProcedure

Procedure TestInput()
  Check(Bool(ParsePeople("3") = 3), "minimum input")
  Check(Bool(ParsePeople("21") = 21), "maximum input")
  Check(Bool(ParsePeople(" 5 ") = 5), "surrounding spaces")
  Check(Bool(ParsePeople("005") = 5), "leading zeros")
  Check(Bool(ParsePeople(Chr(9) + "5" + Chr(10)) = 5), "surrounding whitespace")
  Check(Bool(ParsePeople("") = 0), "blank input")
  Check(Bool(ParsePeople("   ") = 0), "whitespace input")
  Check(Bool(ParsePeople("2") = 0 And ParsePeople("22") = 0), "outside range")
  Check(Bool(ParsePeople("-1") = 0 And ParsePeople("+5") = 0), "signs")
  Check(Bool(ParsePeople("3.5") = 0 And ParsePeople("3abc") = 0), "partial numeric strings")
  Check(Bool(ParsePeople(RSet("", 100, "9")) = 0), "oversized number")
EndProcedure

Procedure CompleteJob(*job.GenerationJob)
  Protected attempts.i
  While *job\state = #Running And attempts < 1000
    AdvanceGeneration(*job, 16)
    attempts + 1
  Wend
EndProcedure

Procedure TestGeneration()
  Protected job.GenerationJob, previous.Schedule, n.i, r.i, i.i, group.i
  For n = 3 To 21
    Check(BeginGeneration(n, n, @job), "begin " + Str(n))
    CompleteJob(@job)
    Check(Bool(job\state = #Verified And VerifySchedule(@job\result)), "verified complete schedule " + Str(n))
    If job\state = #Verified
      Select n
        Case 3 : Check(Bool(job\result\rowCount = 1), "one sitting for 3")
        Case 5 : Check(Bool(job\result\rowCount = 6), "six sittings for 5")
        Case 13 : Check(Bool(job\result\rowCount = 66), "66 sittings for 13")
        Case 21 : Check(Bool(job\result\rowCount = 190), "190 sittings for 21")
      EndSelect
      If job\cyclic
        For r = 1 To job\result\rowCount - 1
          If job\result\rows[r]\group = job\result\rows[r - 1]\group
            For i = 0 To n - 1
              Check(Bool(job\result\rows[r]\person[i] = job\successor[job\result\rows[r - 1]\person[i]]), "cycle expansion " + Str(n))
            Next
          EndIf
        Next
      EndIf
    EndIf
  Next
  BeginGeneration(21, 100, @job) : CompleteJob(@job)
  CopyStructure(@job\result, @previous, Schedule)
  BeginGeneration(3, 101, @job) : CompleteJob(@job)
  Check(VerifySchedule(@job\result), "21 then 3")
  BeginGeneration(17, 102, @job) : CompleteJob(@job)
  Check(VerifySchedule(@job\result), "3 then 17")
  BeginGeneration(5, 103, @job) : CompleteJob(@job)
  Check(VerifySchedule(@job\result), "17 then 5")
  BeginGeneration(21, 104, @job) : CompleteJob(@job)
  Check(Bool(CompareMemory(@previous, @job\result, SizeOf(Schedule))), "repeat jobs are deterministic with fresh state")
  Check(Bool(Not BeginGeneration(22, 105, @job)), "reject unsupported job")
  Check(Bool(job\state = #Failed And job\result\rowCount = 0), "invalid job cannot expose old result")
EndProcedure

Procedure TestCancellation()
  Protected job.GenerationJob
  BeginGeneration(21, 1, @job) : CancelGeneration(@job)
  Check(Bool(AdvanceGeneration(@job, 16) = #Cancelled And job\result\rowCount = 0), "cancel before first batch")
  BeginGeneration(21, 2, @job) : AdvanceGeneration(@job, 1)
  Check(Bool(job\state = #Running And job\result\rowCount = 1), "one candidate batch")
  CancelGeneration(@job)
  Check(Bool(AdvanceGeneration(@job, 16) = #Cancelled And job\result\rowCount = 0), "cancel partial result")
  BeginGeneration(5, 3, @job) : CompleteJob(@job)
  Check(Bool(job\id = 3 And job\state = #Verified And job\result\people = 5), "replacement job")
  BeginGeneration(21, 4, @job) : AdvanceGeneration(@job, 0)
  Check(Bool(job\state = #Running And job\result\rowCount = 0), "zero budget does not advance")
  AdvanceGeneration(@job, 1000)
  Check(Bool(job\state = #Running And job\cursor <= 16), "batch budget is capped")
  ; Damage construction data before completion; final verification must reject it.
  BeginGeneration(21, 5, @job)
  job\starters[0]\person[0] = job\starters[0]\person[1]
  CompleteJob(@job)
  Check(Bool(job\state = #Failed And job\result\rowCount = 0), "verification failure cannot publish partial rows")
EndProcedure

Procedure TestPresentation()
  Protected sample.Schedule, job.GenerationJob, text.s
  FivePeople(@sample)
  Check(Bool(FormatSeating(@sample\rows[0], 5) = " 1  2  3  4  5"), "aligned author-style row")
  BeginGeneration(21, 1, @job) : CompleteJob(@job)
  text = FormatSeating(@job\result\rows[0], 21)
  Check(Bool(Len(text) = 62 And CountString(text, "21") = 1), "21 columns retain two-digit alignment")
  Check(Bool(StartingRowIndex(@job, 37) = 19), "expanded row maps to compact group's first sitting")
  Check(Bool(StartingRowIndex(@job, 189) = 171), "last group maps correctly")
  Check(Bool(StartingRowIndex(@job, -1) = -1 And StartingRowIndex(@job, 190) = -1), "invalid selections rejected")
EndProcedure

OpenConsole()
TestVerification()
TestInput()
TestGeneration()
TestCancellation()
TestPresentation()
PrintN(Str(Checks) + " checks, " + Str(Failures) + " failures")
If Failures : End 1 : EndIf
End 0
