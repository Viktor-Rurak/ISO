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
		If Not ValueIsFilled(Object.СкладВідправник) Then
			Object.СкладВідправник = AtServer.GetDefaultWarehouse();
		EndIf;
		If Not ValueIsFilled(Object.Відповідальний) Then
			Object.Відповідальний = AtServer.GetDefaultStorekeeper();
		EndIf;
	EndIf;
EndProcedure

// Перевірка заповнення реквізитів шапки перед записом
&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	NotFilled = "";
	If Not ValueIsFilled(Object.СкладВідправник) Then
		NotFilled = NotFilled + Chars.LF + "  - Склад-відправник";
	EndIf;
	If Not ValueIsFilled(Object.СкладОтримувач) Then
		NotFilled = NotFilled + Chars.LF + "  - Склад-отримувач";
	EndIf;
	If Not ValueIsFilled(Object.Відповідальний) Then
		NotFilled = NotFilled + Chars.LF + "  - Відповідальний";
	EndIf;
	If Object.ТаблицяНоменклатури.Count() = 0 Then
		NotFilled = NotFilled + Chars.LF + "  - таблична частина (немає жодного рядка)";
	EndIf;
	If NotFilled <> "" Then
		Message("Не заповнено:" + NotFilled);
		Cancel = True;
	EndIf;
EndProcedure

// Заповнення рядка після вибору номенклатури: одиниця, ціна, кількість = 1, сума
&AtClient
Procedure FillRow(CurRow)
	If CurRow.Кількість = 0 Then
		CurRow.Кількість = 1;
	EndIf;
EndProcedure

&AtClient
Procedure НоменклатураOnChange(Item)
	CurRow = Items.ТаблицяНоменклатури.CurrentData;
	If CurRow <> Undefined Then
		FillRow(CurRow);
	EndIf;
EndProcedure

&AtClient
Procedure КількістьOnChange(Item)
	CurRow = Items.ТаблицяНоменклатури.CurrentData;
	If CurRow <> Undefined And CurRow.Кількість < 0 Then
		CurRow.Кількість = 0;
	EndIf;
EndProcedure

&AtClient
Procedure ТаблицяНоменклатуриOnEditEnd(Item, NewRow, CancelEdit)
	// підсумок кількості виводиться у підвалі таблиці
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
