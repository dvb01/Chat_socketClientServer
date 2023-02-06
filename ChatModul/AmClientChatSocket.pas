unit AmClientChatSocket;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,
  AmChatCustomSocket,Winapi.WinSock,AmLIst,
  AmChatServerBaza,AmUserType,JsonDataObjects,AmHandleObject,
  AmMultiSockTcpCustomPrt,
  AmMultiSockTcpCustomThread,
  System.Generics.Collections;

  type
  TAmChatClientPopapInfo = record

    id:integer; // будет тот который запрос сейчас выполняет из MsgChat  например SVR_LogIn
    IsError:boolean;
    text:string;
    Sec:string;



  end;
  type
    MsgChat = record
    const
       MSG_TO_SOCKET=wm_user+2000;
       MSG_TO_EDITOR=wm_user+2001;
       MSG_ONCONNECT=wm_user+2002;
       MSG_ONDISCONNECT=wm_user+2003;
       MSG_ONREAD=wm_user+2004;
       MSG_ONWRITE=wm_user+2005;
       MSG_ONERROR=wm_user+2006;
       MSG_ONCONNECTING=wm_user+2007;

       //используются когда с главного потока отправляется команда сокет потоку и обратно  SVR_ в сокет поток  FRM_ в главный поток
       SVR_LogIn = 1;
       FRM_LogIn = 2;
       AuthTrue  = 1000;
       SVR_LogInParam = 3;
       SVR_Reg = 4;
       FRM_Reg = 5;
       SVR_SetPhotoProfile = 6;
       FRM_SetPhotoProfile = 7;

       //SVR_User_PhotoDownload = 8;
       //FRM_User_PhotoDownload = 9;

       SVR_Profile_GetListContacts = 10;
       FRM_Profile_GetListContacts = 11;

       SVR_Message_Send = 12;
       FRM_Message_New = 13;

       SVR_Message_History = 14;
       FRM_Message_History = 15;

       SVR_UpConnect = 16;
       FRM_UpConnect = 17;

       SVR_TypeOnline    = 18;
       FRM_TypeOnline    = 19;

       SVR_Message_Read    = 20;
       FRM_Message_Read    = 21;

       SVR_LogOut = 22;

    //   SVR_Voice_Download    = 23;
    //   FRM_Voice_Download    = 24;

       FRM_Auth_ActivSeans    = 25;

     //  SVR_GetIdFileUpload = 26;
     //  FRM_GetIdFileUpload = 27;
       SVR_Serch    = 28;
       FRM_Serch    = 29;

       SVR_Groop_Create   = 30;
       FRM_Groop_Create    = 31;

       SVR_Groop_GetListUsers   = 32;
       FRM_Groop_GetListUsers    = 33;

       SVR_Groop_AddUser   = 34;
       FRM_Groop_AddUser    = 35;

       SVR_Groop_DeleteUser   = 36;
       FRM_Groop_DeleteUser    = 37;



       FRM_ContactNew  = 38;
       FRM_ContactDelete  = 39;

       SVR_ContactNew  = 40;
       SVR_ContactDelete  = 41;


       SVR_Groop_SetPhoto   = 42;
       FRM_Groop_SetPhoto    = 43;

       SVR_Groop_SetUserName   = 44;
       FRM_Groop_SetUserName    = 45;
    type


        TMSG = class
       //   From:Cardinal;
         // Whom:Cardinal;
          ResultSend:boolean; //было ли отпаравлен запрос серверу

          PopapInfo:TAmChatClientPopapInfo;
          IsDestroy:boolean;
          DataCreate:TDateTime;
          constructor Create;
          destructor  Destroy;override;
        end;

        TSVR_LogIn =class (TMSG)
          Id:string;// текуший idUser
          Token:string;
        end;

        TSeans = class (TMSG)

          LParamPot:string; // если в потоке что то выполнятся то Lparam этого объекта тип объекта не передается сам должен знать какие потоки что делают
          Indiv:string;   // произвольный индификатор что бы не перепутать ответы  задается когда отправляется запрос и сервером возвращается он обратно без изменений
       end;

        /////////////////
        TSVRSeans = class (TSeans)
          Token,Hash:string;
        end;
        TFRMSeans = class (TSeans)
          ResultAuth:Integer;  //или 1000 или 0=нет
          Result:boolean;     // удачно ли выполнился запрос
          Procedure CopyAndFree(Source:TFRMSeans);
        end;
        ////////////////////////
        TSRVproc = procedure (SRV:TMSG;out Result:boolean) of object;
        TFRMseansProc = procedure (SRV:TjsonObject;FRM:TFRMSeans) of object;

        TSVR_LogOut =class (TSVRSeans)
          Id:string;// текуший idUser

        end;

        TFRM_LogIn =class (TFRMSeans)

          Id,ScreenName,UserName,PhotoId,PhotoData,ContactsUpData:string;
          Token,Hash:string;
        end;
        TSVR_LogInParam =class (TMSG)
          Login,Pass:string;
          Rmb:boolean;
        end;
        TSVR_Reg =class (TMSG)
          Login,Email,Pass,Pass2,UserName:string;
        end;
        TFRM_Reg =class (TMSG)
          Result:boolean;     //учачно ли выполнился запрос
          Id:string;// текуший idUser
        end;



        TSVR_SetPhotoProfile =class (TSVRSeans)
          IsMain:boolean;
          PhotoId:string;
        end;
        TFRM_SetPhotoProfile =class (TFRMSeans)
          IsMain:boolean;
          PhotoId:string;

        end;

       { TSVR_GetIdFileUpload =class (TSVRSeans)

        end;
        TFRM_GetIdFileUpload =class (TFRMSeans)
           FileId:string;
        end; }

       { TSVR_User_PhotoDownload  =class (TSVRSeans)
           PhotoData,PhotoId:string;
        end;

        TFRM_User_PhotoDownload =class (TFRMSeans)

          PhotoData,PhotoId:string;
          PhotoBase64:string;

        end; }

        TFRM_Profile_GetListContacts =class (TFRMSeans)
          ObjString:string;
        end;

        TSVR_Message_Send =class (TSVRSeans)
           TypeUser,TypeContent,ContactUserId,Content,MimId,MimLparam:string;
           // Content отсылается в base64
            // если это текс тогда обычный текст
        end;

        TFRM_Message_New =class (TFRMSeans)
           ObjContact:string;
           ObjMessage:string;
           ObjUsers:string;
            // Content приходит как id этого контента если этого id у получателя нет тогда выполнится другой запрос что бы его скачать
            // если это текс тогда текст и вырнется
        end;

        TSVR_Message_History =class (TSVRSeans)
           TypeUser,ContactUserId,StartIdLocal,GetCount:string;
           IsBegin:boolean;

        end;
        TFRM_Message_History =class (TFRMSeans)
           ObjContact:string;
           ObjMessage:string;
           ObjUsers:string;
           StartIdLocal,GetCount:string;
           IsBegin:boolean;
        end;
        TSVR_UpConnect =class (TMSG)
          ConnectValue:string;
        end;
        TFRM_UpConnect =class (TMSG)
          ConnectValue:string;
        end;

        TSVR_TypeOnline =class (TSVRSeans)
          TypeOnline:string;
        end;

        TFRM_TypeOnline =class (TFRMSeans)
          IdUserOnline:string;
          TypeOnline:string;
        end;



        TSVR_Message_Read = class (TSVRSeans)
            TypeMetodReadMessage:string;
            TypeUser:string;
            ContactUserId:string;
            UserIdMessage:string;
            IdLocalMessage:string;
        end;
        TFRM_Message_Read = class (TFRMSeans)
            TypeUser:string;
            ContactUserId:string;
            IdLocalMessage:string;
            IsMy:boolean;
        end;

        TSVR_Serch = class (TSVRSeans)
          Metod:string;
          Val:String;
        end;
        TFRM_Serch = class (TFRMSeans)
          type Titem = record Id,TypeUser,UserName,ScreenName:string;end;
          var Arr:TAmListVar<Titem>;
        end;
        TSVR_Groop_Create = class (TSVRSeans)
          ScreenGroopName,GroopName,TypeGroopPrivacy:string
        end;
        TFRM_Groop_Create = class (TFRMSeans)
          idGroop:string;
        end;
        TSVR_Groop = class (TSVRSeans)
         GroopId:string;
        end;
        TFRM_Groop = class (TFRMSeans)
         GroopId:string;
        end;

        TSVR_Groop_GetListUsers = class (TSVR_Groop)

        end;
        TFRM_Groop_GetListUsers = class (TFRM_Groop)
          JsonArray:string;
        end;


        TSVR_Groop_AddUser = class (TSVR_Groop)
          AddUserId:string;
        end;
        TFRM_Groop_AddUser = class (TFRM_Groop)
          AddUserId:string;
        end;
        TSVR_Groop_DeleteUser = class (TSVR_Groop)
          DeleteUserId:string;
        end;
        TFRM_Groop_DeleteUser = class (TFRM_Groop)
          DeleteUserId:string;
        end;

        TFRM_ContactNew =class (TFRMSeans)
           TypeUser,UserId:string;
           ContactObj:string;
        end;

        TSVR_ContactDelete =class (TSVRSeans)
          TypeUser,UserId:string;
        end;
        TFRM_ContactDelete =class (TFRMSeans)
           TypeUser,UserId:string;
        end;

        TSVR_Groop_SetPhoto = class (TSVR_Groop)
          PhotoId:string;
        end;
        TFRM_Groop_SetPhoto = class (TFRM_Groop)
          PhotoId:string;
        end;


        TSVR_Groop_SetUserName = class (TSVR_Groop)
          UserName:string;
        end;
        TFRM_Groop_SetUserName = class (TFRM_Groop)
          UserName:string;
        end;
    end;

 // type
  //  TonListClientUpdate = procedure (List:TAmChatServerBaza.TListActiv.TListClients ) of object;




  type
    TAmChatClientSocket = class(TAmChatCustomSocketClient)
     {  1 задача класса получить от сервера распарсить если надо записать в в базу и отравить в главный поток для отображения инфу
        2 задача класса получить исходяшие дейсвие от юзера и отправить запрос серверу

     }
          type TOnEventMainPot =  class (TamHandleObject)
                 private
                    FOnConnect      : TProcDefault;
                    FOnConnecting   : TProcDefault;
                    FOnDisconnect   : TProcDefault;
                    FOnRead         : TProcDefaultStr;
                    FOnWrite        : TProcDefault;
                    FOnError        : TProcDefaultInt ;

                   procedure DoConnect ;
                   procedure DoConnecting ;
                   procedure DoDisconnect;
                   procedure DoRead(Str:string);
                   procedure DoWrite;
                   procedure DoError(Int:integer);
                   procedure ChConnectingPost (var Msg:Tmessage) ; message MsgChat.MSG_ONCONNECTING;
                   procedure ChConnectPost    (var Msg:Tmessage) ; message MsgChat.MSG_ONCONNECT;
                   procedure ChDisconnectPost (var Msg:Tmessage) ; message MsgChat.MSG_ONDISCONNECT;
                   procedure ChReadPost       (var Msg:Tmessage) ; message MsgChat.MSG_ONREAD;
                   procedure ChWritePost      (var Msg:Tmessage) ; message MsgChat.MSG_ONWRITE;
                   procedure ChErrorPost      (var Msg:Tmessage) ; message MsgChat.MSG_ONERROR;
                 public
                  //эти события выполняются в главном потоке
                  property OnConnect: TProcDefault read FOnConnect write FOnConnect;
                  property OnConnecting: TProcDefault read FOnConnecting write FOnConnecting;
                  property OnDisconnect: TProcDefault read FOnDisconnect write FOnDisconnect;
                  property OnRead: TProcDefaultStr read FOnRead write FOnRead;
                  property OnWrite: TProcDefault read FOnWrite write FOnWrite;
                  property OnError : TProcDefaultInt read FOnError write FOnError;
          end;
     private
      var






        procedure AfterRead   (Thread:TObject;
                                var Prt:TAmProtocolSock;
                                var Stream:TStream;
                                var IsNeedCloseConnect:boolean;
                                ResultRead:boolean) ;

        procedure BeforeRead (Thread:TObject;
                                var Prt:TAmProtocolSock;
                                var Stream:TStream;
                                var IsNeedCloseConnect:boolean);
     protected
        procedure   Execute; override;
        procedure   SockDisconnect (Sender: TObject; Socket: TCustomWinSocket);override;
        procedure   ThreadReadStart (Sender: TObject); override;
        procedure   SockConnect (Sender: TObject; Socket: TCustomWinSocket);override;
        procedure   SockConnecting (Sender: TObject; Socket: TCustomWinSocket);override;
     public
        FRM_HANDLE:Cardinal;
        OnEventMainPot:TOnEventMainPot;


        constructor Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
        destructor  Destroy; override;




        { сюда сообщения winApi приходят от формы к серверу через postmessage
          Задача SRV_... Составить Запрос и отправить серверу в своем потоке а не в потоке формы
          Задача FRM_... Составить Запрос и отправить в главный поток для отображения инфы
          FRM_ это как result SRV_  функции  и SRV_ FRM_ вызывается только с этого объекта

        }

        procedure SRV_MAIN (var Msg:Tmessage); message MsgChat.MSG_TO_SOCKET;
        function  SRV_SendText(OutText:string):boolean;


        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        function  SVR_UpConnect(SVR:MsgChat.TSVR_UpConnect):boolean;
        function  SVR_TypeOnline(SVR:MsgChat.TSVR_TypeOnline):boolean;
        function  SVR_LogOut(SVR:MsgChat.TSVR_LogOut):boolean;

        function  SRV_LogIn(SVR:MsgChat.TSVR_LogIn):boolean;
        function  SRV_LogInParam(SVR:MsgChat.TSVR_LogInParam):boolean;
        function  SRV_Reg(SVR:MsgChat.TSVR_Reg):boolean;


        function  SVR_SetPhotoProfile(SVR:MsgChat.TSVR_SetPhotoProfile):boolean;
       // function  SVR_GetIdFileUpload(SVR:MsgChat.TSVR_GetIdFileUpload):boolean;

       // function  SVR_User_PhotoDownload(SVR:MsgChat.TSVR_User_PhotoDownload):boolean;
        function  SVR_Profile_GetListContacts (SVR:MsgChat.TSVRSeans):boolean;
        function  SVR_Message_Send (SVR:MsgChat.TSVR_Message_Send):boolean;
        function  SVR_Message_History(SVR:MsgChat.TSVR_Message_History):boolean;
        function  SVR_Message_Read(SVR:MsgChat.TSVR_Message_Read):boolean;
       // function  SVR_Voice_Download (SVR:MsgChat.TSVR_Voice_Download):boolean;
        function  SVR_Serch(SVR:MsgChat.TSVR_Serch):boolean;
        function  SVR_ContactDelete(SVR:MsgChat.TSVR_ContactDelete):boolean;


        function  SVR_Groop_Create(SVR:MsgChat.TSVR_Groop_Create):boolean;
        function  SVR_Groop_GetListUsers(SVR:MsgChat.TSVR_Groop_GetListUsers):boolean;
        function  SVR_Groop_AddUser (SVR:MsgChat.TSVR_Groop_AddUser):boolean;
        function  SVR_Groop_DeleteUser(SVR:MsgChat.TSVR_Groop_DeleteUser):boolean;
        function  SVR_Groop_SetPhoto(SVR:MsgChat.TSVR_Groop_SetPhoto):boolean;
        function  SVR_Groop_SetUserName(SVR:MsgChat.TSVR_Groop_SetUserName):boolean;




        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        procedure FRM_MAIN_ParsResponse (InputText:String);
        procedure FRM_UpConnect (SVR:TjsonObject);
        procedure FRM_ACTIV_SEANS (SVR:TjsonObject;Proc:MsgChat.TFRMseansProc);
        procedure FRM_PostMessage(WParam:Cardinal;MSG:MsgChat.TMSG);


        procedure FRM_Before_LogIn(SVR:TjsonObject);
        procedure FRM_Sended_LogIn(FRM:MsgChat.TMSG);

        procedure FRM_Before_Reg(SVR:TjsonObject);
        procedure FRM_Sended_Reg(FRM:MsgChat.TFRM_Reg);
