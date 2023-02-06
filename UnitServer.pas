unit UnitServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,AmServerChat,AmlogTo,AmLIst,AmChatServerBaza,
  Vcl.ExtCtrls,amUSerType, Vcl.Imaging.pngimage,AmSocketLongDataTransfer,AmChatServerBazaHelpType,AmChatCustomSocket,
  TypInfo;

type
  TForm1 = class(TForm)
    memoLog: TMemo;
    Label1: TLabel;
    Edit1: TEdit;
    ButtonStart: TButton;
    Memo1: TMemo;
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit2: TEdit;
    procedure ButtonStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
    procedure AcvtiveList( );
    procedure Wm_IMG (var Msg:Tmessage); message wm_user+11;
  end;

var
  Form1: TForm1;
  Sr:TAmChatServer;


implementation

{$R *.dfm}

procedure TForm1.AcvtiveList( );
begin
postmessage(self.Handle,wm_user+11,0,0);
end;
procedure TForm1.Wm_IMG (var Msg:Tmessage); //message wm_user+10;
var i: integer;
s:string;
Cl: TAmBth.TListActiv.TOneClient;
begin

    memo1.Clear;
    if not Assigned(Sr) then exit;
    try
       Sr.Baza.Lock;
       try
            try

             for I := 0 to Sr.Baza.ListActiv.List.Count-1 do
             begin
               Cl:= Sr.Baza.ListActiv.List[i];

               s:=amStr(Cl.port);
               memo1.Lines.Add(s);
             end;
            except
              showmessage('TForm1.AcvtiveList');
            end;


       finally
          Sr.Baza.Unlock;
       end;
    except
       showmessage('TForm1.AcvtiveList 2');
    end;

end;


procedure TForm1.Button1Click(Sender: TObject);

begin
   if Assigned(Sr) then
   begin
      Sr.Terminate;
      Sr.WaitFor;
      FreeAndNil(Sr);
   end;
  //  AcvtiveList(Sr.Baza.ListActiv.List);
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin

Button1Click(self);
Sr:=TAmChatServer.Create(10000);
Sr.OnListActivUpdate:= AcvtiveList;
Sr.Port:=strtoint(Edit1.Text);
Sr.OnLog:=LogMain.LogProc;
Sr.Start;

end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

LogMain.Global_CanCreatePopap:=false;
LogMain.Global_CanCreateNewRecordToMemo :=false;
Button1Click(Sender);

LogMain.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    ReportMemoryLeaksOnShutdown := true;
    LogMain:= TamLogString.create(self);

    LogMain.SetErrorLog.fmemo                :=  memoLog;
    LogMain.SetErrorLog.FileName             :=  ExtractFilePath(Application.ExeName)+'set\log\log.txt';
    LogMain.SetErrorLog.TimeNeed                  :=true;
    LogMain.SetErrorLog.Format                    := 1;
    LogMain.SetErrorLog.CanCreatePopPap      := 3;

    LogMain.SetLog.fmemo                     :=memoLog;
    LogMain.SetLog.FileName                  :=  ExtractFilePath(Application.ExeName)+'set\log\log.txt';
    LogMain.SetLog.TimeNeed                  :=true;
    LogMain.SetLog.Format                    := 2;
    LogMain.SetLog.CanCreatePopPap           := 3;

    LogMain.SetErrorApplication.fmemo        :=memoLog;
    LogMain.SetErrorApplication.FileName     :=  ExtractFilePath(Application.ExeName)+'set\log\logErrorApplication.log';
    LogMain.SetErrorApplication.TimeNeed                  :=true;
    LogMain.SetErrorApplication.Format                    := 1;
    LogMain.SetErrorApplication.CanCreatePopPap      := 1;

    LogMain.Global_CanCreatePopap:=true;
    LogMain.Global_CanCreateNewRecordToMemo:=true;
    LogMain.Global_CanCreateNewRecordToFile :=false;
    LogMain.CanCreateNewFileIfFileBig    :=false;

    LogMain.UpdateSettingExeAfterCreate;

end;

end.
