unit AmServerChat;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,AmChatCustomSocket,Winapi.WinSock,AmLIst,
  AmChatServerBaza,AmUserType,AmChatServerBazaHelpType,AmMultiSockTcpCustomThread,
  AmMultiSockTcpCustomPrt,System.Zip,
  System.Diagnostics;




  type
    TonListClientUpdate = procedure ( ) of object;




  type
    TAmChatServer = class(TAmChatCustomSocketServer)
     private
       FOnListActivUpdate: TonListClientUpdate;
       procedure DoListActivUpdate;
       procedure ChatNewAddClient     (Client:TCustomParam.TClient) ;
       procedure ChatRemoveClient     (ClientPort:integer) ;
       procedure SendToUsers          (NeedDeleteFile:boolean;
                                       ClientThread:TAmSocketMultiServerThreadListen;
                                       ResBaza:TAmBth.TMainResult;
                                       PrtUser,PrtOthers:TAmProtocolSock;
                                       ClientDisconnectAfterSend:boolean=false);
       procedure ChatSendStringOthers(Port:integer;Text:string;Prt:TAmProtocolSock);
       function  ZipOpenOneFile(FnZip,SerchFn,DirCteateNewFile:string):TFileName;
     protected
        procedure   Execute; override;
        procedure   SockClientConnectThread (Thread : TObject); override;
        procedure   SockClientDisconnect (Sender: TObject; Socket: TCustomWinSocket);override;

        procedure ReadAfter   (Thread:TObject;
                                var Prt:TAmProtocolSock;
                                var Stream:TStream;
                                var IsNeedCloseConnect:boolean;
                                ResultRead:boolean) ;
        procedure ReadBefore (Thread:TObject;
                                var Prt:TAmProtocolSock;
                                var Stream:TStream;
                                var IsNeedCloseConnect:boolean);





        procedure ReadPostAfter(ClientThread :TAmSocketMultiServerThreadListen;
                                Port:integer;
                                var Prt:TAmProtocolSock;
                                JsonString:string;
                                ResultRead:boolean);

        procedure ReadDonwloadAfter(ClientThread :TAmSocketMultiServerThreadListen;
                                Port:integer;
                                var Prt:TAmProtocolSock;
                                JsonString:string;
                                ResultRead:boolean);





        procedure ReadUploadBefore( ClientThread:TAmSocketMultiServerThreadListen;
                                Port:integer;
                                var Prt:TAmProtocolSock;
                                var Stream:TStream;
                                var IsNeedCloseConnect:boolean);
        procedure ReadUploadAfter(
                                   ClientThread:TAmSocketMultiServerThreadListen;
                                   Port:integer;
                                   var Prt:TAmProtocolSock;
                                   var Stream:TStream;
                                   var IsNeedCloseConnect:boolean;
                                   ResultRead:boolean);

     public
        Baza:TAmChatServerBaza;
        property OnListActivUpdate:TonListClientUpdate read FOnListActivUpdate write FOnListActivUpdate;
        constructor Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
        destructor  Destroy; override;
    end;




implementation








              {TAmChatServer}
constructor TAmChatServer.Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
begin
    inherited  Create(AmiliSecondsTimeOutWaitFor);
    Baza:=TAmChatServerBaza.Create;
    OnAfterRead:=ReadAfter;
    OnBeforeRead:= ReadBefore;
end;
destructor  TAmChatServer.Destroy;
begin
    inherited Destroy;
    Baza.Free;
end;
procedure   TAmChatServer.Execute;
begin
 inherited Execute;
end;

                        {ClientConnect}
procedure   TAmChatServer.SockClientConnectThread (Thread : TObject);
var Client:TCustomParam.TClient;
    ClientThread:TAmSocketMultiServerThreadListen;