//        procedure FRM_Before_Undefended(SVR:TjsonObject);
        procedure FRM_SetPhotoProfile (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
//        procedure FRM_GetIdFileUpload (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);

       // procedure FRM_User_PhotoDownload(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Profile_GetListContacts(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Message_New (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Message_History (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Online (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Message_Read(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
      //  procedure FRM_Voice_Download(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Serch(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_Create(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_GetListUsers(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_AddUser(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_DeleteUser(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_ContactNew(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_ContactDelelte(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_SetPhoto(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
        procedure FRM_Groop_SetUserName(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);


    end;

  type
   TAmChatHttpFiles = class(TAmChatSocketClientFile)
    private
       Function GetIdFilesBeforeUpload_GetJson(Token,Hash:string;ParamIdForGetFiles:integer):string;
    public
      Function GetIdFilesBeforeUpload(Token,Hash:string;ParamIdForGetFiles:integer;var ResultJsonString:string):integer;
   end;


   TSVRMSG_Checker = class
     List:TList<MsgChat.TMSG>;
   end;


implementation
Function TAmChatHttpFiles.GetIdFilesBeforeUpload_GetJson(Token,Hash:string;ParamIdForGetFiles:integer):string;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.File_GetIdBeforeUpload_Call;
       Hob['Response']['Token']:= Token;
       Hob['Response']['Hash']:= Hash;
       Hob['Response']['LParamPot'].Value:='';
       Hob['Response']['Indiv'].Value:='';
       Hob['Response']['FileGetIdParam']['Param'].Value:=AmStr(ParamIdForGetFiles){ConstAmChat.FileGetIdParam};
       Result:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;

end;
Function TAmChatHttpFiles.GetIdFilesBeforeUpload(Token,Hash:string;ParamIdForGetFiles:integer;var ResultJsonString:string):integer;
var  HobString:string;
begin
     Result:=-100;
     HobString:= GetIdFilesBeforeUpload_GetJson(Token,Hash,ParamIdForGetFiles);
     if HobString='' then exit;
     Result:=GetIdForFiles(HobString,ResultJsonString);
end;

constructor MsgChat.TMSG.Create;
begin
   inherited create;
  ResultSend:=false;
  IsDestroy:=false;
  DataCreate:=now;
end;
destructor  MsgChat.TMSG.Destroy;
begin
   if IsDestroy then exit;
   IsDestroy:=true;
   inherited;
end;
Procedure MsgChat.TFRMSeans.CopyAndFree(Source:TFRMSeans);

begin
 if Assigned(Source) then
 begin
  Self.LParamPot:=  Source.LParamPot;
  Self.Indiv:=      Source.Indiv;
  Self.ResultAuth:= Source.ResultAuth;
  Self.Result:=     Source.Result;
  Self.ResultSend:= Source.ResultSend;
  Self.PopapInfo:=  Source.PopapInfo;
  Source.Free;
 end;

end;

procedure TAmChatClientSocket.SRV_MAIN (var Msg:Tmessage); //message ConstChatForm.MSG_TO_SOCKET;
var m: MsgChat.TMSG;
ResultSend:Boolean;
FRM:MsgChat.TMSG;
TextResp:string;
begin

    ResultSend:=false;
    TextResp:= 'Сервер оффлайн';
    m:= MsgChat.TMSG(Msg.LParam);
    try
     if Assigned(m) then
     begin
      case Msg.WParam of
          MsgChat.SVR_LogIn                        : ResultSend:=  SRV_LogIn                        (  MsgChat.TSVR_LogIn(LPARAM(m)) );
          MsgChat.SVR_LogInParam                   : ResultSend:=  SRV_LogInParam                   (  MsgChat.TSVR_LogInParam (LPARAM(m)) );
          MsgChat.SVR_Reg                          : ResultSend:=  SRV_Reg                          (  MsgChat.TSVR_Reg (LPARAM(m)) );
          MsgChat.SVR_SetPhotoProfile               : ResultSend:=  SVR_SetPhotoProfile                     (  MsgChat.TSVR_SetPhotoProfile (LPARAM(m)) );
        //  MsgChat.SVR_User_PhotoDownload           : ResultSend:=  SVR_User_PhotoDownload           (  MsgChat.TSVR_User_PhotoDownload (LPARAM(m)) );
          MsgChat.SVR_Profile_GetListContacts      : ResultSend:=  SVR_Profile_GetListContacts      (  MsgChat.TSVRSeans (LPARAM(m)) );
          MsgChat.SVR_Message_Send                 : ResultSend:=  SVR_Message_Send                 (  MsgChat.TSVR_Message_Send (LPARAM(m)) );
          MsgChat.SVR_Message_History              : ResultSend:=  SVR_Message_History              (  MsgChat.TSVR_Message_History (LPARAM(m)) );
          MsgChat.SVR_UpConnect                    : ResultSend:=  SVR_UpConnect                    (  MsgChat.TSVR_UpConnect (LPARAM(m)) );
          MsgChat.SVR_Message_Read                 : ResultSend:=  SVR_Message_Read                 (  MsgChat.TSVR_Message_Read (LPARAM(m)) );
          MsgChat.SVR_TypeOnline                   : ResultSend:=  SVR_TypeOnline                   (  MsgChat.TSVR_TypeOnline (LPARAM(m)) );
          MsgChat.SVR_LogOut                       : ResultSend:=  SVR_LogOut                       (  MsgChat.TSVR_LogOut (LPARAM(m)) );


        //  MsgChat.SVR_Voice_Download               : ResultSend:=  SVR_Voice_Download               (  MsgChat.TSVR_Voice_Download (LPARAM(m)) );
        //  MsgChat.SVR_GetIdFileUpload              : ResultSend:=  SVR_GetIdFileUpload               (  MsgChat.TSVR_GetIdFileUpload (LPARAM(m)) );

          MsgChat.SVR_Serch                        : ResultSend:=  SVR_Serch                 (  MsgChat.TSVR_Serch (LPARAM(m)) );
          MsgChat.SVR_Groop_Create                 : ResultSend:=  SVR_Groop_Create          (  MsgChat.TSVR_Groop_Create (LPARAM(m)) );
          MsgChat.SVR_Groop_GetListUsers           : ResultSend:=  SVR_Groop_GetListUsers          (  MsgChat.TSVR_Groop_GetListUsers (LPARAM(m)) );
          MsgChat.SVR_Groop_AddUser               : ResultSend:=   SVR_Groop_AddUser          (  MsgChat.TSVR_Groop_AddUser (LPARAM(m)) );
          MsgChat.SVR_Groop_DeleteUser               : ResultSend:=   SVR_Groop_DeleteUser          (  MsgChat.TSVR_Groop_DeleteUser (LPARAM(m)) );
          MsgChat.SVR_Groop_SetPhoto               : ResultSend:=   SVR_Groop_SetPhoto          (  MsgChat.TSVR_Groop_SetPhoto (LPARAM(m)) );
          MsgChat.SVR_Groop_SetUserName               : ResultSend:=   SVR_Groop_SetUserName          (  MsgChat.TSVR_Groop_SetUserName (LPARAM(m)) );
          MsgChat.SVR_ContactDelete                : ResultSend:=   SVR_ContactDelete          (  MsgChat.TSVR_ContactDelete (LPARAM(m)) );

          else TextResp:= 'Нет такой команды SRV_MAIN';
      end;
     end;
    finally
     if Assigned(m) then m.Free;
    end;

    if not ResultSend then
    begin

      FRM:=  MsgChat.TMSG.Create;
      FRM.PopapInfo.id:= -1;
      FRM.PopapInfo.IsError:=true;
      FRM.PopapInfo.text:= TextResp;
      FRM.ResultSend:= false;
      FRM_Sended_LogIn(FRM);
    end;

end;
function  TAmChatClientSocket.SVR_Groop_SetPhoto(SVR:MsgChat.TSVR_Groop_SetPhoto):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Groop_SetPhoto_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;

       Hob['Response']['Groop']['PhotoId'].Value:= SVR.PhotoId;
       Hob['Response']['Groop']['GroopId'].Value:= SVR.GroopId;
       Hob['Response']['Groop']['IsMain'].BoolValue:= True;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_ContactDelete(SVR:MsgChat.TSVR_ContactDelete):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Profile_DeleteContacts_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;

       Hob['Response']['Contact']['Id'].Value:= SVR.UserId;
       Hob['Response']['Contact']['TypeUser'].Value:= SVR.TypeUser;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Groop_SetUserName(SVR:MsgChat.TSVR_Groop_SetUserName):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Groop_SetUserName_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;

       Hob['Response']['Groop']['UserName'].Value:= SVR.UserName;
       Hob['Response']['Groop']['GroopId'].Value:= SVR.GroopId;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Groop_DeleteUser(SVR:MsgChat.TSVR_Groop_DeleteUser):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.GroopDeleteUser_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Groop']['GroopId'].Value:= SVR.GroopId;
       Hob['Response']['Groop']['DeleteUserId'].Value:= SVR.DeleteUserId;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Groop_AddUser (SVR:MsgChat.TSVR_Groop_AddUser):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.GroopAddUser_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Groop']['GroopId'].Value:= SVR.GroopId;
       Hob['Response']['Groop']['AddUserId'].Value:= SVR.AddUserId;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Groop_GetListUsers(SVR:MsgChat.TSVR_Groop_GetListUsers):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Groop_GetListUsers_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Groop']['GroopId'].Value:= SVR.GroopId;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Groop_Create(SVR:MsgChat.TSVR_Groop_Create):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.GroopCreate_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Groop']['ScreenGroopName'].Value:= SVR.ScreenGroopName;
       Hob['Response']['Groop']['GroopName'].Value:= SVR.GroopName;
       Hob['Response']['Groop']['TypeGroopPrivacy'].Value:= SVR.TypeGroopPrivacy;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;
