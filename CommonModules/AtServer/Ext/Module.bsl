Procedure OnStartSystem() Export
	Constants.ДатаОстанньогоЗапуску.Set(CurrentDate());
	WriteUserInput();
EndProcedure

Procedure WriteUserInput()
	// Фіксує вхід користувача в журналі реєстрації
	WriteLogEvent("Вхід користувача", EventLogLevel.Information, , , "Користувач: " + UserName());
EndProcedure