begin

  try
   inherited;
   if not Assigned(Thread) or not (Thread is TAmSocketMultiServerThreadListen) then exit;
   ClientThread:=  TAmSocketMultiServerThreadListen(Thread);
   Client.ip:= ClientThread.ClientSocket.LocalAddress;
   Client.port:= ClientThread.ClientSocket.RemotePort;
   Client.WinName:= ClientThread.ClientSocket.LocalHost;
   Client.Thread:=  ClientThread;
   ChatNewAddClient(Client);
  except
     on e:exception do
     Log('Error.TAmChatServer.SockClientConnectThread ',e);
  end;
end;

                          {ClientAdd}
procedure TAmChatServer.ChatNewAddClient(Client:TCustomParam.TClient) ;
begin
  try
     // .Log('TAmChatServer.ChClientConnect '+Client.port.ToString);
      Baza.lock;
      try
       Baza.ListActiv.Add(Client);
      finally
        Baza.Unlock;
      end;
       DoListActivUpdate ;
  except
     on e:exception do
    Log('Error.TAmChatServer.ChatNewAddClient ',e);
  end;
end;
procedure   TAmChatServer.SockClientDisconnect (Sender: TObject; Socket: TCustomWinSocket);
begin
  try
   inherited;
   ChatRemoveClient(Socket.RemotePort);
  except
     on e:exception do
     Log('Error.TAmChatServer.SockClientDisconnect ',e);
  end;
end;


                            {ClientRemove}
procedure TAmChatServer.ChatRemoveClient(ClientPort:integer) ;
var ResultBaza:TAmBth.TMainResult;
    PrtOutUser:TAmProtocolSock;
    ClientThread:TAmSocketMultiServerThreadListen;
    IndexClientPort:integer;
begin
  try
    //  Log('TAmChatServer.ChClientDisconnect'+ClientPort.ToString);
    if  Terminated then exit;
    if  ClientPort<0 then exit;

     Baza.lock;
     try
         PrtOutUser.Clear;
         ResultBaza.Clear;

         IndexClientPort:= Baza.ListActiv.SerchPort(ClientPort);
         if IndexClientPort>=0 then
         begin
           ClientThread:=Baza.ListActiv.List[IndexClientPort].Thread;
           Baza.ListActiv.ListId_Delete(AmInt(Baza.ListActiv.List[IndexClientPort].Id,-1));
           ResultBaza:=Baza.Diconnect(ClientPort,IndexClientPort);

         end;
         Baza.ListActiv.Delete(ClientPort,IndexClientPort);


       

     finally
     Baza.Unlock;
     end;

     SendToUsers(false,ClientThread,ResultBaza,PrtOutUser,PrtOutUser);
     DoListActivUpdate ;


  except
     on e:exception do
     Log('Error.TAmChatServer.ChatRemoveClient ',e);
  end;
end;


                               {Read Before}

procedure TAmChatServer.ReadBefore (Thread:TObject;
                                   var Prt:TAmProtocolSock;
                                   var Stream:TStream;
                                   var IsNeedCloseConnect:boolean);
var
    ClientThread:TAmSocketMultiServerThreadListen;
    Port:integer;
begin
  try
     IsNeedCloseConnect:=true;
     if not Assigned(Thread) or not (Thread is TAmSocketMultiServerThreadListen) then exit();
     ClientThread:=  TAmSocketMultiServerThreadListen(Thread);
     Port:= ClientThread.ClientSocket.RemotePort;
     IsNeedCloseConnect:=false;


     if (Prt.TypeRequest= AmPrtSockTypeRequest.cPost)
     or (Prt.TypeRequest= AmPrtSockTypeRequest.cDonwload) then
     begin
       if Prt.TypeData = AmPrtSockTypeData.dJsonString then
       Stream:= TMemoryStream.Create as TStream
       else
       begin
         log('BeforeRead.cPost.cDonwload не верно указан заголовок  TypeData '+Prt.TypeData.ToString+' ');
         IsNeedCloseConnect:=true;
       end;

     end
     else if Prt.TypeRequest= AmPrtSockTypeRequest.cUpload then
     begin
       if (Prt.TypeData =  AmPrtSockTypeData.dFile)
       or (Prt.TypeData =  AmPrtSockTypeData.dMemory)  then
       ReadUploadBefore(ClientThread,Port,Prt,Stream,IsNeedCloseConnect)
       else
       begin
         log('BeforeRead.cUpload не верно указан заголовок '+Prt.TypeData.ToString+' ');
         IsNeedCloseConnect:=true;
       end;
     end
     else
     begin
        log('TAmChatServer.ReadBefore не верно указан заголовок TypeRequest '+Prt.TypeRequest.ToString+' ');
        IsNeedCloseConnect:=true;
     end;

  except
     on e:exception do
     Log('Error.TAmChatServer.ReadBefore ',e);
  end;
