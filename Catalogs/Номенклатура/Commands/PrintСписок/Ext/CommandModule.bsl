
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	Spreadsheet = New SpreadsheetDocument;
	PrintСписок(Spreadsheet);
	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = True;
	Spreadsheet.ReadOnly = True;
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show("Список номенклатури");
EndProcedure

&AtServer
Procedure PrintСписок(Spreadsheet)
	Catalogs.Номенклатура.PrintСписок(Spreadsheet);
EndProcedure
