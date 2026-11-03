&AtServer
Procedure GetFullName()
	// Найменування = Прізвище І. Б.
	FullName = TrimAll(Object.Прізвище);
	If ValueIsFilled(Object.Імя) Then
		FullName = FullName + " " + Left(TrimAll(Object.Імя), 1) + ".";
	EndIf;
	If ValueIsFilled(Object.ПоБатькові) Then
		FullName = FullName + " " + Left(TrimAll(Object.ПоБатькові), 1) + ".";
	EndIf;
	Object.Description = FullName;
EndProcedure

&AtClient
Procedure ПІБOnChange(Item)
	GetFullName();
EndProcedure