end;
                                 {Read After}

procedure TAmChatServer.ReadAfter (Thread:TObject;
                                   var Prt:TAmProtocolSock;
                                   var Stream:TStream;
                                   var IsNeedCloseConnect:boolean;
                                   ResultRead:boolean) ;
var
  ClientThread:TAmSocketMultiServerThreadListen;
  Port:integer;
begin

  try
     try
           IsNeedCloseConnect:=false;
           ClientThread:=  TAmSocketMultiServerThreadListen(Thread);
           Port:= ClientThread.ClientSocket.RemotePort;
           if Not ResultRead then
           begin
             log('AfterRead.ResultRead=false ');
             //exit;
           end;
      
           if Prt.TypeRequest= AmPrtSockTypeRequest.cPost then
           begin
             if Prt.TypeData = AmPrtSockTypeData.dJsonString then
              ReadPostAfter(ClientThread,Port,Prt,AmStr(Stream),ResultRead)
             else
             begin
               log('AfterRead.cPost не верно указан заголовок '+Prt.TypeData.ToString+' ');
               IsNeedCloseConnect:=true;
             end;
           end
           else if Prt.TypeRequest= AmPrtSockTypeRequest.cDonwload then
           begin
             if Prt.TypeData = AmPrtSockTypeData.dJsonString then
             ReadDonwloadAfter(ClientThread,Port,Prt,AmStr(Stream),ResultRead)
             else
             begin
               log('AfterRead.cDonwload не верно указан заголовок '+Prt.TypeData.ToString+' ');
               IsNeedCloseConnect:=true;
             end;
           end
           else if Prt.TypeRequest= AmPrtSockTypeRequest.cUpload then
           begin
             if (Prt.TypeData =  AmPrtSockTypeData.dFile)
             or (Prt.TypeData =  AmPrtSockTypeData.dMemory)  then
             begin
                ReadUploadAfter(ClientThread,Port,Prt,Stream,IsNeedCloseConnect,ResultRead);
               // log('AfterRead.cUpload файл загружен ');
             end
             else
             begin
               log('AfterRead не верно указан заголовок '+Prt.TypeData.ToString+' ');
               IsNeedCloseConnect:=true;
             end;
           end
           else
           begin
              log('TAmChatServer.ReadAfter не верно указан заголовок TypeRequest '+Prt.TypeRequest.ToString+' ');
              IsNeedCloseConnect:=true;
           end;
     finally
       if Assigned(Stream) then Stream.Free;
       Stream:=nil;
     end;

  except
     on e:exception do
     Log('Error.TAmChatServer.ReadAfter ',e);
  end;


end;


                                 {Read Post After}
procedure TAmChatServer.ReadPostAfter(ClientThread :TAmSocketMultiServerThreadListen;
                        Port:integer;
                        var Prt:TAmProtocolSock;
                        JsonString:string;
                        ResultRead:boolean);
var ResultBaza:TAmBth.TMainResult;
    PrtOutUser:TAmProtocolSock;
    PrtOutOthers:TAmProtocolSock;
    Tim:TStopwatch;
    Time:int64;
