
// Друкована форма елемента довідника Номенклатура (картка з актуальними цінами)
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	SetPrivilegedMode(True);
	Template = Catalogs.Номенклатура.GetTemplate("PrintДрукувати");

	Query = New Query;
	Query.Text =
	"SELECT
	|	Номенклатура.Code AS Code,
	|	Номенклатура.Description AS Description,
	|	Номенклатура.Parent AS Parent,
	|	Номенклатура.ВидНоменклатури AS ВидНоменклатури,
	|	Номенклатура.ОдиницяВиміру AS ОдиницяВиміру,
	|	Номенклатура.СтрокВикористання AS СтрокВикористання,
	|	ISNULL(ЦіниЗакупівлі.Ціна, 0) AS ЦінаЗакупівлі,
	|	ISNULL(ЦіниРоздрібні.Ціна, 0) AS ЦінаРоздрібна,
	|	ISNULL(ЦіниГуртові.Ціна, 0) AS ЦінаГуртова
	|FROM
	|	Catalog.Номенклатура AS Номенклатура
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Закупівельні)) AS ЦіниЗакупівлі
	|		ON (ЦіниЗакупівлі.Номенклатура = Номенклатура.Ref)
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Роздрібні)) AS ЦіниРоздрібні
	|		ON (ЦіниРоздрібні.Номенклатура = Номенклатура.Ref)
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Гуртові)) AS ЦіниГуртові
	|		ON (ЦіниГуртові.Номенклатура = Номенклатура.Ref)
	|WHERE
	|	Номенклатура.Ref IN (&Ref)
	|	AND NOT Номенклатура.IsFolder";
	Query.SetParameter("Ref", Ref);
	Query.SetParameter("Period", CurrentDate());
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");

	Spreadsheet.Clear();
	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			Spreadsheet.PutHorizontalPageBreak();
		EndIf;
		Spreadsheet.Put(AreaCaption);
		Header.Parameters.Fill(Selection);
		Header.Parameters.ДатаЦін = Format(CurrentDate(), "DF=dd.MM.yyyy");
		Spreadsheet.Put(Header);
		InsertPageBreak = True;
	EndDo;
EndProcedure