function  TAmChatClientSocket.SVR_Serch(SVR:MsgChat.TSVR_Serch):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Serch_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Serch']['Metod'].Value:= SVR.Metod;
       Hob['Response']['Serch']['Val'].Value:= SVR.Val;

       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;

 {
function TAmChatClientSocket.SVR_Voice_Download (SVR:MsgChat.TSVR_Voice_Download):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Voice_Download_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['Voice']['VoiceId'].Value:= SVR.VoiceId;
       Hob['Response']['Voice']['IsPlay'].Value:= BoolToStr(SVR.IsPlay);
       Hob['Response']['Voice']['LParamOneMessage'].Value:= IntTostr(SVR.LParamOneMessage);


       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end;  }
function  TAmChatClientSocket.SVR_TypeOnline(SVR:MsgChat.TSVR_TypeOnline):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.OnlineType_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;


       Hob['Response']['Online']['TypeOnline'].Value:= SVR.TypeOnline;

       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SVR_LogOut(SVR:MsgChat.TSVR_LogOut):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.LogOut_Call;
       Hob['Response']['Token'].Value:= SVR.Token;
       Hob['Response']['Hash'].Value:= SVR.Hash;
       Hob['Response']['Id'].Value:= SVR.Id;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SVR_Message_Read(SVR:MsgChat.TSVR_Message_Read):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Message_Read_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['Message']['TypeMetodReadMessage']:= SVR.TypeMetodReadMessage;
       Hob['Response']['Message']['TypeUser']:= SVR.TypeUser;
       Hob['Response']['Message']['ContactUserId']:= SVR.ContactUserId;
       Hob['Response']['Message']['UserIdMessage']:= SVR.UserIdMessage;
       Hob['Response']['Message']['IdLocalMessage']:= SVR.IdLocalMessage;
       HobString:=Hob.ToJSON();

    //    LogMessage.Log('SVR_Message_Read'+HobString);
     finally
       Hob.free;
     end;
      Result:=SRV_SendText(HobString);
