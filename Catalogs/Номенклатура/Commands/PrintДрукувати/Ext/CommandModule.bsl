
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	Spreadsheet = New SpreadsheetDocument;
	PrintДрукувати(Spreadsheet, CommandParameter);

	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = True;
	Spreadsheet.ReadOnly = True;
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show("Картка номенклатури");
EndProcedure

&AtServer
Procedure PrintДрукувати(Spreadsheet, CommandParameter)
	Catalogs.Номенклатура.PrintДрукувати(Spreadsheet, CommandParameter);
EndProcedure
