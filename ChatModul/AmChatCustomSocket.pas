unit AmChatCustomSocket;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,AmHandleObject,Winapi.WinSock,
  AmUserType,AmMultiSockTcpCustomThread,AmMultiSockTcpCustom,
  AmMultiSockTcpCustomPrt,
  JsonDataObjects;

  type

   // ConstAmChat.TypeOnline.Check

    ConstAmChat =record
       type
        TypeGroopPrivacy = record
           const OpenChat ='OpenChat';OpenChanell ='OpenChanell';CloseChat ='CloseChat';CloseChanell ='CloseChanell';
          class Function Check(value:string):boolean;  static;
          class Function CheckOpen(value:string):boolean;  static;
          class Function CheckClose(value:string):boolean;  static;
          class Function CheckChat(value:string):boolean;  static;
          class Function NeedVisibleAswert(value:string;TypeUser:string; IsAdmin:boolean):boolean; static;
          class Function CheckChanell(value:string):boolean;  static;

        end;
        TypeUser = record  const User ='User';Chat ='Chat';Groop ='Groop';
        class Function Check(value:string):boolean;  static;
        end;
        TypeContent = record  const Text ='Text';Voice ='Voice';Files ='Files'; Image ='Image';Video ='Video';Emogji ='Emogji';
        class Function Check(value:string):boolean;  static;
        end;
        TypeSistemCommand = record  const SetOnline ='SetOnline';UpConnect ='UpConnect';
        class Function Check(value:string):boolean;  static;
        end;
        TypeMetodReadMessage = record  const AllBeforeReading ='AllBeforeReading';All ='All';OneByOne ='OneByOne';
        class Function Check(value:string):boolean;  static;
        end;
        TypeOnline = record  const Online ='Online';Offline ='Offline';Nearby ='Nearby'; Unknown ='Unknown';
        class Function Check(var value:string):boolean;  static;
        end;
        TypePanelFree = record
          const GroopList ='GroopList';GroopUserAdd = 'GroopUserAdd';GroopEdit = 'GroopEdit';
        end;

     const
       WordBegin:string='*begin*';
       WordEnd:string='*end*';
       RegUser_Call = 1;
       RegUser_Back = 2;
       Auth_Call    = 3;
       Auth_Back    = 4;

       OnlineType_Call    = 5;
       OnlineType_Back    = 6;
       SetPhotoProfile_Call    = 7;
       SetPhotoProfile_Back    = 8;
      // User_PhotoDownload_Call    = 9;
      // User_PhotoDownload_Back    = 10;

       Profile_GetListContacts_Call  = 11;
       Profile_GetListContacts_Back  = 12;

       Message_Send_Call  = 13;
       Message_New_Back  = 14;

       Message_History_Call  = 15;
       Message_History_Back  = 16;

       UpConnect_Call  = 17;
       UpConnect_Back  = 18;

       Message_Read_Call =19;
       Message_Read_Back =20;

       LogOut_Call =      21;

      // Voice_Download_Call =      22;
       //Voice_Download_Back =      23;

       Auth_ActivSeans_Back    = 24;

     //  GetIdFileUpload_Call =25;
     //  GetIdFileUpload_Back =26;

       File_Error_Back    = 27;
       File_Upload_Back    = 28;

       File_GetIdBeforeUpload_Call = 29;
       File_GetIdBeforeUpload_Back = 30;

       Serch_Call  = 31;
       Serch_Back  = 32;

       GroopCreate_Call  = 33;
       GroopCreate_Back  = 34;

       Profile_NewContacts_Back  = 35;

       GroopAddUser_Call  = 36;
       GroopAddUser_Back  = 37;

       Profile_DeleteContacts_Back  = 38;
       Profile_DeleteContacts_Call  = 39;

       GroopDeleteUser_Call  = 40;
       GroopDeleteUser_Back  = 41;

       Groop_GetListUsers_Call  = 42;
       Groop_GetListUsers_Back  = 43;

       Groop_SetPhoto_Call  = 44;
       Groop_SetPhoto_Back  = 45;

       Groop_SetUserName_Call  = 46;
       Groop_SetUserName_Back  = 47;

     type FileGetIdParam = record
          const
           Voice =1;
           Zip = 2;
           Photo = 3;
           PhotoAndZip = 4;



     end;
     type NameFileType = record
         const
           nVoice   ='Voice';
           nFile    ='File';
           nPhoto   ='Photo';
           nNoneExt    ='None';


           eVoiceExt   ='.mp3';
           eFilesExt   ='.zip';
           ePhotoExt   ='.jpg';
           eNoneExt    ='.none';

           class function GetExt(name:string):string; static;
           class function GetName(Ext:string):string; static;
           class Function CheckName(var value:string):boolean;  static;
           class function CheckExt(var value:string):boolean; static;
     end;

     type FileError = record
          const
           CountVal           = 13;
           Donwload           = 'Donwload';
           Upload             = 'Upload';
           Def                = 0;
           Def_Val            = 'Неопознаная ощибка файла на сервере';

           dUseFile           = 1;
           dUseFile_Val       = ' В данный момент нельзя скачать файл';

           dIdFile            = 2;
           dIdFile_Val        = ' Не валидный IdFile';


           dTypeFile          = 3;
           dTypeFile_Val      = ' Не валидный TypeFile';

           uUseFile           = 4;
           uUseFile_Val       = ' Уже есть такой файл';

           uTypeFile          = 5;
           uTypeFile_Val      = ' Не валидный TypeFile';

           uHashFile          = 6;
           uHashFile_Val      = ' Не валидный HashFile';

           uHashFileData      = 7;
           uHashFileData_Val  = ' Время HashFile вышло';

           uHashFileNull      = 8;
           uHashFileNull_Val  = ' Не распознан HashFile';

           uIdFile            = 9;
           uIdFile_Val        = ' Не валидный IdFile';

           dNotFile           = 10;
           dNotFile_Val       = ' На сервере нет такого файла';

           rNotRead           = 11;
           rNotReadVal       = ' Не удалось получить данные полностью ResultRead';

           dNotSerchFile           = 12;
           dNotSerchFileVal       = ' Не удалось найти запрошенный файл в списке файлов';
           Val : array [0..CountVal-1] of string = (
                Def_Val,
                Donwload + dUseFile_Val,
                Donwload + dIdFile_Val,
                Donwload + dTypeFile_Val,

                Upload  +  uUseFile_Val,
                Upload  +  uTypeFile_Val,
                Upload  +  uHashFile_Val,
                Upload  +  uHashFileData_Val,
                Upload  +  uHashFileNull_Val,
                Upload  +  uIdFile_Val,
                Donwload + dNotFile_Val,
                rNotReadVal,
                Donwload + dNotSerchFileVal
           );
     end;
     class function CheckIdFile(IdFile:string):boolean;static;
    end;





  type
    TCustomParam = record
        type
         TClient =record
           ip:string;
           port:integer;
           WinName:string;
           Thread:TAmSocketMultiServerThreadListen;
         end;
        type
         TInput = record
            Text:string;
         end;
        type
         TError = record
            ErrorCode:Integer;
         end;
    end;

  type
    TAmChatEventClient = procedure (Sender: TObject; Client:TCustomParam.TClient) of object;
    TAmChatEventRead = procedure (Sender: TObject; Client:TCustomParam.TClient;Input:TCustomParam.TInput) of object;
    TAmChatEventReadClient = procedure (Sender: TObject;Input:TCustomParam.TInput) of object;
    TAmChatEventError = procedure (Sender: TObject; Client:TCustomParam.TClient;Input:TCustomParam.TError) of object;
    TAmChatEventErrorClient = procedure (Sender: TObject;Input:TCustomParam.TError) of object;


  type
    TAmChatCustomSocketClient = class(AmMultiSockClientCustom)
     private
     protected
        procedure   Execute; override;
     public
        function  SendFile          (FileName:string;        NeedDeleteFile:boolean;Prt:TAmProtocolSock; Disconnect:boolean=false ):int64;override;
        function  SendString        (Text:string;            Prt:TAmProtocolSock; Disconnect:boolean=false):int64; override;
        function  SendStream        (Stream:TStream;         Prt:TAmProtocolSock; Disconnect:boolean=false):int64; override;

        constructor Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
        destructor  Destroy; override;
    end;


  type
    TAmChatCustomSocketServer = class(AmMultiSockServerCustom)
     private
     protected
        procedure   Execute; override;
     public
       constructor Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
       destructor  Destroy; override;
    end;


      Function CustomSocketCheckWholePackage(var InputText:String;WordBegin,WordEnd:string):boolean;
      Function CustomSocketCheckWholePackage2(var InputText:String;WordBegin,WordEnd:string):Tarray<string>;

  type
   TAmChatSocketClientFile = class(AmSockClientGetBlockedCustom)
     private
      function ParsResponse(var Prt: TAmProtocolSock):integer;
      function GetBodyJsonString(Token,Hash,FileName:string):string;
      Function GetFile(IdFile,Token,Hash,FileName:string;TypeFile:integer;Stream:TStream) :integer;

     public
       Host:string;
       Port:integer;
       Function GetPhoto(IdPhoto,Token,Hash:string;Stream:TStream):integer;
       Function GetVoice(IdVoice,Token,Hash:string;Stream:TStream):integer;
       Function GetZip(IdFile,Token,Hash,FileName:string;Stream:TStream):integer;
       Function UploadFile(var Prt: TAmProtocolSock;SendS,ResultS:TStream) :integer;
       Function GetIdForFiles(JsonString:string;var ResultJsonString:string):integer;
    end;


