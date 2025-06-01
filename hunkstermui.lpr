program hunkstermui;
{$mode objfpc}{$H+}
uses
  SysUtils,
  MUIClass.Base, MUIClass.Window, MUIClass.Group, MUIClass.Area,
  MUIClass.Gadget, MUIClass.Dialog,
  hunklib,
  MUI, muihelper;

type

  { THunksterMain }

  THunksterMain = class(TMUIWindow)
  private
    EditFilename: TMUIString;
    EditDataName: TMUIString;
    EditDataSize: TMUIString;
    EditHunkName: TMUIString;
    ChooseType: TMUIRadio;
    SaveDialog: TFileDialog;
    MemLoad: LongWord;
    procedure InFileClick(Sender: TObject);
    procedure MemoryChanged(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure UpdateHunkInfo;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

{ THunksterMain }

procedure THunksterMain.InFileClick(Sender: TObject);
var
  OpenDialog: TFileDialog;
  SName: string;
begin
  OpenDialog := TFileDialog.Create;
  try
    OpenDialog.TitleText := 'Select file';
    if OpenDialog.Execute then
    begin
      EditFilename.Contents := OpenDialog.FileName;
      SName := LowerCase(ExtractFileName(ChangeFileExt(OpenDialog.FileName, '')));
      EditDataName.Contents := '_' + SName;
      EditDataSize.Contents := '_' + SName + '_size';
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure THunksterMain.MemoryChanged(Sender: TObject);
begin
  UpdateHunkInfo;
end;

procedure THunksterMain.SaveAsClick(Sender: TObject);
var
  OutF: File;
  Error: Word;
  Size: LongWord;
begin
  if SaveDialog.Execute = false then
    Exit;
 {$I-}
  System.Assign(OutF, SaveDialog.FileName);
  System.Rewrite(OutF, 1);

  WriteHunkUnit(OutF);
  WriteHunkName(OutF, EditHunkName.Contents);
  Size:=WriteHunkData(OutF, MemLoad, EditFilename.Contents, EditDataSize.Contents <> '');
  WriteHunkExt(OutF,EditDataName.Contents);
  if EditDataSize.Contents <> '' then
    WriteHunkExtSize(OutF, EditDataSize.Contents, Size);
  WriteHunkEnd(OutF);
  System.Close(OutF);
  Error := IORESULT;
{$I+}
  if Error = 0 then
    ShowMessage('New hunk successfully created and saved!')
  else
    ShowMessage('Ouch it looks like we had booboo!');
end;

procedure THunksterMain.UpdateHunkInfo;
begin
  case ChooseType.Active of
    0:begin
        MemLoad := ANY_MEM;
        EditHunkName.Contents := 'ANYMEM';
      end;
   1:begin
        MemLoad := CHIP_MEM;
        EditHunkName.Contents := 'CHIPMEM';
      end;
   2:begin
        MemLoad := FAST_MEM;
        EditHunkName.Contents := 'FASTMEM';
      end;
  end;
end;

constructor THunksterMain.Create;
var
  LeftGrp, RightGrp: TMUIGroup;
  InFileBtn, SaveBtn: TMUIButton;
begin
  inherited Create;

  ID := MAKE_ID('H', 'n', 'k', 's'); // that it can save its position

  // title and screen title
  Self.Title := 'HunksterMUI v1.0';
  Self.ScreenTitle := 'HunksterMUI v1.0 - original idea by RetroNick';

  Horizontal := True;

  // group for left labels + string inputs
  LeftGrp := TMUIGroup.Create;
  LeftGrp.Frame := MUIV_Frame_None;
  LeftGrp.Columns := 2;   // arrange them in two columns
  LeftGrp.Parent := Self;

  // first row, select a file
  InFileBtn := TMUIButton.Create('In File');
  InFileBtn.FixWidthTxt := '  In File  ';
  InFileBtn.OnClick  := @InFileClick;
  InFileBtn.Parent := LeftGrp;

  EditFilename := TMUIString.Create;
  EditFilename.Parent :=LeftGrp;

  // second row, dataname
  TMUIText.Create('Data Name').Parent := LeftGrp;
  EditDataName := TMUIString.Create;
  EditDataName.Parent := LeftGrp;

  // third row, dataseizename
  TMUIText.Create('Data Size Name').Parent := LeftGrp;
  EditDataSize := TMUIString.Create;
  EditDataSize.Parent := LeftGrp;

  // fourth row, hunk name
  TMUIText.Create('Hunk Name').Parent := LeftGrp;
  EditHunkName := TMUIString.Create;
  EditHunkName.Parent := LeftGrp;

  // right side, memory type selectior and save button
  RightGrp := TMUIGroup.Create;
  RightGrp.Frame := MUIV_Frame_None;
  RightGrp.Parent := Self;

  // memory type selection
  ChooseType := TMUIRadio.Create;
  ChooseType.FrameTitle := 'Memory Type';
  ChooseType.Entries := ['Any               ', 'Chip', 'Fast'];  // some odd spaces added that it lookjs nicer an screen, not so cramped up
  ChooseType.OnActiveChange  := @MemoryChanged;
  ChooseType.Parent := RightGrp;

  // the save button itself
  SaveBtn := TMUIButton.Create('Save As');
  SaveBtn.OnClick  := @SaveAsClick;
  SaveBtn.Parent := RightGrp;

  // save dialog for later use
  SaveDialog := TFileDialog.Create;
  SaveDialog.TitleText := 'Choose Filename for Hunk file';
  SaveDialog.SaveMode := True;

  // initial setting for choosetype
  UpdateHunkInfo;
end;

destructor THunksterMain.Destroy;
begin
  inherited Destroy;
  SaveDialog.Free;
end;


begin
  THunksterMain.Create;
  MUIApp.Description := 'Creates Amiga 68k hunk files';
  MUIApp.Author := 'Marcus "ALB42" Sackrow';
  MUIApp.Run;
end.

