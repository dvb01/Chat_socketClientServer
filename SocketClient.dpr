program SocketClient;



uses
  Vcl.Forms,
  UnitClient in 'UnitClient.pas' {Form2},
  AmClientChatSocket in 'AmClientChatSocket.pas',
  AmChatCustomSocket in 'AmChatCustomSocket.pas',
  AmChatClientForm in 'AmChatClientForm.pas' {ChatClientForm},
  AmChatClientEditor in 'AmChatClientEditor.pas',
  AmChatClientComponets in 'AmChatClientComponets.pas',
  AmControls in '..\..\My_mod\LIB_Am\AmControls.pas',
  AmChatClientMessageBox in 'AmChatClientMessageBox.pas',
  AmChatClientContactBox in 'AmChatClientContactBox.pas',
  AmChatClientPeopleBox in 'AmChatClientPeopleBox.pas',
  AmVoiceControl in 'AmVoiceControl.pas',
  AmVoiceRecord in 'AmVoiceRecord.pas',
  AmMessageFilesControl in 'AmMessageFilesControl.pas',
  AmChatClientFileThread in 'AmChatClientFileThread.pas',
  AmChatClientParticipantBox in 'AmChatClientParticipantBox.pas',
  AmFormPopapNewMessage in 'AmFormPopapNewMessage.pas' {FormPopapNewMessage};

{$R *.res}
{$R ChatRes.RES}

begin
//C:\Windows\SysWOW64>regsvr32.exe /s "E:\Red 10.3\Projects\socketClientServer\Win32\test\lib\bass.dll"
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