implementation


Function TAmChatSocketClientFile.GetIdForFiles(JsonString:string;var ResultJsonString:string):integer;
var Prt: TAmProtocolSock;
    StreamStr:TStringstream;
    StreamResult:TMemoryStream;
begin
    {
      Result < 0  какая то ошибка  см const этого объекта и родителя
      Result = 0  непонятно что пришло в Stream но запрос выполнен
      Result > 0  что именно пришло в  Stream  см AmPrtSockTypeFile

    }
   ResultJsonString:='';
   StreamStr:= TStringstream.Create(JsonString);
   StreamResult:=  TMemoryStream.Create;
   try
      StreamStr.Position:=0;
      Prt.Clear;
      Prt.TypeRequest:=  AmPrtSockTypeRequest.cPost;
      Prt.TypeData :=    AmPrtSockTypeData.dJsonString;
      Result:= Get(Host,Port,Prt,StreamStr,StreamResult);
      if Result>0 then
      begin
          Result:= ParsResponse(Prt);
          if (Result = AmPrtSockTypeFile.json) And (StreamResult.Size>0)  and (StreamResult.Size<1050*1000) then
          ResultJsonString:= AmStr(StreamResult);
      end;
   finally
     StreamStr.Free;
     StreamResult.Free;
   end;

end;

