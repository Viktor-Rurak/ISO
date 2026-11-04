Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = ТаблицяНоменклатури.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// товари надходять на склад
	RegisterRecords.ЗалишкиНоменклатури.Write = True;
	For Each CurRow In ТаблицяНоменклатури Do
		Record = RegisterRecords.ЗалишкиНоменклатури.AddReceipt();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = Склад;
		Record.Кількість = CurRow.Кількість;
	EndDo;
EndProcedure