end;

function  TAmChatClientSocket.SVR_UpConnect(SVR:MsgChat.TSVR_UpConnect):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.UpConnect_Call;
       Hob['Response']['UpConnect']['ConnectValue']:= SVR.ConnectValue;
       HobString:=Hob.ToJSON();

     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SVR_Message_History(SVR:MsgChat.TSVR_Message_History):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Message_History_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['Message']['TypeUser']:= SVR.TypeUser;
       Hob['Response']['Message']['ContactUserId']:= SVR.ContactUserId;
       Hob['Response']['Message']['StartIdLocal']:= SVR.StartIdLocal;
       Hob['Response']['Message']['GetCount']:= SVR.GetCount;
       Hob['Response']['Message']['IsBegin']:= BoolToStr(SVR.IsBegin);
       HobString:=Hob.ToJSON();

     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SVR_Message_Send (SVR:MsgChat.TSVR_Message_Send):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Message_Send_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['Message']['TypeUser']:= SVR.TypeUser;
       Hob['Response']['Message']['TypeContent']:= SVR.TypeContent;
       Hob['Response']['Message']['ContactUserId']:= SVR.ContactUserId;
       Hob['Response']['Message']['Content']:= SVR.Content;
       Hob['Response']['Message']['MimId']:= SVR.MimId;
       Hob['Response']['Message']['MimLparam']:= SVR.MimLparam;
       HobString:=Hob.ToJSON();

     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SVR_Profile_GetListContacts (SVR:MsgChat.TSVRSeans):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Profile_GetListContacts_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       HobString:=Hob.ToJSON();

     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
{
function TAmChatClientSocket.SVR_User_PhotoDownload(SVR:MsgChat.TSVR_User_PhotoDownload):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.User_PhotoDownload_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['User']['PhotoDownload']['PhotoData'].Value:= SVR.PhotoData;
       Hob['Response']['User']['PhotoDownload']['PhotoId'].Value:= SVR.PhotoId;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;  }
{
function  TAmChatClientSocket.SVR_GetIdFileUpload(SVR:MsgChat.TSVR_GetIdFileUpload):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.GetIdFileUpload_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;
       Hob['Response']['Profile']['NewFile']['NewFile'].Value:= '';
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);

