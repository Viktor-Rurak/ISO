Procedure OnStartSystem() Export
	Constants.ДатаОстанньогоЗапуску.Set(CurrentDate());
	WriteUserInput();
EndProcedure

Procedure WriteUserInput()
	// Фіксує вхід користувача в журналі реєстрації
	WriteLogEvent("Вхід користувача", EventLogLevel.Information, , , "Користувач: " + UserName());
EndProcedure

// Назва організації з константи (виводиться у шапці кожного документа)
Function GetOrganizationName() Export
	Return Constants.НазваОрганізації.Get();
EndFunction

// Значення за замовчуванням з констант
Function GetChiefAccountant() Export
	Return Constants.ГоловБухгалтер.Get();
EndFunction

Function GetDefaultUnit() Export
	Return Constants.ОдиницяВиміруЗаЗамовчуванням.Get();
EndFunction

Function GetDefaultWarehouse() Export
	Return Constants.СкладЗаЗамовчуванням.Get();
EndFunction

Function GetDefaultResponsibleMSHP() Export
	Return Constants.ВідповідальнийЗаМШПЗаЗамовчуванням.Get();
EndFunction

Function GetDefaultStorekeeper() Export
	Return Constants.КомірникЗаЗамовчуванням.Get();
EndFunction

// Перевірка залишків номенклатури на складі перед видатком.
// Table - таблична частина документа (колонки Номенклатура, Кількість),
// Boundary - межа (момент часу документа, не включаючи його власні рухи).
Procedure CheckStockBalance(Склад, Table, Boundary, Cancel) Export
	Needed = Table.Unload(, "Номенклатура, Кількість");
	Needed.GroupBy("Номенклатура", "Кількість");

	Query = New Query;
	Query.Text = "SELECT
	|	Т.Номенклатура AS Номенклатура,
	|	Т.Кількість AS Кількість
	|INTO ТабДок
	|FROM
	|	&Needed AS Т
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ТабДок.Номенклатура AS Номенклатура,
	|	ТабДок.Кількість AS Потрібно,
	|	ISNULL(Залишки.КількістьBalance, 0) AS Залишок
	|FROM
	|	ТабДок AS ТабДок
	|		LEFT JOIN AccumulationRegister.ЗалишкиНоменклатури.Balance(&Boundary, Склад = &Склад) AS Залишки
	|		ON ТабДок.Номенклатура = Залишки.Номенклатура
	|WHERE
	|	ТабДок.Кількість > ISNULL(Залишки.КількістьBalance, 0)";
	Query.SetParameter("Needed", Needed);
	Query.SetParameter("Boundary", Boundary);
	Query.SetParameter("Склад", Склад);

	Selection = Query.Execute().Select();
	While Selection.Next() Do
		Message("Недостатньо """ + Selection.Номенклатура + """ на складі """ + Склад
			+ """: потрібно " + Selection.Потрібно + ", є " + Selection.Залишок);
		Cancel = True;
	EndDo;
EndProcedure

// Перевірка кількості МШП в експлуатації у підрозділу / матеріально відповідального перед списанням
Procedure CheckMSHPInUse(Підрозділ, МВО, Table, Boundary, Cancel) Export
	Needed = Table.Unload(, "Номенклатура, Кількість");
	Needed.GroupBy("Номенклатура", "Кількість");

	Query = New Query;
	Query.Text = "SELECT
	|	Т.Номенклатура AS Номенклатура,
	|	Т.Кількість AS Кількість
	|INTO ТабДок
	|FROM
	|	&Needed AS Т
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ТабДок.Номенклатура AS Номенклатура,
	|	ТабДок.Кількість AS Потрібно,
	|	ISNULL(ВЕксплуатації.КількістьBalance, 0) AS Залишок
	|FROM
	|	ТабДок AS ТабДок
	|		LEFT JOIN AccumulationRegister.МШПВЕксплуатації.Balance(&Boundary,
	|			Підрозділ = &Підрозділ AND МатеріальноВідповідальний = &МВО) AS ВЕксплуатації
	|		ON ТабДок.Номенклатура = ВЕксплуатації.Номенклатура
	|WHERE
	|	ТабДок.Кількість > ISNULL(ВЕксплуатації.КількістьBalance, 0)";
	Query.SetParameter("Needed", Needed);
	Query.SetParameter("Boundary", Boundary);
	Query.SetParameter("Підрозділ", Підрозділ);
	Query.SetParameter("МВО", МВО);

	Selection = Query.Execute().Select();
	While Selection.Next() Do
		Message("В експлуатації недостатньо """ + Selection.Номенклатура + """ (" + Підрозділ + ", " + МВО
			+ "): списується " + Selection.Потрібно + ", є " + Selection.Залишок);
		Cancel = True;
	EndDo;
EndProcedure
