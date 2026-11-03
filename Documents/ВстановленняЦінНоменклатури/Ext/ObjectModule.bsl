Procedure Posting(Cancel, Mode)
	// регістр ЦіниНоменклатури
	RegisterRecords.ЦіниНоменклатури.Write = True;
	For Each CurRowНоменклатура In Номенклатура Do
		Record = RegisterRecords.ЦіниНоменклатури.Add();
		Record.Period = Date;
		Record.Номенклатура = CurRowНоменклатура.НоменклатураНазва;
		Record.ТипЦіни = CurRowНоменклатура.ТипЦіни;
		Record.Ціна = CurRowНоменклатура.Ціна;
	EndDo;
EndProcedure