begin
  try
     ResultBaza.Clear;
     PrtOutUser.Clear;
     PrtOutOthers.Clear;

     PrtOutUser.CopySeans(Prt);

     Tim:=TStopwatch.StartNew;
     Tim.Start;

     Baza.lock;
     try
     ResultBaza:=Baza.Pars(Port , JsonString,ResultRead);
     finally Baza.Unlock;  end;
     Time:=Tim.ElapsedMilliseconds;
     Tim.Stop;
     Log('ReadPostAfter:'+Time.ToString);


     SendToUsers(false,ClientThread,ResultBaza,PrtOutUser,PrtOutOthers);
  except
     on e:exception do
     Log('Error.TAmChatServer.ReadPostAfter ',e);
  end;
end;


                                    {Read Donwload After}
procedure TAmChatServer.ReadDonwloadAfter(ClientThread :TAmSocketMultiServerThreadListen;
                        Port:integer;
                        var Prt:TAmProtocolSock;
                        JsonString:string;
                        ResultRead:boolean);
var ResultBaza:TAmBth.TMainResult;
    PrtOutUser:TAmProtocolSock;
    PrtOutOthers:TAmProtocolSock;
    NewFnZipOne:string;
begin
  try
     ResultBaza.Clear;
     PrtOutUser.Clear;
     PrtOutOthers.Clear;

     PrtOutUser.CopySeans(Prt);
     PrtOutUser.IdFile:= Prt.IdFile;
     PrtOutUser.TypeFile:= Prt.TypeFile;
     Baza.lock;
     try

     ResultBaza:=Baza.ParsDonwload(Port , JsonString , PrtOutUser, ResultRead);
     finally Baza.Unlock;  end;

    if ResultBaza.Result
    and not ResultBaza.IsJsonSend
    and (ResultBaza.CmdFN=2)
    and (ResultBaza.FileNameFN<>'')
    and (ResultBaza.FileNameFNZipIndex<>'')
    and (ResultBaza.DirFNTime<>'')
    and (PrtOutUser.TypeFile = AmPrtSockTypeFile.Zip) then
    begin
       // с зип архива нужно доставть один файл и отправить
      NewFnZipOne:= ZipOpenOneFile(ResultBaza.FileNameFN,ResultBaza.FileNameFNZipIndex,ResultBaza.DirFNTime);
      if (NewFnZipOne<>'') and FileExists(NewFnZipOne) and AmFileIsFreeRead(NewFnZipOne) then
      begin
         ResultBaza.FileNameFN:= NewFnZipOne;
         ResultBaza.FileNameFNZipIndex:='';
         SendToUsers(true,ClientThread,ResultBaza,PrtOutUser,PrtOutOthers);
      end
      else
      begin
         if (NewFnZipOne<>'') and FileExists(NewFnZipOne) then DeleteFile(NewFnZipOne);
         Log('TAmChatServer.ReadDonwloadAfter не удалось получить один файл с zip архива искомый файл:'+ResultBaza.FileNameFNZipIndex);
      end;
      

    end
    else SendToUsers(false,ClientThread,ResultBaza,PrtOutUser,PrtOutOthers);
     




  except
     on e:exception do
     Log('Error.TAmChatServer.ReadDonwloadAfter ',e);
  end;
end;
function  TAmChatServer.ZipOpenOneFile(FnZip,SerchFn,DirCteateNewFile:string):TFileName;
   var Zip: TZipFile;
       LocalHeader: TZipHeader;
      index:integer;
      Stream:TStream;
      NameZip,NameNewZip:string;
      Ext:string;
      FileStream:TFileStream;
begin
      Result:='';
      Zip:=TZipFile.Create;
      try
           try
              Zip.Open(FnZip,zmRead);
              try
                 index:= Zip.IndexOf(SerchFn);
                 if index>=0 then
                 begin
                   NameZip:=ExtractFileName(FnZip);
                   NameZip:=NameZip.Split(['.'])[0];
                   Ext:='.time';
                   NameZip:= NameZip +'_'+generatPass(12)+Ext;
                   NameNewZip:=DirCteateNewFile+NameZip;

                   Zip.Read(index, Stream, LocalHeader);
                   FileStream:=TFileStream.Create(NameNewZip,fmCreate);
                   try
                      FileStream.CopyFrom(Stream,Stream.Size);
                      if FileStream.Size>0 then Result:= NameNewZip;
                   finally
                     Stream.Free;
                     FileStream.Free;
                   end;

                 end;

              finally
                Zip.Close;
              end;
           except
             on e:exception do
             begin
             Log('Error.TAmChatServer.ZipOpenOneFile ',e);
             if (NameNewZip<>'') and FileExists(NameNewZip) then DeleteFile(NameNewZip);
             Result:='';
             end;
           end;
      finally
        Zip.Free;
      end;