Function  TAmChatSocketClientFile.UploadFile(var Prt: TAmProtocolSock;SendS,ResultS:TStream) :integer;

begin
    {
      Result < 0  какая то ошибка  см const этого объекта и родителя
      Result = 0  непонятно что пришло в Stream но запрос выполнен
      Result > 0  что именно пришло в  Stream  см AmPrtSockTypeFile

    }

      Prt.TypeRequest  :=  AmPrtSockTypeRequest.cUpload;
      Prt.TypeData     :=  AmPrtSockTypeData.dFile;
      Result:= Get(Host,Port,Prt,SendS,ResultS);
      if Result>0 then  Result:= ParsResponse(Prt);
end;


Function TAmChatSocketClientFile.GetPhoto(IdPhoto,Token,Hash:string;Stream:TStream):integer;
begin
  Result:=GetFile(IdPhoto,Token,Hash,'',AmPrtSockTypeFile.Image,Stream);
end;
Function TAmChatSocketClientFile.GetVoice(IdVoice,Token,Hash:string;Stream:TStream):integer;
begin
  Result:=GetFile(IdVoice,Token,Hash,'',AmPrtSockTypeFile.Voice,Stream);
end;
Function TAmChatSocketClientFile.GetZip(IdFile,Token,Hash,FileName:string;Stream:TStream):integer;
begin
  Result:=GetFile(IdFile,Token,Hash,FileName,AmPrtSockTypeFile.Zip,Stream);
