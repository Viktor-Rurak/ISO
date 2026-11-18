Procedure Posting(Cancel, Mode)
	//{{__REGISTER_REGISTERRECORDS_WIZARD
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.

	// register ЦіниНоменклатури
	RegisterRecords.ЦіниНоменклатури.Write = True;
	For Each CurRowНоменклатура In Номенклатура Do
		Record = RegisterRecords.ЦіниНоменклатури.Add();
		Record.Period = Date;
		Record.Номенклатура = CurRowНоменклатура.НоменклатураНазва;
		Record.ТипЦіни = CurRowНоменклатура.ТипЦіни;
		Record.Ціна = CurRowНоменклатура.Ціна;
	EndDo;

	//}}__REGISTER_REGISTERRECORDS_WIZARD
EndProcedure
