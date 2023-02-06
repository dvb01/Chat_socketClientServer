unit AmSocketLongDataTransfer;

interface
uses ScktComp,Vcl.Dialogs,Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes;
type
  TAmSocketLongDataTransfer = record
    type
    TProcSoc = procedure(const S: AnsiString) ;

    var
    InputBuf: string;
    InputDataSize: LongWord;
    InputReceivedSize: LongWord;
    MySProc: TProcSoc;
    function SendLongText(Socket: TCustomWinSocket; S: string): boolean;
    function ReceiveLongText(Socket: TCustomWinSocket; SafeCalledStr: string = ''): boolean;
    procedure FlushBuffers;
    property OnNewMessage : TProcSoc read MySProc write MySProc;
  end;





implementation

function TAmSocketLongDataTransfer.SendLongText(Socket: TCustomWinSocket; S: string): boolean;
var
  TextSize: integer;
  TSSig: string[4];
begin
  Result := True;
  try
    if not Socket.Connected then
      Exit;
    TextSize := Length(S);
    asm
        mov EAX,TextSize;
        mov dword ptr TSSig[1],EAX;
        mov byte ptr TSSig[0],4;

    end;
    S := string(TSSig + S);
    Socket.SendBuf(Pointer(S)^, Length(S));
  except Result := False;
  end;
end;

procedure TAmSocketLongDataTransfer.FlushBuffers;
begin
  InputBuf := '';
  InputDataSize := 0;
  InputReceivedSize := 0;
end;

function TAmSocketLongDataTransfer.ReceiveLongText(Socket: TCustomWinSocket;
  SafeCalledStr: string = ''): boolean;
var
  S: string;
  RDSize: LongWord;
  F: string[4];
  dd:dword;
begin
  Result := True;
  try
    if SafeCalledStr = '' then
    begin
      RDSize := Socket.ReceiveLength;
      S := Socket.ReceiveText;
    end
    else
    begin

      S := SafeCalledStr;
      RDSize := length(S);
    end;
    if (Length(InputBuf) < 4) and (Length(InputBuf) > 0) then
    begin //�������������, � ��� ������
      S := InputBuf + S; //���� �������������� ��� ���������
      FlushBuffers; //����� ������
    end;
    if InputBuf = '' then
    begin //����� ������ �����;
      F := Copy(S, 0, 4);
     // showmessage(F);
     // asm
                      //  mov EAX,dword ptr F[1];
                        //mov InputDataSize,EAX;
     // end;
      InputDataSize:= sizeof(F);
      if InputDataSize = RDSize - 4 then
      begin //���� ���� � ������

        InputBuf := Copy(S, 5, RDSize - 4); //�� ������, �� ������������ ���.
        MySProc(InputBuf);
        FlushBuffers;
        Exit;
      end;
      if InputDataSize < RDSize - 4 then
      begin //����� �������.
        InputBuf := Copy(S, 5, InputDataSize);
        MySProc(InputBuf);
        Delete(S, 1, InputDataSize + 4);
        FlushBuffers;
        ReceiveLongText(Socket, S);
        Exit;
      end;
      if InputDataSize > RDSize - 4 then
      begin //��� ������ ��������
        InputBuf := Copy(S, 5, RDSize - 4); //�������� ������
        InputReceivedSize := RDSize - 4;
      end;
    end
    else
    begin //����� ������ �� ����
      //InputBuf:=
      if RDSize + InputReceivedSize = InputDataSize then
      begin //�������� ���������
        InputBuf := InputBuf + Copy(S, 0, RDSize); //�������� �������
        MySProc(InputBuf); //� ������, ������
        FlushBuffers; // � ������ ������ ���
        Exit;
      end;
      if RDSize + InputReceivedSize < InputDataSize then // ��������
      begin //���������
        InputBuf := InputBuf + Copy(S, 0, RDSize); //��������
        InputReceivedSize := InputReceivedSize + RDSize;
        Exit;
      end;
      if RDSize + InputReceivedSize > InputDataSize then //�������� ��������
      begin // �� � ������ ���� ��� ������ - �������.
        InputBuf := InputBuf + Copy(S, 0, InputDataSize - InputReceivedSize);
        MySProc(InputBuf);
        Delete(S, 1, InputDataSize - InputReceivedSize);
        FlushBuffers;
        ReceiveLongText(Socket, S);
      end;
    end;
  except Result := False;
  end;
end;

end.
