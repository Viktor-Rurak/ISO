
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(PrintДрукувати)
	Template = Documents.НадходженняМШП.GetTemplate("PrintДрукувати");
	Query = New Query;
	Query.Text =
	"SELECT
	|	НадходженняМШП.Date,
	|	НадходженняМШП.Number,
	|	НадходженняМШП.Відповідальний,
	|	НадходженняМШП.Контрагент,
	|	НадходженняМШП.Склад,
	|	НадходженняМШП.Сума,
	|	НадходженняМШП.МШП.(
	|		LineNumber,
	|		Номенклатура,
	|		ОдиницяВиміру,
	|		Кількість,
	|		Ціна,
	|		Сума
	|	)
	|FROM
	|	Document.НадходженняМШП AS НадходженняМШП
	|WHERE
	|	НадходженняМШП.Ref IN (&Ref)";
	Query.Parameters.Insert("Ref", Ref);
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaМШПHeader = Template.GetArea("МШПHeader");
	AreaМШП = Template.GetArea("МШП");
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

		Spreadsheet.Put(AreaМШПHeader);
		SelectionМШП = Selection.МШП.Select();
		While SelectionМШП.Next() Do
			AreaМШП.Parameters.Fill(SelectionМШП);
			Spreadsheet.Put(AreaМШП, SelectionМШП.Level());
		EndDo;

		Footer.Parameters.Fill(Selection);
		Spreadsheet.Put(Footer);

		InsertPageBreak = True;
	EndDo;
	//}}
EndProcedure
