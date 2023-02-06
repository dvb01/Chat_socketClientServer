unit AmChatClientEditor;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,
  AmChatClientComponets,
  DateUtils,
  AmChatClientContactBox,
  AmChatClientMessageBox,
  AmChatCustomSocket,
  AmVoiceRecord,
  AmMessageFilesControl,
  AmChatClientFileThread,
  amList,AmControls,
  System.RegularExpressions,
  IdCoderMIME,
  IdCoder,
  ES.BaseControls, ES.Layouts, ES.Images,
  AmMultiSockTcpCustomPrt,
  AmChatClientPeopleBox,
  AmChatClientParticipantBox,
  AmFormPopapNewMessage,
  mmsystem;

  const
    AM_CLIENT_TIM_LOAD_MAIN_PHOTO =4000;


    type
     ConstEditor =record
          type
            TLoadFile = class
              Ext:string;
              Dir:string;
              IdFile:string;

            end;
          type
            TLoadPhotoAddr = class(TLoadFile)
               IsMain:boolean;
               AddrImg:Cardinal;
            end;
     end;
   Type
    TChatClientNeedSaveDialogEvent = procedure (var FileName:string) of object;
   type
    TChatClientStoreMessageHistory = class

    strict private
      FIdLastMsgTop:string;
      FMax,FNow:integer;
      FMessage:TjsonObject;
      FUsers:TjsonObject;
      //FContact:TjsonObject;
    private
      IsFinish:boolean;
      IsGetOldBlockToServer:boolean;
      IsFinishAll:boolean;
      IsOpenDiadlog:boolean;
      NextIdLocal:integer;
      Procedure NewDialog(ObjMessageJsonString,ObjUsersJsonString:string);
      Procedure AddOldMessageToNowDialog(ObjMessageJsonString:string);
      Procedure CloseDialog;
      Function  NewMessageAdd(ObjOneMessageJsonString:string):TjsonObject;
      Procedure  NewUsersAdd(ObjUserOneJsonString:string);
     // Procedure DownMessageToDialog;
      Property  Message: TjsonObject read  FMessage;
      Property  Users: TjsonObject read  FUsers;
    //  Property  Contact: TjsonObject read  FContact;
      Property  Max :integer  read FMax write FMax;
      Property  Now :integer read FNow write FNow;
      
     
    public
      Const  CountBlockMessage = 10; 
      constructor Create;
      destructor Destroy; override;
    end;
   type
    TChatActivDialog = record

     strict private
       FUserId:string;
       FTypeUser:string;
       FIsActiv:boolean;
       FUserName,FStatusOnline:string;
       Procedure SetUserName(val:string);
       Procedure SetStatusOnline(val:string);
     public
      property  UserName:string read FUserName  write SetUserName ;
      property  StatusOnline:string read FStatusOnline  write SetStatusOnline ;
      property  IsActiv:boolean read FIsActiv;
      property  UserId:string read FUserId;
      property  TypeUser:string read FTypeUser;
      Procedure DeActiv;
      Procedure Activ(aUserId,aTypeUser:string);
      Function Check(aTypeUser:string):boolean; overload;
      Function Check(aUserId,aTypeUser:string):boolean; overload;
    end;
   Type
    TEventInt = procedure (Val:integer)of object;
   type
    TChatClientEditor = Class (TamHandleObject)

       private
       FTimerUpConnect:TTimer;
       FUserActivSeans:boolean;  // c момента зайти в чат до момента выхода с чата только юзером изменяется
       FUserActivSeansAuth:boolean;  // c момента удачного входа в чат до момента пока аторизация не пропала или выхода
       FIsServerOnlineSave:boolean;

       FId:string;
       FScreenName:string;
       FUserName:string;
       FPopapInfo:TAmChatClientPopapInfo;
       FStatusAuth:boolean;
       FToken:string;
       FHash:string;
       FMainPhotoId:string;
       FMainPhotoData:string;
       StoreMsgHistory: TChatClientStoreMessageHistory; // хранит всю историю диалога
       FCountNoReadMessage:integer;
       FCountNoReadMessageChange: TEventInt;

       FDir:string;
       FDirPhotos:string;
       FDirVoice:string;
       FDirFiles:string;
       FnObjUser:string;

       Socket_Address:string;
       Socket_Port:integer;
       Socket: TAmChatClientSocket;
       SocketFile:TAmClientSockFile;

       FOnNeedSaveDialogEvent:TChatClientNeedSaveDialogEvent;

       Procedure OnTimerUpConnect(s:Tobject);
       Function GetId:string;
       Procedure SetId(val:string);

       Function  GetScreenName:string;
       Procedure SetScreenName(val:string);

       Function  GetUserName:string;
       Procedure SetUserName(val:string);

       Function  GetPopapInfo:TAmChatClientPopapInfo;
       Procedure SetPopapInfo(val:TAmChatClientPopapInfo);

       Function  GetStatusAuth:boolean;
       Procedure SetStatusAuth(val:boolean);

       Function  GetToken:string;
       Procedure SetToken(val:string);

       Function  GetHash:string;
       Procedure SetHash(val:string);
       Procedure CountNoReadMessageSetInc(Val:integer);

       Procedure FormShow;
       Procedure EventConnect;
       Procedure EventDisConnect;
       Procedure EventConnecting;
     public
      //BufferConteiner:TMemoryStream;// исрользуется что бы хранить временно последнее голосове или др контент пока не будет известно куда его сохранить

      ObjUser:TjsonObject;
      ActivDialog:TChatActivDialog;

      // список активных потоков
    //  ListThread:TAmClientListPot;

       //попап панелька иформация о поключении
      PopapResult: TChatClientPopapWindow;

      constructor Create;
      destructor Destroy; override;
      {var}
      Procedure  ClearAllInfoUserExceptToken;
      property  IsServerOnlineSave:boolean read FIsServerOnlineSave;
      property  SocketClient:TAmChatClientSocket read  Socket;
      property  CountNoReadMessage:integer read  FCountNoReadMessage write CountNoReadMessageSetInc;
      property  OnChangeCountNoReadMessage: TEventInt  read FCountNoReadMessageChange write FCountNoReadMessageChange;


      // подключение сокета к серверу
      Procedure  Start( aAddressSocket:string;  aPortSokect:integer;  MiliSecondsTimeOutSocket:Cardinal=INFINITE);
      // отключить сокет от сервера
      Procedure  Stop;

      // переменные хронят данные текущего юзера и какие то из них записываются в базу как куки в браузере
      property Id:string  Read GetId write SetId;
      property ScreenName:string  Read GetScreenName write SetScreenName;
      property UserName:string  Read GetUserName write SetUserName;
      property PopapInfo :TAmChatClientPopapInfo  Read GetPopapInfo write SetPopapInfo;
      property StatusAuth:boolean  Read GetStatusAuth write SetStatusAuth;
      property Token:string  Read GetToken write SetToken;
      property Hash:string  Read GetHash write SetHash;
      property MainPhotoId :string  Read FMainPhotoId write FMainPhotoId;
      property MainPhotoData :string  Read FMainPhotoData write FMainPhotoData;


      // находится ли пользователь в активном сеансе (от момента авторизация до выйти)
      property UserActivSeans:boolean  Read FUserActivSeans write FUserActivSeans;



     // Procedure PhotoCheckList(ListItem:TChatClientTimerPhoto.TListItem);
      //Событие по таймеру после PhotoCheck  or PhotoCheckList
   //   Procedure PhotoNeedDowloadImg(PhotoId,PhotoData:string;var ResultSend:boolean);


      // Отображение в нижнем левом лога
      Procedure PopapInfoSetText(Text:String;IsError:boolean=false;Sec:string='7');
      //Procedure GetContacts;

      // запускается после получения контактов от сервера
      Procedure Contacts_LoadParsJson(ContactsObjJsonString:string);

      // запускается в Contacts_LoadParsJson загружает весь список контакотов
      Procedure Contacts_LoadList(ContactsObj:TjsonObject);

      // заполняет данными 1 контакт
      Function Contact_LoadOne(ContactOne:TAmClientOneContact;ContactObj:TjsonObject):TAmResult16;


      // если нет такого контакта то создает его  Result true контакт только что был создан осталось его заполнить данными если false контакт уже существует в списке нужно обновить данные
      Function Contacts_AnyGetOneContact(UserId,TypeUser:string;var ContactOne:TAmClientOneContact):boolean;

      //запускается с FRM_Online когда какой то контакт стал онлайн
      Procedure Contact_SetTypeOnline(aIdUser:string;TypeOnline:string);


      Procedure Participants_LoadList(ParticipantsArray:TjsonArray;TypePanelFree:string);
      Procedure Participants_LoadOne(ParticipantOne:TAmClientOneParticipant;ParticipantObj:TjsonObject);
      Procedure ContactsCopyParticipants(TypePanelFree:string);
      // запускается при попытке покинуть чат или выход из текушего диалога
      Procedure CloseDialog;





    //  Procedure SetContactStatusOnline(ContactUpdate:TAmClientOneContact;TypeOnline:string);
    //  Procedure SetContactStatusName(ContactUpdate:TAmClientOneContact;NameUser:string);

      //подключена к событиию  при попытке посмотреть историю диалога  отправляет запрос на сервер
      Procedure GetHistoryChat(OneContact:TAmClientOneContact); overload;
      Procedure GetHistoryChat(OnePeople:TAmClientOnePeople); overload;
      Procedure GetHistoryChat(AId,ATypeUser:string); overload;
      // после ответа сервера загружает историю диалога не всю остальная в StoreMsgHistory
      Procedure MessageHistory_Load(ObjMessageJsonString,ObjUsersJsonString,ObjContactJsonString:string);

      // подключатеся к событию скрола вверх и догружает еще немного сообщений с StoreMsgHistory в box
      Procedure GetOldBlockMessageHistory(LastIdLocalMessage:string);

      //загрузка одного блока соообщений запускается при скроле вверх  GetOldBlockMessageHistory
      // и при открытии нового диалога в LoadMessageHistory
      Procedure MessageHistory_LoadOneBlock(IsNewDialog:Boolean);



      //вызывается с FRM_Message_New загружает 1 новое сообщение и обновляет контакт
      Procedure Message_LoadOneNew(ObjMessageJsonString,ObjUsersJsonString,ObjContactJsonString:string);

      // подключается к сообытию когда сообщение прочитывается и отправляет запрос на сервер
      Procedure Message_ReadOne(OneMessage:TAmClientOneMessage);



      // подключается к сообытию когда не удается воспроизвести песню или голос
      Procedure OneMessageVoiceNotPlay(OneMessage:TAmClientOneMessage;FileName:string;IsPlay:boolean);

      // после скачивая с сервера загрузка песни голосвого
   //   Procedure LoadVoice(VoiceId:string;IsPlay:boolean;LParamOneMessage:Integer;VoiceBase64:string);





      //TIM_  сам себе отсыдается сообщение postmessge что бы разгрузить высокозначимые действия
      //Procedure TIM_LoadMainPhoto(var Msg:TMessage);message AM_CLIENT_TIM_LOAD_MAIN_PHOTO;

      // не отправленное сообщение только что нажали отправить (мнимое в памяти сесии)
      // т.е на сервере его пока нет, только у юзера
      Procedure  MIM_Message_Send_Text(TypeUser,ContactUserId,Text:string);
      Procedure  MIM_Message_Send_Voice(TypeUser,ContactUserId:string; ms:TStream; MaxPos:integer;CaptionTime:string;Spectr:TAmBassSpectrMono);
      Procedure  MIM_Message_Send_Files(TypeUser,ContactUserId,Comment:string;ListFiles:TamListVar<string>);
      Procedure  MIM_OnAbortSend(OneMessage:TObject);
      Procedure  MIM_OnPauseSend(OneMessage:TObject);
      function   mim_help_Add_MessageCteate(TypeUser,ContactUserId,TypeContent:string):TAmClientOneMessage;




      // <<<<<<<<<<<<<<<<<<<<< от потока отправляющий файлы в текущий поток для обновления или на сервер>>SVR ..ListThread
      {upload}
      Procedure  PFT_NewMessageUploadSend(var Msg:TMessage);message AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD;
      Procedure  PFT_WorkUploadSend(Work:TamClientFileThreadParamWorkSender);
      Procedure  PFT_WorkUploadEndSend(Param:TAmClientChatFilesSendParam);
      Procedure  PFT_SendMessageAtUpload(Msg:PFT.TSendMessage);
      Procedure  PFT_UpdateListParamAtUploadSend(var Msg:TMessage);message AM_CLIENT_EDITOR_THREAD_PFT_UPDATE_LIST;


      Procedure  Profile_PhotoUpload(FileName:String;IsMain:boolean;ComponentLparam:integer=0);
      Procedure  Groop_PhotoUpload(FileName:String;GroopId:string;LparamPhoto:integer);
      Procedure  PhotoUpload(FileName:String;ComponentInDivId:integer;ComponentLparam:integer;indiv:string);


      Procedure  PFT_NewMessageUploadPhotoMain(var Msg:TMessage);message AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD_PHOTOMAIN;
      Procedure  PFT_WorkUploadPhotoMain(Work:TamClientFileThreadParamWorkSender);
      Procedure  PFT_WorkUploadEndPhotoMain(Param:TAmClientUploadMainPhotoParam);





      {Download}
     //загрузить файлы в компонент если они есть на диске если нет скачать

     procedure FilesControlOnDownloadStart (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string);
     procedure FilesControlOpenManagger  (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string);
     procedure FilesControlOnDownloadAbort (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string);
     procedure FilesControlOnDownloadPause (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string);

     procedure FilesControlOnDownloadAbortPause (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string;IsPause:boolean);

      Procedure MessageFilesCheckDownload(
                               Message:TAmClientOneMessage;
                               IdPhoto10,IdPhoto500,IdFileZip,IdVoice:string;
                               DownloadNow:boolean=true;
                               FileSetToControlAtError:boolean=false
                               );
       // отправка в поток на скачивание
      Procedure  MessageFilesDownload(
                              Message:TAmClientOneMessage;
                              IdFile,FileName:string;
                              TypeFile:integer;
                              indiv:string
      );
      //загружает с диска в компонент файлы  или возвращает ошибку result<0
      Function  MessageFilesLoadWithDisk(
                              Message:TAmClientOneMessage;
                              IdFile,FileName:string;
                              TypeFile:integer;
                              indiv:string;
                              FileSetToControlAtError:boolean
                              ):integer;

      //ответ от потока
      Procedure  PFT_MAIN_Download_MessageFiles(var Msg:TMessage);message AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_MSG_FILES;
      Procedure  PFT_Download_MessageFiles_Work(Work:TamClientFileThreadParamWorkSender);
      Procedure  PFT_Download_MessageFiles_End(Param:TamClientDownloadParam);



       //....................
      //загрузить картинку для профиля или контакта если нет то скачать
      // отправка в поток на скачивание
      Procedure  PhotoContact_CheckDownload(PhotoId:string;LParamImage:Cardinal);
      //загрузить фото с диска в компонент если фото нет result <0
      function   Photo_LoadWithDisk(PhotoId:string;LParamImage:Cardinal):integer;


      Procedure  PFT_MAIN_DownloadPhotoContact(var Msg:TMessage);message AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_PHOTO_CONTACT;
      Procedure  PFT_Download_PhotoContact_Work(Work:TamClientFileThreadParamWorkSender);
      Procedure  PFT_Download_PhotoContact_End(Param:TamClientDownloadParam);









      //>>>>>>>>>>>>>>>>>>>>>  запросы на сервер
      Function   SVR_PostMessage(Wparam:Cardinal;MSG:MsgChat.TMSG):boolean;
      //команды дейсвий юзера  на сервер
      Function   SVR_UpConnect(ConnectValue:string):boolean; // разв 2 мин должно обновлять соединение

      Procedure  SVR_LogIn; //эту команду запустить первой после Start она откроет саму форму и  авторизируется если был токен
      Procedure  SVR_LogInParam(Login,Pass:string;Rmb:Boolean);
      Procedure  SVR_LogOut(IsOutAcc:boolean);
      Function   SVR_SetTypeOnline(TypeOnline:string):boolean;
      Procedure  SVR_Reg(Login,Email,Pass,Pass2,UserName:string);
      Function   SVR_SetPhotoProfile(PhotoId:string;IsMain:boolean;LParamPot:string='';Indiv:string=''):boolean;
    //  Function   SVR_GetIdFileUpload(LParamPot:string='';Indiv:string=''):boolean;
     // Function   Profile_GetById(UserId:string):boolean;
    //  Function   SVR_User_PhotoDownload(PhotoId,PhotoData:string;LParamPot:string='';Indiv:string=''):boolean;



      // что бы получить список контактов и всю иторию переписок сначало
      //в ответе FRM_LogIn сранивается дата и если дата не совподает то тогда уже полный список получить нужно SVR_Contacts
      Function   SVR_Profile_ContactsFull():boolean;
      Function   SVR_Message_Send(
                                              TypeUser:string;
                                              ContactUserId:string;
                                              TypeContent:string;
                                              Content:string;
                                              MimId:string;
                                              MimLparam:string;
                                              LParamPot:string='';Indiv:string=''):boolean;
      Function   SVR_Message_History( TypeUser:string;ContactUserId:string):boolean;
      Function   SVR_Message_History_OffSet( TypeUser:string;ContactUserId,StartIdLocal,GetCount,Indiv:string;IsBegin:boolean=false):boolean;
      Function   SVR_Message_Read( TypeMetodReadMessage,TypeUser,ContactUserId,UserIdMessage,IdLocalMessage:string):boolean;
    //  Function   SVR_Voice_Dowload(VoiceId:string;IsPlay:boolean; LParamOneMessage:Cardinal):boolean;
      Function   SVR_ContactDelete(TypeUser:string;UserId:string):boolean;

      Function   SVR_Serch(val:string):boolean;

      Function   SVR_Groop_Create(ScreenGroopName,GroopName,TypeGroopPrivacy:string):boolean;
      Function   SVR_Groop_GetListUsers(GroopId:string):boolean;
      Function   SVR_Groop_AddUser(GroopId:string;AUserId:string;LPot:string):boolean;
      Function   SVR_Groop_DeleteUser(GroopId:string;AUserId:string;LPot:string):boolean;
      Function   SVR_Groop_SetPhoto(GroopId:string;PhotoId:string;LPot:integer):boolean;
      Function   SVR_Groop_SetUserName(GroopId,NewUserName:string):boolean;


      //<<<<<<<<<<<<<<<< получаю результат от сервера
      procedure  FRM_MAIN (var Msg:Tmessage); message MsgChat.MSG_TO_EDITOR;



      //команды отображения результата которые сами вызываются после ответа сервера
      procedure  FRM_UpConnect(MSG:MsgChat.TMSG); // разв 2 мин должно обновлять соединение
      procedure  FRM_LogIn(MSG:MsgChat.TMSG);
      procedure  FRM_Auth_ActivSeans_Back(MSG:MsgChat.TMSG);
      procedure  FRM_Reg(MSG:MsgChat.TMSG);
      procedure  FRM_SetPhotoProfile(MSG:MsgChat.TMSG);
    //  procedure  FRM_GetIdFileUpload(MSG:MsgChat.TMSG);