end;



                                 {Read Upload Before}
procedure TAmChatServer.ReadUploadBefore(
                                           ClientThread:TAmSocketMultiServerThreadListen;
                                           Port:integer;
                                           var Prt:TAmProtocolSock;
                                           var Stream:TStream;
                                           var IsNeedCloseConnect:boolean);
var
    BazaResult:TAmBth.TMainResult;
    PrtOutUser:TAmProtocolSock;
    CheckCountProcessing:integer;
begin
  try
    BazaResult.Clear;

    Baza.lock;
    try  BazaResult:=
         Baza.ParsBeforeUpload(Port,Prt.TypeFile,string(Prt.IdFile), string(Prt.Token),string(Prt.Hash),string(Prt.TokenAuth));
    finally Baza.Unlock; end;

    if  BazaResult.Result
    and (BazaResult.FileNameFN<>'') then
    begin
          if FileExists(BazaResult.FileNameFN)
          and AmIsFileInUse(BazaResult.FileNameFN) then
          begin
             log('BeforeReadFile Prt.NameFile  Файл сейчас используется другим процессом '+BazaResult.FileNameFN);
             IsNeedCloseConnect:=true;
          end
          else
          begin
             try
                  Stream := TFileStream.Create(BazaResult.FileNameFN,fmCreate) as TStream;
             except
               on e:exception do
               begin
               log('Error.BeforeReadFile Prt.NameFile '+e.Message);
               IsNeedCloseConnect:=true;
               end;
             end;
          end;
    end
    else
    begin
        log('send udload error');
        PrtOutUser.Clear;
        PrtOutUser.CopySeans(Prt);
        SendToUsers(false,ClientThread,BazaResult,PrtOutUser,PrtOutUser,false);
        sleep(6000);
        IsNeedCloseConnect:=true;
         log('send udload error CloseConnect');
    end;

  except
     on e:exception do
     Log('Error.TAmChatServer.ReadUploadBefore ',e);
  end;

end;


                              {Read Upload After}
procedure TAmChatServer.ReadUploadAfter(
                                         ClientThread:TAmSocketMultiServerThreadListen;
                                         Port:integer;
                                         var Prt:TAmProtocolSock;
                                         var Stream:TStream;
                                         var IsNeedCloseConnect:boolean;
                                         ResultRead:boolean);
var
  BazaResult:TAmBth.TMainResult;
  PrtOutUser:TAmProtocolSock;
  FileName:string;
begin
  try
      FileName:='';
      BazaResult.Clear;
      Baza.lock;
      try  BazaResult:=
           Baza.ParsAfterUpload(Port,Prt.TypeFile,string(Prt.IdFile),ResultRead);
      finally Baza.Unlock; end;

      if Assigned(Stream) and( Stream is TFileStream) then
      FileName:= TFileStream(Stream).FileName;

  
      if Assigned(Stream) then Stream.Free;
      Stream:=nil;
      if not ResultRead and (FileName<>'') and FileExists(FileName) and not DeleteFile(FileName) then
      begin
        sleep(1000);
        DeleteFile(FileName);
      end;



      if  BazaResult.Result then
      begin
          PrtOutUser.Clear;
          PrtOutUser.CopySeans(Prt);
          SendToUsers(false,ClientThread,BazaResult,PrtOutUser,PrtOutUser);
      end;
  except
     on e:exception do
     Log('Error.TAmChatServer.ReadUploadAfter ',e);
  end;
end;