end; }

function  TAmChatClientSocket.SVR_SetPhotoProfile(SVR:MsgChat.TSVR_SetPhotoProfile):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.SetPhotoProfile_Call;
       Hob['Response']['Token']:= SVR.Token;
       Hob['Response']['Hash']:= SVR.Hash;
       Hob['Response']['LParamPot'].Value:=SVR.LParamPot;
       Hob['Response']['Indiv'].Value:=SVR.Indiv;

       Hob['Response']['Profile']['PhotoId'].Value:= SVR.PhotoId;
       Hob['Response']['Profile']['IsMain'].BoolValue:= SVR.IsMain;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function  TAmChatClientSocket.SRV_Reg(SVR:MsgChat.TSVR_Reg):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.RegUser_Call;
       Hob['Response']['RegUser']['ScreenName'].Value:= SVR.Login;
       Hob['Response']['RegUser']['Password'].Value:= SVR.Pass;
       Hob['Response']['RegUser']['Password2'].Value:= SVR.Pass2;
       Hob['Response']['RegUser']['Email'].Value:= SVR.Email;
       Hob['Response']['RegUser']['UserName'].Value:= SVR.UserName;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;

function  TAmChatClientSocket.SRV_LogInParam(SVR:MsgChat.TSVR_LogInParam):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Auth_Call;
       Hob['Response']['Auth']['ScreenName'].Value:= SVR.Login;
       Hob['Response']['Auth']['Password'].Value:= SVR.Pass;
       Hob['Response']['Auth']['Rmb'].BoolValue:= SVR.Rmb;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;
function TAmChatClientSocket.SRV_LogIn(SVR:MsgChat.TSVR_LogIn):boolean;
var Hob:Tjsonobject;
HobString:string;
begin

     Hob:= Tjsonobject.create;
     try
       Hob['Response']['Idmsg'].IntValue:=ConstAmChat.Auth_Call;
       Hob['Response']['Auth']['Token'].Value:= SVR.Token;
       Hob['Response']['Auth']['Id'].Value:= SVR.Id;
       HobString:=Hob.ToJSON();



     finally
       Hob.free;
     end;
     Result:=SRV_SendText(HobString);
end;

function  TAmChatClientSocket.SRV_SendText(OutText:string):boolean;
var Prt:TAmProtocolSock;
begin
    Result:=false;
    // OutText:= ConstAmChat.WordBegin+OutText+ConstAmChat.WordEnd;
    Prt.Clear;
    Prt.TypeRequest:=AmPrtSockTypeRequest.cPost;
    Prt.TypeData := AmPrtSockTypeData.dJsonString;

   if AutoConnected then
    Result:=SendString(OutText,Prt)>0;

end;



procedure TAmChatClientSocket.FRM_MAIN_ParsResponse (InputText:String);
var
I,idmsg:integer;
HobInput:Tjsonobject;
begin
    {
   try
    LocalInput:=FBufferText+InputText;
    WholePackage:= CustomSocketCheckWholePackage2(LocalInput,ConstAmChat.WordBegin,ConstAmChat.WordEnd);
    FBufferText:=LocalInput;
    ResultWholePackage:= Length(WholePackage)>0;
   except
       ResultWholePackage:=false;
   end;
   }
       self.LogMessage.Log(InputText);

      try
         HobInput:= Tjsonobject.Parse(InputText) as Tjsonobject ;
         try
            try
                 if not HobInput['Response'].IsNull then
                 begin

                  idmsg:=HobInput['Response']['Idmsg'].IntValue;
                  case idmsg of


                      ConstAmChat.UpConnect_Back:              FRM_UpConnect(HobInput['Response']);
                      ConstAmChat.Auth_Back :                  FRM_Before_LogIn(HobInput['Response']);
                      ConstAmChat.Auth_ActivSeans_Back  :      FRM_ACTIV_SEANS(HobInput['Response'],nil);
                      ConstAmChat.RegUser_Back :               FRM_Before_Reg(HobInput['Response']);
                      ConstAmChat.SetPhotoProfile_Back:         FRM_ACTIV_SEANS(HobInput['Response'],FRM_SetPhotoProfile); //FRM_Before_Profile_NewPhoto
                     // ConstAmChat.GetIdFileUpload_Back:        FRM_ACTIV_SEANS(HobInput['Response'],FRM_GetIdFileUpload);
                     // ConstAmChat.User_PhotoDownload_Back:     FRM_ACTIV_SEANS(HobInput['Response'],FRM_User_PhotoDownload);
                      ConstAmChat.Profile_GetListContacts_Back:FRM_ACTIV_SEANS(HobInput['Response'],FRM_Profile_GetListContacts);
                      ConstAmChat.Message_New_Back:            FRM_ACTIV_SEANS(HobInput['Response'],FRM_Message_New);
                      ConstAmChat.Message_History_Back:        FRM_ACTIV_SEANS(HobInput['Response'],FRM_Message_History);
                      ConstAmChat.OnlineType_Back:             FRM_ACTIV_SEANS(HobInput['Response'],FRM_Online);
                      ConstAmChat.Message_Read_Back:           FRM_ACTIV_SEANS(HobInput['Response'],FRM_Message_Read);
                      //ConstAmChat.Voice_Download_Back:         FRM_ACTIV_SEANS(HobInput['Response'],FRM_Voice_Download);
                      ConstAmChat.Serch_Back:                  FRM_ACTIV_SEANS(HobInput['Response'],FRM_Serch);
                      ConstAmChat.GroopCreate_Back:            FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_Create);
                      ConstAmChat.Groop_GetListUsers_Back:      FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_GetListUsers);
                      ConstAmChat.GroopAddUser_Back:           FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_AddUser);
                      ConstAmChat.GroopDeleteUser_Back:           FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_DeleteUser);
                      ConstAmChat.Profile_NewContacts_Back:           FRM_ACTIV_SEANS(HobInput['Response'],FRM_ContactNew);
                      ConstAmChat.Profile_DeleteContacts_Back:           FRM_ACTIV_SEANS(HobInput['Response'],FRM_ContactDelelte);
                      ConstAmChat.Groop_SetPhoto_Back :           FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_SetPhoto);
                      ConstAmChat.Groop_SetUserName_Back :           FRM_ACTIV_SEANS(HobInput['Response'],FRM_Groop_SetUserName);
                      else FRM_ACTIV_SEANS(HobInput['Response'],nil);
                     //
                  end;


                 end;
            except
               self.LogMessage.Log('Error TAmChatClientSocket.Pars2');
            end;
         finally
            HobInput.Free;
         end;
      except
         self.LogMessage.Log('Error TAmChatClientSocket.Pars');
      end;