end;
Function TAmChatSocketClientFile.GetFile(IdFile,Token,Hash,FileName:string;TypeFile:integer;Stream:TStream) :integer;
var Prt: TAmProtocolSock;
    StreamStr:TStringstream;
begin
    {
      Result < 0  какая то ошибка  см const этого объекта и родителя
      Result = 0  непонятно что пришло в Stream но запрос выполнен
      Result > 0  что именно пришло в  Stream  см AmPrtSockTypeFile

    }
   StreamStr:= TStringstream.Create(GetBodyJsonString(Token,Hash,FileName));
   try
      StreamStr.Position:=0;
      Prt.Clear;
      Prt.TypeRequest:=  AmPrtSockTypeRequest.cDonwload;
      Prt.TypeData :=    AmPrtSockTypeData.dJsonString;
      Prt.IdFile:=       IdFile;
      Prt.TypeFile:=     TypeFile;
      Result:= Get(Host,Port,Prt,StreamStr,Stream);
      if Result>0 then  Result:= ParsResponse(Prt);
   finally
     StreamStr.Free;
   end;

end;
function TAmChatSocketClientFile.ParsResponse(var Prt: TAmProtocolSock):integer;
begin
           if (Prt.TypeRequest = AmPrtSockTypeRequest.cPost)
           and (Prt.TypeData =AmPrtSockTypeData.dJsonString)  then
                                                              Result:= AmPrtSockTypeFile.json


           else if (Prt.TypeRequest = AmPrtSockTypeRequest.cUpload)
           and (Prt.TypeData =AmPrtSockTypeData.dFile)  then
                                                              Result:= Prt.TypeFile
           else
              Result:= 0;
end;
function TAmChatSocketClientFile.GetBodyJsonString(Token,Hash,FileName:string):string;
var Hob:Tjsonobject;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Token']:= Token;// 'wXIxKQnLlcvvoZXofCacVFoIHF';
       Hob['Response']['Hash']:= Hash;// 'TWGbcdAnWXneFhdzpZCgdGCrUa';
       Hob['Response']['FileName']:= FileName;
       Result:=Hob.ToJSON();
     finally
       Hob.free;
     end;

end;

  {

Function TAmChatCustomClientDownload.GetPhoto(IdPhoto:string;Stream:TStream):integer;
var Prt:TAmProtocolSock;
    Ms:TMemoryStream;


begin
 Ms:=TMemoryStream.Create;
 Donload:= AmSockClientGetBlockedCustom.create;
 try
    inc(CountSend);
    Result:=-1;

    Prt.Clear;
    Prt.TypeRequest:=AmPrtSockTypeRequest.cDonwload;
    Prt.TypeData := AmPrtSockTypeData.dJsonString;
    Prt.IdFile:= '5_114';
    Prt.TypeFile:= AmPrtSockTypeFile.Image;


  //Photo5_114.jpg

   Donload.LogMessage:=logMain;
   Result:=Donload.Download(ComboBox1.Items[ComboBox1.ItemIndex],
                            strtoint(EditPort.Text),
                            SVR_User_PhotoDownload,
                            Prt,Ms);

   if (Prt.TypeRequest = AmPrtSockTypeRequest.cPost)
   and (Prt.TypeData =AmPrtSockTypeData.dJsonString)  then
   begin
      log(AmStr(ms));
   end
   else if (Prt.TypeRequest = AmPrtSockTypeRequest.cUpload)
   and (Prt.TypeData =AmPrtSockTypeData.dFile)  then
   begin
         if Prt.TypeFile =  AmPrtSockTypeFile.Image then
         EsImage1.Picture.LoadFromStream(Ms);

   end;


   log(Result.ToString);
 finally
   log('Принят ms.size:'+Ms.Size.ToString);
   Ms.Free;
   Donload.Free;

 end;


end;

 }




             {TAmChatCustomSocketServer}
