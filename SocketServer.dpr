program SocketServer;

uses
  Vcl.Forms,
  UnitServer in 'UnitServer.pas' {Form1},
  AmServerChat in 'AmServerChat.pas',
  AmChatCustomSocket in 'AmChatCustomSocket.pas',
  AmChatServerBaza in 'AmChatServerBaza.pas',
  AmSocketLongDataTransfer in 'AmSocketLongDataTransfer.pas',
  AmChatServerBazaHelpType in 'AmChatServerBazaHelpType.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
