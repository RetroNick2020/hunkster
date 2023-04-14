unit fmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,LazFileUtils,hunklib;

type

  { TForm1 }

  TForm1 = class(TForm)
    SaveAs: TButton;
    InFile: TButton;
    EditFileName: TEdit;
    EditDataName: TEdit;
    EditSizeName: TEdit;
    EditHunkName: TEdit;
    InfoLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenDialog: TOpenDialog;
    MemoryGroup: TRadioGroup;
    SaveDialog: TSaveDialog;
    procedure MemoryGroupClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure InFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    MemLoad     : Longword;
    IncludeFileSize : boolean;
    function ValidFields : boolean;
    procedure CreateHunkFile;
    procedure UpdateHunkInfo;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.ValidFields : boolean;
begin
   result:=false;
   if EditFileName.Text = '' then
   begin
     ShowMessage('No File Selected');
   end
   else if EditDataName.Text = ''  then
   begin
     ShowMessage('Data Name cannot be empty');
   end
   else if EditHunkName.Text = ''  then
   begin
     ShowMessage('Hunk Name cannot be empty');
   end
   else
   begin
     result:=true;
   end;
end;

procedure TForm1.UpdateHunkInfo;
begin
 case MemoryGroup.ItemIndex of 0:begin
                                   MemLoad:=ANY_MEM;
                                   EditHunkName.Text:='ANYMEM';
                                 end;
                               1:begin
                                    MemLoad:=CHIP_MEM;
                                    EditHunkName.Text:='CHIPMEM';
                                  end;
                               2:begin
                                    MemLoad:=FAST_MEM;
                                    EditHunkName.Text:='FASTMEM';
                                  end;
 end;
 if EditSizeName.Text<>'' then IncludeFileSize:=true else IncludeFileSize:=false;
end;

procedure TForm1.CreateHunkFile;
var
  outF  : File;
  error : word;
  size  : longword;
begin
  if SaveDialog.Execute = false then exit;
 {$I-}
  System.Assign(outF,SaveDialog.FileName);
  System.Rewrite(outF,1);

  WriteHunkUnit(outF);
  WriteHunkName(outF,EditHunkName.Text);
  size:=WriteHunkData(outF,MemLoad,OpenDialog.Filename,IncludeFileSize);
  WriteHunkExt(outF,EditDataName.Text);
  if IncludeFileSize then WriteHunkExtSize(outF,EditSizeName.Text,size);
  WriteHunkEnd(outF);
  system.close(outF);
  error:=IORESULT;
{$I+}
  if error=0 then
  begin
    InfoLabel.Caption:='New hunk successfully created and saved!';
  end
  else
  begin
    InfoLabel.Caption:='Ouch it looks like we had booboo!';
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.SaveAsClick(Sender: TObject);
begin
  if ValidFields then CreateHunkFile;
end;

procedure TForm1.MemoryGroupClick(Sender: TObject);
begin
  UpdateHunkInfo;
end;

procedure TForm1.InFileClick(Sender: TObject);
var
  sname : string;
begin
 // OpenDialog.Filter := 'Windows BMP|*.bmp|PNG|*.png|PC Paintbrush |*.pcx|DP-Amiga IFF LBM|*.lbm|DP-Amiga IFF BBM Brush|*.bbm|GIF|*.gif|RM RAW Files|*.raw|All Files|*.*';
  if OpenDialog.Execute then
  begin
    InfoLabel.Caption:='';
    EditFileName.Text:=OpenDialog.FileName;
    sname:=LowerCase(ExtractFileName(ExtractFileNameWithoutExt(OpenDialog.FileName)));
    EditDataName.Text:='_'+sname;
    EditSizeName.Text:='_'+sname+'_size';
    UpdateHunkInfo;
  end;
end;



end.

