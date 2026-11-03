
Procedure PrintДрукувати(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(PrintДрукувати)
	Template = Documents.СписанняМШП.GetTemplate("PrintДрукувати");
	Query = New Query;
	Query.Text =
	"SELECT
	|	СписанняМШП.Date,
	|	СписанняМШП.Number,
	|	СписанняМШП.ГоловаКомісії,
	|	СписанняМШП.МатеріальноВідповідальний,
	|	СписанняМШП.Причина,
	|	СписанняМШП.Підрозділ,
	|	СписанняМШП.МШП.(
	|		LineNumber,
	|		Номенклатура,
	|		Кількість,
	|		Ціна,
	|		Сума
	|	)
	|FROM
	|	Document.СписанняМШП AS СписанняМШП
	|WHERE
	|	СписанняМШП.Ref IN (&Ref)";
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