procedure TAmChatServer.SendToUsers  (NeedDeleteFile:boolean;
                                      ClientThread:TAmSocketMultiServerThreadListen;
                                      ResBaza:TAmBth.TMainResult;
                                      PrtUser,PrtOthers:TAmProtocolSock;
                                      ClientDisconnectAfterSend:boolean=false);
var I:integer;
begin
  try

     if ResBaza.IsSendUser then
     begin
       if ResBaza.IsJsonSend then
       begin
          PrtUser.TypeRequest:= AmPrtSockTypeRequest.cPost;
          PrtUser.TypeData:=AmPrtSockTypeData.dJsonString;

          ResBaza.CmdFN:=SendString(ResBaza.TextOutputUser,PrtUser,ClientThread,False);
         // Log('SendToUsers.IsJsonSend Result='+ResBaza.CmdFN.ToString +' '+ResBaza.TextOutputUser);
       end
       else
       begin
          if (ResBaza.CmdFN = 1) and Assigned(ResBaza.MsFN) then
          begin
              PrtUser.TypeRequest:= AmPrtSockTypeRequest.cUpload;
              PrtUser.TypeData:=AmPrtSockTypeData.dMemory;

              ResBaza.CmdFN:=SendStream(ResBaza.MsFN,PrtUser,ClientThread,False);
              if ResBaza.CmdFN<=0 then
              begin
                 ResBaza.MsFN.Free;
                 log('SendToUsers.IsJsonSend.MsFM не удалось отправить ms Result='+ResBaza.CmdFN.ToString);
              end;
          end
          else if (ResBaza.CmdFN = 2) and (ResBaza.FileNameFN<>'') then
          begin
              PrtUser.TypeRequest:= AmPrtSockTypeRequest.cUpload;
              PrtUser.TypeData:=AmPrtSockTypeData.dFile;
             ResBaza.CmdFN:=SendFile(ResBaza.FileNameFN,NeedDeleteFile,PrtUser,ClientThread,False);
             if (ResBaza.CmdFN<=0) and NeedDeleteFile then DeleteFile(ResBaza.FileNameFN);
             
            // Log('SendToUsers.IsJsonSend.FileNameFN Result='+ResBaza.CmdFN.ToString);
          end
          else  log('TAmChatServer.SendToUsers ResBaza.CmdFN не совподает CmdFN='+ResBaza.CmdFN.ToString);


       end;
     end;
     if ResBaza.IsSendOthers then
     begin
         PrtOthers.TypeRequest:= AmPrtSockTypeRequest.cPost;
         PrtOthers.TypeData:=AmPrtSockTypeData.dJsonString;

         for I := 0 to ResBaza.ListPort.Count-1 do
         if ResBaza.TextOutputOthers<>'' then
         ChatSendStringOthers(ResBaza.ListPort[i],ResBaza.TextOutputOthers,PrtOthers);
     end;
  except
     on e:exception do
     Log('Error.TAmChatServer.SendToUsers ',e);
  end;
end;
procedure TAmChatServer.ChatSendStringOthers(Port:integer;Text:string;Prt:TAmProtocolSock);
var Index:integer;
    Thread:TAmSocketMultiServerThreadListen;
begin
  try
       //  OutText:= ConstAmChat.WordBegin+OutText+ConstAmChat.WordEnd;
        Thread:=nil;
//        Result:=-2;
        Baza.lock;
        try
         Index:= Baza.ListActiv.SerchPort(Port);
         if Index>=0 then
          Thread:=Baza.ListActiv.List[Index].Thread
        finally
          Baza.Unlock;
        end;
        if Assigned(Thread) then SendString(Text,Prt,Thread);
       // Log('ChatSendStringOthers Result='+Result.ToString);
  except
     on e:exception do
     Log('Error.TAmChatServer.ChatSendStringOthers ',e);
  end;
end;
procedure TAmChatServer.DoListActivUpdate;
begin
   if Assigned(FOnListActivUpdate) then FOnListActivUpdate();
end;












end.