constructor TAmChatCustomSocketServer.Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
begin
    inherited  Create(AmiliSecondsTimeOutWaitFor);
end;
destructor  TAmChatCustomSocketServer.Destroy;
begin
    inherited Destroy;
end;
procedure   TAmChatCustomSocketServer.Execute;
begin
{    Client.ip:= Socket.LocalAddress;
    Client.port:= Socket.RemotePort;
    Client.WinName:= Socket.LocalHost;}
 inherited Execute;
end;


class function ConstAmChat.CheckIdFile(IdFile:string):boolean;
var l:integer;
begin
 l:= length(IdFile);
 Result:= (l>=3) and (l<23) and (amreg.GetValue('\d+\_\d+',IdFile)=IdFile);
end;

class function ConstAmChat.NameFileType.GetExt(name:string):string;
begin
   if name = nVoice then Result:= eVoiceExt
   else if name = nFile then Result:= eFilesExt
   else if name = nPhoto then Result:= ePhotoExt
   else  Result:= eNoneExt

end;

class function ConstAmChat.NameFileType.GetName(Ext:string):string;
begin
   if Ext = eVoiceExt then Result:= nVoice
   else if Ext = eFilesExt then Result:= nFile
   else if Ext = ePhotoExt then Result:= nPhoto
   else  Result:= nNoneExt
end;
class Function ConstAmChat.NameFileType.CheckName(var value:string):boolean;
begin
  Result:= (value=nVoice) or (value=nFile) or (value=  nPhoto)

end;
class function ConstAmChat.NameFileType.CheckExt(var value:string):boolean;
begin
  Result:= (value=eVoiceExt) or (value=eFilesExt) or (value=  ePhotoExt)
end;

class Function ConstAmChat.TypeGroopPrivacy.Check(value:string):boolean;
begin
  Result:= (value=OpenChat) or (value=OpenChanell) or (value=  CloseChat)  or (value=  CloseChanell)
end;
class Function ConstAmChat.TypeGroopPrivacy.CheckOpen(value:string):boolean;
begin
   Result:=false;
   if not Check(value) then  exit();
   Result:= Pos('Open',value)<>0;

end;
class Function ConstAmChat.TypeGroopPrivacy.CheckClose(value:string):boolean;
begin
   Result:=false;
   if not Check(value) then  exit();
   Result:= Pos('Close',value)<>0;
end;
class Function ConstAmChat.TypeGroopPrivacy.CheckChat(value:string):boolean;
begin
   Result:=false;
   if not Check(value) then  exit();
   Result:= Pos('Chat',value)<>0;
end;
class Function ConstAmChat.TypeGroopPrivacy.CheckChanell(value:string):boolean;
begin
   Result:=false;
   if not Check(value) then  exit();
   Result:= Pos('Chanell',value)<>0;
end;
class Function ConstAmChat.TypeGroopPrivacy.NeedVisibleAswert(value:string;TypeUser:string; IsAdmin:boolean):boolean;
begin
   Result:=false;
   if ConstAmChat.TypeUser.Groop = TypeUser then
   begin
     if Check(value) then
     begin
       if IsAdmin then Result:=IsAdmin
       else  Result:=CheckChat(value);
     end;
   end
   else
   begin
      Result:= ConstAmChat.TypeUser.User = TypeUser;
   end;

