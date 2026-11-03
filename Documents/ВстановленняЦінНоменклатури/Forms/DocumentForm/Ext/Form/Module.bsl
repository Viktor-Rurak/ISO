&AtClient
Procedure OnOpen(Cancel)
	SetOrganizationName();
EndProcedure

&AtServer
Procedure SetOrganizationName()
	orgName = AtServer.GetOrganizationName();
	Items.НазваОрганізації.Title = "Назва організації: " + orgName;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	// Бухгалтер за замовчуванням з константи ГоловБухгалтер
	If Object.Ref.IsEmpty() And Not ValueIsFilled(Object.Бухгалтер) Then
		Object.Бухгалтер = AtServer.GetChiefAccountant();
	EndIf;
EndProcedure
