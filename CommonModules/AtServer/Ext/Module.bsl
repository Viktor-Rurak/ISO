Procedure OnStartSystem() Export
	Constants.ДатаОстанньогоЗапуску.Set(CurrentDate());
	WriteUserInput();
EndProcedure

Procedure WriteUserInput()
	// Фіксує вхід користувача в журналі реєстрації
	WriteLogEvent("Вхід користувача", EventLogLevel.Information, , , "Користувач: " + UserName());
EndProcedure

// Назва організації з константи (виводиться у шапці кожного документа)
Function GetOrganizationName() Export
	Return Constants.НазваОрганізації.Get();
EndFunction

// Значення за замовчуванням з констант
Function GetChiefAccountant() Export
	Return Constants.ГоловБухгалтер.Get();
EndFunction

Function GetDefaultUnit() Export
	Return Constants.ОдиницяВиміруЗаЗамовчуванням.Get();
EndFunction

Function GetDefaultWarehouse() Export
	Return Constants.СкладЗаЗамовчуванням.Get();
EndFunction

Function GetDefaultResponsibleMSHP() Export
	Return Constants.ВідповідальнийЗаМШПЗаЗамовчуванням.Get();
EndFunction