//      procedure  FRM_User_PhotoDownload(MSG:MsgChat.TMSG);
      procedure  FRM_Profile_ContactsFull(MSG:MsgChat.TMSG);
      procedure  FRM_Message_New(MSG:MsgChat.TMSG);
      procedure  FRM_Message_History(MSG:MsgChat.TMSG);
      procedure  FRM_TypeOnline(MSG:MsgChat.TMSG);
      procedure  FRM_Message_Read(MSG:MsgChat.TMSG);
     // procedure  FRM_Voice_Download(MSG:MsgChat.TMSG);
      procedure  FRM_Serch(MSG:MsgChat.TMSG);
      procedure  FRM_Groop_Create(MSG:MsgChat.TMSG);
      procedure  FRM_Groop_GetListUsers(MSG:MsgChat.TMSG);

      procedure  FRM_Groop_ShowResponse(LParamPot:integer;Text:string);
      procedure  FRM_Groop_AddUser(MSG:MsgChat.TMSG);
      procedure  FRM_Groop_DeleteUser(MSG:MsgChat.TMSG);
      procedure  FRM_ContactNew(MSG:MsgChat.TMSG);
      procedure  FRM_ContactDelete(MSG:MsgChat.TMSG);
      procedure  FRM_Groop_SetPhoto(MSG:MsgChat.TMSG);
      procedure  FRM_Groop_SetUserName(MSG:MsgChat.TMSG);




      property OnNeedSaveDialogEvent:TChatClientNeedSaveDialogEvent read FOnNeedSaveDialogEvent write FOnNeedSaveDialogEvent;


   end;



implementation
uses AmChatClientForm;

Procedure TChatActivDialog.DeActiv;
begin
   self.FUserId:='';
   self.FTypeUser:='';
   self.UserName:='';
   self.StatusOnline:='';
   self.FIsActiv:=false;

   if ASsigned(ChatClientForm) then
   ChatClientForm.PanelChatTop_ChatShare.Visible:=False;

end;
Procedure TChatActivDialog.Activ(aUserId,aTypeUser:string);
begin
   FUserId:=aUserId;
   FTypeUser:=aTypeUser;
   FIsActiv:=true;
   if ASsigned(ChatClientForm) then
   ChatClientForm.PanelChatTop_ChatShare.Visible:=true;
end;
Function TChatActivDialog.Check(aTypeUser:string):boolean;
begin
   Result:=IsActiv
   and (aTypeUser = TypeUser)
   and (AmInt(UserId,0)>0)
end;
Function TChatActivDialog.Check(aUserId,aTypeUser:string):boolean;
begin
   Result:= Check(aTypeUser) and (UserId = aUserId);
end;
Procedure TChatActivDialog.SetUserName(val:string);
begin

   FUserName:= val;
   if Assigned(ChatClientForm) then
   ChatClientForm.PanelChatTop_UserName.Caption:= FUserName;

end;
Procedure TChatActivDialog.SetStatusOnline(val:string);
var s:string;
  procedure St(col:TColor;Text:String);
  begin
    if Assigned(ChatClientForm) then
    begin
            ChatClientForm.PanelChatTop_Status.Caption:=Text;
            ChatClientForm.PanelChatTop_Status.Font.Color:= col// зеленый

    end;
  end;
begin
   FStatusOnline:= val;
   if      FStatusOnline = ConstAmChat.TypeOnline.Online  then St($00C8DD7D , 'В сети' )
   else if FStatusOnline = ConstAmChat.TypeOnline.Nearby  then St($0079DBD9 , 'Рядом' )
   else if FStatusOnline = ConstAmChat.TypeOnline.Offline  then St($008C8A66 , 'Не в сети' )
   else                                                      St(clSilver , '' )
end;


 // <<<<<<<<<<<<<<<<<<<<< от потока отправляющий файлы в текущий поток для обновления или на сервер>>SVR ..ListThread

               {Download}
Procedure  TChatClientEditor.PFT_MAIN_Download_MessageFiles(var Msg:TMessage);//message AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_MSG_FILES;
begin
      case Msg.WParam of

          PFT.ChangeWorkDownload :      PFT_Download_MessageFiles_Work(TamClientFileThreadParamWorkSender(Msg.LParam));
          PFT.EndParam:                 PFT_Download_MessageFiles_End(TamClientDownloadParam(Msg.LParam));
          else showmessage('Нет такой команды PFT_NewMessage');

      end;
end;
Procedure  TChatClientEditor.PFT_Download_MessageFiles_Work(Work:TamClientFileThreadParamWorkSender);
var Item:TAmClientMessageFilesPaintBox.TItem;
    Message:TAmClientOneMessage;
begin
     if not Assigned(Work) then  exit;
     try
        if Work.ComponentLparam>0 then
        begin
          if AmCheckObject(TObject(Work.ComponentLparam)) then
          begin
          
             if TObject(Work.ComponentLparam) is TAmClientMessageFilesPaintBox.TItem then
             begin
                Item:=  TAmClientMessageFilesPaintBox.TItem(Work.ComponentLparam);
                if Assigned(Item) and not Item.IsDestroy then
                begin
                     Item.SizeFile:= Work.Size;
                     Item.PositionBar:=  Work.Position;
                end;
             end
             else
             if TObject(Work.ComponentLparam) is TAmClientOneMessage then
             begin
                Message:=  TAmClientOneMessage(Work.ComponentLparam);
                if AmCheckControl(Message) then
                begin
                   if Work.TypeFile = AmPrtSockTypeFile.Voice then
                   begin
                      if AmCheckControl(Message.MsgVoice) then
                      begin
                        Message.MsgVoice.LabelInfo.Caption:=
                        FormatFloat('0.00',Work.Position /  1000000) +' '+ FormatFloat('0.00',Work.Size /  1000000)+'Mb';
                      end;
                   end;


                end;
             end
          end;
        end;
     finally
       Work.Free;
     end;

end;
Procedure  TChatClientEditor.PFT_Download_MessageFiles_End(Param:TamClientDownloadParam);
var R:integer;
Dw:TAmClientFileThreadDownload;
var ItemFile:TAmClientMessageFilesPaintBox.TItem;
    ItemImg:TAmClientMessageFilesImageCollage.TItem ;
begin
  Dw:=nil;
  if not Assigned(Param) or Param.IssDestroy then  exit;
  try


       if (Param.ComponentLparam>0) and (Param.TypesAddr=2) then
       begin
          if AmCheckObject(TObject(Param.ComponentLparam)) then
          begin
             if TObject(Param.ComponentLparam) is TAmClientOneMessage then
             begin
               if AmCheckControl(TAmClientOneMessage(Param.ComponentLparam)) then
               begin
                 if Param.Result = Param.TypeFile then
                 MessageFilesLoadWithDisk(TAmClientOneMessage(Param.ComponentLparam),
                 Param.IdFile,Param.FileName,Param.TypeFile,Param.InDiv,False);
               end;
             end
             else if TObject(Param.ComponentLparam) is TAmClientMessageFilesPaintBox.TItem then
             begin
               ItemFile:=  TAmClientMessageFilesPaintBox.TItem(Param.ComponentLparam);
               if not ItemFile.IsDestroy then
               begin
                  if Param.NeedAbort and Param.NeedPause then
                  begin
                      // Item.KindDownload:= TAmClientMessageFilesPaintBox.TItemState.itNoDownload;
                       ItemFile.PositionBar:=1;
                       ItemFile.LastJsonError :='';
                       ItemFile.repaint;
                  end
                  else if Param.NeedAbort then
                  begin
                       ItemFile.KindDownload:= mfitNoDownload;
                       ItemFile.PositionBar:=1;
                       ItemFile.LastJsonError :='';
                       ItemFile.repaint;
                       ItemFile.ComponentLparam:=0;

                  end
                  else if Param.ErrorIsWas then
                  begin
                       ItemFile.KindDownload:= mfitErrorDownload;
                       ItemFile.LastJsonError :=  Param.ErrorMessage +' '+Param.Result.ToString +' '+Param.JsonSring;
                       ItemFile.repaint;
                       ItemFile.ComponentLparam:=0;
                  end
                  else
                  begin
                     if Param.Result = Param.TypeFile then
                     begin
                       ItemFile.KindDownload:= mfitIsDownload;
                       ItemFile.FileNameFull:= Param.FileName;
                       ItemFile.repaint;
                       ItemFile.ComponentLparam:=0;
                     end
                     else
                     begin
                       ItemFile.KindDownload:= mfitErrorDownload;
                       ItemFile.LastJsonError :=  Param.JsonSring;
                       ItemFile.repaint;
                       ItemFile.ComponentLparam:=0;
                     end;
                  end;


               end;
             end
             else if TObject(Param.ComponentLparam) is TAmClientMessageFilesImageCollage.TItem then
             begin
                 ItemImg:=TAmClientMessageFilesImageCollage.TItem(Param.ComponentLparam);
                 if not ItemImg.IsDestroy then
                 begin
                     ItemImg.FullFileName:= Param.FileName;

                 end;
             end;



          end;
                  

       end;





  finally


      if Param.InDiv='IdPhoto10' then  Dw:=SocketFile.DownloadPhoto10
      else
      if Param.InDiv='IdPhoto500' then  Dw:=SocketFile.DownloadPhoto500
      else
      if Param.InDiv='IdFileZip' then  Dw:=SocketFile.DownloadFiles
      else
      if Param.InDiv='IdVoice' then  Dw:=SocketFile.DownloadVoice;

      if Assigned(Dw) then
      begin
      
          if Param.NeedAbort and Param.NeedPause then
          begin
               Param.NeedPause:=false;
               Param.NeedAbort:=false;
               Param.ErrorIsWas:=false;
               Param.ErrorMessage:='';
               Dw.RemoveParamNoFree(TamClientFileThreadParam(Param));
               Dw.AddNewParam(Param);
          end
          else Dw.RemoveParam(Param);
      end;
  end;

end;
Procedure  TChatClientEditor.MessageFilesDownload(
                        Message:TAmClientOneMessage;
                        IdFile,FileName:string;
                        TypeFile:integer;
                        indiv:string );
var
 Par:TamClientDownloadParam;
begin


   Par:=  TamClientDownloadParam.Create;
   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;
   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.EventMessage:= AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_MSG_FILES;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= Lparam(Message);

   Par.isUpload:=false;

   Par.TypeFile :=  TypeFile;//AmPrtSockTypeFile.Image;


   
   Par.FileName:=   FileName;
   Par.IdFile:=   IdFile;
   Par.TypesAddr :=2;
   Par.EventWorkNeed:=true;
   Par.InDiv:= indiv;


  if indiv='IdPhoto10' then  SocketFile.DownloadPhoto10.AddNewParam(Par)

  else
  if indiv='IdPhoto500' then  SocketFile.DownloadPhoto500.AddNewParam(Par)
  else
  if indiv='IdFileZip' then  SocketFile.DownloadFiles.AddNewParam(Par)
  else
  if indiv='IdVoice' then  SocketFile.DownloadVoice.AddNewParam(Par)


  else par.Free;




end;
Function  TChatClientEditor.MessageFilesLoadWithDisk(
                        Message:TAmClientOneMessage;
                        IdFile,FileName:string;
                        TypeFile:integer;
                        indiv:string;
                        FileSetToControlAtError:boolean):integer;
var
 S: TFileStream;


     procedure LoadVoice;
     begin
        if not AmControlCheckWork(Message.MsgVoice) then exit;
        Message.MsgVoice.FileName := FileName;

        if Message.MsgVoice.isPlay then
        begin
        // Message.MsgVoice.LabelPlay.Enabled:=True;
         Message.MsgVoice.Start;

        end;
     end;
     procedure LoadVoiceDefault;
     begin
       if not AmControlCheckWork(Message.MsgVoice) then exit;
     end;


     procedure LoadPhoto;
     begin
       if not AmControlCheckWork(Message.MsgFiles) then exit;

        if indiv='IdPhoto10' then Message.MsgFiles.Photo10FileName:= FileName
        else
        if indiv='IdPhoto500' then Message.MsgFiles.Photo500FileName:= FileName
     end;
     procedure LoadPhotoDefault;
     begin
       if not AmControlCheckWork(Message.MsgFiles) then exit;
       Message.MsgFiles.PhotoDefaultResource:='photo_def_png';
     end;




     procedure LoadFile;
     begin
        if not AmControlCheckWork(Message.MsgFiles) then exit;
        Message.MsgFiles.ZipFileName :=FileName;
     end;
     procedure LoadFileDefault;
     begin
       if not AmControlCheckWork(Message.MsgFiles) then exit;
     end;


     procedure Load;
     begin
                   if TypeFile = AmPrtSockTypeFile.Image then   LoadPhoto

                   else
                   if TypeFile = AmPrtSockTypeFile.Voice then   LoadVoice

                   else
                   if TypeFile = AmPrtSockTypeFile.Zip then     LoadFile

                   else
                   begin
                     showmessage('MessageLoadFilesFromDisk');
                     exit;
                   end;
     end;
     procedure NoFile;
     begin
                   if TypeFile = AmPrtSockTypeFile.Image then   LoadPhotoDefault

                   else
                   if TypeFile = AmPrtSockTypeFile.Voice then   LoadVoiceDefault

                   else
                   if TypeFile = AmPrtSockTypeFile.Zip then     LoadFileDefault

                   else
                   begin
                     showmessage('MessageLoadFilesFromDisk');
                     exit;
                   end;
     end;
begin

    Result:=-1;

    {
      1 удачно
     -1 непонятно что
     -2 idfile
     -3 нет файла
     -4 файл используется
     -5 пустой указатель на компонент
     -6 компонент был удален
     -7 ErrorCode

    }

    if not ConstAmChat.CheckIdFile(IdFile) then Exit(-2);
    if not AmControlCheckWork(Message) then Exit(-6);

     try
        if FileSetToControlAtError then
        begin
           Load;
           Result:=1;
        end
        else
        begin
          if fileexists(FileName) then
          begin
             if not AmIsFileInUse(FileName) then
             begin
                Load;
                Result:=1;
             end
             else
             begin
               Result:=-4;
               NoFile;
             end;
          end
          else
          begin
             NoFile;
             Result:=-3;
          end;

        end;
    
     except
       on e:exception do
       begin
        Result:=-7;
        logMain.Log('ErrorCode.TChatClientEditor.MessageLoadFilesFromDisk '+e.message);
       end;
     end;




end;
Procedure TChatClientEditor.MessageFilesCheckDownload(
                         Message:TAmClientOneMessage;
                         IdPhoto10,IdPhoto500,IdFileZip,IdVoice:string;
                         DownloadNow:boolean=true;
                         FileSetToControlAtError:boolean=false);
var Fn,IdFile,indiv:string;
TypeFile:integer;
R:integer;
begin
   if IdPhoto10<>'' then
   begin
     if not ConstAmChat.CheckIdFile(IdPhoto10) then exit;
     TypeFile := AmPrtSockTypeFile.Image;
     Fn:=  FDirPhotos+IdPhoto10+ConstAmChat.NameFileType.ePhotoExt;
     IdFile:=  IdPhoto10;
     indiv:='IdPhoto10';
   end
   else if IdPhoto500<>'' then
   begin
     if not ConstAmChat.CheckIdFile(IdPhoto500) then exit;
     TypeFile := AmPrtSockTypeFile.Image;
     Fn:=  FDirPhotos+IdPhoto500+ConstAmChat.NameFileType.ePhotoExt;
     IdFile:=  IdPhoto500;
     indiv:='IdPhoto500';
   end
   else if IdFileZip<>'' then
   begin
     if not ConstAmChat.CheckIdFile(IdFileZip) then exit;
     TypeFile := AmPrtSockTypeFile.Zip;
     Fn:=  FDirFiles+IdFileZip+ConstAmChat.NameFileType.eFilesExt;
     IdFile:=  IdFileZip;
     indiv:='IdFileZip';
   end
   else if IdVoice<>'' then
   begin
     if not ConstAmChat.CheckIdFile(IdVoice) then exit;
     TypeFile := AmPrtSockTypeFile.Voice;
     Fn:=  FDirVoice+IdVoice+ConstAmChat.NameFileType.eVoiceExt;
     IdFile:=  IdVoice;
     indiv:='IdVoice';
   end
   else exit;

  R:= MessageFilesLoadWithDisk(Message,IdFile,Fn,TypeFile,indiv,FileSetToControlAtError);
  if DownloadNow and (R=-3) or (R = -1) then
  MessageFilesDownload(Message,IdFile,Fn,TypeFile,indiv);

end;
procedure TChatClientEditor.FilesControlOnDownloadStart (
                              FilesZip:TAmClientMessageFilesZipControl;
                              S:TObject;CompLparam,Index:integer;FileName:string);
var
 Par:TamClientDownloadParam;
 FileNameSave:string;
begin
   if not Assigned(FOnNeedSaveDialogEvent) then exit;
   FileNameSave:=FileName;
   FOnNeedSaveDialogEvent(FileNameSave);

   if FileNameSave='' then exit;
   

   Par:=  TamClientDownloadParam.Create;

   if AmCheckObject(S) then
   begin
       if s is TAmClientMessageFilesPaintBox then
       begin
       
         if Index>=0 then
         begin
          FilesZip.BoxFiles.ListFiles[Index].KindDownload:=  mfitProcessing;
          FilesZip.BoxFiles.ListFiles[Index].FileNameFull:='';
          FilesZip.BoxFiles.ListFiles[Index].SizeFile:=0;
          FilesZip.BoxFiles.ListFiles[Index].ComponentLparam:= Lparam(Par);
          FilesZip.BoxFiles.ListFiles[Index].LastJsonError:='';
          FilesZip.BoxFiles.ListFiles[Index].PositionBar:=1;

          FilesZip.BoxFiles.Repaint;
         end;
       end;
   end;

   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;
   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.EventMessage:= AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_MSG_FILES;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= CompLparam;
   Par.ComponentInDivId:= Index;


   Par.isUpload:=false;

   Par.TypeFile :=  AmPrtSockTypeFile.Zip;



   Par.FileName:=   FileNameSave;
   Par.FileNameIndexZip:= FileName;
   Par.IdFile:=   FilesZip.IdFile;
   Par.TypesAddr :=2;
   Par.EventWorkNeed:=true;
   Par.InDiv:= 'IdFileZip';

   if  SocketFile.DownloadFiles.AddNewParam(Par)<=0 then
   begin
       Par.Free;
       if Index>=0 then
       begin
        FilesZip.BoxFiles.ListFiles[Index].KindDownload:=  mfitErrorDownload;
        FilesZip.BoxFiles.ListFiles[Index].LastJsonError:='Не удачный запрос на сервер';
        FilesZip.BoxFiles.Repaint;
       end;
   end;




end;

procedure TChatClientEditor.FilesControlOnDownloadAbortPause (
                              FilesZip:TAmClientMessageFilesZipControl;
                              S:TObject;CompLparam,Index:integer;FileName:string;IsPause:boolean);
var  Item: TAmClientMessageFilesPaintBox.TItem;
Param:TamClientDownloadParam;
begin

  if CompLparam>0 then
  begin
   if AmCheckObject(TObject(CompLparam)) then
   begin

      if TObject(CompLparam) is TAmClientMessageFilesPaintBox.TItem then
      begin
        Item:=TAmClientMessageFilesPaintBox.TItem(CompLparam);
        if not Item.IsDestroy then
        begin
          if Item.ComponentLparam>0 then
          begin
             if AmCheckObject(TObject(Item.ComponentLparam)) then
             begin
                 if TObject(Item.ComponentLparam) is TamClientDownloadParam then
                 begin
                     Param:= TamClientDownloadParam(Item.ComponentLparam);
                     if not Param.IssDestroy then
                     begin
                        Param.NeedPause:= IsPause;
                        Param.NeedAbort:=true;

                     end;
                     
                 end;
                 
             end;

          end;
        end;

          
      end;
      
   end;

  end;

