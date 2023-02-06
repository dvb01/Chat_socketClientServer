unit AmFormPopapNewMessage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;
type
  TFormPopapNewMessage_OnOpenDialog = procedure (Id,TypeUser:string) of object;
type
  TFormPopapNewMessage = class(TForm)
    L_Message: TLabel;
    L_UserName: TLabel;
    L_Close: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure L_UserNameClick(Sender: TObject);
    procedure L_MessageClick(Sender: TObject);
    procedure L_CloseClick(Sender: TObject);
  private
    { Private declarations }
     FId,FTypeUser:string;
     FOnOpenDialog:TFormPopapNewMessage_OnOpenDialog;

  public
    { Public declarations }
     procedure OpenForm(Id,TypeUser,UserName,Message:string);
     procedure CloseForm;
     property  OnOpenDialog : TFormPopapNewMessage_OnOpenDialog read FOnOpenDialog write FOnOpenDialog;
  end;
   procedure FormPopapNewMessageCreate();
   procedure FormPopapNewMessageDestroy();
var
  FormPopapNewMessage: TFormPopapNewMessage;

implementation

{$R *.dfm}
procedure FormPopapNewMessageCreate();
begin
    FormPopapNewMessage:= TFormPopapNewMessage.create(nil);
end;
procedure FormPopapNewMessageDestroy();
begin
   if Assigned(FormPopapNewMessage) then  
   FormPopapNewMessage.Free;
   FormPopapNewMessage:=nil;
end;
procedure TFormPopapNewMessage.CloseForm;
begin
   self.Hide;
end;

procedure TFormPopapNewMessage.OpenForm(Id,TypeUser,UserName,Message:string);
begin
   FId:=       Id;
   FTypeUser:= TypeUser;
   L_UserName.Caption:= UserName;
   L_Message.Caption:= Message;

  Top :=0;// Screen.Height - Height;
  Left := 0;//Screen.Width -Width;
   self.Show;
end;
procedure TFormPopapNewMessage.FormClick(Sender: TObject);
begin
 if Assigned(FOnOpenDialog) then FOnOpenDialog(FId,FTypeUser);
 self.Hide;
end;

procedure TFormPopapNewMessage.FormCreate(Sender: TObject);
begin
  //
  Top :=0;// Screen.Height - Height;
  Left := 0;//Screen.Width -Width;
  self.Hide;
end;

procedure TFormPopapNewMessage.FormHide(Sender: TObject);
begin
   FId:=       '';
   FTypeUser:= '';
   L_UserName.Caption:= '';
   L_Message.Caption:= '';
end;

procedure TFormPopapNewMessage.FormShow(Sender: TObject);
begin
      //
end;

procedure TFormPopapNewMessage.L_CloseClick(Sender: TObject);
begin
self.Hide;
end;

procedure TFormPopapNewMessage.L_MessageClick(Sender: TObject);
begin
    FormClick(self);
end;

procedure TFormPopapNewMessage.L_UserNameClick(Sender: TObject);
begin
    FormClick(self);
end;

end.