end;

class Function ConstAmChat.TypeUser.Check(value:string):boolean;
begin
  Result:= (value=User) or (value=Chat) or (value=  Groop)
end;
class Function ConstAmChat.TypeContent.Check(value:string):boolean;
begin
  Result:= (value=Text) or (value=Voice) or (value=Files) or (value=  Image) or (value=  Video) or (value=  Emogji)
end;
class Function ConstAmChat.TypeSistemCommand.Check(value:string):boolean;
begin
  Result:= (value=SetOnline) or (value=UpConnect)
end;
class Function ConstAmChat.TypeMetodReadMessage.Check(value:string):boolean;
begin
  Result:= (value=All) or (value=All)   or (value=OneByOne)
end;
class Function ConstAmChat.TypeOnline.Check(var value:string):boolean;
begin
  Result:= (value=Online) or (value=Offline)   or (value=Nearby) or (value=Unknown);
  if not Result then value:=Unknown;
  Result:=true;
end;



           {TAmChatCustomSocketClient}
   {
procedure TAmChatCustomSocketClient.ScConnect           (Sender: TObject; Socket: TCustomWinSocket);
begin
  //  Log('ScConnect');
    if not Assigned(FOnConnect) then  exit;
    FOnConnect(Sender);
end;
procedure TAmChatCustomSocketClient.ScConnecting        (Sender: TObject; Socket: TCustomWinSocket);
begin
  //   Log('ScConnecting...');
    if not Assigned(FOnConnecting) then  exit;
    FOnConnecting(Sender);
end;
procedure TAmChatCustomSocketClient.ScDisconnect        (Sender: TObject; Socket: TCustomWinSocket);
begin
  //   Log('ScDisconnect');
    if not Assigned(FOnDisconnect) then  exit;
    FOnDisconnect(Sender);
end;
procedure TAmChatCustomSocketClient.ScRead              (Sender: TObject; Socket: TCustomWinSocket);
var  Input:TCustomParam.TInput;
begin
     //Log('ScRead');
    Input.Text:= Socket.ReceiveText;
    if not Assigned(FOnRead) then  exit;
    FOnRead(Sender,Input);
end;
procedure TAmChatCustomSocketClient.ScWrite             (Sender: TObject; Socket: TCustomWinSocket);
begin
  //   Log('ScWrite');
    if not Assigned(FOnWrite) then  exit;
    FOnWrite(Sender);
end;
procedure TAmChatCustomSocketClient.ScError             (Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer) ;
var  Error:TCustomParam.TError;
begin
     Log('ScError '+inttostr(ErrorCode));

     Socket.Close;
    if Assigned(FOnError) then
    begin
      Error.ErrorCode:= ErrorCode;
      FOnError(Sender,Error);
    end;
    if ErrorCode<>0 then  ErrorCode:=0;

end;
}

constructor TAmChatCustomSocketClient.Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
begin
    inherited  Create(AmiliSecondsTimeOutWaitFor);
end;
destructor  TAmChatCustomSocketClient.Destroy;
begin
    inherited;
end;
procedure   TAmChatCustomSocketClient.Execute;
begin
 inherited Execute;
end;
function TAmChatCustomSocketClient.SendFile(FileName:string;NeedDeleteFile:boolean;Prt:TAmProtocolSock; Disconnect:boolean=false ):int64;
begin

   Result:= inherited SendFile(FileName,NeedDeleteFile,Prt,Disconnect);
end;
function TAmChatCustomSocketClient.SendString(Text:string;Prt:TAmProtocolSock; Disconnect:boolean=false):int64;
begin

 Result:= inherited SendString(Text,Prt,Disconnect);
end;
function TAmChatCustomSocketClient.SendStream(Stream:TStream;Prt:TAmProtocolSock; Disconnect:boolean=false):int64;
begin

 Result:= inherited SendStream(Stream,Prt,Disconnect);


end;