end;
procedure TChatClientEditor.FilesControlOnDownloadAbort (
                                    FilesZip:TAmClientMessageFilesZipControl;
                                    S:TObject;CompLparam,Index:integer;FileName:string);
begin
   FilesControlOnDownloadAbortPause(FilesZip,S,CompLparam,Index,FileName,false);
end;
procedure TChatClientEditor.FilesControlOnDownloadPause (
                              FilesZip:TAmClientMessageFilesZipControl;
                              S:TObject;CompLparam,Index:integer;FileName:string);
begin
   FilesControlOnDownloadAbortPause(FilesZip,S,CompLparam,Index,FileName,true);
end;
procedure TChatClientEditor.FilesControlOpenManagger  (
                              FilesZip:TAmClientMessageFilesZipControl;
                              S:TObject;CompLparam,Index:integer;FileName:string);
begin

end;
               {Upload}
Procedure  TChatClientEditor.PFT_NewMessageUploadSend(var Msg:TMessage);//message AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD;
begin

      case Msg.WParam of

          PFT.ChangeWorkUpload :        PFT_WorkUploadSend(TamClientFileThreadParamWorkSender(Msg.LParam));
          PFT.EndParam:                 PFT_WorkUploadEndSend(TAmClientChatFilesSendParam(Msg.LParam));
          PFT.SendMessageSVR:           PFT_SendMessageAtUpload(PFT.TSendMessage(Msg.LParam));
          else showmessage('Нет такой команды PFT_NewMessage');

      end;

end;
Procedure  TChatClientEditor.PFT_SendMessageAtUpload(Msg:PFT.TSendMessage);
var Message:TAmClientOneMessage;
    MimId:string;
    ComponentLparam:string;
begin
  if not Assigned(Msg) then  exit;

  try
     try

         if Msg.ComponentLparam>0 then
         begin
           Message:=  TAmClientOneMessage(Msg.ComponentLparam);

           if  AmControlCheckWork(Message)
           and AmControlCheckWork(Message.LoingMessage)  then
           begin
                 Message.LoingMessage.ProcentLoad:= 100;
                 Message.LoingMessage.SizeLoad:=  'Отправка...';
                 MimId:=Message.MimId;
                 ComponentLparam:= AmStr(Msg.ComponentLparam);
           end;
         end;


     finally
       SVR_Message_Send(Msg.TypeUser,Msg.ContactUserId,Msg.TypeContent,Msg.Content,
       MimId,ComponentLparam,Msg.Indiv);
     end;


  finally
   Msg.Content:='';
   Msg.Free;
  end;


end;
Procedure  TChatClientEditor.PFT_WorkUploadEndSend(Param:TAmClientChatFilesSendParam);
var Message:TAmClientOneMessage;
 Dw:TAmClientChatFilesSend;
begin
  if not Assigned(Param) or Param.IssDestroy then  exit;
  try
          if Param.ComponentLparam>0 then
          begin
            Message := TAmClientOneMessage( Param.ComponentLparam );

            if  AmControlCheckWork(Message)
            and AmControlCheckWork(Message.LoingMessage)  then
            begin

                 if Param.NeedAbort and Param.NeedPause then
                 begin
                     Message.LoingMessage.ProcentLoad:=0;
                 end
                 else Message.LoingMessage.FilesSendParamLparam:=0;

                 if Param.ErrorIsWas then
                 begin
                   Message.LoingMessage.SizeLoad:=  Param.ErrorMessage;
                 end




            end;
          end;
  finally

      {if Param.InDiv='IdPhoto10' then  Dw:=SocketFile.DownloadPhoto10
      else
      if Param.InDiv='IdPhoto500' then  Dw:=SocketFile.DownloadPhoto500  }
     // else
      if Param.InDiv='IdFileZip' then  Dw:=SocketFile.SendFiles
      else
      if Param.InDiv='IdVoice' then  Dw:=SocketFile.SendVoice;

      if Assigned(Dw) then
      begin

          if Param.NeedAbort and Param.NeedPause then
          begin
               Param.NeedPause:=false;
               Param.NeedAbort:=false;
               Param.ErrorIsWas:=false;
               Param.ErrorMessage:='';
               Dw.RemoveParamNoFree(TamClientFileThreadParam(Param));
               Dw.AddNewParam(Param);
          end
          else Dw.RemoveParam(Param);
      end;
  end;



end;
Procedure  TChatClientEditor.PFT_WorkUploadSend(Work:TamClientFileThreadParamWorkSender);
var Message:TAmClientOneMessage;
begin
  if not Assigned(Work) then  exit;
   try

     if Work.ComponentLparam>0 then
     begin
         Message := TAmClientOneMessage( Work.ComponentLparam );

         if not AmControlCheckWork(Message) then exit;
         if Message.MimId='' then
         begin
          showmessage('PFT_UpdateListParam MimId пусто');
          exit;
         end;
         if not AmControlCheckWork(Message.LoingMessage) then exit;
         Message.LoingMessage.ProcentLoad:=round(Work.SummaPos *100 / Work.SummaSize);
         Message.LoingMessage.SizeLoad:=  FormatFloat('0.00',(Work.SummaPos / 1000000)) +
         '/'+ FormatFloat('0.00',(Work.SummaSize / 1000000))+' Mb';
     end;


   finally
    Work.Free;
   end;



end;
Procedure  TChatClientEditor.PFT_UpdateListParamAtUploadSend(var Msg:TMessage); //message AM_CLIENT_EDITOR_THREAD_PFT_UPDATE_LIST;
var Param:TAmClientChatFilesSendParam;
    Message:TAmClientOneMessage;
begin
    Param:=  TAmClientChatFilesSendParam(Msg.LParam);
    if not Assigned(Param) or Param.IssDestroy  then exit;

     if Param.ComponentLparam>0 then
     begin
        Message := TAmClientOneMessage( Param.ComponentLparam );
        if not AmControlCheckWork(Message) then exit;
        if Message.MimId='' then
        begin
          showmessage('PFT_UpdateListParam MimId пусто');
          exit;
        end;
        if Message.ContentType <>  ConstAmChat.TypeContent.Files then
        begin
          showmessage('PFT_UpdateListParam ContentType<>Files');
          exit;
        end;

        Message.MsgFiles.Config.AddListFileOtherTextJson(Param.ListFilesEditJson);
        if (Param.FullPhoto500 <> '')
        and FileExists(Param.FullPhoto500)
        and not AmIsFileInUse(Param.FullPhoto500) then
        begin
         Message.MsgFiles.Photo500FileName:= Param.FullPhoto500;
         Msg.Result:=2;
        end;
     end;

   // Postmessage(Message.Handle,wm_size,0,0);
end;
       {<><><><><><><><><>}   {MIM_}
Procedure  TChatClientEditor.MIM_OnAbortSend(OneMessage:TObject);
var  Message: TAmClientOneMessage;
Param:TAmClientChatFilesSendParam;
begin



   if Amcontrols.AmControlCheckWork(OneMessage)
   and (OneMessage is TAmClientOneMessage)   then
   begin
     Message:=  TAmClientOneMessage(OneMessage);
     Param:= TAmClientChatFilesSendParam( Message.LoingMessage.FilesSendParamLparam);
     if not  ChatClientForm.BoxMessage.RemoveMessage(TAmClientOneMessage(OneMessage)) then Message.Free;

     if Assigned(Param) and not Param.IssDestroy then
     begin

        Param.Lock;
        try
           Param.ComponentLparam:=0;
           Param.ComponentInDivId:=0;
        finally
          Param.UnLock;
        end;
        Param.NeedAbort:=true;
     end;
   end;



end;
Procedure  TChatClientEditor.MIM_OnPauseSend(OneMessage:TObject);
var Message:TAmClientOneMessage;
Param:TAmClientChatFilesSendParam;
begin
   Message:= TAmClientOneMessage(OneMessage);
   if not Amcontrols.AmControlCheckWork(Message)  then exit;

   Param:= TAmClientChatFilesSendParam( Message.LoingMessage.FilesSendParamLparam );
   if Assigned(Param) and not Param.IssDestroy then
   begin
       Param.NeedPause:=true;
       Param.NeedAbort:=true;
   end;

end;
Procedure  TChatClientEditor.MIM_Message_Send_Files(TypeUser,ContactUserId,Comment:string;ListFiles:TamListVar<string>);
var Mim:TAmClientOneMessage;
    Par:AmChatClientFileThread.TAmClientChatFilesSendParam;
    TypeContent:string;
begin
   if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
   TypeContent:=ConstAmChat.TypeContent.Files;
   Mim:=mim_help_Add_MessageCteate(TypeUser,ContactUserId,TypeContent);
   Mim.MsgTextFull:= Comment;
   //Mim.MsgFiles.Config..Arr:= ListFiles.Arr;





   Par:=  TAmClientChatFilesSendParam.Create;
   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;

   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.isUpload:=true;
   Par.TypeUser:= TypeUser;
   Par.ContactUserId:=ContactUserId;
   Par.EventMessage:= AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= Lparam(Mim);
   Par.EventWorkNeed:=true;
   Par.TypeContent:=ConstAmChat.TypeContent.Files;
   Par.Path_Photo:= FDirPhotos;
   Par.Path_Zip:= FDirFiles;
   Par.ListFilesConst :=ListFiles;
   Par.Comment:= Comment;



   Mim.LoingMessage:= TChatMimLoadMessage.Create(Mim);
   Mim.LoingMessage.OnAbortSend:= MIM_OnAbortSend;
   Mim.LoingMessage.OnPauseSend:= MIM_OnPauseSend;
   Mim.LoingMessage.FilesSendParamLparam:= Lparam(Par);
   Par.InDiv:='IdFileZip';
   ChatClientForm.BoxMessage.AddNewMessage(Mim,25);
   SocketFile.SendFiles.AddNewParam(Par);








end;
Procedure TChatClientEditor.MIM_Message_Send_Voice(TypeUser,ContactUserId:string; ms:TStream; MaxPos:integer;CaptionTime:string;Spectr:TAmBassSpectrMono);
var Mim:TAmClientOneMessage;
    Par:AmChatClientFileThread.TAmClientChatFilesSendParam;
    TypeContent:string;
begin
   if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
   TypeContent:=ConstAmChat.TypeContent.Voice;
   Mim:=mim_help_Add_MessageCteate(TypeUser,ContactUserId,TypeContent);
   Mim.LoingMessage:= TChatMimLoadMessage.Create(Mim);
   Mim.LoingMessage.OnAbortSend:= MIM_OnAbortSend;
   Mim.LoingMessage.OnPauseSend:= MIM_OnPauseSend;


   Mim.MsgVoice.IdVoice:=  '';
   Mim.MsgVoice.FileName:=   '';//FDirVoice +  NewMsg.MsgVoice.IdVoice+'.mp3';
   Mim.MsgVoice.LabelInfo.Caption:=  CaptionTime;
   Mim.MsgVoice.Spectr.Spectr:=  Spectr;



   Par:=  TAmClientChatFilesSendParam.Create;
   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;
   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.EventMessage:= AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= Lparam(Mim);
   Par.EventWorkNeed:=true;

   Par.isUpload:=true;

   Par.TypeContent:=ConstAmChat.TypeContent.Voice;
   Par.TypeUser:= TypeUser;
   Par.ContactUserId:=ContactUserId;


   Par.MsVoice:= ms;
   Par.Path_Voice:= FDirVoice;
   Par.MaxPos:=MaxPos;
   Par.CaptionTime:= CaptionTime;
   Par.Spectr:=Spectr;
   Par.InDiv:='IdVoice';

   Mim.LoingMessage.FilesSendParamLparam:= Lparam(Par);
   ChatClientForm.BoxMessage.AddNewMessage(Mim,25);
   SocketFile.SendVoice.AddNewParam(Par);



end;

Procedure  TChatClientEditor.MIM_Message_Send_Text(TypeUser,ContactUserId,Text:string);
var Mim:TAmClientOneMessage;
    TypeContent:string;
