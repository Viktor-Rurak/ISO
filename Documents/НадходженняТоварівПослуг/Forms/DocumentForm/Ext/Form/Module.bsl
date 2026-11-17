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
	If Object.Ref.IsEmpty() Then
		If Not ValueIsFilled(Object.Склад) Then
			Object.Склад = AtServer.GetDefaultWarehouse();
		EndIf;
		If Not ValueIsFilled(Object.Комірник) Then
			Object.Комірник = AtServer.GetDefaultStorekeeper();
		EndIf;
	EndIf;
EndProcedure

// Перевірка заповнення реквізитів шапки перед записом
&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	NotFilled = "";
	If Not ValueIsFilled(Object.Склад) Then
		NotFilled = NotFilled + Chars.LF + "  - Склад";
	EndIf;
	If Not ValueIsFilled(Object.Контрагент) Then
		NotFilled = NotFilled + Chars.LF + "  - Контрагент";
	EndIf;
	If Not ValueIsFilled(Object.Комірник) Then
		NotFilled = NotFilled + Chars.LF + "  - Комірник";
	EndIf;
	If Object.ТаблицяНоменклатури.Count() = 0 Then
		NotFilled = NotFilled + Chars.LF + "  - таблична частина (немає жодного рядка)";
	EndIf;
	If NotFilled <> "" Then
		Message("Не заповнено:" + NotFilled);
		Cancel = True;
	EndIf;
	Object.Сума = Object.ТаблицяНоменклатури.Total("Сума");
EndProcedure

// Одиниця виміру вибраної номенклатури
&AtServerNoContext
Function GetUnit(Номенклатура)
	Return Номенклатура.ОдиницяВиміру;
EndFunction

// Закупівельна ціна номенклатури на дату документа (регістр ЦіниНоменклатури)
&AtServerNoContext
Function GetPrice(Date, Номенклатура)
	Filter = New Structure("Номенклатура, ТипЦіни", Номенклатура, Enums.ТипиЦін.Закупівельні);
	Return InformationRegisters.ЦіниНоменклатури.GetLast(Date, Filter).Ціна;
EndFunction

// Заповнення рядка після вибору номенклатури: одиниця, ціна, кількість = 1, сума
&AtClient
Procedure FillRow(CurRow)
	CurRow.ОдиницяВиміру = GetUnit(CurRow.Номенклатура);
	CurRow.Ціна = GetPrice(Object.Date, CurRow.Номенклатура);
	If CurRow.Кількість = 0 Then
		CurRow.Кількість = 1;
	EndIf;
	CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	Object.Сума = Object.ТаблицяНоменклатури.Total("Сума");
EndProcedure

&AtClient
Procedure НоменклатураOnChange(Item)
	CurRow = Items.ТаблицяНоменклатури.CurrentData;
	If CurRow <> Undefined Then
		FillRow(CurRow);
	EndIf;
EndProcedure

// Перерахунок суми рядка при зміні кількості або ціни
&AtClient
Procedure КількістьЦінаOnChange(Item)
	CurRow = Items.ТаблицяНоменклатури.CurrentData;
	If CurRow <> Undefined Then
		CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	EndIf;
	Object.Сума = Object.ТаблицяНоменклатури.Total("Сума");
EndProcedure

&AtClient
Procedure ТаблицяНоменклатуриOnEditEnd(Item, NewRow, CancelEdit)
	Object.Сума = Object.ТаблицяНоменклатури.Total("Сума");
EndProcedure

// Підбір номенклатури: форма вибору не закривається після вибору
&AtClient
Procedure Підбір(Command)
	FormParameters = New Structure;
	FormParameters.Insert("ChoiceMode", True);
	FormParameters.Insert("CloseOnChoice", False);
	FormParameters.Insert("ChoiceFoldersAndItems", FoldersAndItemsUse.Items);
	OpenForm("Catalog.Номенклатура.ChoiceForm", FormParameters, Items.ТаблицяНоменклатури);
EndProcedure

&AtClient
Procedure Очистити(Command)
	Object.ТаблицяНоменклатури.Clear();
	Object.Сума = 0;
EndProcedure

// Обробка вибору з форми підбору з перевіркою повторення найменувань
&AtClient
Procedure ТаблицяНоменклатуриChoiceProcessing(Item, SelectedValue, StandardProcessing)
	StandardProcessing = False;
	If TypeOf(SelectedValue) = Type("Array") Then
		Values = SelectedValue;
	Else
		Values = New Array;
		Values.Add(SelectedValue);
	EndIf;
	For Each Value In Values Do
		If Object.ТаблицяНоменклатури.FindRows(New Structure("Номенклатура", Value)).Count() > 0 Then
			Message("Це найменування уже є в списку: " + Value);
			Continue;
		EndIf;
		NewRow = Object.ТаблицяНоменклатури.Add();
		NewRow.Номенклатура = Value;
		NewRow.Кількість = 1;
		FillRow(NewRow);
		Items.ТаблицяНоменклатури.CurrentRow = NewRow.GetID();
	EndDo;
EndProcedure
