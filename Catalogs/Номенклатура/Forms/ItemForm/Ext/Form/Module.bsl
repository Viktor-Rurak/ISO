&AtClient
Procedure OnOpen(Cancel)
	Object.ДатаПерегляду = CurrentDate();
	// одиниця виміру за замовчуванням з константи
	If Not ValueIsFilled(Object.ОдиницяВиміру) Then
		Object.ОдиницяВиміру = AtServer.GetDefaultUnit();
	EndIf;
	FillPrices();
EndProcedure

&AtServer
Procedure FillPrices()
	SetPrivilegedMode(True);

	Query = New Query;
	Query.Text = "SELECT
	|	ЦіниНоменклатуриSliceLast.Номенклатура AS Номенклатура,
	|	ЦіниНоменклатуриSliceLast.Ціна AS Ціна,
	|	ЦіниНоменклатуриSliceLast.ТипЦіни AS ТипЦіни
	|FROM
	|	InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ) AS ЦіниНоменклатуриSliceLast
	|WHERE
	|	ЦіниНоменклатуриSliceLast.Номенклатура = &Номенклатура";

	Query.SetParameter("Period", Object.ДатаПерегляду);
	Query.SetParameter("Номенклатура", Object.Ref);

	Object.ЦінаГуртова = 0;
	Object.ЦінаЗакупівлі = 0;
	Object.ЦінаРоздрібна = 0;

	Result = Query.Execute();
	If Not Result.IsEmpty() Then
		Selection = Result.Select();
		While Selection.Next() Do
			If Selection.ТипЦіни = Enums.ТипиЦін.Гуртові Then
				Object.ЦінаГуртова = Selection.Ціна;
			ElsIf Selection.ТипЦіни = Enums.ТипиЦін.Закупівельні Then
				Object.ЦінаЗакупівлі = Selection.Ціна;
			ElsIf Selection.ТипЦіни = Enums.ТипиЦін.Роздрібні Then
				Object.ЦінаРоздрібна = Selection.Ціна;
			EndIf;
		EndDo;
	EndIf;
EndProcedure

&AtClient
Procedure ДатаПереглядуOnChange(Item)
	FillPrices();
EndProcedure
