Procedure Posting(Cancel, Mode)
	// МШП вибувають з експлуатації і фіксуються як списані з причиною
	RegisterRecords.МШПВЕксплуатації.Write = True;
	RegisterRecords.СписаніМШП.Write = True;
	For Each CurRow In МШП Do
		Record = RegisterRecords.МШПВЕксплуатації.AddExpense();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Підрозділ = Підрозділ;
		Record.МатеріальноВідповідальний = МатеріальноВідповідальний;
		Record.Кількість = CurRow.Кількість;
		Record.Сума = CurRow.Сума;

		Record = RegisterRecords.СписаніМШП.AddReceipt();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Підрозділ = Підрозділ;
		Record.Причина = Причина;
		Record.Кількість = CurRow.Кількість;
		Record.Сума = CurRow.Сума;
	EndDo;
EndProcedure
