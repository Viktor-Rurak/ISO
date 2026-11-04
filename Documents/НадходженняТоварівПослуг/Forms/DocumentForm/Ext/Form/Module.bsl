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

&AtClient
Procedure РядокКількістьOnChange(Item)
	RecalcRowSum();
EndProcedure

&AtClient
Procedure РядокЦінаOnChange(Item)
	RecalcRowSum();
EndProcedure

&AtClient
Procedure RecalcRowSum()
	CurRow = Items.ТаблицяНоменклатури.CurrentData;
	If CurRow <> Undefined Then
		CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	EndIf;
EndProcedure
