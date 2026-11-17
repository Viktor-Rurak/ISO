&AtClient
Procedure OnOpen(Cancel)
	SetOrganizationName();
EndProcedure

&AtServer
Procedure SetOrganizationName()
	Items.НазваОрганізації.Title = "Назва організації: " + AtServer.GetOrganizationName();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	// Значення за замовчуванням з констант
	If Object.Ref.IsEmpty() And Not ValueIsFilled(Object.МатеріальноВідповідальний) Then
		Object.МатеріальноВідповідальний = AtServer.GetDefaultResponsibleMSHP();
	EndIf;
EndProcedure

// Перевірка заповнення реквізитів шапки перед записом
&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	NotFilled = "";
	If Not ValueIsFilled(Object.Підрозділ) Then
		NotFilled = NotFilled + Chars.LF + "  - Підрозділ";
	EndIf;
	If Not ValueIsFilled(Object.МатеріальноВідповідальний) Then
		NotFilled = NotFilled + Chars.LF + "  - Матеріально відповідальний";
	EndIf;
	If Not ValueIsFilled(Object.ГоловаКомісії) Then
		NotFilled = NotFilled + Chars.LF + "  - Голова комісії";
	EndIf;
	If Not ValueIsFilled(Object.Причина) Then
		NotFilled = NotFilled + Chars.LF + "  - Причина списання";
	EndIf;
	If Object.МШП.Count() = 0 Then
		NotFilled = NotFilled + Chars.LF + "  - таблична частина (немає жодного рядка)";
	EndIf;
	If NotFilled <> "" Then
		Message("Не заповнено:" + NotFilled);
		Cancel = True;
	EndIf;
	Object.Сума = Object.МШП.Total("Сума");
EndProcedure

// Закупівельна ціна номенклатури на дату документа (регістр ЦіниНоменклатури)
&AtServerNoContext
Function GetPrice(Date, Номенклатура)
	Filter = New Structure("Номенклатура, ТипЦіни", Номенклатура, Enums.ТипиЦін.Закупівельні);
	Return InformationRegisters.ЦіниНоменклатури.GetLast(Date, Filter).Ціна;
EndFunction

// Заповнення рядка після вибору номенклатури: одиниця, ціна, кількість = 1, сума
&AtClient
Procedure FillRow(CurRow)
	CurRow.Ціна = GetPrice(Object.Date, CurRow.Номенклатура);
	If CurRow.Кількість = 0 Then
		CurRow.Кількість = 1;
	EndIf;
	CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	Object.Сума = Object.МШП.Total("Сума");
EndProcedure

&AtClient
Procedure НоменклатураOnChange(Item)
	CurRow = Items.МШП.CurrentData;
	If CurRow <> Undefined Then
		FillRow(CurRow);
	EndIf;
EndProcedure

// Перерахунок суми рядка при зміні кількості або ціни
&AtClient
Procedure КількістьЦінаOnChange(Item)
	CurRow = Items.МШП.CurrentData;
	If CurRow <> Undefined Then
		CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	EndIf;
	Object.Сума = Object.МШП.Total("Сума");
EndProcedure

&AtClient
Procedure МШПOnEditEnd(Item, NewRow, CancelEdit)
	Object.Сума = Object.МШП.Total("Сума");
EndProcedure

// Підбір номенклатури: форма вибору не закривається після вибору
&AtClient
Procedure Підбір(Command)
	FormParameters = New Structure;
	FormParameters.Insert("ChoiceMode", True);
	FormParameters.Insert("CloseOnChoice", False);
	FormParameters.Insert("ChoiceFoldersAndItems", FoldersAndItemsUse.Items);
	FormParameters.Insert("Filter", New Structure("ВидНоменклатури", PredefinedValue("Enum.ВидиНоменклатури.МШП")));
	OpenForm("Catalog.Номенклатура.ChoiceForm", FormParameters, Items.МШП);
EndProcedure

&AtClient
Procedure Очистити(Command)
	Object.МШП.Clear();
	Object.Сума = 0;
EndProcedure

// Обробка вибору з форми підбору з перевіркою повторення найменувань
&AtClient
Procedure МШПChoiceProcessing(Item, SelectedValue, StandardProcessing)
	StandardProcessing = False;
	If TypeOf(SelectedValue) = Type("Array") Then
		Values = SelectedValue;
	Else
		Values = New Array;
		Values.Add(SelectedValue);
	EndIf;
	For Each Value In Values Do
		If Object.МШП.FindRows(New Structure("Номенклатура", Value)).Count() > 0 Then
			Message("Це найменування уже є в списку: " + Value);
			Continue;
		EndIf;
		NewRow = Object.МШП.Add();
		NewRow.Номенклатура = Value;
		NewRow.Кількість = 1;
		FillRow(NewRow);
		Items.МШП.CurrentRow = NewRow.GetID();
	EndDo;
EndProcedure
