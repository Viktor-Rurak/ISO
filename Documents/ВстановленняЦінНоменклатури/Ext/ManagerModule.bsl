
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(PrintДрукувати)
	Template = Documents.ВстановленняЦінНоменклатури.GetTemplate("PrintДрукувати");
	Query = New Query;
	Query.Text =
	"SELECT
	|	ВстановленняЦінНоменклатури.Date,
	|	ВстановленняЦінНоменклатури.Number,
	|	ВстановленняЦінНоменклатури.Бухгалтер,
	|	ВстановленняЦінНоменклатури.ВибірВидНоменклатури,
	|	ВстановленняЦінНоменклатури.Номенклатура.(
	|		LineNumber,
	|		НоменклатураНазва,
	|		ТипЦіни,
	|		Ціна
	|	)
	|FROM
	|	Document.ВстановленняЦінНоменклатури AS ВстановленняЦінНоменклатури
	|WHERE
	|	ВстановленняЦінНоменклатури.Ref IN (&Ref)";
	Query.Parameters.Insert("Ref", Ref);
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaНоменклатураHeader = Template.GetArea("НоменклатураHeader");
	AreaНоменклатура = Template.GetArea("Номенклатура");
	Footer = Template.GetArea("Footer");

	Spreadsheet.Clear();

	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			Spreadsheet.PutHorizontalPageBreak();
		EndIf;

		Spreadsheet.Put(AreaCaption);

		Header.Parameters.Fill(Selection);
		Spreadsheet.Put(Header, Selection.Level());

		Spreadsheet.Put(AreaНоменклатураHeader);
		SelectionНоменклатура = Selection.Номенклатура.Select();
		While SelectionНоменклатура.Next() Do
			AreaНоменклатура.Parameters.Fill(SelectionНоменклатура);
			Spreadsheet.Put(AreaНоменклатура, SelectionНоменклатура.Level());
		EndDo;

		Footer.Parameters.Fill(Selection);
		Spreadsheet.Put(Footer);

		InsertPageBreak = True;
	EndDo;
	//}}
EndProcedure
