
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	//{{_PRINT_WIZARD(PrintДрукувати)
	Spreadsheet = New SpreadsheetDocument;
	PrintДрукувати(Spreadsheet, CommandParameter);

	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = True;
	Spreadsheet.ReadOnly = True;
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show();
	//}}
EndProcedure

&AtServer
Procedure PrintДрукувати(Spreadsheet, CommandParameter)
	Documents.ПродажТоварівПослугПродукції.PrintДрукувати(Spreadsheet, CommandParameter);
EndProcedure
