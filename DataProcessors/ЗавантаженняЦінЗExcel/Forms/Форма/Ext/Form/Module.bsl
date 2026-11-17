&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ДатаЦін = CurrentSessionDate();
	ТипЦіни = Enums.ТипиЦін.Закупівельні;
EndProcedure

// Вибір файлу Excel
&AtClient
Procedure ШляхДоФайлуStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing = False;
	Dialog = New FileDialog(FileDialogMode.Open);
	Dialog.Title = "Виберіть файл Excel з цінами";
	Dialog.Filter = "Файли Excel (*.xlsx;*.xls)|*.xlsx;*.xls|Усі файли (*.*)|*.*";
	Dialog.Multiselect = False;
	Dialog.Show(New NotifyDescription("ФайлВибрано", ThisObject));
EndProcedure

&AtClient
Procedure ФайлВибрано(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles <> Undefined And SelectedFiles.Count() > 0 Then
		ШляхДоФайлу = SelectedFiles[0];
	EndIf;
EndProcedure

// Завантаження: файл передається на сервер і читається як табличний документ
&AtClient
Procedure Завантажити(Command)
	If Not ValueIsFilled(ШляхДоФайлу) Then
		Message("Виберіть файл Excel");
		Return;
	EndIf;
	BeginPutFile(New NotifyDescription("ФайлПередано", ThisObject), , ШляхДоФайлу, False, UUID);
EndProcedure

&AtClient
Procedure ФайлПередано(Result, Address, SelectedFileName, AdditionalParameters) Export
	If Not Result Then
		Message("Не вдалося передати файл");
		Return;
	EndIf;
	Count = ПрочитатиФайл(Address, SelectedFileName);
	Message("Прочитано рядків з цінами: " + Count);
EndProcedure

&AtServer
Function ПрочитатиФайл(Address, FileName)
	Ext = "xlsx";
	Pos = StrFind(FileName, ".", SearchDirection.FromEnd);
	If Pos > 0 Then
		Ext = Mid(FileName, Pos + 1);
	EndIf;
	TempFile = GetTempFileName(Ext);
	GetFromTempStorage(Address).Write(TempFile);
	Count = ЗаповнитиЦіни(TempFile);
	DeleteFiles(TempFile);
	DeleteFromTempStorage(Address);
	Return Count;
EndFunction

&AtServer
Function ЗаповнитиЦіни(FileName)
	Ціни.Clear();
	Doc = New SpreadsheetDocument;
	Doc.Read(FileName);
	For RowNum = 1 To Doc.TableHeight Do
		Name = TrimAll(Doc.Area(RowNum, 1, RowNum, 1).Text);
		PriceText = TrimAll(Doc.Area(RowNum, 2, RowNum, 2).Text);
		If Name = "" Or PriceText = "" Then
			Continue;
		EndIf;
		PriceText = StrReplace(StrReplace(StrReplace(PriceText, Chars.NBSp, ""), " ", ""), ",", ".");
		Try
			Price = Number(PriceText);
		Except
			Continue; // рядок заголовка або текст замість ціни
		EndTry;
		NewRow = Ціни.Add();
		NewRow.НазваУФайлі = Name;
		NewRow.Ціна = Price;
		NewRow.Номенклатура = Catalogs.Номенклатура.FindByDescription(Name, True);
		If Not ValueIsFilled(NewRow.Номенклатура) Then
			Message("Не знайдено в довіднику: " + Name + " (рядок " + RowNum + ") - виберіть номенклатуру вручну");
		EndIf;
	EndDo;
	Return Ціни.Count();
EndFunction

// Запис цін: створюється і проводиться документ «Встановлення цін номенклатури»
&AtClient
Procedure ЗаписатиЦіни(Command)
	If Not ValueIsFilled(ТипЦіни) Then
		Message("Вкажіть тип ціни");
		Return;
	EndIf;
	If Ціни.Count() = 0 Then
		Message("Спочатку завантажте файл");
		Return;
	EndIf;
	DocRef = ЗаписатиЦіниНаСервері();
	If DocRef <> Undefined Then
		ShowUserNotification("Ціни записано", GetURL(DocRef), String(DocRef));
		ShowValue(, DocRef);
	EndIf;
EndProcedure

&AtServer
Function ЗаписатиЦіниНаСервері()
	Doc = Documents.ВстановленняЦінНоменклатури.CreateDocument();
	Doc.Date = ?(ValueIsFilled(ДатаЦін), ДатаЦін, CurrentSessionDate());
	Doc.Бухгалтер = AtServer.GetChiefAccountant();
	Skipped = 0;
	For Each Row In Ціни Do
		If Not ValueIsFilled(Row.Номенклатура) Then
			Skipped = Skipped + 1;
			Continue;
		EndIf;
		NewRow = Doc.Номенклатура.Add();
		NewRow.НоменклатураНазва = Row.Номенклатура;
		NewRow.ТипЦіни = ТипЦіни;
		NewRow.Ціна = Row.Ціна;
	EndDo;
	If Doc.Номенклатура.Count() = 0 Then
		Message("Немає рядків з вибраною номенклатурою");
		Return Undefined;
	EndIf;
	Try
		Doc.Write(DocumentWriteMode.Posting);
	Except
		Message("Не вдалося провести документ: " + BriefErrorDescription(ErrorInfo()));
		Return Undefined;
	EndTry;
	If Skipped > 0 Then
		Message("Пропущено рядків без номенклатури: " + Skipped);
	EndIf;
	Return Doc.Ref;
EndFunction
