XIncludeFile "model.pbi"
XIncludeFile "verify.pbi"
XIncludeFile "constructions.pbi"

Procedure FailGeneration(*job.GenerationJob, message.s)
  *job\state = #Failed
  *job\error = message
  *job\result\rowCount = 0
EndProcedure

Procedure.i LoadConstruction(*job.GenerationJob)
  Protected order.i, groups.i, period.i, i.i, g.i, discard.i
  Restore StarterData
  Repeat
    Read.i order
    If order = 0 : ProcedureReturn #False : EndIf
    Read.i groups : Read.i period
    If order <> *job\result\people
      For i = 1 To order * (groups + 1) : Read.i discard : Next
    Else
      *job\cyclic = #True : *job\groupCount = groups : *job\period = period
      For i = 1 To order : Read.i *job\successor[i] : Next
      For g = 0 To groups - 1
        For i = 0 To order - 1 : Read.i *job\starters[g]\person[i] : Next
        *job\starters[g]\group = g + 1
      Next
      *job\totalCandidates = groups * period
      ProcedureReturn #True
    EndIf
  ForEver
EndProcedure

Procedure.i BeginGeneration(people.i, jobId.i, *job.GenerationJob)
  ResetStructure(*job, GenerationJob)
  *job\id = jobId
  *job\state = #Failed
  If people < #MinimumPeople Or people > #MaximumPeople
    *job\error = "Enter a whole number from 3 to 21."
    ProcedureReturn #False
  EndIf
  *job\result\people = people
  If Not LoadConstruction(*job)
    If Not PrepareProjective(*job)
      FailGeneration(*job, "The construction could not be prepared.")
      ProcedureReturn #False
    EndIf
    *job\totalCandidates = (people - 1) * (people - 2)
  EndIf
  *job\state = #Running
  ProcedureReturn #True
EndProcedure

Procedure.i AdvanceGeneration(*job.GenerationJob, maxCandidates.i)
  Protected n.i = *job\result\people, q.i = n - 1, budget.i, group.i, turn.i
  Protected s.i, t.i, i.i, j.i, reverse.i, key.s, index.i, candidate.SeatingRow
  If *job\state <> #Running : ProcedureReturn *job\state : EndIf
  If maxCandidates > 16 : maxCandidates = 16 : EndIf
  For budget = 1 To maxCandidates
    If *job\cursor >= *job\totalCandidates : Break : EndIf
    key = ""
    If *job\cyclic
      group = *job\cursor / *job\period
      turn = Mod(*job\cursor, *job\period)
      CopyStructure(@*job\starters[group], @candidate, SeatingRow)
      For j = 1 To turn
        For i = 0 To n - 1
          candidate\person[i] = *job\successor[candidate\person[i]]
        Next
      Next
    Else
      s = *job\cursor / q + 1 : t = Mod(*job\cursor, q)
      candidate\person[0] = n : candidate\group = s
      For i = 1 To q
        candidate\person[i] = *job\addTable(*job\multiplyTable(s, *job\seed[i]), t) + 1
      Next
      reverse = 0
      For i = 1 To q
        If candidate\person[i] < candidate\person[n - i] : Break : EndIf
        If candidate\person[i] > candidate\person[n - i] : reverse = 1 : Break : EndIf
      Next
      key = Str(n) + ","
      For i = 1 To q
        If reverse : key + Str(candidate\person[n - i]) + "," : Else : key + Str(candidate\person[i]) + "," : EndIf
      Next
    EndIf
    *job\cursor + 1
    If *job\cyclic Or Not FindMapElement(*job\seen(), key)
      If Not *job\cyclic : AddMapElement(*job\seen(), key) : EndIf
      index = *job\result\rowCount
      If index >= #MaximumSittings
        FailGeneration(*job, "The construction produced too many sittings.")
        ProcedureReturn *job\state
      EndIf
      CopyStructure(@candidate, @*job\result\rows[index], SeatingRow)
      *job\result\rowCount + 1
    EndIf
  Next
  If *job\cursor = *job\totalCandidates
    If VerifySchedule(@*job\result)
      *job\state = #Verified
    Else
      FailGeneration(*job, "The generated schedule failed verification.")
    EndIf
  EndIf
  ProcedureReturn *job\state
EndProcedure

Procedure CancelGeneration(*job.GenerationJob)
  If *job\state = #Running
    *job\state = #Cancelled
    *job\result\rowCount = 0
    ClearMap(*job\seen())
  EndIf
EndProcedure
