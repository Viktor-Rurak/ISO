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
