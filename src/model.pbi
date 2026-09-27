EnableExplicit

#MinimumPeople = 3
#MaximumPeople = 21
#MaximumSittings = 190
#MaximumStartingRows = 12

Enumeration
  #Idle
  #Running
  #Verified
  #Cancelled
  #Failed
EndEnumeration

Structure SeatingRow
  person.i[21]
  group.i
EndStructure

Structure Schedule
  people.i
  rowCount.i
  rows.SeatingRow[190]
EndStructure

Structure GenerationJob
  id.i
  state.i
  result.Schedule
  cyclic.i
  groupCount.i
  period.i
  starters.SeatingRow[#MaximumStartingRows]
  successor.i[22]
  cursor.i
  totalCandidates.i
  seed.i[21]
  inverse.i[20]
  Array addTable.i(19, 19)
  Array multiplyTable.i(19, 19)
  Map seen.i()
  error.s
EndStructure