end;
procedure TAmChatClientSocket.FRM_Groop_SetPhoto(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_SetPhoto;
begin

    FRM:=  MsgChat.TFRM_Groop_SetPhoto.Create;
    FRM.CopyAndFree(aFRM);
    FRM.GroopId:=          SVR['Groop']['GroopId'].Value;
    FRM.PhotoId:=        SVR['Groop']['PhotoId'].Value;
    FRM_PostMessage(MsgChat.FRM_Groop_SetPhoto,FRM);

end;
procedure TAmChatClientSocket.FRM_Groop_SetUserName(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_SetUserName;
begin

    FRM:=  MsgChat.TFRM_Groop_SetUserName.Create;
    FRM.CopyAndFree(aFRM);
    FRM.GroopId:=          SVR['Groop']['GroopId'].Value;
    FRM.UserName:=        SVR['Groop']['UserName'].Value;
    FRM_PostMessage(MsgChat.FRM_Groop_SetUserName,FRM);

end;
procedure TAmChatClientSocket.FRM_ContactDelelte(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_ContactDelete;
begin

    FRM:=  MsgChat.TFRM_ContactDelete.Create;
    FRM.CopyAndFree(aFRM);
    FRM.UserId:=            SVR['Contact']['Id'].Value;
    FRM.TypeUser:=          SVR['Contact']['TypeUser'].Value;
    FRM_PostMessage(MsgChat.FRM_ContactDelete,FRM);

end;
procedure TAmChatClientSocket.FRM_ContactNew(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_ContactNew;
begin

    FRM:=  MsgChat.TFRM_ContactNew.Create;
    FRM.CopyAndFree(aFRM);
    FRM.UserId:=            SVR['Contact']['Id'].Value;
    FRM.TypeUser:=          SVR['Contact']['TypeUser'].Value;
    FRM.ContactObj:=          SVR['Contact'].ObjectValue.ToJSON;
    FRM_PostMessage(MsgChat.FRM_ContactNew,FRM);

end;
procedure TAmChatClientSocket.FRM_Groop_DeleteUser(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_DeleteUser;
begin

    FRM:=  MsgChat.TFRM_Groop_DeleteUser.Create;
    FRM.CopyAndFree(aFRM);
    FRM.GroopId:=          SVR['Groop']['GroopId'].Value;
    FRM.DeleteUserId:=        SVR['Groop']['DeleteUserId'].Value;
    FRM_PostMessage(MsgChat.FRM_Groop_DeleteUser,FRM);

end;
procedure TAmChatClientSocket.FRM_Groop_AddUser(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_AddUser;
begin

    FRM:=  MsgChat.TFRM_Groop_AddUser.Create;
    FRM.CopyAndFree(aFRM);
    FRM.GroopId:=          SVR['Groop']['GroopId'].Value;
    FRM.AddUserId:=        SVR['Groop']['AddUserId'].Value;
    FRM_PostMessage(MsgChat.FRM_Groop_AddUser,FRM);

end;
procedure TAmChatClientSocket.FRM_Groop_GetListUsers(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_GetListUsers;
begin

    FRM:=  MsgChat.TFRM_Groop_GetListUsers.Create;
    FRM.CopyAndFree(aFRM);
    FRM.GroopId:=          SVR['Groop']['GroopId'].Value;
    FRM.JsonArray:=        SVR['Groop'].A['List'].ToJSON();
    FRM_PostMessage(MsgChat.FRM_Groop_GetListUsers,FRM);

end;
procedure TAmChatClientSocket.FRM_Groop_Create(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Groop_Create;
begin

    FRM:=  MsgChat.TFRM_Groop_Create.Create;
    FRM.CopyAndFree(aFRM);
    FRM.idGroop:=          SVR['Groop']['Id'].Value;
    FRM_PostMessage(MsgChat.FRM_Groop_Create,FRM);

end;
procedure TAmChatClientSocket.FRM_Serch(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Serch;
     Item: MsgChat.TFRM_Serch.Titem;
i:integer;
ArrJson:TJsonArray;
Hob:TJsonObject;
begin

    FRM:=  MsgChat.TFRM_Serch.Create;
    FRM.CopyAndFree(aFRM);
    FRM.Arr.Clear;
    i:=SVR['Serch']['Items'].Count;
    ArrJson:=SVR['Serch'].A['Items'];
    for i := 0 to ArrJson.Count-1 do
    begin
      Item.Id:='';
      Item.UserName:='';
      Item.ScreenName:='';
      if ArrJson[i].Typ =jdtObject then
      begin
        Hob:= ArrJson[i];
        Item.Id:= Hob['Id'];
        Item.TypeUser:=Hob['TypeUser'];
        Item.UserName:= Hob['UserName'];
        Item.ScreenName:= Hob['ScreenName'];
        FRM.Arr.Add(Item);
      end;
    end;

    FRM_PostMessage(MsgChat.FRM_Serch,FRM);

end;
{
procedure TAmChatClientSocket.FRM_Voice_Download(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Voice_Download;
begin

    FRM:=  MsgChat.TFRM_Voice_Download.Create;
    FRM.CopyAndFree(aFRM);
    FRM.VoiceId:=                SVR['Voice']['VoiceId'].Value;
    FRM.IsPlay:=                 AmBool(SVR['Voice']['IsPlay'].Value);
    FRM.LParamOneMessage:=       AmInt(SVR['Voice']['LParamOneMessage'].Value);
    FRM.VoiceBase64:=            SVR['Voice']['VoiceBase64'].Value;
    FRM_PostMessage(MsgChat.FRM_Voice_Download,FRM);




end;  }
procedure  TAmChatClientSocket.FRM_Message_Read(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Message_Read;
begin

    FRM:=  MsgChat.TFRM_Message_Read.Create;
    FRM.CopyAndFree(aFRM);
    FRM.TypeUser:=          SVR['Message']['TypeUser'].Value;
    FRM.ContactUserId:=     SVR['Message']['ContactUserId'].Value;
    FRM.IdLocalMessage:=    SVR['Message']['IdLocalMessage'].Value;
    FRM.IsMy:=              AmBool(SVR['Message']['IsMy'].Value,false);
    FRM_PostMessage(MsgChat.FRM_Message_Read,FRM);

end;
procedure TAmChatClientSocket.FRM_Online (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_TypeOnline;
begin
    FRM:=  MsgChat.TFRM_TypeOnline.Create;
    FRM.CopyAndFree(aFRM);
    FRM.IdUserOnline:=   SVR['Online']['Id'].Value;
    FRM.TypeOnline       :=   SVR['Online']['TypeOnline'].Value;
    FRM_PostMessage(MsgChat.FRM_TypeOnline ,FRM);

end;
procedure TAmChatClientSocket.FRM_Message_History (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Message_History;
begin
    FRM:=  MsgChat.TFRM_Message_History.Create;
    FRM.CopyAndFree(aFRM);

    FRM.ObjMessage:=     SVR['Message'].ObjectValue.ToJSON(true);
    FRM.ObjUsers:=       SVR['Users'].ObjectValue.ToJSON(true);
    FRM.ObjContact:=     SVR['Contact'].ObjectValue.ToJSON(true);
    FRM.StartIdLocal:=   SVR['StartIdLocal'].Value;
    FRM.GetCount:=       SVR['GetCount'].Value;
    FRM.IsBegin:=        AmBool(SVR['IsBegin'].Value,false);
    FRM_PostMessage(MsgChat.FRM_Message_History,FRM);

end;
procedure  TAmChatClientSocket.FRM_Message_New (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Message_New;
begin
    FRM:=  MsgChat.TFRM_Message_New.Create;
    FRM.CopyAndFree(aFRM);
    FRM.ObjMessage:=     SVR['Message'].ObjectValue.ToJSON(true);
    FRM.ObjUsers:=       SVR['Users'].ObjectValue.ToJSON(true);
    FRM.ObjContact:=     SVR['Contact'].ObjectValue.ToJSON(true);
    FRM_PostMessage(MsgChat.FRM_Message_New,FRM);

end;
procedure TAmChatClientSocket.FRM_Profile_GetListContacts(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_Profile_GetListContacts;
begin
    FRM:=  MsgChat.TFRM_Profile_GetListContacts.Create;
    FRM.CopyAndFree(aFRM);
    FRM.ObjString:= SVR['Contacts'].ObjectValue.ToJSON(true);
    FRM_PostMessage(MsgChat.FRM_Profile_GetListContacts,FRM);
end;

{
procedure TAmChatClientSocket.FRM_User_PhotoDownload(SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_User_PhotoDownload;
begin
   // FRM:=   MsgChat.TFRM_Profile_NewPhoto(LParam(aFRM));
//    FRM:=    MsgChat.TFRM_User_PhotoDownload(LParam(aFRM));

    FRM:=  MsgChat.TFRM_User_PhotoDownload.Create;
    FRM.CopyAndFree(aFRM);
    FRM.PhotoBase64:= SVR['PhotoBase64'].Value;
    FRM.PhotoId:=     SVR['PhotoId'].Value;
    FRM.PhotoData:=   SVR['PhotoData'].Value;
    FRM_PostMessage(MsgChat.FRM_User_PhotoDownload,FRM);

end; }
{
procedure TAmChatClientSocket.FRM_GetIdFileUpload (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_GetIdFileUpload;
begin

    FRM:=  MsgChat.TFRM_GetIdFileUpload.Create;
    FRM.CopyAndFree(aFRM);
    FRM.FileId:= SVR['Profile']['NewFile']['FileId'].Value;
    FRM_PostMessage(MsgChat.FRM_GetIdFileUpload,FRM);

end; }
procedure TAmChatClientSocket.FRM_SetPhotoProfile (SVR:TjsonObject;aFRM:MsgChat.TFRMSeans);
var  FRM:MsgChat.TFRM_SetPhotoProfile;

begin
   // FRM:=   MsgChat.TFRM_Profile_NewPhoto(LParam(aFRM));
  //  FRM:=    MsgChat.TFRM_Profile_NewPhoto(LParam(aFRM));

    FRM:=  MsgChat.TFRM_SetPhotoProfile.Create;
    FRM.CopyAndFree(aFRM);
    FRM.PhotoId:=   SVR['Profile']['PhotoId'].Value;
    FRM.IsMain:=    SVR['Profile']['IsMain'].BoolValue;
    FRM_PostMessage(MsgChat.FRM_SetPhotoProfile,FRM);
end;
procedure TAmChatClientSocket.FRM_ACTIV_SEANS (SVR:TjsonObject;Proc:MsgChat.TFRMseansProc);
var  FRM:MsgChat.TFRMSeans;
begin
    FRM:=  MsgChat.TFRMSeans.Create;
    FRM.ResultSend:=        true;
    FRM.PopapInfo.id:=      MsgChat.FRM_LogIn;
    FRM.PopapInfo.IsError:= not(SVR['Result'].BoolValue);
    FRM.PopapInfo.text:=    SVR['ResultMsg'];
    if SVR['ResultAuth'].BoolValue then    FRM.ResultAuth:= MsgChat.AuthTrue
    else FRM.ResultAuth:=0;

    FRM.Result:= SVR['Result'].BoolValue;
    FRM.LParamPot:= SVR['LParamPot'].Value;
    FRM.Indiv:=     SVR['Indiv'].Value;


    if FRM.ResultAuth= MsgChat.AuthTrue then
    begin
       if Assigned(Proc) then Proc(SVR,FRM)
       else  FRM_PostMessage(MsgChat.FRM_Auth_ActivSeans,FRM);
    end
    else  FRM_Sended_LogIn(FRM);

end;
procedure TAmChatClientSocket.FRM_Before_Reg(SVR:TjsonObject);
var  FRM:MsgChat.TFRM_Reg;
begin
    FRM:=  MsgChat.TFRM_Reg.Create;
    FRM.ResultSend:=        true;

    FRM.PopapInfo.id:=      MsgChat.FRM_LogIn;
    FRM.PopapInfo.IsError:= not(SVR['Result'].BoolValue);
    FRM.PopapInfo.text:=    SVR['ResultMsg'];


    FRM.Result:=      SVR['Result'];

    if FRM.Result then
    begin
      FRM.Id:=              SVR['Auth']['Id'];
    end;
    FRM_Sended_Reg(FRM);

end;
procedure TAmChatClientSocket.FRM_Sended_Reg(FRM:MsgChat.TFRM_Reg);
begin
    FRM_PostMessage(MsgChat.FRM_Reg,FRM);
end;
procedure TAmChatClientSocket.FRM_Before_LogIn(SVR:TjsonObject);
var  FRM:MsgChat.TFRM_LogIn;
begin
    FRM:=  MsgChat.TFRM_LogIn.Create;
    FRM.ResultSend:=        true;
    FRM.PopapInfo.id:=      MsgChat.FRM_LogIn;
    FRM.PopapInfo.IsError:= not(SVR['Result'].BoolValue);
    FRM.PopapInfo.text:=    SVR['ResultMsg'];


    if SVR['Result'].BoolValue then FRM.ResultAuth:= MsgChat.AuthTrue ;
    FRM.Result:= SVR['Result'].BoolValue;

    if FRM.ResultAuth=MsgChat.AuthTrue then
    begin
      FRM.Token:=           SVR['Auth']['Token'];
      FRM.Hash:=            SVR['Auth']['Hash'];
      FRM.Id:=              SVR['Auth']['Id'];
      FRM.ScreenName:=      SVR['Auth']['ScreenName'];
      FRM.UserName:=        SVR['Auth']['UserName'];
      FRM.PhotoId:=         SVR['Auth']['PhotoId'];
      FRM.PhotoData:=         SVR['Auth']['PhotoData'];
      FRM.ContactsUpData:=    SVR['Auth']['Contacts']['UpData'];

    end;
    FRM_Sended_LogIn(FRM);

end;


procedure TAmChatClientSocket.FRM_Sended_LogIn(FRM:MsgChat.TMSG);
begin
     FRM_PostMessage(MsgChat.FRM_LogIn,FRM);
end;
procedure TAmChatClientSocket.FRM_UpConnect (SVR:TjsonObject);
var  FRM:MsgChat.TFRM_UpConnect;

begin
   // FRM:=   MsgChat.TFRM_Profile_NewPhoto(LParam(aFRM));
//    FRM:=    MsgChat.TFRM_User_PhotoDownload(LParam(aFRM));

    FRM:=  MsgChat.TFRM_UpConnect.Create;
    FRM.ConnectValue:= SVR['ConnectValue'].Value;
    FRM.ResultSend:=        true;
    FRM.PopapInfo.id:=      MsgChat.FRM_UpConnect;
    FRM.PopapInfo.IsError:= false;
    FRM.PopapInfo.text:=    SVR['ResultMsg'];

    FRM_PostMessage(MsgChat.FRM_UpConnect,FRM);
end;
procedure TAmChatClientSocket.FRM_PostMessage(WParam:Cardinal;MSG:MsgChat.TMSG);
var Result:boolean;
begin
  Result:=false;
  if ISWINDOW(FRM_HANDLE) then
   Result:=PostMessage(FRM_HANDLE,MsgChat.MSG_TO_EDITOR,WParam,LParam(MSG));
   if not Result then  MSG.Free;

end;

constructor TAmChatClientSocket.Create(AmiliSecondsTimeOutWaitFor:Cardinal=INFINITE);
begin
    inherited  Create(AmiliSecondsTimeOutWaitFor);
    OnEventMainPot:= TOnEventMainPot.Create;
    OnAfterRead:=AfterRead;
    OnBeforeRead:= BeforeRead;
    FRM_HANDLE:=0;

end;
destructor  TAmChatClientSocket.Destroy;
begin

    inherited;
    OnEventMainPot.Free;
end;

procedure   TAmChatClientSocket.Execute;
begin

   inherited Execute;
end;
procedure   TAmChatClientSocket.SockDisconnect (Sender: TObject; Socket: TCustomWinSocket);
begin
   inherited ;
   //ChatRemoveClient(Socket.RemotePort);
   OnEventMainPot.DoDisconnect;
   log('SockDisconnect');
end;
procedure  TAmChatClientSocket.SockConnect (Sender: TObject; Socket: TCustomWinSocket);
begin
    log('SockConnect');
    inherited ;
    OnEventMainPot.DoConnect;
end;
procedure  TAmChatClientSocket.SockConnecting (Sender: TObject; Socket: TCustomWinSocket);
begin
    log('SockConnecting...');
    inherited ;
    OnEventMainPot.DoConnecting;
end;
procedure   TAmChatClientSocket.ThreadReadStart (Sender: TObject);
begin
  inherited;

end;

procedure TAmChatClientSocket.BeforeRead (Thread:TObject;
                        var Prt:TAmProtocolSock;
                        var Stream:TStream;
                        var IsNeedCloseConnect:boolean);
begin
   if (Prt.TypeRequest= AmPrtSockTypeRequest.cPost)
   and (Prt.TypeData = AmPrtSockTypeData.dJsonString) then
   Stream:= TMemoryStream.Create as TStream
   else log('TAmChatClientSocket.BeforeRead не верно указан заголовок  TypeRequest='+
   Prt.TypeRequest.ToString+' TypeData '+Prt.TypeData.ToString+' ');
end;

procedure TAmChatClientSocket.AfterRead   (Thread:TObject;
                        var Prt:TAmProtocolSock;
                        var Stream:TStream;
                        var IsNeedCloseConnect:boolean;
                        ResultRead:boolean) ;
begin
 try
   if not ResultRead then
   begin
      log('TAmChatClientSocket.AfterRead не прочитано ResultRead=false');
      exit;
   end;
   if (Prt.TypeRequest= AmPrtSockTypeRequest.cPost)
   and (Prt.TypeData = AmPrtSockTypeData.dJsonString) then
   FRM_MAIN_ParsResponse(AmStr(Stream));
 finally
   if Assigned(Stream) then Stream.Free;
   Stream:=nil;
 end;


    
end;










procedure TAmChatClientSocket.TOnEventMainPot.DoConnect ;
begin
   PostMessage(self.Handle,MsgChat.MSG_ONCONNECT,0,0);
end;
procedure TAmChatClientSocket.TOnEventMainPot.DoConnecting ;
begin
   PostMessage(self.Handle,MsgChat.MSG_ONCONNECTING,0,0);
end;

procedure TAmChatClientSocket.TOnEventMainPot.DoDisconnect;
begin
    PostMessage(self.Handle,MsgChat.MSG_ONDISCONNECT,0,0);
end;
procedure TAmChatClientSocket.TOnEventMainPot.DoRead(Str:string);
begin
    PostMessage(self.Handle,MsgChat.MSG_ONREAD,0,0);
end;
procedure TAmChatClientSocket.TOnEventMainPot.DoWrite;
begin
    PostMessage(self.Handle,MsgChat.MSG_ONWRITE,0,0);
end;
procedure TAmChatClientSocket.TOnEventMainPot.DoError(Int:integer);
begin
     PostMessage(self.Handle,MsgChat.MSG_ONERROR,0,0);
end;

procedure TAmChatClientSocket.TOnEventMainPot.ChConnectPost    (var Msg:Tmessage) ;// message MsgChat.MSG_ONCONNECT;
begin
   if Assigned(FOnConnect) then FOnConnect;
end;
procedure TAmChatClientSocket.TOnEventMainPot.ChConnectingPost (var Msg:Tmessage) ;// message MsgChat.MSG_ONCONNECTING;
begin
    if Assigned(FOnConnecting) then FOnConnecting;
end;
procedure TAmChatClientSocket.TOnEventMainPot.ChDisconnectPost (var Msg:Tmessage) ;// message MsgChat.MSG_ONDISCONNECT;
begin
     if Assigned(FOnDisconnect) then FOnDisconnect;
end;
procedure TAmChatClientSocket.TOnEventMainPot.ChReadPost       (var Msg:Tmessage) ;// message MsgChat.MSG_ONREAD;
begin
   //  if Assigned(FOnConnect) then FOnDisconnect;
end;
procedure TAmChatClientSocket.TOnEventMainPot.ChWritePost      (var Msg:Tmessage) ; //message MsgChat.MSG_ONWRITE;
begin
    if Assigned(FOnWrite) then FOnWrite;
end;
procedure TAmChatClientSocket.TOnEventMainPot.ChErrorPost      (var Msg:Tmessage) ; //message MsgChat.MSG_ONERROR;
begin
   //  if Assigned(FOnConnect) then FOnDisconnect;
end;



end.
