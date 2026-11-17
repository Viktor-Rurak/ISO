Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = МШП.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// МШП списуються зі складу і передаються в експлуатацію підрозділу
	// контроль кількості МШП на складі
	AtServer.CheckStockBalance(Склад, МШП, New Boundary(PointInTime(), BoundaryType.Excluding), Cancel);
	If Cancel Then
		Return;
	EndIf;

	RegisterRecords.ЗалишкиНоменклатури.Write = True;
	RegisterRecords.МШПВЕксплуатації.Write = True;
	For Each CurRow In МШП Do
		Record = RegisterRecords.ЗалишкиНоменклатури.AddExpense();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = Склад;
		Record.Кількість = CurRow.Кількість;

		Record = RegisterRecords.МШПВЕксплуатації.AddReceipt();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Підрозділ = Підрозділ;
		Record.МатеріальноВідповідальний = МатеріальноВідповідальний;
		Record.Кількість = CurRow.Кількість;
		Record.Сума = CurRow.Сума;
	EndDo;
EndProcedure
