Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = ТаблицяНоменклатури.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// товари списуються зі складу, продаж фіксується в розрізі контрагента
	// контроль: на складі не може залишитися від'ємна кількість
	AtServer.CheckStockBalance(Склад, ТаблицяНоменклатури, New Boundary(PointInTime(), BoundaryType.Excluding), Cancel);
	If Cancel Then
		Return;
	EndIf;

	RegisterRecords.ЗалишкиНоменклатури.Write = True;
	RegisterRecords.ПродажіКомпанії.Write = True;
	For Each CurRow In ТаблицяНоменклатури Do
		Record = RegisterRecords.ЗалишкиНоменклатури.AddExpense();
		Record.Period = Date;
		Record.Номенклатура = CurRow.Номенклатура;
		Record.Склад = Склад;
		Record.Кількість = CurRow.Кількість;

		Record = RegisterRecords.ПродажіКомпанії.Add();
		Record.Period = Date;
		Record.Контрагент = Контрагент;
		Record.Кількість = CurRow.Кількість;
		Record.Сума = CurRow.Сума;
	EndDo;
EndProcedure
