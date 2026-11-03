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

&AtClient
Procedure МШПКількістьOnChange(Item)
	RecalcRowSum();
EndProcedure

&AtClient
Procedure МШПЦінаOnChange(Item)
	RecalcRowSum();
EndProcedure

&AtClient
Procedure RecalcRowSum()
	CurRow = Items.МШП.CurrentData;
	If CurRow <> Undefined Then
		CurRow.Сума = CurRow.Кількість * CurRow.Ціна;
	EndIf;
EndProcedure