Function CustomSocketCheckWholePackage(var InputText:String;WordBegin,WordEnd:string):boolean;
var InputWordBegin,InputWordEnd:string;
begin
  Result:=false;
  InputWordBegin := Copy(InputText,1,length(WordBegin)); // первые три
 // showmessage(InputWordBegin+'.');
  InputWordEnd := Copy(InputText,Length(InputText)-length(WordEnd)+1,length(WordEnd)); // последние три

  //showmessage(InputWordEnd+'.');

  if (InputWordBegin=WordBegin) and (InputWordEnd=WordEnd) then
  begin
       //InputText:=InputText.Split()

       delete(InputText,1,length(WordBegin));
       delete(InputText,length(InputText)-length(WordEnd)+1,length(InputText));
       Result:=true;
  end;


end;
Function CustomSocketCheckWholePackage2(var InputText:String;WordBegin,WordEnd:string):Tarray<string>;
var B,E,PoE,PoB,Offset,MemPoE:integer;
ArrB,ArrE:Tarray<integer>;
type
  Tadd = record
      B,E:integer;
   end;
var
 ArrBE:Tarray<Tadd>;
 Procedure add(B,E:integer);
 begin
       MemPoE:= E;
       SetLength(ArrBE,length(ArrBE)+1);
       ArrBE[length(ArrBE)-1].B:= B;
       ArrBE[length(ArrBE)-1].E:= E;
 end;
 var S,S2:String;
begin
   // CountB:= CountPos(WordBegin,InputText);
 //  CountE:= CountPos(WordEnd,InputText);
    Offset:=1;
   while Offset< length(InputText) do
    begin
       PoB:=Pos(WordBegin,InputText,Offset);
       if PoB=0 then break;
       Offset:= PoB+length(WordBegin);
       SetLength(ArrB,length(ArrB)+1);
       ArrB[length(ArrB)-1]:= PoB;
    end;
     Offset:=1;
   while Offset< length(InputText) do
    begin
       PoB:=Pos(WordEnd,InputText,Offset);
       if PoB=0 then break;
       Offset:=PoB+length(WordEnd);;
       SetLength(ArrE,length(ArrE)+1);
       ArrE[length(ArrE)-1]:= PoB;
    end;

    if (Length(ArrB)>0) and (Length(ArrE)>0) then
    begin
         MemPoE:=0;
         for E := 0 to Length(ArrE)-1  do
         for B := 0 to Length(ArrB)-1  do
         begin
           if MemPoE<=ArrB[B] then
           begin

            if ArrB[B] < ArrE[E] then
            begin
              if (B+1)<Length(ArrB) then
              begin
                  if not (ArrB[B+1] < ArrE[E]) then add(ArrB[B],ArrE[E]);

              end
              else add(ArrB[B],ArrE[E]);

            end;
           end;


         end;

    end;
     SetLength(Result,length(ArrBE));
    for B := 0 to length(ArrBE)-1 do
    begin
         S := Copy(InputText,ArrBE[B].B+length(WordBegin),ArrBE[B].E-ArrBE[B].B-length(WordBegin));
         Result[B]:= S;


       //  showmessage(S);

    end;

   if length(ArrBE)>0 then
   begin
    S2:=InputText;
    InputText:='';
    for B := 0 to length(ArrBE) do
    begin
         if B=0 then
         S := Copy(S2,1,ArrBE[B].B-1)
         else if  B=length(ArrBE) then
         S := Copy(S2,ArrBE[B-1].E+length(WordEnd),(LEngth(S2)-ArrBE[B-1].E-length(WordEnd))+1)

         else S := Copy(S2,ArrBE[B-1].E+length(WordEnd),ArrBE[B].B-ArrBE[B-1].E-length(WordEnd));
         InputText:= InputText+S;




    end;

   end;
  //  if pos(WordBegin,InputText)=0 then InputText:='';

   // showmessage('ost='+InputText);


end;


end.
