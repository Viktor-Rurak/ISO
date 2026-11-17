Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	If СкладВідправник = СкладОтримувач Then
		Message("Склад-відправник і склад-отримувач мають бути різними");
		Cancel = True;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// товари списуються зі складу-відправника і надходять на склад-отримувач
	// контроль кількості на складі-відправнику
	AtServer.CheckStockBalance(СкладВідправник, ТаблицяНоменклатури, New Boundary(PointInTime(), BoundaryType.Excluding), Cancel);
	If Cancel Then
		Return;
	EndIf;

	RegisterRecords.ЗалишкиНоменклатури.Write = True;
	For Each CurRow In ТаблицяНоменклатури Do
		Record = RegisterRecords.ЗалишкиНоменклатури.AddExpense();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = СкладВідправник;
		Record.Кількість = CurRow.Кількість;

		Record = RegisterRecords.ЗалишкиНоменклатури.AddReceipt();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = СкладОтримувач;
		Record.Кількість = CurRow.Кількість;
	EndDo;
EndProcedure
