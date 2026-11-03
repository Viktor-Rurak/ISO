
// Друкована форма елемента довідника Номенклатура (картка з актуальними цінами)
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	SetPrivilegedMode(True);
	Template = Catalogs.Номенклатура.GetTemplate("PrintДрукувати");

	Query = New Query;
	Query.Text =
	"SELECT
	|	Ном.Code AS Code,
	|	Ном.Description AS Description,
	|	Ном.Parent AS Parent,
	|	Ном.ВидНоменклатури AS ВидНоменклатури,
	|	Ном.ОдиницяВиміру AS ОдиницяВиміру,
	|	Ном.СтрокВикористання AS СтрокВикористання,
	|	ISNULL(ЦіниЗакупівлі.Ціна, 0) AS ЦінаЗакупівлі,
	|	ISNULL(ЦіниРоздрібні.Ціна, 0) AS ЦінаРоздрібна,
	|	ISNULL(ЦіниГуртові.Ціна, 0) AS ЦінаГуртова
	|FROM
	|	Catalog.Номенклатура AS Ном
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Закупівельні)) AS ЦіниЗакупівлі
	|		ON (ЦіниЗакупівлі.Номенклатура = Ном.Ref)
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Роздрібні)) AS ЦіниРоздрібні
	|		ON (ЦіниРоздрібні.Номенклатура = Ном.Ref)
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Гуртові)) AS ЦіниГуртові
	|		ON (ЦіниГуртові.Номенклатура = Ном.Ref)
	|WHERE
	|	Ном.Ref IN (&Ref)
	|	AND NOT Ном.IsFolder";
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

// Друкована форма списку номенклатури з роздрібними цінами
Procedure PrintСписок(Spreadsheet) Export
	SetPrivilegedMode(True);
	Template = Catalogs.Номенклатура.GetTemplate("PrintСписок");
	Query = New Query;
	Query.Text =
	"SELECT
	|	Ном.Description AS Description,
	|	Ном.ВидНоменклатури AS ВидНоменклатури,
	|	ISNULL(Ціни.Ціна, 0) AS ЦінаРоздрібна
	|FROM
	|	Catalog.Номенклатура AS Ном
	|		LEFT JOIN InformationRegister.ЦіниНоменклатури.SliceLast(&Period, ТипЦіни = VALUE(Enum.ТипиЦін.Роздрібні)) AS Ціни
	|		ON (Ціни.Номенклатура = Ном.Ref)
	|WHERE
	|	NOT Ном.IsFolder
	|	AND NOT Ном.DeletionMark
	|
	|ORDER BY
	|	Description";
	Query.SetParameter("Period", CurrentDate());
	Selection = Query.Execute().Select();

	Spreadsheet.Clear();
	Spreadsheet.Put(Template.GetArea("Caption"));
	Spreadsheet.Put(Template.GetArea("TableHeader"));
	Area = Template.GetArea("Row");
	N = 0;
	While Selection.Next() Do
		N = N + 1;
		Area.Parameters.Fill(Selection);
		Area.Parameters.N = N;
		Spreadsheet.Put(Area);
	EndDo;
EndProcedure
