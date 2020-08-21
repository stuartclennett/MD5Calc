unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type

  TNotifyStringEvent = procedure (Sender: TObject; const aString: string) of object;

  TfrmMain = class(TForm)
    edtFilename: TEdit;
    edtMD5: TEdit;
    edtExpected: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure edtFilenameChange(Sender: TObject);
  private
    procedure CalcMD5(aFilename: string; fOnCalculated: TNotifyStringEvent);
    procedure HandleOnCalculated(Sender: TObject; const aString: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Threading, IdHashMessageDigest;

{$R *.dfm}

procedure TfrmMain.Button1Click(Sender: TObject);
var
  dlgOpen: TOpenDialog;
begin
  dlgopen := TOpenDialog.create(nil);
  try
    if dlgOpen.Execute then
      edtFilename.text := dlgOpen.Filename;
  finally
    dlgOpen.free;
  end;
end;

procedure TfrmMain.HandleOnCalculated(Sender: TObject; const aString : String);
begin
  edtMD5.text := aString;
end;

procedure TfrmMain.edtFilenameChange(Sender: TObject);
begin
  CalcMD5(TEdit(Sender).Text, HandleOnCalculated);
end;

procedure TfrmMain.CalcMD5(aFilename: string; fOnCalculated: TNotifyStringEvent);
begin
  TTask.Run(
    procedure
    var
      Stream : TMemoryStream;
      MD5: TIdHashMessageDigest5;
      aMD5 : string;
    begin
      MD5 := nil;
      Stream := TMemoryStream.Create;
      try
        Stream.LoadFromFile(aFilename);
        Stream.Position := 0;
        MD5 := TIdHashMessageDigest5.Create;
        aMD5 := MD5.HashStreamAsHex(Stream);
        TThread.Queue(nil,
          procedure
          begin
            if assigned(fOnCalculated) then
              fOnCalculated(Stream, aMD5);
          end
          );
      finally
        MD5.Free;
        Stream.Free;
      end;
    end
  )
end;

end.
