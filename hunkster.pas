program hunkster;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  hunklib;

type
  { THunkster }

  THunkster = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ THunsker }

procedure THunkster.DoRun;
var
  MemLoad,Size : Longword;
  IncludeFileSize : boolean;
  HunkName : String;
  infile,outfile : string;
  outF : File;
  DataName,DataSizeName : String;

begin
  CaseSensitiveOptions:=false;

  // parse parameters
  if HasOption('h', 'help') or (ParamCount < 2) then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  infile:=paramstr(1);
  outfile:=paramstr(2);
  MemLoad:=ANY_MEM;
  IncludeFileSize:=False;
  Dataname:='_'+ExtractFileName(infile);
  
  DataSizeName:=DataName+'_size';
  HunkName:='ANY';

  if UpperCase(GetOptionValue('m')) = 'CHIP' then 
  begin
     MemLoad:=CHIP_MEM;
     Hunkname:='CHIP';
  end;   

  if UpperCase(GetOptionValue('m')) = 'FAST' then 
  begin
    MemLoad:=FAST_MEM;
    Hunkname:='FAST';
  end;  

  if GetOptionValue('dn')<>'' then 
  begin
    DataName:=GetOptionValue('dn');
    //writeln('Dataname:',DataName);
  end;  
  if GetOptionValue('ds')<>'' then DataSizeName:=GetOptionValue('ds');
  if GetOptionValue('hn') <>'' then Hunkname:=GetOptionValue('hn');
  if HasOption('i','includesize') then IncludeFileSize:=true;
  
  //using System.Assign because of name collision with class
  System.Assign(outF,outFile);
  System.Rewrite(outF,1);
  write('Writing HunkUnit..');
  WriteHunkUnit(outF);
  write('HunkName..',HunkName,'..');
  WriteHunkName(outF,HunkName);
  write('HunkData..');
  size:=WriteHunkData(outF,MemLoad,inFile,IncludeFileSize);
  write('HunkExt..');
  WriteHunkExt(outF,DataName);
  if IncludeFileSize then 
  begin
    write('HunkExt..',DataSizeName,'..');
    WriteHunkExtSize(outF,DataSizeName,size);
  end;
  writeln('HunkEnd');
  WriteHunkEnd(outF);
  System.close(outF);

  // stop program loop
  Terminate;
end;

constructor THunkster.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor THunkster.Destroy;
begin
  inherited Destroy;
end;

procedure THunkster.WriteHelp;
begin
  { add your help code here }
  writeln('Hunkster v1.0 for Windows/Linux By RetroNick');
  writeln('Usage: Hunkster infile outhunkfile'); 
  writeln('  Optional -DN  (DataName Value)'); 
  writeln('           -DS  (DataNameSize Value)'); 
  writeln('           -I   (IncludeSize'); 
  writeln('           -HN  (HunkName Value');
  writeln('           -M   (Load to Memory {Chip,Fast,Any}'); 
  writeln('eg. Hunkster image.xgf image.o -DN _image -M chip')
end;

var
  Application: THunkster;

begin

  Application:=THunkster.Create(nil);
  Application.Title:='TheHunkster';
  Application.Run;
  Application.Free;


end.

