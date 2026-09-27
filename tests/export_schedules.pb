XIncludeFile "../src/solver.pbi"
Define job.GenerationJob, n.i, r.i, i.i, line.s
OpenConsole()
For n = 3 To 21
  If Not BeginGeneration(n, n, @job) : End 1 : EndIf
  While job\state = #Running : AdvanceGeneration(@job, 16) : Wend
  If job\state <> #Verified : End 1 : EndIf
  PrintN("# " + Str(n))
  For r = 0 To job\result\rowCount - 1
    line = ""
    For i = 0 To n - 1
      If i : line + " " : EndIf
      line + Str(job\result\rows[r]\person[i])
    Next
    PrintN(line)
  Next
Next
