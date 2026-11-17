Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = МШП.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// МШП вибувають з експлуатації і фіксуються як списані з причиною
	// контроль: списати можна не більше, ніж є в експлуатації
	AtServer.CheckMSHPInUse(Підрозділ, МатеріальноВідповідальний, МШП, New Boundary(PointInTime(), BoundaryType.Excluding), Cancel);
	If Cancel Then
		Return;
	EndIf;

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
