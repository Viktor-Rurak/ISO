Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = МШП.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// МШП надходять на склад
	RegisterRecords.ЗалишкиНоменклатури.Write = True;
	For Each CurRow In МШП Do
		Record = RegisterRecords.ЗалишкиНоменклатури.AddReceipt();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = Склад;
		Record.Кількість = CurRow.Кількість;
	EndDo;
EndProcedure
