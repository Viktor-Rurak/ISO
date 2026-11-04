
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(PrintДрукувати)
	Template = Documents.НадходженняТоварівПослуг.GetTemplate("PrintДрукувати");
	Query = New Query;
	Query.Text =
	"SELECT
	|	НадходженняТоварівПослуг.Date,
	|	НадходженняТоварівПослуг.Number,
	|	НадходженняТоварівПослуг.Комірник,
	|	НадходженняТоварівПослуг.Контрагент,
	|	НадходженняТоварівПослуг.Склад,
	|	НадходженняТоварівПослуг.Сума,
	|	НадходженняТоварівПослуг.ТаблицяНоменклатури.(
	|		LineNumber,
	|		Номенклатура,
	|		ОдиницяВиміру,
	|		Кількість,
	|		Ціна,
	|		Сума
	|	)
	|FROM
	|	Document.НадходженняТоварівПослуг AS НадходженняТоварівПослуг
	|WHERE
	|	НадходженняТоварівПослуг.Ref IN (&Ref)";
	Query.Parameters.Insert("Ref", Ref);
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaТаблицяНоменклатуриHeader = Template.GetArea("ТаблицяНоменклатуриHeader");
	AreaТаблицяНоменклатури = Template.GetArea("ТаблицяНоменклатури");
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

		Spreadsheet.Put(AreaТаблицяНоменклатуриHeader);
		SelectionТаблицяНоменклатури = Selection.ТаблицяНоменклатури.Select();
		While SelectionТаблицяНоменклатури.Next() Do
			AreaТаблицяНоменклатури.Parameters.Fill(SelectionТаблицяНоменклатури);
			Spreadsheet.Put(AreaТаблицяНоменклатури, SelectionТаблицяНоменклатури.Level());
		EndDo;

		Footer.Parameters.Fill(Selection);
		Spreadsheet.Put(Footer);

		InsertPageBreak = True;
	EndDo;
	//}}
EndProcedure
