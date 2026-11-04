Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	Сума = ТаблицяНоменклатури.Total("Сума");
EndProcedure

Procedure Posting(Cancel, Mode)
	// товари списуються зі складу, продаж фіксується в розрізі контрагента
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