begin
   if Text.Replace(#13,'')='' then exit;

   if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
   if ContactUserId='' then exit;
   TypeContent:=ConstAmChat.TypeContent.Text;
   Mim:=mim_help_Add_MessageCteate(TypeUser,ContactUserId,TypeContent);
   Mim.MsgTextFull:=    Text;
   Mim.LoingMessage:= TChatMimLoadMessage.Create(Mim);
   Mim.LoingMessage.SizeLoadVisible:=false;
   ChatClientForm.BoxMessage.AddNewMessage(Mim,25);
   SVR_Message_Send(TypeUser,ContactUserId,TypeContent,Text,Mim.MimId,Inttostr(Lparam(Mim)));//Inttostr(Lparam(Mim))

end;
function TChatClientEditor.mim_help_Add_MessageCteate(TypeUser,ContactUserId,TypeContent:string):TAmClientOneMessage;
begin

         Result:=TAmClientOneMessage.Create(ChatClientForm.BoxMessage,TypeContent);
         Result.UserId:=         Id;
         Result.MimId:=          ChatClientForm.BoxMessage.GetMimId;
         Result.TimeFull:=       '';
         Result.MsgIsMy:= true;
         Result.MsgIsRead:= false;
         Result.UserNameFull:=    UserName;
        // NewMsg.PhotoId:=        StoreMsgHistory.Users[NewMsg.UserId]['Photos']['MainId'].Value;
        // NewMsg.PhotoData:=      StoreMsgHistory.Users[NewMsg.UserId]['Photos']['MainData'].Value;
        // NewMsg.MessageId:=      ObjNewMsg['IdLocal'].Value;
end;
Procedure  TChatClientEditor.Groop_PhotoUpload(FileName:String;GroopId:string;LparamPhoto:integer);
begin
   LogMain.Log('Groop_PhotoUpload'+FileName);
    PhotoUpload(FileName,AmInt(GroopId,0),LparamPhoto,'MainGroop');
end;
Procedure  TChatClientEditor.Profile_PhotoUpload(FileName:String;IsMain:boolean;ComponentLparam:integer=0);
var indiv:string;
begin
   if IsMain then indiv:= 'MainProfile'
   else indiv:='Profile';
   
   PhotoUpload(FileName,0,ComponentLparam,indiv);
end;
Procedure  TChatClientEditor.PhotoUpload(FileName:String;ComponentInDivId:integer;ComponentLparam:integer;indiv:string);
var Par:TAmClientUploadMainPhotoParam;
begin
   Par:=  TAmClientUploadMainPhotoParam.Create;
   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;
   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.EventMessage:= AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD_PHOTOMAIN;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= ComponentLparam;

   Par.InDiv:= indiv;
   Par.ComponentInDivId:= ComponentInDivId;
   Par.EventWorkNeed:=false;
   Par.isUpload:=true;

   Par.Path_Photo:= FDirPhotos;
   Par.FileNameMainPhoto:= FileName;
  SocketFile.Upload.AddNewParam(Par);

end;
Procedure  TChatClientEditor.PFT_NewMessageUploadPhotoMain(var Msg:TMessage);//message AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD_PHOTOMAIN
begin
      case Msg.WParam of

          PFT.ChangeWorkUpload :        PFT_WorkUploadPhotoMain(TamClientFileThreadParamWorkSender(Msg.LParam));
          PFT.EndParam:                 PFT_WorkUploadEndPhotoMain(TAmClientUploadMainPhotoParam(Msg.LParam));

          else showmessage('Нет такой команды PFT_NewMessageUploadPhotoMain');

      end;
end;
Procedure  TChatClientEditor.PFT_WorkUploadPhotoMain(Work:TamClientFileThreadParamWorkSender);
begin

end;
Procedure  TChatClientEditor.PFT_WorkUploadEndPhotoMain(Param:TAmClientUploadMainPhotoParam);
begin
  if not Assigned(Param) or Param.IssDestroy then  exit;
  try
          if Param.ErrorIsWas then
          begin
             PopapInfoSetText(Param.ErrorMessage,true);
          end
          else
          begin
            if FileExists(Param.FullPhoto500) and ConstAmChat.CheckIdFile(Param.IdPhoto500) then
            begin
               //  showmessage('OK '+Param.IdPhoto500);

               if Param.InDiv = 'MainProfile' then
               begin
                 SVR_SetPhotoProfile(Param.IdPhoto500,true);
               end
               else if  Param.InDiv = 'Profile' then
               begin
                  SVR_SetPhotoProfile(Param.IdPhoto500,False);
               end
               else if Param.InDiv = 'MainGroop' then
               begin
                 if (Param.ComponentLparam>0)and (Param.ComponentInDivId>0) then
                 SVR_Groop_SetPhoto(Param.ComponentInDivId.ToString,Param.IdPhoto500,Param.ComponentLparam)
               end;
                    
            end
            else
            begin
              PopapInfoSetText('Не удалось выполнить загрузку фото',true);
            end;

          end;
  finally
          if Param.NeedAbort and Param.NeedPause then
          begin
               Param.NeedPause:=false;
               Param.NeedAbort:=false;
               SocketFile.Upload.RemoveParamNoFree(TamClientFileThreadParam(Param));
               SocketFile.Upload.AddNewParam(Param);
          end
          else SocketFile.Upload.RemoveParam(Param);
  end;

end;


// <<<<<<<<<<<<<<<<<<<<< от составного потока на сервер>>SVR  ListPot:TAmClientListPot;




 {
Procedure  TChatClientEditor.POT_NewMessage(var Msg:TMessage);//message AM_CLIENT_POT_TO_EDITOR;
var m:ClientPotParam.TParam;
TextResp:string;
begin
    TextResp:='';
    m:= ClientPotParam.TParam(Msg.LParam);
    try
       if Assigned(m) then
       begin


       end
       else  TextResp:= 'Нет объекта ответа POT_NewMessage';
    finally
     if Assigned(m) then  FreeAndNil(m);
    end;
    if TextResp<>'' then
    PopapInfoSetText(PopapInfo.text+' '+TextResp,true);


end;
     }
















     {>>>>>>>>>>>>}   {SVR_}
Function   TChatClientEditor.SVR_ContactDelete(TypeUser:string;UserId:string):boolean;
var SVR:MsgChat.TSVR_ContactDelete;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_ContactDelete.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;

    SVR.TypeUser:=TypeUser;
    SVR.UserId:= UserId;

    Result:=SVR_PostMessage(MsgChat.SVR_ContactDelete,SVR);

end;
Function   TChatClientEditor.SVR_Groop_SetUserName(GroopId,NewUserName:string):boolean;
var SVR:MsgChat.TSVR_Groop_SetUserName;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_Groop_SetUserName.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;

    SVR.GroopId:=GroopId;
    SVR.UserName:= NewUserName;

    Result:=SVR_PostMessage(MsgChat.SVR_Groop_SetUserName,SVR);

end;
Function   TChatClientEditor.SVR_Groop_SetPhoto(GroopId:string;PhotoId:string;LPot:integer):boolean;
var SVR:MsgChat.TSVR_Groop_SetPhoto;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_Groop_SetPhoto.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:=AmStr(LPot);
    SVR.GroopId:=GroopId;
    SVR.PhotoId:= PhotoId;

    Result:=SVR_PostMessage(MsgChat.SVR_Groop_SetPhoto,SVR);

end;
Function   TChatClientEditor.SVR_Groop_DeleteUser(GroopId:string;AUserId:string;LPot:string):boolean;
var SVR:MsgChat.TSVR_Groop_DeleteUser;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_Groop_DeleteUser.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:=LPot;
    SVR.GroopId:=GroopId;
    SVR.DeleteUserId:= AUserId;
    Result:=SVR_PostMessage(MsgChat.SVR_Groop_DeleteUser,SVR);

end;
Function   TChatClientEditor.SVR_Groop_AddUser(GroopId:string;AUserId:string;LPot:string):boolean;
var SVR:MsgChat.TSVR_Groop_AddUser;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_Groop_AddUser.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:=LPot;
    SVR.GroopId:=GroopId;
    SVR.AddUserId:= AUserId;
    Result:=SVR_PostMessage(MsgChat.SVR_Groop_AddUser,SVR);

end;
Function   TChatClientEditor.SVR_Groop_GetListUsers(GroopId:string):boolean;
var SVR:MsgChat.TSVR_Groop_GetListUsers;
begin
    Result:=false;
    SVR:= MsgChat.TSVR_Groop_GetListUsers.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.GroopId:=GroopId;
    Result:=SVR_PostMessage(MsgChat.SVR_Groop_GetListUsers,SVR);

end;
Function   TChatClientEditor.SVR_Groop_Create(ScreenGroopName,GroopName,TypeGroopPrivacy:string):boolean;
var SVR:MsgChat.TSVR_Groop_Create;
begin
    Result:=false;
    if Length(GroopName)<4 then exit;

    SVR:= MsgChat.TSVR_Groop_Create.Create;

    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.ScreenGroopName:=ScreenGroopName;
    SVR.GroopName:= GroopName;
    SVR.TypeGroopPrivacy:=TypeGroopPrivacy;
    Result:=SVR_PostMessage(MsgChat.SVR_Groop_Create,SVR);

end;
Function   TChatClientEditor.SVR_Serch(val:string):boolean;
var SVR:MsgChat.TSVR_Serch;
begin
    Result:=false;
    if Length(val)<4 then exit;

    SVR:= MsgChat.TSVR_Serch.Create;

    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.Metod:='ScreenName';
    SVR.Val:= val;
    Result:=SVR_PostMessage(MsgChat.SVR_Serch,SVR);

end;
{
Function   TChatClientEditor.SVR_Voice_Dowload(VoiceId:string;IsPlay:boolean; LParamOneMessage:Cardinal):boolean;
var SVR:MsgChat.TSVR_Voice_Download;
begin
    SVR:= MsgChat.TSVR_Voice_Download.Create;

    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.VoiceId:= VoiceId;
    SVR.IsPlay:=  IsPlay;
    SVR.LParamOneMessage:= LParamOneMessage;
    Result:=SVR_PostMessage(MsgChat.SVR_Voice_Download,SVR);
end;  }
Function   TChatClientEditor.SVR_Message_Read(TypeMetodReadMessage, TypeUser,ContactUserId,UserIdMessage,IdLocalMessage:string):boolean;
var SVR:MsgChat.TSVR_Message_Read;
begin
    Result:=false;

    if not ConstAmChat.TypeMetodReadMessage.Check(TypeMetodReadMessage) then exit;
    if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
    if Amint(ContactUserId,-1)<0 then exit;
    if Amint(UserIdMessage,-1)<0 then exit;
    if Amint(IdLocalMessage,-1)<0 then exit;

    SVR:= MsgChat.TSVR_Message_Read.Create;

    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.TypeMetodReadMessage:= TypeMetodReadMessage;
    SVR.TypeUser:=  TypeUser;
    SVR.ContactUserId:= ContactUserId;
    SVR.UserIdMessage:= UserIdMessage;
    SVR.IdLocalMessage:= IdLocalMessage;
    Result:=SVR_PostMessage(MsgChat.SVR_Message_Read,SVR);

end;
Procedure TChatClientEditor.OnTimerUpConnect(s:Tobject);
begin
   SVR_UpConnect('');
   LogMain.Log('OnTimerUpConnect');
end;
Function   TChatClientEditor.SVR_UpConnect(ConnectValue:string):boolean;
var SVR:MsgChat.TSVR_UpConnect;
begin

    SVR:= MsgChat.TSVR_UpConnect.Create;
    SVR.ConnectValue:=  ConnectValue;
    Result:=SVR_PostMessage(MsgChat.SVR_UpConnect,SVR);

end;
Function   TChatClientEditor.SVR_Message_History_OffSet( TypeUser:string;ContactUserId,StartIdLocal,GetCount,Indiv:string;IsBegin:boolean=false):boolean;
var SVR:MsgChat.TSVR_Message_History;
begin
    Result:=false;
    if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
    if Amint(ContactUserId,-1)<0 then exit;

    ActivDialog.Activ(ContactUserId,TypeUser);

    SVR:= MsgChat.TSVR_Message_History.Create;

    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.TypeUser:=  TypeUser;
    SVR.ContactUserId:= ContactUserId;
    SVR.StartIdLocal:=StartIdLocal;
    SVR.GetCount:=GetCount;
    SVR.IsBegin:= IsBegin;
    SVR.Indiv:= Indiv;
    Result:=SVR_PostMessage(MsgChat.SVR_Message_History,SVR);

end;
Function   TChatClientEditor.SVR_Message_History( TypeUser:string;ContactUserId:string):boolean;
begin
   SVR_Message_History_OffSet(TypeUser,ContactUserId,
   Inttostr(integer.MaxValue),
   AmStr(StoreMsgHistory.CountBlockMessage),'',true);
end;
Function   TChatClientEditor.SVR_Message_Send(
                                              TypeUser:string;
                                              ContactUserId:string;
                                              TypeContent:string;
                                              Content:string;
                                              MimId:string;
                                              MimLparam:string;
                                              LParamPot:string='';Indiv:string=''):boolean;
var SVR:MsgChat.TSVR_Message_Send;
begin
    Result:=false;
    if not ConstAmChat.TypeUser.Check(TypeUser) then exit;
    if not ConstAmChat.TypeContent.Check(TypeContent) then exit;


    if Amint(ContactUserId,-1)<0 then exit;
    if Content='' then exit;



    SVR:= MsgChat.TSVR_Message_Send.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:=  LParamPot;
    SVR.Indiv:=      Indiv;
    SVR.TypeUser:=  TypeUser;
    SVR.TypeContent:= TypeContent;
    SVR.ContactUserId:= ContactUserId;
    SVR.Content:=  Content;
    SVR.MimId:= MimId;
    SVR.MimLparam:=MimLparam;
    Content:='';
    Result:=SVR_PostMessage(MsgChat.SVR_Message_Send,SVR);


end;
Function   TChatClientEditor.SVR_Profile_ContactsFull():boolean;
var SVR:MsgChat.TSVRSeans;
begin
    SVR:= MsgChat.TSVRSeans.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    Result:=SVR_PostMessage(MsgChat.SVR_Profile_GetListContacts,SVR);
end;
{
Function   TChatClientEditor.SVR_User_PhotoDownload(PhotoId,PhotoData:string;LParamPot:string='';Indiv:string=''):boolean;
var SVR:MsgChat.TSVR_User_PhotoDownload;
begin
    SVR:= MsgChat.TSVR_User_PhotoDownload.Create;
    SVR.PhotoData:= PhotoData;
    SVR.PhotoId:=  PhotoId;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:=LParamPot;
    SVR.Indiv:= Indiv;
    Result:=SVR_PostMessage(MsgChat.SVR_User_PhotoDownload,SVR);

end;}
Procedure  TChatClientEditor.SVR_Reg(Login,Email,Pass,Pass2,UserName:string);
var SVR:MsgChat.TSVR_Reg;
begin
if FUserActivSeansAuth then exit;
    SVR:= MsgChat.TSVR_Reg.Create;
    SVR.Login:= Login;
    SVR.Email:= Email;
    SVR.Pass:= Pass;
    SVR.Pass2:= Pass2;
    SVR.UserName:= UserName;
    SVR_PostMessage(MsgChat.SVR_Reg,SVR);

end;
{
Function  TChatClientEditor.SVR_GetIdFileUpload(LParamPot:string='';Indiv:string=''):boolean;
var SVR:MsgChat.TSVR_GetIdFileUpload;
begin
    SVR:= MsgChat.TSVR_GetIdFileUpload.Create;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:= LParamPot;
    SVR.Indiv:=Indiv;
    Result:=SVR_PostMessage(MsgChat.SVR_GetIdFileUpload,SVR);


end;  }
Function  TChatClientEditor.SVR_SetPhotoProfile(PhotoId:string;IsMain:boolean;LParamPot:string='';Indiv:string=''):boolean;
var SVR:MsgChat.TSVR_SetPhotoProfile;
begin
    SVR:= MsgChat.TSVR_SetPhotoProfile.Create;
    SVR.IsMain:= IsMain;
    SVR.PhotoId:=  PhotoId;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    SVR.LParamPot:= LParamPot;
    SVR.Indiv:=Indiv;

    Result:=SVR_PostMessage(MsgChat.SVR_SetPhotoProfile,SVR);

end;
Procedure  TChatClientEditor.SVR_LogInParam(Login,Pass:string;Rmb:Boolean);
var SVR:MsgChat.TSVR_LogInParam;
begin
    if FUserActivSeansAuth then exit;
    FUserActivSeans :=true;
    FUserActivSeansAuth:=True;


    SVR:= MsgChat.TSVR_LogInParam.Create;
    SVR.Login:= Login;
    SVR.Pass:= Pass;
    SVR.Rmb:= Rmb;
    SVR_PostMessage(MsgChat.SVR_LogInParam,SVR);

end;
Procedure  TChatClientEditor.SVR_LogIn;
var SVR:MsgChat.TSVR_LogIn;
begin
    if FUserActivSeansAuth then exit;
    FUserActivSeans :=true;
    FUserActivSeansAuth:=True;


    FormShow;
    SVR:= MsgChat.TSVR_LogIn.Create;

    SVR.Token:= Token;
    SVR.Id:= Id;
    SVR_PostMessage(MsgChat.SVR_LogIn,SVR);

end;
Procedure  TChatClientEditor.SVR_LogOut(IsOutAcc:boolean);
var SVR:MsgChat.TSVR_LogOut;
begin
    FUserActivSeans :=false;
    FUserActivSeansAuth:=false;
    CloseDialog;
    //ChatClientForm.BoxContact.ClearBox;

    if not IsOutAcc then
    begin
       SVR_SetTypeOnline(ConstAmChat.TypeOnline.Nearby);
    end
    else
    begin
        SVR:= MsgChat.TSVR_LogOut.Create;
        SVR.Id:=Id;
        SVR.Token:=Token;
        SVR.Hash:= Hash;
        SVR_PostMessage(MsgChat.SVR_LogOut,SVR);
        StatusAuth:=False;
    end;
    

end;
Function   TChatClientEditor.SVR_SetTypeOnline(TypeOnline:string):boolean;
var SVR:MsgChat.TSVR_TypeOnline;
begin

    SVR:= MsgChat.TSVR_TypeOnline.Create;
    SVR.TypeOnline:= TypeOnline;
    SVR.Token:=Token;
    SVR.Hash:= Hash;
    Result:=SVR_PostMessage(MsgChat.SVR_TypeOnline,SVR);


end;
Function    TChatClientEditor.SVR_PostMessage(Wparam:Cardinal;MSG:MsgChat.TMSG):boolean;
var P:TAmChatClientPopapInfo;
begin
      if FTimerUpConnect.Enabled then  FTimerUpConnect.Enabled:=false;
      FTimerUpConnect.Enabled:=true;


      Result:=Socket.PostMessageThread(MsgChat.MSG_TO_SOCKET,Wparam,Lparam(MSG));
      if not Result then
      begin
         P.id:=      Wparam;
         P.IsError:= true;
         P.text:=    'Не запушен поток соединения';
         PopapInfo:=P;
         MSG.Free;
      end;

end;


    {<<<<<<<<<<<<<<<<<<<<}
    {
procedure TChatClientEditor.FRM_CheckLparam(LParamPotStr:string;Proc:Tproc<TAmClientPot_FileSend>);
var Pot:TAmClientPot_FileSend;
LParamPot:integer;
begin
    // для составного потока         Pot:TAmClientPot_FileSend
    if LParamPotStr<>'' then
    begin
       LParamPot:= amInt(LParamPotStr,0);
       if LParamPot>0 then
       begin
         LParamPot:=ListThread.Serch(LParamPot);
         if LParamPot>=0 then
         begin
          if Assigned(ListThread.List[LParamPot]) and (ListThread.List[LParamPot] is TAmClientPot) then
          begin

            Pot:= TAmClientPot_FileSend(ListThread.List[LParamPot]);
            if Assigned(Pot) then Proc(Pot);
          end;

         end;

       end;

    end;
end; }
procedure  TChatClientEditor.FRM_MAIN (var Msg:Tmessage);
var m:MsgChat.TMSG;
TextResp:string;
begin
    TextResp:='';
    m:= MsgChat.TMSG(Msg.LParam);
    FIsServerOnlineSave:=true;
    try
       if Assigned(m) then
       begin
         PopapInfo:=  m.PopapInfo;
         if m.ResultSend then
         begin
                        case Msg.WParam of


                            MsgChat.FRM_UpConnect :              FRM_UpConnect(m);
                            MsgChat.FRM_LogIn     :              FRM_LogIn(m);
                            MsgChat.FRM_Auth_ActivSeans:         FRM_Auth_ActivSeans_Back(m);
                            MsgChat.FRM_Reg       :              FRM_Reg(m);
                            MsgChat.FRM_SetPhotoProfile :         FRM_SetPhotoProfile(m);
                           // MsgChat.FRM_GetIdFileUpload :        FRM_GetIdFileUpload(m);
                            //MsgChat.FRM_User_PhotoDownload :     FRM_User_PhotoDownload(m);
                            MsgChat.FRM_Profile_GetListContacts : FRM_Profile_ContactsFull(m);
                            MsgChat.FRM_Message_New:             FRM_Message_New(m);
                            MsgChat.FRM_Message_History:         FRM_Message_History(m);
                            MsgChat.FRM_TypeOnline :             FRM_TypeOnline(m);
                            MsgChat.FRM_Message_Read:            FRM_Message_Read(m);
                           // MsgChat.FRM_Voice_Download:          FRM_Voice_Download(m);
                            MsgChat.FRM_Serch:                  FRM_Serch(m);
                            MsgChat.FRM_Groop_Create   :        FRM_Groop_Create(m);
                            MsgChat.FRM_Groop_GetListUsers   :        FRM_Groop_GetListUsers(m);
                            MsgChat.FRM_Groop_AddUser        :        FRM_Groop_AddUser(m);
                            MsgChat.FRM_Groop_DeleteUser   :           FRM_Groop_DeleteUser(m);

                            MsgChat.FRM_ContactNew   :           FRM_ContactNew(m);
                            MsgChat.FRM_ContactDelete   :           FRM_ContactDelete(m);

                            MsgChat.FRM_Groop_SetPhoto   :           FRM_Groop_SetPhoto(m);
                            MsgChat.FRM_Groop_SetUserName   :           FRM_Groop_SetUserName(m);
                            else TextResp:= 'Нет такой команды FRM_MAIN';

                        end;
         end
       //  else TextResp:= 'Сервер оффлайн FRM_MAIN';

       end
       else  TextResp:= 'Нет объекта ответа FRM_MAIN';
    finally

     if Assigned(m) then  FreeAndNil(m);

    end;
    if TextResp<>'' then
    PopapInfoSetText(PopapInfo.text+' '+TextResp,true);


end;
procedure  TChatClientEditor.FRM_Groop_SetPhoto(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_SetPhoto;
R:integer;
Contact:TAmClientOneContact;
begin
  FRM:= MsgChat.TFRM_Groop_SetPhoto(LPARAM(MSG));
  if FRM.Result then
  begin
            R:= Photo_LoadWithDisk(FRM.PhotoId,AmInt(FRM.LParamPot,0));
            if R<>1 then showmessage('FRM_Groop_SetPhoto ResultError='+R.ToString);

            Contact:=ChatClientForm.BoxContact.GetContact(FRM.GroopId,ConstAmChat.TypeUser.Groop);
            if Assigned(Contact) then
            begin
                Contact.PhotoId:= FRM.PhotoId;
                Photo_LoadWithDisk(FRM.PhotoId,AmInt(Contact.GetPhotoLParam,0));
            end;
            
  end;

end;
procedure  TChatClientEditor.FRM_Groop_SetUserName(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_SetUserName;
Contact:TAmClientOneContact;
begin
  FRM:= MsgChat.TFRM_Groop_SetUserName(LPARAM(MSG));
  if FRM.Result then
  begin
            Contact:=ChatClientForm.BoxContact.GetContact(FRM.GroopId,ConstAmChat.TypeUser.Groop);
            if Assigned(Contact) then
            begin
                Contact.UserNameFull:=FRM.UserName;
                if Contact.CanFocus then PostMEssage(Contact.Handle,wm_size,0,0);


            end;
            if ActivDialog.Check(FRM.GroopId,ConstAmChat.TypeUser.Groop) then
            begin
              ActivDialog.UserName:=FRM.UserName;
            end;
  end;

end;
procedure  TChatClientEditor.FRM_ContactNew(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_ContactNew;
var ContactOne:TAmClientOneContact;
    ContactObj:TJsonObject;
R:boolean;
begin
  FRM:= MsgChat.TFRM_ContactNew(LPARAM(MSG));
  if FRM.Result then
  begin
      ContactOne:=nil;
      R:=Contacts_AnyGetOneContact(FRM.UserId,FRM.TypeUser,ContactOne);
      if R then
      begin
        ContactObj:=AmJson.LoadObjectText(FRM.ContactObj);
        try
          Contact_LoadOne(ContactOne,ContactObj);
          CountNoReadMessageSetInc(ContactOne.CountNoRead);
        finally
          ContactObj.Free;
        end;
        ChatClientForm.BoxContact.AddContact(ContactOne,false);
        ChatClientForm.BoxContact.MoviTopContact(ContactOne);
      end;
  end;


end;

procedure  TChatClientEditor.FRM_ContactDelete(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_ContactDelete;
    ContactOne:TAmClientOneContact;
begin
  FRM:= MsgChat.TFRM_ContactDelete(LPARAM(MSG));
  if FRM.Result then
  begin
    ContactOne:=ChatClientForm.BoxContact.GetContact(FRM.UserId,FRM.TypeUser);
    if Assigned(ContactOne) then
    begin
      if ActivDialog.Check(ContactOne.UserId,ContactOne.TypeUser) then
      begin
        self.CloseDialog;
      end;
      CountNoReadMessageSetInc(-ContactOne.CountNoRead);
      ChatClientForm.BoxContact.DeleteContact(ContactOne);
    end;

  end;

end;
procedure  TChatClientEditor.FRM_Groop_DeleteUser(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_DeleteUser;
begin
  FRM:= MsgChat.TFRM_Groop_DeleteUser(LPARAM(MSG));
  if (FRM.LParamPot='') or (FRM.LParamPot='0') then  exit;
  FRM_Groop_ShowResponse(AMInt(FRM.LParamPot,0),FRM.PopapInfo.text);
end;
procedure  TChatClientEditor.FRM_Groop_AddUser(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_AddUser;
begin
  FRM:= MsgChat.TFRM_Groop_AddUser(LPARAM(MSG));
  if (FRM.LParamPot='') or (FRM.LParamPot='0') then  exit;
  FRM_Groop_ShowResponse(AMInt(FRM.LParamPot,0),FRM.PopapInfo.text);
end;
procedure  TChatClientEditor.FRM_Groop_ShowResponse(LParamPot:integer;Text:string);
var P:TAmClientOneParticipant;
begin
  if LParamPot<=0 then  exit;
  if AmCheckControl(TWinControl(LParamPot)) then
  begin
    if TWinControl(LParamPot) is TAmClientOneParticipant then
    begin
       P:=  TAmClientOneParticipant(LParamPot);
       P.LabelResponse.Caption:=Text;
    end;
  end;
end;
procedure  TChatClientEditor.FRM_Groop_GetListUsers(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_GetListUsers;
    ContactOne:TAmClientOneContact;
    R:boolean;
    Arr:TJsonArray;
begin

    FRM:= MsgChat.TFRM_Groop_GetListUsers(LPARAM(MSG));

    if FRM.Result then
    begin
        if ChatClientForm.PanelAutoVisibleParticipants.InNameControlCall =
        ConstAmChat.TypePanelFree.GroopList then
        begin
          if ActivDialog.Check(FRM.GroopId,ConstAmChat.TypeUser.Groop) then
          begin
              Arr:= AmJson.LoadArrayText(FRM.JsonArray);
              try
                 Participants_LoadList(Arr,ConstAmChat.TypePanelFree.GroopList);
              finally
                Arr.Free;
              end;

          end;
          
        end;

    end;

end;
procedure  TChatClientEditor.FRM_Groop_Create(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Groop_Create;
    ContactOne:TAmClientOneContact;
    R:boolean;
begin

    FRM:= MsgChat.TFRM_Groop_Create(LPARAM(MSG));

    if FRM.Result then
    begin
       if ChatClientForm.PanelObjectCreate.Visible then
       begin
          ChatClientForm.PanelObjectCreate_backClick(ChatClientForm);
       end;
       ContactOne:=nil;
       R:=Contacts_AnyGetOneContact(FRM.idGroop,ConstAmChat.TypeUser.Groop,ContactOne);
       if R then
       ChatClientForm.BoxContact.AddContact(ContactOne,false);
       ChatClientForm.BoxContact.MoviTopContact(ContactOne);
       ChatClientForm.BoxContact.ClearContactsSelect;
       ContactOne.IsSelectContact:=true;

      // SVR_Message_History(ConstAmChat.TypeUser.Groop,FRM.idGroop);
    end
    else
    begin
      ChatClientForm.PanelObjectCreate_Groop_Error.Caption:= FRM.PopapInfo.text;
    end;

end;
procedure  TChatClientEditor.FRM_Serch(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Serch;
    Item:MsgChat.TFRM_Serch.Titem;
    P:TAmClientOnePeople;
    I: Integer;
begin

    FRM:= MsgChat.TFRM_Serch(LPARAM(MSG));

    ChatClientForm.BoxPeople.ClearBox;
    for I := 0 to Frm.Arr.Count-1 do
    begin
      Item:=  Frm.Arr[i];
      P:=   TAmClientOnePeople.Create(ChatClientForm.BoxPeople);
      P.UserNameFull:=Item.UserName;
      P.TypeUser:=Item.TypeUser;
      P.ScreenNameFull:=Item.ScreenName;
      P.UserId:=      Item.Id;

      ChatClientForm.BoxPeople.AddContact(P,true);
    end;

end;
{
procedure  TChatClientEditor.FRM_Voice_Download(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Voice_Download;
begin
    FRM:= MsgChat.TFRM_Voice_Download(LPARAM(MSG));
    if FRM.Result  then
    LoadVoice(FRM.VoiceId,FRM.IsPlay,FRM.LParamOneMessage,FRM.VoiceBase64);

end; }
procedure  TChatClientEditor.FRM_Message_Read(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Message_Read;
Contact:TAmClientOneContact;
OneMsg:TAmClientOneMessage;
R:integer;
begin
    FRM:= MsgChat.TFRM_Message_Read(LPARAM(MSG));
    if not FRM.Result  then exit;
    Contact:= ChatClientForm.BoxContact.GetContact(FRM.ContactUserId,FRM.TypeUser);
    if not  Assigned(Contact) then exit;
    if not FRM.IsMy then
    begin

       if AmInt(Contact.Message_ReadLastLocalIdHim,0)< AmInt(FRM.IdLocalMessage,0) then
       begin
         Contact.Message_ReadLastLocalIdHim:= FRM.IdLocalMessage;
       end;

       if Assigned(ChatClientForm.BoxContact.ActivContact )
       and (Contact = ChatClientForm.BoxContact.ActivContact) then
       begin
          OneMsg:= ChatClientForm.BoxMessage.GetOneMessage(FRM.IdLocalMessage);
          if Assigned(OneMsg ) then  OneMsg.MsgIsRead:=true;
       end;

       
       Contact.IsOnlineType:= ConstAmChat.TypeOnline.Online;
       Contact_SetTypeOnline(Contact.UserId,Contact.IsOnlineType);


    end
    else
    begin
        if AmInt(Contact.Message_ReadLastLocalIdMy,0)< AmInt(FRM.IdLocalMessage,0) then
        Contact.Message_ReadLastLocalIdMy:= FRM.IdLocalMessage;
        R:=Contact.CountNoRead;
        Contact.CountNoRead :=     (AmInt(Contact.Message_LastId,0) - AmInt(Contact.Message_ReadLastLocalIdMy,0));
        CountNoReadMessageSetInc(Contact.CountNoRead-R);



       if Assigned(ChatClientForm.BoxContact.ActivContact )
       and (Contact = ChatClientForm.BoxContact.ActivContact) then
       begin
          if Contact.CountNoRead>0 then  ChatClientForm.BoxMessage.ButtonToDown.Captions:=inttostr(Contact.CountNoRead)
          else  ChatClientForm.BoxMessage.ButtonToDown.Captions:='';
       end;

    end;

end;
procedure  TChatClientEditor.FRM_TypeOnline(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_TypeOnline;
begin
    FRM:= MsgChat.TFRM_TypeOnline(LPARAM(MSG));
    if FRM.Result  then
    if FRM.IdUserOnline<>'' then Contact_SetTypeOnline(FRM.IdUserOnline,FRM.TypeOnline);
end;
procedure  TChatClientEditor.FRM_Message_History(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Message_History;
 ContactObj:TJsonObject;
 ContactId,ContactTypeUser,TypeGroopPrivacy:string;
 IsAdmin:boolean;
begin
    FRM:= MsgChat.TFRM_Message_History(LPARAM(MSG));
    if FRM.Result  then
    begin
       if FRM.IsBegin and (AmInt(FRM.StartIdLocal,-1)=integer.MaxValue) then
       MessageHistory_Load(FRM.ObjMessage,FRM.ObjUsers,FRM.ObjContact)
       else 
       begin
         ContactObj:= amJson.LoadObjectText(FRM.ObjContact);
         try
            ContactId:=   ContactObj['Id'].Value;
            ContactTypeUser:= ContactObj['TypeUser'].Value;
            TypeGroopPrivacy:= ContactObj['TypeGroopPrivacy'].Value;
            IsAdmin:= AmBool(ContactObj['IsAdmin'].Value,false);
         finally
            ContactObj.Free;
         end;

         if ActivDialog.Check(ContactId,ContactTypeUser) then
         begin
             ChatClientForm.PanelChatBottomClient.Visible:=
             ConstAmChat.TypeGroopPrivacy.NeedVisibleAswert(TypeGroopPrivacy,ActivDialog.TypeUser,IsAdmin);
             StoreMsgHistory.AddOldMessageToNowDialog(FRM.ObjMessage);
             MessageHistory_LoadOneBlock(AmBool(FRM.Indiv,false));
         end;
       end;

    end;

end;
procedure  TChatClientEditor.FRM_Message_New(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Message_New;
begin
     FRM:= MsgChat.TFRM_Message_New(LPARAM(MSG));
     if FRM.Result  then
     Message_LoadOneNew(FRM.ObjMessage,FRM.ObjUsers,FRM.ObjContact);

end;



procedure  TChatClientEditor.FRM_Profile_ContactsFull(MSG:MsgChat.TMSG);
var  FRM:MsgChat.TFRM_Profile_GetListContacts;
begin
     FRM:= MsgChat.TFRM_Profile_GetListContacts(LPARAM(MSG));
     if FRM.Result  then
     Contacts_LoadParsJson(FRM.ObjString);
end;


{
procedure  TChatClientEditor.FRM_User_PhotoDownload(MSG:MsgChat.TMSG);
var  FRM:MsgChat.TFRM_User_PhotoDownload;
Stream:TMemoryStream;
begin
    FRM:= MsgChat.TFRM_User_PhotoDownload(LPARAM(MSG));

    if FRM.Result  then
    if FRM.PhotoBase64<>'' then
    begin
     Stream:= TMemoryStream.Create;
     try
        if AmBase64.Base64ToStream(Stream,FRM.PhotoBase64) then
        begin
  
              try
                 ObjUser['Data']['Photos'][FRM.PhotoId]:= FRM.PhotoData;
                 Stream.SaveToFile(FDirPhotos+FRM.PhotoId+'.jpg');

                 LogMain.Log('Фото скачалось и сохранилось '+FRM.PhotoId);
              except
                 on E:Exception do
                 LogMain.Log('Error TChatClientEditor.SavePhotoUserDisk '+FRM.PhotoId +' '+E.Message);
              end;

        end;
     finally
       Stream.Free;
     end;

    end;



end;}
{
procedure  TChatClientEditor.FRM_GetIdFileUpload(MSG:MsgChat.TMSG);
var  FRM:MsgChat.TFRM_GetIdFileUpload;
begin
    FRM:= MsgChat.TFRM_GetIdFileUpload(LPARAM(MSG));

end;}
procedure  TChatClientEditor.FRM_SetPhotoProfile(MSG:MsgChat.TMSG);
var  FRM:MsgChat.TFRM_SetPhotoProfile;
var Fn:string;
begin
    FRM:= MsgChat.TFRM_SetPhotoProfile(LPARAM(MSG));
    if not FRM.Result  then  exit;
    if FRM.PhotoId<>''  then
    begin
      Fn:= FDirPhotos+FRM.PhotoId+ConstAmChat.NameFileType.ePhotoExt;
      if FRM.IsMain and FileExists(Fn) and not AmIsFileInUse(Fn) then
      begin
         ChatClientForm.PanelProfile_Photo.Picture.LoadFromFile(Fn);
        // ObjUser['Data']['Profile']['PhotoId'].Value:= FRM.PhotoId;
        // ObjUser['Data']['Profile']['PhotoData'].Value:= FRM.PhotoData;
      end
      else
      begin
         PopapInfoSetText('Загрузка выполнена но не удалось отобразить фото',true);
      end;
    end;


   { FRM_CheckLparam(FRM.LParamPot,
    procedure(Pot:TAmClientPot_FileSend)
    begin
            Pot.Wf_Value.Val:= FRM.PhotoId;
            Pot.Wf_Indiv.Val:= FRM.Indiv;
    end);}





end;

procedure  TChatClientEditor.FRM_Reg(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_Reg;
begin
  FRM:=   MsgChat.TFRM_Reg(LPARAM(MSG));
  if FRM.Result then
  begin
    Id:=FRM.Id;
    SVR_LogInParam(ChatClientForm.PanelReg_Login.Text,ChatClientForm.PanelReg_Pass.Text,true);
  end;

end;
procedure  TChatClientEditor.FRM_LogIn(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_LogIn;
begin
  FRM:=  MsgChat.TFRM_LogIn(LPARAM(MSG));
  StatusAuth:= FRM.ResultAuth=MsgChat.AuthTrue;

  if StatusAuth and (FRM.ScreenName<>'') and (FRM.Token<>'') and (FRM.Hash<>'') then
  begin

    Id:=FRM.Id;
    ScreenName:=  FRM.ScreenName;
    UserName:= FRM.UserName;
    Token:=    FRM.Token;
    Hash:=    FRM.Hash;
    MainPhotoId:= FRM.PhotoId;
    MainPhotoData:= FRM.PhotoData;
    if FRM.PhotoId<>'' then
    PhotoContact_CheckDownload(FRM.PhotoId,LParam(ChatClientForm.PanelProfile_Photo))
    else PopapInfoSetText('Установите фото профиля');

    //запрос на получение контактов
    SVR_Profile_ContactsFull;


  end;

  FUserActivSeansAuth:=false;
end;
procedure  TChatClientEditor.FRM_Auth_ActivSeans_Back(MSG:MsgChat.TMSG);
begin
    PopapInfoSetText('Запрос  был выполнен не верно ActivSeans_Back',true,'20');
end;
procedure  TChatClientEditor.FRM_UpConnect(MSG:MsgChat.TMSG);
var FRM:MsgChat.TFRM_UpConnect;
begin
  FRM:=  MsgChat.TFRM_UpConnect(LPARAM(MSG));
  PopapInfoSetText(FRM.PopapInfo.text);
end;








Procedure TChatClientEditor.EventConnect;
begin
     PopapResult.MiniText:='Connect';
     FIsServerOnlineSave:=true;
     if FUserActivSeans then
     begin

       PopapResult.Close;
       SVR_LogIn;
     end;
end;
Procedure TChatClientEditor.EventConnecting;
begin
   PopapResult.MiniText:='Connecting...';
   if FUserActivSeans then
   PopapResult.Open;
end;
Procedure TChatClientEditor.EventDisConnect;
begin
   PopapResult.MiniText:='DisConnect';
   FIsServerOnlineSave:=false;
   if FUserActivSeans then
   begin

      PopapInfoSetText('Сервер оффлайн',true);
      StatusAuth:=false;
   end;
end;
Procedure TChatClientEditor.PopapInfoSetText(Text:String;IsError:boolean=false;Sec:string='7');
var p:TAmChatClientPopapInfo;
begin
      p.id:=-1;
      p.IsError:=IsError;
      p.text:= Text;
      p.Sec:=Sec;
      PopapInfo :=p;
end;




            {CREATE START STOP FREE}

constructor TChatClientEditor.Create;
begin
   inherited create;
     FCountNoReadMessage:=0;
     FUserActivSeans:=false;
     FUserActivSeansAuth:=false;
     FIsServerOnlineSave:=false;
     ActivDialog.DeActiv;

     //BufferConteiner:= TmemoryStream.Create;


     StoreMsgHistory:= TChatClientStoreMessageHistory.Create;
     FId:='0';
     FScreenName:='';
     FUserName:='';

     FStatusAuth:=false;
     FToken:='';
     FHash:='';
    FDir:=ExtractFileDir(Application.ExeName)+'\set\chat\client\';
    FDirPhotos:= FDir+'photos\';
    FDirVoice:=   FDir+'voice\';
    FDirFiles:=   FDir+'files\';
    FnObjUser:='ObjUser.json';

    if not TDirectory.Exists(FDir) then  TDirectory.CreateDirectory(FDir);
    if not TDirectory.Exists(FDirPhotos) then  TDirectory.CreateDirectory(FDirPhotos);
    if not TDirectory.Exists(FDirVoice) then  TDirectory.CreateDirectory(FDirVoice);
    if not TDirectory.Exists(FDirFiles) then  TDirectory.CreateDirectory(FDirFiles);


    ObjUser:= amJson.LoadObjectFile(FDir+FnObjUser);
    FToken:= ObjUser['Data']['Token'].Value;
    FId:=ObjUser['Data']['Id'].Value;

    FTimerUpConnect:= TTimer.Create(Nil);
    FTimerUpConnect.Enabled:=false;
    FTimerUpConnect.Interval:=120*1000;
    FTimerUpConnect.OnTimer:= OnTimerUpConnect;
    FTimerUpConnect.Enabled:=true;

    SocketFile:=TAmClientSockFile.Create();
    SocketFile.OnLog:= LogMain.LogProc;
end;
destructor TChatClientEditor.Destroy;
begin

     FTimerUpConnect.Enabled:=false;

     ObjUser.SaveToFile(FDir+FnObjUser);
     SocketFile.Free;
     Stop;

     ObjUser.free;
     FTimerUpConnect.Free;
     StoreMsgHistory.Free;
     //BufferConteiner.Free;
     inherited Destroy;
end;
Procedure TChatClientEditor.Start( aAddressSocket:string;  aPortSokect:integer;  MiliSecondsTimeOutSocket:Cardinal=INFINITE);
begin
        Stop;
        Socket_Address:=aAddressSocket;
        Socket_Port:=aPortSokect;
        Socket:= TAmChatClientSocket.create(MiliSecondsTimeOutSocket);
        Socket.Address:=aAddressSocket;
        Socket.Port:= aPortSokect;
        Socket.OnLog:= LogEvent;
        Socket.FRM_HANDLE := HANDLE;
        Socket.OnEventMainPot.OnConnect:= EventConnect;
        Socket.OnEventMainPot.OnDisconnect:=  EventDisConnect;
        Socket.OnEventMainPot.OnConnecting:= EventConnecting;
        Socket.Start;


end;
Procedure  TChatClientEditor.Stop;
begin
   if Assigned(Socket) then
   begin
      Socket.Terminate;
      Socket.WaitFor;
      FreeAndNil(Socket);
   end;
end;


     {HELP}

Procedure  TChatClientEditor.ClearAllInfoUserExceptToken;
begin
     Id:='';
     ScreenName:='';
     UserName:='';

     if FStatusAuth then
     StatusAuth:=false;
    // Token:='';
     Hash:='';
     FPopapInfo.id:=-1;
     FPopapInfo.IsError:=false;
     FPopapInfo.text:='';

     ChatClientForm.ClearPanelChatClient;
end;
Function  TChatClientEditor.GetId:string;
begin
    Result:= FId;
end;
Procedure TChatClientEditor.SetId(val:string);
begin
   if (val<>FId) and (val<>'') then
   begin
    FId :=val;
    ObjUser['Data']['Id']:=FId;
   end;
end;

Function  TChatClientEditor.GetScreenName:string;
begin
    Result:= FScreenName;
end;
Procedure TChatClientEditor.SetScreenName(val:string);
begin
    FScreenName :=val;


    if ChatClientForm.PanelProfile_ScreenName.Caption<>val then

    ChatClientForm.PanelProfile_ScreenName.Caption:= val;
end;

Function  TChatClientEditor.GetUserName:string;
begin
     Result:= FUserName;
end;
Procedure TChatClientEditor.SetUserName(val:string);
begin
    FUserName :=val;
    ChatClientForm.PanelProfile_UserName.Caption:= val;
end;

Function  TChatClientEditor.GetPopapInfo:TAmChatClientPopapInfo;
begin
     Result:= FPopapInfo;
end;
Procedure TChatClientEditor.SetPopapInfo(val:TAmChatClientPopapInfo);
begin
    FPopapInfo :=val;
    if val.Sec='' then val.Sec:='7';
   PopapResult.MessageText:= FPopapInfo.text;
   PopapResult.SecondTimer:= AmInt(val.Sec,7);
   PopapResult.isError:= FPopapInfo.IsError;

   if PopapResult.isError then   
   PopapResult.Open
   else
   begin
      PopapResult.Close;
   end;
   // showmessage(FPopapInfo.text);

end;

Function  TChatClientEditor.GetStatusAuth:boolean;
begin
     Result:= FStatusAuth;
end;
Procedure TChatClientEditor.SetStatusAuth(val:boolean);
begin

   if FStatusAuth<>val then
   begin
    FStatusAuth :=val;
    ChatClientForm.CloseAllMainPanel;
     if FStatusAuth then
     ChatClientForm.OpenPanel(ChatClientForm.PanelChatClient)
     else
     begin
        ClearAllInfoUserExceptToken;
        CloseDialog;
        ChatClientForm.BoxContact.ClearBox;
        ChatClientForm.OpenPanel(ChatClientForm.PanelLogin);
     end;


   end;




end;
Procedure  TChatClientEditor.FormShow;
begin
     if not ChatClientForm.Showing then
     begin
        ChatClientForm.show;
        ChatClientForm.Height:=  ChatClientForm.Height+2;

     end;
end;

Function  TChatClientEditor.GetToken:string;
begin
    Result:= FToken;
end;
Procedure TChatClientEditor.SetToken(val:string);
begin
    FToken :=val;
    ObjUser['Data']['Token']:=FToken;
end;

Function  TChatClientEditor.GetHash:string;
begin
   Result:= FHash;
end;
Procedure TChatClientEditor.SetHash(val:string);
begin
   FHash :=val;
end;
Procedure TChatClientEditor.CountNoReadMessageSetInc(Val:integer);
begin
   inc( FCountNoReadMessage,Val );
   if FCountNoReadMessage<0 then FCountNoReadMessage:=0;
   if Assigned(FCountNoReadMessageChange) then FCountNoReadMessageChange(FCountNoReadMessage);
   
   
end;
{
Procedure TChatClientEditor.PhotoCheckList(ListItem:TChatClientTimerPhoto.TListItem);
var Timer:TChatClientTimerPhoto;
begin
    Timer:= TChatClientTimerPhoto.Create(ChatClientForm);
    Timer.ObjectPhotos:=ObjUser['Data']['Photos'];
    Timer.List:=ListItem;
    Timer.OnNeedDowloadImg :=PhotoNeedDowloadImg;
    Timer.Start;
end;}
Procedure  TChatClientEditor.PFT_MAIN_DownloadPhotoContact(var Msg:TMessage);
//message AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_PHOTO_CONTACT;
begin
      case Msg.WParam of

          PFT.ChangeWorkDownload :      PFT_Download_PhotoContact_Work(TamClientFileThreadParamWorkSender(Msg.LParam));
          PFT.EndParam:                 PFT_Download_PhotoContact_End(TamClientDownloadParam(Msg.LParam));
          else showmessage('Нет такой команды PFT_NewMessage');

      end;
end;
Procedure  TChatClientEditor.PFT_Download_PhotoContact_Work(Work:TamClientFileThreadParamWorkSender);
begin
     if not Assigned(Work) then  exit;
     try

     finally
       Work.Free;
     end;
end;
Procedure  TChatClientEditor.PFT_Download_PhotoContact_End(Param:TamClientDownloadParam);
var R:integer;
begin
    if not Assigned(Param) or Param.IssDestroy then  exit;
  try

        if Param.Result = Param.TypeFile then
        begin
          if Param.TypesAddr=1 then
          begin
            R:= Photo_LoadWithDisk(Param.IdFile,Param.ComponentLparam);
            if R<>1 then showmessage('PFT_WorkDownload ResultError='+R.ToString);

          end;
        end;




  finally
          if Param.NeedAbort and Param.NeedPause then
          begin
               Param.NeedPause:=false;
               Param.NeedAbort:=false;
               SocketFile.DownloadPhotoContact.RemoveParamNoFree(TamClientFileThreadParam(Param));
               SocketFile.DownloadPhotoContact.AddNewParam(Param);
          end
          else SocketFile.DownloadPhotoContact.RemoveParam(Param);
  end;

end;
Procedure TChatClientEditor.PhotoContact_CheckDownload(PhotoId:string;LParamImage:Cardinal);
var R:integer;
 Par:TamClientDownloadParam;
begin
    R:= Photo_LoadWithDisk(PhotoId,LParamImage);
    if (r<>-3) and (r<>-1) then exit;


   Par:=  TamClientDownloadParam.Create;
   Par.Host:=Socket_Address;
   Par.Port:=Socket_Port;
   Par.Token:= Token;
   Par.Hash:=  Hash;
   Par.EventMessage:= AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_PHOTO_CONTACT;
   Par.EventHandle:=  self.Handle;
   Par.ComponentLparam:= LParamImage;

   Par.isUpload:=false;

   Par.TypeFile :=  AmPrtSockTypeFile.Image;
   Par.FileName:=   FDirPhotos+PhotoId+ConstAmChat.NameFileType.ePhotoExt;
   Par.IdFile:=   PhotoId;
   Par.TypesAddr :=1;
   Par.EventWorkNeed:=false;
   SocketFile.DownloadPhotoContact.AddNewParam(Par);


end;
function TChatClientEditor.Photo_LoadWithDisk( PhotoId:string;LParamImage:Cardinal):integer;
var
 FullFn:String;
 Stream: TFileStream;
 Img:TEsImage;
begin

    Result:=0;

    {
      1 удачно
     -1 непонятно что
     -2 idfile
     -3 нет файла
     -4 файл используется
     -5 пустой указатель на компонент
     -6 компонент был удален
     -7 ErrorCode
     -8 Пустой файл
    }

    if not ConstAmChat.CheckIdFile(PhotoId) then Exit(-2);
    if LParamImage=0 then Exit(-5);



    FullFn:= FDirPhotos+PhotoId+ConstAmChat.NameFileType.ePhotoExt;

    if fileexists(FullFn) then
    begin
       if not AmIsFileInUse(FullFn) then
       begin
         Stream:=  TFileStream.Create(FullFn,fmOpenReadWrite);
         try
           if Stream.Size>0 then
           begin
             try
                 Img:=TEsImage(LParamImage);
                 if not AmControlCheckWork(Img) then exit(-6);
                 Stream.Position:=0;
                 Img.Picture.LoadFromStream(Stream);
                 Result:=1;
             except
               on e:exception do
               begin
                Result:=-7;
                logMain.Log('ErrorCode.TChatClientEditor.Photo_LoadWithDisk '+e.message);
               end;
             end;
           end
           else Result:=-8;

         finally
          Stream.Free;
         end;
       end
       else Result:=-4;


    end
    else Result:=-3;





end;
{
Procedure TChatClientEditor.PhotoNeedDowloadImg(PhotoId,PhotoData:string;var ResultSend:boolean);
begin
  ResultSend:=SVR_User_PhotoDownload(PhotoId,PhotoData);
end; }

Procedure TChatClientEditor.Contacts_LoadParsJson(ContactsObjJsonString:string);
var
 List: Tjsonobject;

begin
     List:=amJson.LoadObjectText(ContactsObjJsonString);
     try
       // ObjUser['Data']['Contacts']['UpData'].Value:=    List['UpData'].Value;
       // ObjUser['Data']['Contacts']['ListString'].Value:=    List['ListString'].Value;
       // ObjUser['Data']['Contacts'].A['List'].Assign(List.A['List']);
       Contacts_LoadList(List);
     finally
       List.Free;
     end;



end;
Function TChatClientEditor.Contacts_AnyGetOneContact(UserId,TypeUser:string;var ContactOne:TAmClientOneContact):boolean;
begin
   Result:=false;
   ContactOne:=ChatClientForm.BoxContact.GetContact(UserId,TypeUser);
   if Not Assigned(ContactOne) then
   begin
     ContactOne:= TAmClientOneContact.Create(ChatClientForm);
     ContactOne.UserId:= UserId;
     ContactOne.TypeUser:= TypeUser;
     Result:=true;
   end;
end;
Procedure TChatClientEditor.Contacts_LoadList(ContactsObj:TjsonObject);
var i:integer;
ContactOne:TAmClientOneContact;
//M:TAmClientMessage;

ContactOneObj:TjsonObject;

begin
   ChatClientForm.BoxContact.ClearBox;
   FCountNoReadMessage:=-1;
   CountNoReadMessageSetInc(1);
   for I := ContactsObj['List'].Count-1 downto 0 do    //
   begin
      ContactOneObj:=  ContactsObj['List'].Items[i];
      ContactOne:=TAmClientOneContact.Create(ChatClientForm);
      try
        ContactOne.IsOnlineType                 :=     ContactOneObj['TypeOnline'].Value;
        Contact_LoadOne(ContactOne,ContactOneObj);

        CountNoReadMessageSetInc(ContactOne.CountNoRead);

      finally
        ChatClientForm.BoxContact.AddContact(ContactOne,false);
      end;

   end;

end;
Function TChatClientEditor.Contact_LoadOne(ContactOne:TAmClientOneContact;ContactObj:TjsonObject):TAmResult16;
var IsNeedPhotoCheck:boolean;
HisUserId,HisTypeUser:string;
CountNoRead:integer;
begin
        IsNeedPhotoCheck:=false;
        Result.Zero;
        Result.Val[1]:=1;
        HisUserId:= ContactObj['Id'].Value;
        HisTypeUser:=ContactObj['TypeUser'].Value;
        if (AmInt(HisUserId,0)=0)
        or  not ConstAmChat.TypeUser.Check(HisTypeUser) then
        begin
          Result.Val[1]:=2;
          exit();
        end;

        CountNoRead:=   AmInt(ContactObj['Message']['LastId'].Value,0) -
                        AmInt(ContactObj['Message']['ReadLastLocalIdMy'].Value,0);

        if Assigned(ContactOne) then
        begin
           Result.Val[2]:=1;
          //  Timer.ListImage.Add(ContactOne.GetPhotoLParam);
            IsNeedPhotoCheck:=              ContactOne.PhotoId<>ContactObj['Photos']['MainId'].Value;
            ContactOne.PhotoId:=            ContactObj['Photos']['MainId'].Value;
           // ContactOne.PhotoData:=          ContactOneObj['Photos']['MainData'].Value;
            ContactOne.UserId:=             ContactObj['Id'].Value;
            ContactOne.TypeUser:=           ContactObj['TypeUser'].Value;
            ContactOne.TimeFull:=           ContactObj['LastActivData'].Value;
            ContactOne.UserNameFull:=       ContactObj['UserName'].Value;
                  //  StatusOnline

           // ContactOne.IsOnlineType                 :=     ContactObj['TypeOnline'].Value;
            ContactOne.Message_ReadLastLocalIdHim   :=     ContactObj['Message']['ReadLastLocalIdHim'].Value;// передам в запросе истроии диалога
            ContactOne.Message_ReadLastLocalIdMy    :=     ContactObj['Message']['ReadLastLocalIdMy'].Value;
            ContactOne.Message_LastId               :=     ContactObj['Message']['LastId'].Value;
            ContactOne.CountNoRead                  :=     CountNoRead;

        end;
               {
        if  ActivDialog.IsActiv
        and (ActivDialog.UserId = ContactOne.UserId)
        and (ActivDialog.TypeUser = ContactOne.TypeUser) then
        begin
          ActivDialog.StatusOnline:= ContactOne.IsOnlineType;
          ActivDialog.UserName:= ContactOne.UserNameFull;
        end;  }


        if ActivDialog.Check(HisUserId,HisTypeUser) then
        begin
          Result.Val[3]:=1;
          if Assigned(ContactOne) then
          begin
            if ContactOne <>ChatClientForm.BoxContact.ActivContact then
            begin
               ChatClientForm.BoxContact.LockEventGetHistoryChat:=true;
               ContactOne.IsSelectContact:=true;
               ChatClientForm.BoxContact.LockEventGetHistoryChat:=false;
            end;

          end
          else
          begin
             ChatClientForm.BoxContact.ClearContactsSelect;
          end;




          ActivDialog.UserName:= ContactObj['UserName'].Value;

          if Assigned(ContactOne) then  ActivDialog.StatusOnline:= ContactOne.IsOnlineType
          else                       ActivDialog.StatusOnline:='';

          //ActivDialog.StatusOnline:= ConstAmChat.TypeOnline.Offline;
          if CountNoRead>0 then
          ChatClientForm.BoxMessage.ButtonToDown.Captions:=inttostr(CountNoRead)
          else  ChatClientForm.BoxMessage.ButtonToDown.Captions:='';
        end;
        if IsNeedPhotoCheck then
        PhotoContact_CheckDownload(ContactOne.PhotoId,ContactOne.GetPhotoLParam);

end;
Procedure TChatClientEditor.Participants_LoadList(ParticipantsArray:TjsonArray;TypePanelFree:string);
var i:integer;
Participant:TAmClientOneParticipant;
//M:TAmClientMessage;

OneObj:TjsonObject;

begin
   ChatClientForm.BoxParticipants.ClearBox;

   for I :=  0 to ParticipantsArray.Count-1 do    //
   begin
      OneObj:=  ParticipantsArray[i];
      Participant:=TAmClientOneParticipant.Create(ChatClientForm);
      try
        Participant.TypePanelFree:= TypePanelFree;
        Participants_LoadOne(Participant,OneObj);

      finally
        ChatClientForm.BoxParticipants.AddContact(Participant,false);
      end;

   end;

   ChatClientForm.PanelAutoVisibleParticipants.Open(TypePanelFree,ChatClientForm.BoxParticipants);

end;
Procedure TChatClientEditor.Participants_LoadOne(ParticipantOne:TAmClientOneParticipant;ParticipantObj:TjsonObject);
var IsNeedPhotoCheck:boolean;
begin


          //  Timer.ListImage.Add(ContactOne.GetPhotoLParam);
            IsNeedPhotoCheck:=                  ParticipantOne.PhotoId<>ParticipantObj['Photos']['MainId'].Value;
            ParticipantOne.PhotoId:=            ParticipantObj['Photos']['MainId'].Value;
           // ContactOne.PhotoData:=          ContactOneObj['Photos']['MainData'].Value;
            ParticipantOne.UserId:=             ParticipantObj['Id'].Value;
            ParticipantOne.TypeUser:=           ParticipantObj['TypeUser'].Value;
            ParticipantOne.UserNameFull:=       ParticipantObj['UserName'].Value;
            ParticipantOne.IsOnlineType :=      ParticipantObj['TypeOnline'].Value;
                  //  StatusOnline

           if IsNeedPhotoCheck then
           PhotoContact_CheckDownload(ParticipantOne.PhotoId,ParticipantOne.GetPhotoLParam);

end;
Procedure TChatClientEditor.ContactsCopyParticipants(TypePanelFree:string);
var i:integer;
Participant:TAmClientOneParticipant;
Contact:TAmClientOneContact;
begin
   ChatClientForm.BoxParticipants.ClearBox;

   for I :=  0 to ChatClientForm.BoxContact.ListContact.Count-1 do    //
   begin
      Contact:=  TAmClientOneContact(ChatClientForm.BoxContact.ListContact[i]);
      if Contact.TypeUser <>ConstAmChat.TypeUser.User then continue;


      Participant:=TAmClientOneParticipant.Create(ChatClientForm);
      try
            Participant.TypePanelFree:= TypePanelFree;
            Participant.PhotoId:=            Contact.PhotoId;
            Participant.UserId:=             Contact.UserId;
            Participant.TypeUser:=           Contact.TypeUser;
            Participant.UserNameFull:=       Contact.UserNameFull;
            Participant.IsOnlineType :=      Contact.IsOnlineType;
            PhotoContact_CheckDownload(Participant.PhotoId,Participant.GetPhotoLParam);

      finally
        ChatClientForm.BoxParticipants.AddContact(Participant,false);
      end;

   end;
   ChatClientForm.PanelAutoVisibleParticipants.Open(TypePanelFree,ChatClientForm.BoxParticipants);


end;


Procedure TChatClientEditor.CloseDialog;
begin

   // SetContactStatusOnline(nil,'');
    //SetContactStatusName(nil,'');
    ChatClientForm.BoxMessage.ButtonToDown.Captions:='';
    ChatClientForm.BoxMessage.ButtonToDown.Visible:=false;
    ChatClientForm.PanelChatBottomClient.Visible:=false;


    SocketFile.DownloadVoice.CommponentAllNil;
    SocketFile.DownloadFiles.CommponentAllNil;
    SocketFile.DownloadPhoto10.CommponentAllNil;
    SocketFile.DownloadPhoto500.CommponentAllNil;
    SocketFile.SendVoice.CommponentAllNil;
    SocketFile.SendFiles.CommponentAllNil;

    ChatClientForm.BoxMessage.CloseDialog;
    StoreMsgHistory.CloseDialog;
    ActivDialog.DeActiv;
end;
Procedure TChatClientEditor.GetHistoryChat(OneContact:TAmClientOneContact);
begin
    CloseDialog;
    if (OneContact.UserId='') or (OneContact.TypeUser='') then exit;    
    SVR_Message_History(OneContact.TypeUser,OneContact.UserId);
end;
Procedure TChatClientEditor.GetHistoryChat(OnePeople:TAmClientOnePeople);
var Contact:TAmClientOneContact;
begin

    Contact:= ChatClientForm.BoxContact.GetContact(OnePeople.UserId,OnePeople.TypeUser);
    if Assigned(Contact) then
    begin
      Contact.IsSelectContact:=true;
    end
    else
    begin
        CloseDialog;
        ChatClientForm.BoxContact.ClearContactsSelect;
        if (OnePeople.UserId='') or (OnePeople.TypeUser='') then exit;
        SVR_Message_History(OnePeople.TypeUser,OnePeople.UserId);
    end;

end;
Procedure TChatClientEditor.GetHistoryChat(AId,ATypeUser:string);
var Contact:TAmClientOneContact;
begin

    Contact:= ChatClientForm.BoxContact.GetContact(AId,ATypeUser);
    if Assigned(Contact) then
    begin
      Contact.IsSelectContact:=true;
    end
    else
    begin
        CloseDialog;
        ChatClientForm.BoxContact.ClearContactsSelect;
        if (AId='') or (ATypeUser='') then exit;
        SVR_Message_History(AId,ATypeUser);
    end;

end;
Procedure TChatClientEditor.MessageHistory_Load(ObjMessageJsonString,ObjUsersJsonString,ObjContactJsonString:string);
var  R:TAmResult16;
    Procedure Local_UpDateContact(JsonStr:string);
     var Contact: TAmClientOneContact;
     ContactObj:TjsonObject;
     HisUserId,HisTypeUser,TypeGroopPrivacy:string;
     IsAdmin:boolean;
     //IsNeedPhotoCheck:boolean;
     //CountNoRead:integer;
     begin
       // IsNeedPhotoCheck:=false;


         ////ntactOne.Message_ReadLastLocalIdHim   :=     ContactOneObj['Message']['ReadLastLocalIdHim'].Value; передам в запросе истроии диалога
        //  MyLastRead:= ActivContact.Message_ReadLastLocalIdMy;
        //  HimLastRead:=   ActivContact.Message_ReadLastLocalIdHim;
        //  MessageLastId:= ActivContact.Message_LastId;
       ContactObj:= amJson.LoadObjectText(JsonStr);
       try
             HisUserId:= ContactObj['Id'].Value;
             HisTypeUser:=ContactObj['TypeUser'].Value;
             if (AmInt(HisUserId,0)=0)
             or  not ConstAmChat.TypeUser.Check(HisTypeUser) then exit;
            // CountNoRead:=  (AmInt(ContactObj['Message']['LastId'].Value,0) - AmInt(ContactObj['Message']['ReadLastLocalIdMy'].Value,0));

            // Contact:= ChatClientForm.BoxContact.ActivContact;
             Contact:= ChatClientForm.BoxContact.GetContact(HisUserId,HisTypeUser);
             R:=Contact_LoadOne(Contact,ContactObj);
             if Assigned(Contact) then
             Contact.Refresh;
             TypeGroopPrivacy:= ContactObj['TypeGroopPrivacy'].Value;
             IsAdmin:= AmBool(ContactObj['IsAdmin'].Value,false);
             if R.Val[3]=1 then
             begin

             IsAdmin:=ConstAmChat.TypeGroopPrivacy.NeedVisibleAswert(TypeGroopPrivacy,ActivDialog.TypeUser,IsAdmin);
             ChatClientForm.PanelChatBottomClient.Visible:= IsAdmin;
             end;
       finally
         ContactObj.Free;
       end;



     end;


begin
   Local_UpDateContact(ObjContactJsonString);
   if R.Val[3]=1 then
   begin
    // ChatClientForm.PanelChatBottomClient.Visible:=true;
     StoreMsgHistory.NewDialog(ObjMessageJsonString,ObjUsersJsonString);
     ChatClientForm.BoxMessage.OpenDialog;
     MessageHistory_LoadOneBlock(true);
   end;

end;
Procedure TChatClientEditor.GetOldBlockMessageHistory(LastIdLocalMessage:string);
//var ListItem:TChatClientTimerPhoto.TListItem;
begin



  if StoreMsgHistory.IsFinishAll then exit;
  if StoreMsgHistory.IsFinish then exit;
  
  ChatClientForm.BoxMessage.Box.BarRange.ScrollTo_Lock :=true;
  try
    //нужно дождатсся перед добалением пока остановится таймер уравления листами (он перекидывает контролы между листами)
   // это цикл в цикле где идет проверка услдовия и вызывается application.processmessage

    ToWaitFor.GoDelay(40,function : boolean begin Result:= not ChatClientForm.BoxMessage.Box.TimerControlList.LockMe end);

    MessageHistory_LoadOneBlock({ListItem}false);

  finally
      ChatClientForm.BoxMessage.Box.BarRange.ScrollTo_Lock :=false;
  end;


  //  PhotoCheckList(ListItem);
end;
Procedure TChatClientEditor.MessageHistory_LoadOneBlock(IsNewDialog:Boolean);
//({var  ListItemPhoto:TChatClientTimerPhoto.TListItem;});
var ss:byte;
  {
 procedure Local_FileDownload(aPhotoId,aPhotoData:string;ImgLparam:Cardinal);
 var Item: TChatClientTimerPhoto.TItem;
 I:integer;
 begin
  exit;
     Item.Clear;
     for I := 0 to ListItemPhoto.Count-1 do
     begin
       if ListItemPhoto[i].PhotoId=aPhotoId then
       begin
          Item:=ListItemPhoto[i];
          Item.ListImage.Add(ImgLparam);
          ListItemPhoto[i]:= Item;
          exit;
       end;
     end;

     Item.PhotoId:= aPhotoId;        //MainPhotoId
     Item.PhotoData:= aPhotoData;//MainPhotoData
     Item.FullFileName:= FDirPhotos+aPhotoId+'.jpg';;
     Item.ListImage.Add(ImgLparam);  //Msg.GetImagePhotoMain
     ListItemPhoto.Add(Item);
 end;}
 {
 procedure CreatePot_FileDownload(Param:TAmClientPot_FileDowload_Param);
 var P:TAmClientPot_FileDowload;
 begin
  //   if not Param.NeedStart then  exit;
    // P:= TAmClientPot_FileDowload.create;
    // P.Param.Copy(Param);
     //ListThread.AddAndStart(P);
 end;}


 procedure Local_ReaderMsgContact(var MyLastRead:string;var HimLastRead:string;var MessageLastId:string);
 var ActivContact: TAmClientOneContact;
 begin
   ActivContact:= ChatClientForm.BoxContact.ActivContact;
   if Assigned(ActivContact) then
   begin
     ////ntactOne.Message_ReadLastLocalIdHim   :=     ContactOneObj['Message']['ReadLastLocalIdHim'].Value; передам в запросе истроии диалога
      MyLastRead:= ActivContact.Message_ReadLastLocalIdMy;
      HimLastRead:=   ActivContact.Message_ReadLastLocalIdHim;
      MessageLastId:= ActivContact.Message_LastId;
   end
   else
   begin
      MyLastRead:= '';
      HimLastRead:=   '';
      MessageLastId:='';
   end;



 end;
 procedure DoFinish;
 begin
          StoreMsgHistory.Max := StoreMsgHistory.Max - StoreMsgHistory.CountBlockMessage;
          if StoreMsgHistory.Max<0 then
          begin
              StoreMsgHistory.Max:=0;
              StoreMsgHistory.IsFinish:=true;
              if StoreMsgHistory.IsFinishAll then  exit;

              if StoreMsgHistory.NextIdLocal<0 then  exit;
              
              if StoreMsgHistory.IsGetOldBlockToServer then  exit;

              StoreMsgHistory.IsGetOldBlockToServer:=true;
              SVR_Message_History_OffSet(
                  ActivDialog.TypeUser,
                  ActivDialog.UserId,
                  AmStr(StoreMsgHistory.NextIdLocal),
                  AmStr(StoreMsgHistory.CountBlockMessage),
                  BoolToStr(IsNewDialog),
                  false
                  );
          end
 end;

var
 Msg:TAmClientOneMessage;
 Block:TAmClientBlockMessages;
 OneMsgHistory: Tjsonobject;
 MyLastRead,HimLastRead,MessageLastId:String;
 BassSpectrMono:TAmBassSpectrMono;
 i:integer;
 ResultCreateRecrus:boolean;
// ParamFileDowload:TAmClientPot_FileDowload_Param;

begin
      ResultCreateRecrus:=false;
      if StoreMsgHistory.IsFinish then exit;
      if StoreMsgHistory.IsFinishAll then exit;

      StoreMsgHistory.Now:= StoreMsgHistory.Max - StoreMsgHistory.CountBlockMessage;
      if StoreMsgHistory.Now<0 then StoreMsgHistory.Now:=0;


      Local_ReaderMsgContact(MyLastRead,HimLastRead,MessageLastId);

      if StoreMsgHistory.Now<StoreMsgHistory.Max then
      begin
        
        Block:= TAmClientBlockMessages.Create(ChatClientForm.BoxMessage);

        try

            for i := StoreMsgHistory.Now  to   StoreMsgHistory.Max-1  do
            begin



                     //  ParamFileDowload.Clear;
                       ResultCreateRecrus:=true;
                       OneMsgHistory:= StoreMsgHistory.Message['List']['Msg'].Items[i];

                       if i= StoreMsgHistory.Now then
                       ChatClientForm.BoxMessage.LastIdMessage:= AmInt(OneMsgHistory['IdLocal'].Value,-1);

                       Msg:=TAmClientOneMessage.Create(ChatClientForm.BoxMessage,OneMsgHistory['TypeContent'].Value);

                       Msg.UserId:=          OneMsgHistory['IdFrom'].Value;
                       Msg.MessageId:=       OneMsgHistory['IdLocal'].Value;
                       Msg.TimeFull:=        OneMsgHistory['Data'].Value;


                       if OneMsgHistory['TypeContent'].Value=ConstAmChat.TypeContent.Text then
                       begin
                           Msg.MsgTextFull:=    OneMsgHistory['Content']['Text'].Value;
                       end
                       else if OneMsgHistory['TypeContent'].Value=ConstAmChat.TypeContent.Voice then
                       begin
                          Msg.MsgVoice.IdVoice:=  OneMsgHistory['Content']['VoiceId'].Value;
                          Msg.MsgVoice.FileName:=   FDirVoice +  Msg.MsgVoice.IdVoice+'.mp3';
                          Msg.MsgVoice.LabelInfo.Caption:=  OneMsgHistory['Content']['VoiceTimerSecond'].Value;

                          Msg.MsgVoice.Spectr.Spectr:=  AmJson.ArrStrToReal(OneMsgHistory['Content']['VoiceSpectrJson'].Value);
                       end
                       else if OneMsgHistory['TypeContent'].Value=ConstAmChat.TypeContent.Files then
                       begin
                           Msg.MsgTextFull:=              OneMsgHistory['Content']['Comment'].Value;
                           Msg.MsgFiles.IdPhoto10:=       OneMsgHistory['Content']['IdPhoto10'].Value;
                           Msg.MsgFiles.IdPhoto500:=      OneMsgHistory['Content']['IdPhoto500'].Value;
                           Msg.MsgFiles.IdFile:=          OneMsgHistory['Content']['IdFile'].Value;
                           Msg.MsgFiles.BoxImage.CollageSizeMax:= AmRectSize.StrToSize(OneMsgHistory['Content']['CollageSizeMax'].Value);
                           Msg.MsgFiles.Config.AddListFileOther(OneMsgHistory['Content'].A['ListFileOther']);
                           Msg.MsgFiles.Config.AddListFilePhoto(OneMsgHistory['Content'].A['ListFilePhoto']);
                           Msg.MsgFiles.OnDownloadStart:= FilesControlOnDownloadStart;
                           Msg.MsgFiles.OnOpenManagger:=  FilesControlOpenManagger;
                           Msg.MsgFiles.OnDownloadAbort:= FilesControlOnDownloadAbort;
                           Msg.MsgFiles.OnDownloadPause:= FilesControlOnDownloadPause;

                            {

                          // Msg.MsgFiles.IdFile:=          OneMsgHistory['Content']['CollageSizeMax'].Value;
                         //  Msg.MsgFiles.IdFile:=          OneMsgHistory['Content']['CollageCountFile'].Value;

                           if  (Msg.MsgFiles.IdPhoto500 <>'') then
                           begin
                             if FileExists(FDirPhotos+Msg.MsgFiles.IdPhoto500 +'.jpg') then
                             Msg.MsgFiles.Photo500FileName:= FDirPhotos+Msg.MsgFiles.IdPhoto500 +'.jpg'
                             else
                             begin
                                if  (Msg.MsgFiles.IdPhoto10 <>'') then
                                begin
                                   if FileExists(FDirPhotos+Msg.MsgFiles.IdPhoto10 +'.jpg') then
                                   Msg.MsgFiles.Photo10FileName:= FDirPhotos+Msg.MsgFiles.IdPhoto10 +'.jpg'
                                   else
                                   begin

                                     Msg.MsgFiles.Photo500FileName:='E:\Red 10.3\Projects\socketClientServer\Resources\Files\Без имени-1.png';
                                     // поток на скачивание Photo10FileName
                                     //ParamFileDowload.NeedStart:=true;
                                     //ParamFileDowload.PhotoNameOnDisk10:=  FDirPhotos+Msg.MsgFiles.IdPhoto10 +'.jpg';
                                     //ParamFileDowload.IdPhoto10:=          Msg.MsgFiles.IdPhoto10;
                                   end;
                                end;

                                // поток на скачивание Photo500FileName
                               // ParamFileDowload.NeedStart:=true;
                               // ParamFileDowload.PhotoNameOnDisk500:=  FDirPhotos+Msg.MsgFiles.IdPhoto500 +'.jpg';
                               // ParamFileDowload.IdPhoto500:=          Msg.MsgFiles.IdPhoto500;
                             end;

                           end
                           else if  (Msg.MsgFiles.IdPhoto10 <>'') then
                           begin
                                   if FileExists(FDirPhotos+Msg.MsgFiles.IdPhoto10 +'.jpg') then
                                   Msg.MsgFiles.Photo10FileName:= FDirPhotos+Msg.MsgFiles.IdPhoto10 +'.jpg'
                                   else
                                   begin
                                     // поток на скачивание Photo10FileName
                                      Msg.MsgFiles.Photo500FileName:='E:\Red 10.3\Projects\socketClientServer\Resources\Files\Без имени-1.png';
                                   end;
                           end;
                                
                           if  (Msg.MsgFiles.IdFile <>'') then
                           begin
                             if FileExists(FDirFiles+Msg.MsgFiles.IdFile +'.zip') then
                             Msg.MsgFiles.ZipFileName:= FDirFiles+Msg.MsgFiles.IdFile +'.zip'
                             else
                             begin
                                Msg.MsgFiles.Config.AddListFileOther(OneMsgHistory['Content'].A['ListFileOther']);
                             end;
                           end;
                            }



                       end ;





                       if OneMsgHistory['IdFrom'].Value=Id then
                       begin
                           Msg.MsgIsMy:= true;



                           Msg.MsgIsRead:= (AmInt(HimLastRead,0)>= AmInt(Msg.MessageId,0));
                           Msg.UserNameFull:=    UserName;
                           //фото
                         //  Local_PhotoAddListItem(MainPhotoId,MainPhotoData,Msg.GetImagePhotoMain);
                       end
                       else
                       begin
                           Msg.MsgIsMy:= false;
                           Msg.MsgIsRead:= (AmInt(MyLastRead,0)>= AmInt(Msg.MessageId,0));
                           Msg.UserNameFull:=    StoreMsgHistory.Users[Msg.UserId]['UserName'].Value;
                           //фото
                        //   Local_PhotoAddListItem(StoreMsgHistory.Users[Msg.UserId]['Photos']['MainId'].Value,
                         //  StoreMsgHistory.Users[Msg.UserId]['Photos']['MainData'].Value,Msg.GetImagePhotoMain);
                       end;
                       Block.AddMessage(Msg,true);

                       {
                       if ParamFileDowload.NeedStart then
                       begin
                         ParamFileDowload.LoadToObject:= Msg;
                         CreatePot_FileDownload(ParamFileDowload);
                       end;
                        }

            end;

        finally
          for I := 0 to Block.ListMsg.Count-1 do
          begin
           if  Block.ListMsg[i].ContentType<> ConstAmChat.TypeContent.Files then continue;
           Msg:= Block.ListMsg[i];

           MessageFilesCheckDownload(Msg,
           Msg.MsgFiles.IdPhoto10,
           '','','',true,false);

           MessageFilesCheckDownload(Msg,
           '',
           Msg.MsgFiles.IdPhoto500,'','',true,false);

           MessageFilesCheckDownload(Msg,
           '',
           '',Msg.MsgFiles.IdFile,'',false,false);
          end;
          ChatClientForm.BoxMessage.AddBlock(Block,true);
          DoFinish;

        end;

      //  showmessage(ChatClientForm.BoxMessage.Height.ToString+' '+ChatClientForm.BoxMessage.Box.BarRange.ControlListCalcPageRange.ToString)

         if IsNewDialog then
         begin
           if  ResultCreateRecrus
          and
          (
             ChatClientForm.BoxMessage.Box.BarRange.ControlListCalcPageRange
              <
             ChatClientForm.BoxMessage.Height
          ) then
          MessageHistory_LoadOneBlock(IsNewDialog);
         end;

      end
      else
      begin
        DoFinish;
      end;
end;

Procedure TChatClientEditor.Message_LoadOneNew(ObjMessageJsonString,ObjUsersJsonString,ObjContactJsonString:string);
var s:string;



   Procedure Local_AddMessageToBox(ActivContact:TAmClientOneContact);
   var
    NewMsg:TAmClientOneMessage;
    ObjNewMsg:TjsonObject;


    MimLparam:integer;
    IsNewCreate:boolean;
   begin
            if not StoreMsgHistory.IsOpenDiadlog then  exit;
            
            NewMsg:=nil;
            IsNewCreate:=true;
            // значит загрузить новое сообщение в диалог
            ObjNewMsg:=StoreMsgHistory.NewMessageAdd(ObjMessageJsonString);
            if ObjNewMsg=nil then exit;
            
            StoreMsgHistory.NewUsersAdd(ObjUsersJsonString) ;

           MimLparam:= AmInt(ObjNewMsg['MimLparam'].Value,0);



           if (MimLparam<>0) then
           begin
             NewMsg:= TAmClientOneMessage(MimLparam);
             if not AmControlCheckWork(NewMsg)
             or not  AmControlCheckWork(NewMsg.LoingMessage)
             or (NewMsg.MimId<>ObjNewMsg['MimId'].Value) then
             begin
                 NewMsg:=nil;
             end;
           end;

           if not Assigned(NewMsg) then
            NewMsg:=TAmClientOneMessage.Create(ChatClientForm.BoxMessage,ObjNewMsg['TypeContent'].Value)
           else
           begin
             NewMsg.MimId:='';
             NewMsg.LoingMessage.Free;
             NewMsg.LoingMessage:=nil;
             IsNewCreate:=false;
           end;

          //{"IdGlobal":"614","IdLocal":"510","IdFrom":"5","Data":"14.11.2020 08:21:05:804",
         // "TypeContent":"Voice",
          //"Content":{"VoiceId":"voice5_8",
          //"VoiceSpectrJson":"{\"List\":[\"0\"]}",
          //VoiceLength":"3","VoiceCaption":"","VoiceTimerSecond":"00:00 / 00:03"}},



            try

             NewMsg.UserId:=         ObjNewMsg['IdFrom'].Value;
             NewMsg.PhotoId:=        StoreMsgHistory.Users[NewMsg.UserId]['Photos']['MainId'].Value;
             NewMsg.PhotoData:=      StoreMsgHistory.Users[NewMsg.UserId]['Photos']['MainData'].Value;
             NewMsg.MessageId:=      ObjNewMsg['IdLocal'].Value;

             NewMsg.TimeFull:=       ObjNewMsg['Data'].Value;

               if ObjNewMsg['TypeContent'].Value=ConstAmChat.TypeContent.Text then
               begin
                   NewMsg.MsgTextFull:=    ObjNewMsg['Content']['Text'].Value;
               end
               else if ObjNewMsg['TypeContent'].Value=ConstAmChat.TypeContent.Voice then
               begin
                  NewMsg.MsgVoice.IdVoice:=  ObjNewMsg['Content']['VoiceId'].Value;
                  NewMsg.MsgVoice.FileName:=   FDirVoice +  NewMsg.MsgVoice.IdVoice+ConstAmChat.NameFileType.eVoiceExt;
                  NewMsg.MsgVoice.LabelInfo.Caption:=  ObjNewMsg['Content']['VoiceTimerSecond'].Value;
                 // GetBassSpectrMono(BassSpectrMono,ObjNewMsg['Content']['VoiceSpectrJson'].Value);
                  NewMsg.MsgVoice.Spectr.Spectr:=  amJson.ArrStrToReal(ObjNewMsg['Content']['VoiceSpectrJson'].Value);
               end
               else if ObjNewMsg['TypeContent'].Value=ConstAmChat.TypeContent.Files then
               begin
                           NewMsg.MsgTextFull:=              ObjNewMsg['Content']['Comment'].Value;
                           NewMsg.MsgFiles.IdPhoto10:=       ObjNewMsg['Content']['IdPhoto10'].Value;
                           NewMsg.MsgFiles.IdPhoto500:=      ObjNewMsg['Content']['IdPhoto500'].Value;
                           NewMsg.MsgFiles.IdFile:=          ObjNewMsg['Content']['IdFile'].Value;
                           NewMsg.MsgFiles.BoxImage.CollageSizeMax:= AmRectSize.StrToSize(ObjNewMsg['Content']['CollageSizeMax'].Value);
                           NewMsg.MsgFiles.Config.AddListFileOther(ObjNewMsg['Content'].A['ListFileOther']);
                           NewMsg.MsgFiles.Config.AddListFilePhoto(ObjNewMsg['Content'].A['ListFilePhoto']);
                           NewMsg.MsgFiles.OnDownloadStart:= FilesControlOnDownloadStart;
                           NewMsg.MsgFiles.OnOpenManagger:=  FilesControlOpenManagger;
                           NewMsg.MsgFiles.OnDownloadAbort:= FilesControlOnDownloadAbort;
                           NewMsg.MsgFiles.OnDownloadPause:= FilesControlOnDownloadPause;

                           MessageFilesCheckDownload(NewMsg,
                           NewMsg.MsgFiles.IdPhoto10,
                           '','','',true,false);

                           MessageFilesCheckDownload(NewMsg,
                           '',
                           NewMsg.MsgFiles.IdPhoto500,'','',true,false);

                           MessageFilesCheckDownload(NewMsg,
                           '',
                           '',NewMsg.MsgFiles.IdFile,'',false,false);

                 // NewMsg.MsgVoice.IdVoice:=  ObjNewMsg['Content']['VoiceId'].Value;
                //  NewMsg.MsgVoice.FileName:=   FDirVoice +  NewMsg.MsgVoice.IdVoice+'.mp3';
                 // NewMsg.MsgVoice.LabelInfo.Caption:=  ObjNewMsg['Content']['VoiceTimerSecond'].Value;
                 // GetBassSpectrMono(BassSpectrMono,ObjNewMsg['Content']['VoiceSpectrJson'].Value);
                 // NewMsg.MsgVoice.Spectr.Spectr:=  BassSpectrMono;
               end;


                  

                     if ObjNewMsg['IdFrom'].Value=Id then
                     begin
                         NewMsg.MsgIsMy:= true;
                         NewMsg.MsgIsRead:= false;
                         NewMsg.UserNameFull:=    UserName;
                         //(AmInt(HimLastRead,0)>= AmInt(MessageLastId,0));
                         //фото
                        // Local_PhotoAddListItem(MainPhotoId,MainPhotoData,Msg.GetImagePhotoMain);
                       // PhotoCheck(MainPhotoId,MainPhotoData,NewMsg.GetImagePhotoMain);
                     end
                     else
                     begin

                         NewMsg.MsgIsMy:= false;
                         NewMsg.MsgIsRead:= false;
                         if ObjNewMsg['IdFrom'].Value<>'' then
                         NewMsg.UserNameFull:=    StoreMsgHistory.Users[NewMsg.UserId]['UserName'].Value;
                         //фото
                        // Local_PhotoAddListItem(StoreMsgHistory.Users[Msg.UserId]['Photos']['MainId'].Value,
                       //  StoreMsgHistory.Users[Msg.UserId]['Photos']['MainData'].Value,Msg.GetImagePhotoMain);

                       // PhotoCheck(NewMsg.PhotoId,NewMsg.PhotoData,NewMsg.GetImagePhotoMain);

                     end;

            finally
                if Assigned(ActivContact) then
                begin
                   if ActivContact.CountNoRead>0 then
                   ChatClientForm.BoxMessage.ButtonToDown.Captions:= inttostr(ActivContact.CountNoRead)
                   else  ChatClientForm.BoxMessage.ButtonToDown.Captions:='';
                end;


              if IsNewCreate then
              begin

               

               ChatClientForm.BoxMessage.AddNewMessage(NewMsg,25);
              end;
            end;
   end;

   Procedure Local_NoActivContact(var IdMessageFrom,IdLocalMessage,IdGlobalMessage:string);
   var  ObjNewMsg:TjsonObject;
   begin
        ObjNewMsg:=amJson.LoadObjectText(ObjMessageJsonString);
        try
             IdMessageFrom:=         ObjNewMsg['IdFrom'].Value;
             IdLocalMessage:=        ObjNewMsg['IdLocal'].Value;
             IdGlobalMessage:=       ObjNewMsg['IdGlobal'].Value;
        finally
          ObjNewMsg.Free;
        end;
   end;


var ContactUpdate:TAmClientOneContact;
var
//Timer: TChatClientTimerPhoto;
ObjMsgContact:TjsonObject;
IdMessageFrom,IdLocalMessage,IdGlobalMessage:string;
BoolIsContactActiv,ActivDialogTrue:boolean;
NeedCheckPhotoContact:boolean;
R:integer;

   procedure PlaySoundLocal;

   begin
     AmMusic.PlaySoundTheadResource('Message_wav');
    { TThread.CreateAnonymousThread( procedure
     var R:TResourceStream;
     begin
      try
        R:=  TamResource.CreateAndGetStream('Message_wav');
        try

          //Ms.LoadFromFile('D:\Загрузки\1.wav');
          SndPlaySound(R.Memory, SND_MEMORY);
        finally
          R.Free;
        end;
      except

      end;
     end).Start;}

    //   hResource:=LoadResource( hInstance, FindResource(hInstance, name, RT_RCDATA));
      //  pData := LockResource(hResource);
      //  SndPlaySound(pData, SND_MEMORY);
       // FreeResource(hResource);
         //             mciSendString(PChar('Play "D:\Загрузки\1.wav"'),nil,0,0);
   end;
begin

     ObjMsgContact:= amJson.LoadObjectText(ObjContactJsonString);
     BoolIsContactActiv:=false;
     ActivDialogTrue:=false;
     try
          //Сначало обновление контакта потом добавления сообщения
            Local_NoActivContact(IdMessageFrom,IdLocalMessage,IdGlobalMessage);

           if ActivDialog.IsActiv
           and (ActivDialog.UserId    = ObjMsgContact['Id'].Value)
           and  (ActivDialog.TypeUser = ObjMsgContact['TypeUser'].Value) then
           begin
           
              ActivDialogTrue:=true;

           end;


            if ( Assigned(ChatClientForm.BoxContact.ActivContact)
                 and  (ChatClientForm.BoxContact.ActivContact.UserId =   ObjMsgContact['Id'].Value)
                 and  (ChatClientForm.BoxContact.ActivContact.TypeUser = ObjMsgContact['TypeUser'].Value)
                ) //or дописать условие может быть такое что написавший еще не в контактах у пользователя это надо проверить
            then
            begin  // значит загрузить новое сообщение в диалог в текуший открытый диалог
                ContactUpdate:= ChatClientForm.BoxContact.ActivContact;
                BoolIsContactActiv:=true;
            end
            else
            begin

              ContactUpdate:=ChatClientForm.BoxContact.GetContact(ObjMsgContact['Id'].Value,ObjMsgContact['TypeUser'].Value);
            end;
            //обновление контакта если контакта нет то создать
            if not Assigned(ContactUpdate) then
            begin
              ContactUpdate:=TAmClientOneContact.Create(ChatClientForm);
              ChatClientForm.BoxContact.AddContact(ContactUpdate,true);


              if ActivDialogTrue then
              begin
                 ChatClientForm.BoxContact.LockEventGetHistoryChat:=true;
                 try
                   ContactUpdate.IsSelectContact:=true;
                 finally
                  ChatClientForm.BoxContact.LockEventGetHistoryChat:=false;
                 end;
                 BoolIsContactActiv:=true;

              end;

            end;

           NeedCheckPhotoContact:= ContactUpdate.PhotoId<>ObjMsgContact['Photos']['MainId'].Value;
           
            ContactUpdate.PhotoId:=            ObjMsgContact['Photos']['MainId'].Value;
           // ContactUpdate.PhotoData:=          ObjMsgContact['Photos']['MainData'].Value;
            ContactUpdate.UserId:=             ObjMsgContact['Id'].Value;
            ContactUpdate.TypeUser:=           ObjMsgContact['TypeUser'].Value;
            ContactUpdate.TimeFull:=           ObjMsgContact['LastActivData'].Value;
            ContactUpdate.UserNameFull:=       ObjMsgContact['UserName'].Value;
            ContactUpdate.Message_LastId:=     ObjMsgContact['Message']['LastId'].Value ;


            //+1 непрочитанное если это сообщение не мое
            if IdMessageFrom<>Id then
            begin
               //это не мое
              // ContactUpdate.CountNoRead := ContactUpdate.CountNoRead+1;
               ContactUpdate.IsOnlineType:=           ConstAmChat.TypeOnline.Online;
               R:= ContactUpdate.CountNoRead;
               ContactUpdate.CountNoRead :=     (AmInt(ContactUpdate.Message_LastId,0) - AmInt(ContactUpdate.Message_ReadLastLocalIdMy,0));
               CountNoReadMessageSetInc(ContactUpdate.CountNoRead-R);


                if  ActivDialog.IsActiv
                and (ActivDialog.UserId = ContactUpdate.UserId)
                and (ActivDialog.TypeUser = ContactUpdate.TypeUser) then
                begin
                  ActivDialog.StatusOnline:= ContactUpdate.IsOnlineType;
                  ActivDialog.UserName:= ContactUpdate.UserNameFull;
                end;

               // if not ChatClientForm.Showing or ChatClientForm.IsMinimaze then
               // FormPopapNewMessage.OpenForm(ContactUpdate.UserId,ContactUpdate.TypeUser,ContactUpdate.UserNameFull,'Новое Сообщение');
               ////....
               ///
               PlaySoundLocal;

            end
            else
            begin
               //это  мое
               ContactUpdate.Message_ReadLastLocalIdMy:= ContactUpdate.Message_LastId;
               R:= ContactUpdate.CountNoRead;
               ContactUpdate.CountNoRead :=     (AmInt(ContactUpdate.Message_LastId,0) - AmInt(ContactUpdate.Message_ReadLastLocalIdMy,0));

               CountNoReadMessageSetInc(ContactUpdate.CountNoRead-R);
               ////....
            end;


            //  перемешаем на 1е место
            ChatClientForm.BoxContact.MoviTopContact(ContactUpdate);
            ContactUpdate.Refresh;

            // чекаем и загружаем фото котнтакта
            if NeedCheckPhotoContact then            
             PhotoContact_CheckDownload(ContactUpdate.PhotoId,ContactUpdate.GetPhotoLParam);

                //добаление сообщения
             if BoolIsContactActiv then
             begin
                 Local_AddMessageToBox(ContactUpdate);
             end;
             






     finally
       ObjMsgContact.Free;

     end;








end;
Procedure TChatClientEditor.Contact_SetTypeOnline(aIdUser:string;TypeOnline:string);
var ContactUpdate:TAmClientOneContact;

begin
    ContactUpdate:=ChatClientForm.BoxContact.GetContact(aIdUser,ConstAmChat.TypeUser.User);
    if Assigned(ContactUpdate) then
    begin
        ContactUpdate.IsOnlineType:=TypeOnline;

        if   ActivDialog.IsActiv
        and (ActivDialog.UserId = ContactUpdate.UserId)
        and (ActivDialog.TypeUser = ContactUpdate.TypeUser) then
        begin
          ActivDialog.StatusOnline:= ContactUpdate.IsOnlineType;
        end;


    end;

end;

Procedure TChatClientEditor.Message_ReadOne(OneMessage:TAmClientOneMessage);
var TypeUser,ContactUserId:string;
begin

    ContactUserId:='';
    TypeUser:='';
    if  Assigned(ChatClientForm.BoxContact.ActivContact)  then
    begin
        ContactUserId:=   ChatClientForm.BoxContact.ActivContact.UserId;
        TypeUser:=        ChatClientForm.BoxContact.ActivContact.TypeUser;
    end;
    if (ContactUserId<>'') and (TypeUser<>'') then
    SVR_Message_Read(
                  ConstAmChat.TypeMetodReadMessage.OneByOne,
                  TypeUser,ContactUserId,OneMessage.UserId,OneMessage.MessageId);
end;
Procedure TChatClientEditor.OneMessageVoiceNotPlay(OneMessage:TAmClientOneMessage;FileName:string;IsPlay:boolean);
var R:Boolean;
begin
 //  showmessage('OneMessageVoiceNotPlay'+OneMessage.MsgVoice.LabelInfo.Caption);

   if ( FileName <> '' ) and fileexists(FileName) then
    begin
     OneMessage.MsgVoice.LabelInfo.Caption:='Плохая запись';
     delay(300);
     OneMessage.MsgVoice.Stop;
    end
   else if   AmReg.GetValue('\d+\_\d+',OneMessage.MsgVoice.IdVoice)='' then
    begin
     OneMessage.MsgVoice.LabelInfo.Caption:='Неопознаный объект';
     delay(300);
     OneMessage.MsgVoice.Stop;

    end
  else
   begin
    // OneMessage.MsgVoice.LabelPlay.Enabled:=false;
     OneMessage.MsgVoice.LabelInfo.Caption:='Подождите...';


     R:= true;
     MessageFilesCheckDownload(OneMessage,
                           '',
                           '','',OneMessage.MsgVoice.IdVoice,true,false);


     //R:= SVR_Voice_Dowload(OneMessage.MsgVoice.IdVoice,IsPlay,LPARAM(OneMessage));

     if not R then
     begin
       OneMessage.MsgVoice.LabelPlay.Enabled:=True;
       OneMessage.MsgVoice.LabelInfo.Caption:='Попробуйте позже. Нет соединения.';
       delay(300);
       OneMessage.MsgVoice.Stop;
     end;


   end;
   


end;
{
Procedure TChatClientEditor.LoadVoice(VoiceId:string;IsPlay:boolean;LParamOneMessage:Integer;VoiceBase64:string);
var
Stream:TMemoryStream;
OneMessage:TAmClientOneMessage;
Result:boolean;
Cap:string;
begin
     OneMessage:=nil;
     Result:=false;
     if LParamOneMessage>0 then
     OneMessage:=TAmClientOneMessage(LParamOneMessage);
     if OneMessage=nil then
     begin
      showmessage('LoadVoice.OneMessage=nil');
      exit;
     end;
     
    OneMessage.MsgVoice.LabelPlay.Enabled:=True;

    if VoiceBase64<>'' then
    begin
     Stream:= TMemoryStream.Create;
     try
        if AmBase64.Base64ToStream(Stream,VoiceBase64) then
        begin

              try

                 Stream.SaveToFile(FDirVoice+VoiceId+'.mp3');

                 LogMain.Log('Voice скачалось и сохранилось '+VoiceId);
                 Result:=true;
                 Cap:='Готово';
              except
                 on E:Exception do
                 begin
                 LogMain.Log('Error TChatClientEditor.LoadVoice '+VoiceId+' '+E.Message);
                  Cap:='Ошибка';
                 end;
              end;

        end
        else Cap:='Не удалось открыть запись.';
     finally
       Stream.Free;
     end;

    end
    else Cap:='Не удалось получить запись.';


    if Result then
    begin
      if IsPlay then
      begin
         OneMessage.MsgVoice.FileName:=FDirVoice+VoiceId+'.mp3';
         OneMessage.MsgVoice.Start;
      end;
      OneMessage.MsgVoice.LabelInfo.Caption:=Cap;
    end
    else OneMessage.MsgVoice.LabelInfo.Caption:=Cap;
end; }




                 {TChatClientStoreMessageHistory}

constructor TChatClientStoreMessageHistory.Create;
begin

     inherited create;
      FMessage:=nil;
      FUsers:=nil;
      CloseDialog;
end;
destructor TChatClientStoreMessageHistory.Destroy;
begin
    CloseDialog;
    inherited;
end;
Procedure TChatClientStoreMessageHistory.NewDialog(ObjMessageJsonString,ObjUsersJsonString:string);
begin
   CloseDialog;
   FMessage:= amJson.LoadObjectText(ObjMessageJsonString);
   FUsers:= amJson.LoadObjectText(ObjUsersJsonString);
   FMax:=Message['List']['Msg'].Count;
   if FMax>0 then
   begin
   NextIdLocal:= AmInt(Message['List']['Msg'].Items[0]['IdLocal'].Value,-1);
   dec(NextIdLocal);
   end;
   IsFinish:=false;
   IsFinishAll:=false;
   IsOpenDiadlog:= (FMessage<>nil) and (FUsers<>nil);

   if FMessage=nil then
   begin
     if FMessage=nil then
   end;
   
  // FContact:= amJson.LoadText(ObjContactJsonString);
end;
Procedure TChatClientStoreMessageHistory.CloseDialog;
begin
    IsGetOldBlockToServer:=false;
    IsOpenDiadlog:=false;
    NextIdLocal:=-1;
    FMax:=-1;
    FNow:=-1;
    FIdLastMsgTop:='';
    IsFinish:=false;
    IsFinishAll:=false;
    if Assigned(FMessage) then FreeAndNil(FMessage);
    if Assigned(FUsers) then FreeAndNil(FUsers);
  // if Assigned(FContact) then FreeAndNil(FContact);
end;
Function  TChatClientStoreMessageHistory.NewMessageAdd(ObjOneMessageJsonString:string):TjsonObject;
var N: TjsonObject;
begin
  try
   N:= amJson.LoadObjectText(ObjOneMessageJsonString);
   try
     Result:=FMessage['List'].A['Msg'].AddObject;
     Result.Assign(N);
   finally N.Free; end;
  except
     Result:=nil;
  end;
end;
Procedure TChatClientStoreMessageHistory.AddOldMessageToNowDialog(ObjMessageJsonString:string);
var Ns,N,New: TjsonObject;
I,ACount,BCount:integer;

begin
  try
   ACount:=FMessage['List']['Msg'].Count;
   Ns:= amJson.LoadObjectText(ObjMessageJsonString);
   try
     for I := Ns['List']['Msg'].Count-1 downto 0 do
     begin
         N:= Ns['List']['Msg'].Items[i];
         New:=FMessage['List'].A['Msg'].InsertObject(0);
         New.Assign(N);
     end;


   finally
    Ns.Free;
   end;
   
   if FMessage['List']['Msg'].Count>0 then  
   begin
   NextIdLocal:= AmInt(FMessage['List']['Msg'].Items[0]['IdLocal'].Value,-1);
   dec(NextIdLocal);  
   end;
   BCount:=FMessage['List']['Msg'].Count;
   FMax:= FMax + BCount - ACount;
   FNow:= FNow + BCount - ACount;   
   self.IsFinishAll:= BCount = ACount;
   self.IsFinish := IsFinishAll;    

  except
    showmessage('Error AddOldMessageToNowDialog');
  end;
  IsGetOldBlockToServer:=false;
end;
Procedure  TChatClientStoreMessageHistory.NewUsersAdd(ObjUserOneJsonString:string);
var N: TjsonObject;
i:integer;
Names:string;
begin
   N:= amJson.LoadObjectText(ObjUserOneJsonString);
   try
       for I := 0 to N.Count-1 do
       begin
         Names :=N.Names[I];
         FUsers[Names].ObjectValue.Assign(N[Names].ObjectValue);
       end;
   finally
     N.Free;
   end;
end;
{
Procedure TChatClientStoreMessageHistory.DownMessageToDialog;
begin

end; }






end.
