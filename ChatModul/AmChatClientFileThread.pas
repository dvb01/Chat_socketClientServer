unit AmChatClientFileThread;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,System.types, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,AmChatClientComponets,DateUtils,
  AmChatCustomSocket,AmVoiceRecord,AmMessageFilesControl,AmList,
  System.Generics.Collections,
  AmMultiSockTcpCustomPrt,
  System.SyncObjs,
  AmMultiSockTcpCustomThread,
  AmGrafic;

      const
      AM_CLIENT_THREAD_DOWNLOAD_NEW_FILE= wm_user+6002;
      AM_CLIENT_THREAD_UPLOAD_NEW_FILE= wm_user+6003;
      AM_CLIENT_THREAD_SEND_MESSAGE_WITH= wm_user+6004;

      AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD = wm_user+6005; //от текушего в эдитор
      AM_CLIENT_EDITOR_THREAD_PFT_UPDATE_LIST = wm_user+6006; //когда нужно обновить лист файлов в mim сообщении
      AM_CLIENT_THREAD_DOWNLOAD_WITH= wm_user+6007;
      AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_MSG_FILES = wm_user+6008; //от текушего в эдитор

      AM_CLIENT_THREAD_UPLOAD_NEW_PHOTO= wm_user+6009;
      AM_CLIENT_EDITOR_THREAD_MESSAGE_PFT_UPLOAD_PHOTOMAIN = wm_user+6010;


     AM_CLIENT_FILE_THREAD_NEWMSG_DOWNLOAD_PHOTO_CONTACT =  wm_user+6011;

    type
      PFT = record
        Const
          ChangeWorkUpload =1; //передается класс TamClientFileThreadParamWorkSender   удалить после прочтения  free
          ChangeWorkDownload =2;
          EndParam =3;  // в lparam передается класс TamClientFileThreadParam или наследник
          SendMessageSVR =4;
        type
         TParam =class
           ComponentLparam:integer;
           LParamPot:string;
           Indiv:string;
         end;
         type
           TSendMessage =class(TParam)
              TypeUser:string;
              ContactUserId:string;
              TypeContent:string;
              Content:string;
           end;
      end;

     type TamClientFileThreadParamWorkSender = class
          isUpload:boolean;
          Status:TAmToSocketSendChangeSendStatus;
          Position,
          Size,
          ErrorCode:int64;
          ComponentLparam:Cardinal;
          ComponentInDivId:Integer;
          IdFile:string;
          TypeFile:integer;

          SummaSize:int64;
          SummaPos:int64;
          SavePos:int64;

        end;



  type
    TamClientFileThreadParam = class


     private
       FLock:TCriticalSection;
       Fid:integer;
       IsDestroy:boolean;
       HashFile:string;
       FEventAbort: TEvent;
       ValAbort:TamVarCs<boolean>;
       FNeedPause:boolean;

        SummaSize:int64;
        SummaPos:int64;
        SavePos:int64;


       Function GetNeedAbort:boolean;
       procedure SetNeedAbort(val:boolean);

     public
     // const

      var
       isUpload:boolean;
       //что бы отправить

       InDiv:string;

       Host:string;
       Port:integer;
       FileName:string;
       FileNameIndexZip:string;
       IdFile:string;
       TypeFile:integer;
       Token,Hash:string;

       EventMessage:Cardinal;
       EventHandle:Cardinal;
       EventWorkNeed:boolean;

       //в процессе отправки  индефикаторы компонентов что бы знать куда выводит инфу в какое именно сообщение
       // этот модуль о этих даных вообще ничего не знает и просто их пересылает в событиях postmessage
       ComponentLparam:Cardinal;
       ComponentInDivId:Integer;

       //после отправки
       Result:integer;
       JsonSring:string;
       ErrorMessage:string;
       ErrorIsWas:boolean;

       property IssDestroy:boolean read IsDestroy ;
       property Id:integer read Fid ;
       property NeedAbort:boolean read GetNeedAbort write SetNeedAbort ;
       property NeedPause:boolean read FNeedPause   write FNeedPause ;
       procedure Clear;
       procedure Lock;
       procedure UnLock;
       constructor Create;
       destructor Destroy;override;
    end;



   type
   TamChatKindFileThread = (amcftList,amcftDefault);
   type
    TAmClientFileThread = class(TamHandleThread)
    private
        FKindFileThread: TamChatKindFileThread;
        FTerminateBeforeDestroy:boolean;
        CounterListParam:integer;
        FListParam: TList<TamClientFileThreadParam>;
        FListLock:TCriticalSection;
        [Unsafe] FParam: TamClientFileThreadParam;
        procedure ListParamAllFree;
     protected
       ZipConvert:TAmClientAddToArchivFilesAtSend;
       procedure   Log(msg:string);override;
    public
      NameThr:string;
      property   KindFileThread:TamChatKindFileThread read FKindFileThread;
      function   AddNewParamToList(Param:TamClientFileThreadParam):integer;
      function   RemoveParam(var Param:TamClientFileThreadParam):integer;
      function   RemoveParamNoFree(var Param:TamClientFileThreadParam):integer;
      procedure  CommponentAllNil;
      procedure  NeedAbortParam(IdParam:integer);
      procedure  NeedAbortParamAll;
      function   TerminatedBeforeDestroy:boolean;
      procedure  TerminateBeforeDestroy;
      constructor Create();
      destructor Destroy;override;
    end;


    TamClientUploadParam =class (TamClientFileThreadParam)

     private
       FileGetIdParam:integer;
     public
        Path_Photo:string;
        Path_Zip:string;
        Path_Voice:string;


        FullPhoto10:string;
        FullPhoto500:string;
        FullZipFile:string;
        FullVoice:string;


        IdPhoto10:string;
        IdPhoto500:string;
        IdZipFile:string;
        IdVoice:string;


        FileNameMainPhoto:string;
        procedure Clear;
    end;
   type
    TAmClientFileThreadUpload = class(TAmClientFileThread)
     private
      procedure UploadNewFile(var Msg:Tmessage); message AM_CLIENT_THREAD_UPLOAD_NEW_FILE;
      procedure Upload(Param:TamClientUploadParam);
      procedure  GetPrt(var Prt: TAmProtocolSock;Param:TamClientUploadParam);
      procedure WorkSend(Status:TAmToSocketSendChangeSendStatus;Position,Size,ErrorCode:int64);
     protected
      procedure GetIdFilePars(Param:TamClientUploadParam;var ResultJsonString:string);
      function  CheckErrorResultUpload(Param:TamClientUploadParam):boolean;
      function  CheckResultUpload(Param:TamClientUploadParam):boolean;
     public
      function RemoveParam(var Param:TamClientUploadParam):integer;
      function AddNewParam(Param:TamClientUploadParam):integer;  overload;
    end;


     {FilesSend}
    type
    TAmClientChatFilesSendParam =class (TamClientUploadParam)

      private
        //FileGetIdParam:integer; >> в родителе
        ResultIdFilesJson:string;
      public
        //обязательно
         TypeContent:string;
         TypeUser:string;
         ContactUserId:string;

         //для файлов
         //Path_Photo:string; >> в родителе
        // Path_Zip:string;   >> в родителе
         ListFilesConst:TamListVar<string>;
         ListFilesEditJson:string;
         Comment:string;

         //для текста
         Text:string;


        //для Voice
      //   Path_Voice:string;  >> в родителе
         MsVoice:TStream; //or
         FileNameVoice:String;//or
         MaxPos:integer;
         CaptionTime:string;
         Spectr:TAmBassSpectrMono;

       // не нужно указывать
     //   FullPhoto10:string; >> в родителе
      //  FullPhoto500:string; >> в родителе
      //  FullZipFile:string;  >> в родителе
      //  FullVoice:string;    >> в родителе

        //IdPhoto10:string;  >> в родителе
        //IdPhoto500:string; >> в родителе
        //IdZipFile:string;  >> в родителе
        //IdVoice:string;    >> в родителе
         procedure Clear;
         constructor Create;
         destructor Destroy;override;
    end;

    type
     TAmClientChatFilesSend =  class(TAmClientFileThreadUpload)
     private


      procedure DoSendMessageWith(var Msg:Tmessage); message AM_CLIENT_THREAD_SEND_MESSAGE_WITH;
      procedure SendMessageWithFiles(Param:TAmClientChatFilesSendParam);
      procedure SendMessageWithVoice(Param:TAmClientChatFilesSendParam);
      procedure SendMessageWithText(Param:TAmClientChatFilesSendParam);

      procedure UpdateMIMMessage(Param:TAmClientChatFilesSendParam);
      procedure SVR_SendMessage(
                                  Param:TAmClientChatFilesSendParam;
                                  TypeContent:string;
                                  Content:string;
                                  indiv:string
                                  );
     public
      function RemoveParam(var Param:TAmClientChatFilesSendParam):integer;
      function AddNewParam(Param:TAmClientChatFilesSendParam):integer; overload;
    end;
    ///////////////////////////////////////////////////////////////


    {Download}
    type
    TamClientDownloadParam =class (TamClientFileThreadParam)

        {
         1 фото по адресу ComponentLparam содержит ссылку на компонент TEsImage
         2. некий файл в сообщении
         картинка файл голосовое определяется по typefile
        }
        TypesAddr:integer;





    end;

   type
    TAmClientFileThreadDownload = class(TAmClientFileThread)
     private
      procedure DownloadNewFile(var Msg:Tmessage); message AM_CLIENT_THREAD_DOWNLOAD_NEW_FILE;
      procedure Download(Param:TamClientDownloadParam);
      procedure WorkRead(Status:TAmToSocketSendChangeSendStatus;Position,Size,ErrorCode:int64);
     protected
     public
      function RemoveParam(var Param:TamClientDownloadParam):integer;
      function AddNewParam(Param:TamClientDownloadParam):integer;
    end;
    //////////////////////////////////////////////////



    {MainPhoto}
    type
    TAmClientUploadMainPhotoParam =class (TamClientUploadParam)



    end;
   type
    TAmClientUploadMainPhoto = class(TAmClientFileThreadUpload)
     private
      procedure UploadNewPhoto(var Msg:Tmessage); message AM_CLIENT_THREAD_UPLOAD_NEW_PHOTO;
      procedure UploadPhoto(Param:TAmClientUploadMainPhotoParam);

     protected
     public
      function RemoveParam(var Param:TAmClientUploadMainPhotoParam):integer;
      function AddNewParam(Param:TAmClientUploadMainPhotoParam):integer;
    end;
    ///////////////////////////////////////////////////////



   type
    TAmClientSockFile = class

      // Download:TAmClientFileThreadDownload;
       DownloadPhotoContact:TAmClientFileThreadDownload;
       DownloadVoice:TAmClientFileThreadDownload;
       DownloadFiles:TAmClientFileThreadDownload;
       DownloadPhoto10:TAmClientFileThreadDownload;
       DownloadPhoto500:TAmClientFileThreadDownload;

       Upload:TAmClientUploadMainPhoto;

       //Send:TAmClientChatFilesSend;
       SendVoice:TAmClientChatFilesSend;
       SendFiles:TAmClientChatFilesSend;
      // SendPhoto:TAmClientChatFilesSend;

      constructor Create(LogMessage:TamLogString);reintroduce;
      destructor Destroy;override;
    end;


implementation

                    {SockFile}
constructor TAmClientSockFile.Create(LogMessage:TamLogString);
begin
    inherited Create;
   // Download:=TAmClientFileThreadDownload.Create;
   // Download.LogMessage:=LogMessage;
   // Download.NameThr:='Download';
  //  Download.Start;




    DownloadPhotoContact:=TAmClientFileThreadDownload.Create;
    DownloadPhotoContact.LogMessage:=LogMessage;
    DownloadPhotoContact.NameThr:='DownloadPhotoContact';
    DownloadPhotoContact.Start;



    DownloadVoice:=TAmClientFileThreadDownload.Create;
    DownloadVoice.LogMessage:=LogMessage;
    DownloadVoice.NameThr:='DownloadVoice';
    DownloadVoice.Start;

    DownloadFiles:=TAmClientFileThreadDownload.Create;
    DownloadFiles.LogMessage:=LogMessage;
    DownloadFiles.NameThr:='DownloadFiles';
    DownloadFiles.Start;


    DownloadPhoto10:=TAmClientFileThreadDownload.Create;
    DownloadPhoto10.LogMessage:=LogMessage;
    DownloadPhoto10.NameThr:='DownloadPhoto10';
    DownloadPhoto10.Start;


    DownloadPhoto500:=TAmClientFileThreadDownload.Create;
    DownloadPhoto500.LogMessage:=LogMessage;
    DownloadPhoto500.NameThr:='DownloadPhoto500';
    DownloadPhoto500.Start;



    Upload:=TAmClientUploadMainPhoto.Create;
    Upload.LogMessage:=LogMessage;
    Upload.NameThr:='Upload';
    Upload.Start;




   // Send:=TAmClientChatFilesSend.Create;
   // Send.LogMessage:=LogMessage;
   // Send.NameThr:='Send';
   // Send.Start;


    SendVoice:=TAmClientChatFilesSend.Create;
    SendVoice.LogMessage:=LogMessage;
    SendVoice.NameThr:='SendVoice';
    SendVoice.Start;


    SendFiles:=TAmClientChatFilesSend.Create;
    SendFiles.LogMessage:=LogMessage;
    SendFiles.NameThr:='SendFiles';
    SendFiles.Start;



  // SendPhoto:=TAmClientChatFilesSend.Create;
  //  SendPhoto.LogMessage:=LogMessage;
  //  SendPhoto.NameThr:='SendPhoto';
  //  SendPhoto.Start;







end;
destructor TAmClientSockFile.Destroy;
begin

// Download.TerminateBeforeDestroy;
 DownloadPhotoContact.TerminateBeforeDestroy;

 DownloadVoice.TerminateBeforeDestroy;
 DownloadFiles.TerminateBeforeDestroy;
 DownloadPhoto10.TerminateBeforeDestroy;
 DownloadPhoto500.TerminateBeforeDestroy;


 Upload.TerminateBeforeDestroy;

 //Send.TerminateBeforeDestroy;
 SendVoice.TerminateBeforeDestroy;
 SendFiles.TerminateBeforeDestroy;
// SendPhoto.TerminateBeforeDestroy;



// Download.Free;
 DownloadPhotoContact.Free;
 DownloadVoice.Free;
 DownloadFiles.Free;
 DownloadPhoto10.Free;
 DownloadPhoto500.Free;

 Upload.Free;

 //Send.Free;
 SendVoice.Free;
 SendFiles.Free;
 //SendPhoto.Free;

 inherited;
end;

                     {UploadNewPhoto}

function TAmClientUploadMainPhoto.RemoveParam(var Param:TAmClientUploadMainPhotoParam):integer;
begin
   Result:= inherited RemoveParam(TamClientUploadParam(Param));
end;
function TAmClientUploadMainPhoto.AddNewParam(Param:TAmClientUploadMainPhotoParam):integer;
begin
  Result:= AddNewParamToList(TamClientFileThreadParam(Param));
  if not PostMessageThread(AM_CLIENT_THREAD_UPLOAD_NEW_PHOTO,0,Lparam(Param))then
  begin
     Result:=-1;
     RemoveParam(Param);
  end;

end;
procedure TAmClientUploadMainPhoto.UploadNewPhoto(var Msg:Tmessage); //message AM_CLIENT_THREAD_UPLOAD_NEW_PHOTO;
var
Param:TAmClientUploadMainPhotoParam;
begin
  Param:= TAmClientUploadMainPhotoParam(Msg.LParam);
  if not Assigned(Param) or  Param.IsDestroy then exit;
  try
    if not Param.ValAbort.Val then UploadPhoto(Param);
  finally
     if  (Param.EventHandle>0) and (Param.EventMessage>0) then
     begin
     if PostMessage(Param.EventHandle,Param.EventMessage,PFT.EndParam,lparam(Param)) then
     Param:=nil;
     end;
     if Assigned(Param) then
     RemoveParam(Param);
  end;

end;
procedure TAmClientUploadMainPhoto.UploadPhoto(Param:TAmClientUploadMainPhotoParam);
var G:TAmChatHttpFiles;
    IdFilesBeforeUpload:string;
    Fs:TFileStream;
    Ms:TMemoryStream;
    ResultExp:boolean;
begin
 try
   G:= TAmChatHttpFiles.Create;
   Ms:=TMemoryStream.Create;
   ResultExp:=false;
   try   
     try

         if (Param.FileNameMainPhoto='') or not  fileexists(Param.FileNameMainPhoto) then
         begin
            Param.Result:=-1100;
            Param.ErrorIsWas:=true;
            Param.ErrorMessage:= 'Не найден файл '+ExtractFileName(Param.FileNameMainPhoto);

            log('Error.TAmClientUploadMainPhoto.UploadPhoto Param.FileNameMainPhoto нет такого файла ');
            exit;
         end;
         if   AmIsFileInUse(Param.FileNameMainPhoto) then
         begin
            Param.Result:=-1099;
            Param.ErrorMessage:= 'Файл занят '+ExtractFileName(Param.FileNameMainPhoto);
            Param.ErrorIsWas:=true;
            log('Error.TAmClientUploadMainPhoto.UploadPhoto Param.FileNameMainPhoto файл занят другим процессом ');
            exit;
         end;

         Ms.LoadFromFile(Param.FileNameMainPhoto);
         amScaleImage.GetPic(Ms,150);
         Ms.Position:=0;
         amScaleImage.Compressing(Ms,90);
         if Ms.Size<=0 then
         begin
            Param.Result:=-1098;
            Param.ErrorMessage:= 'Не удалось сконверттировать файл '+ExtractFileName(Param.FileNameMainPhoto);
            Param.ErrorIsWas:=true;
            log('Error.TAmClientUploadMainPhoto.UploadPhoto Param.FileNameMainPhoto файл занят другим процессом ');
            exit;
         end;








          Param.FEventAbort.ResetEvent;
          G.Host:= Param.Host;
          G.Port:=Param.Port;
          G.LogMessage:= LogMessage;
          G.EventAbort:= Param.FEventAbort.Handle;

          Param.FileGetIdParam:= ConstAmChat.FileGetIdParam.Photo;


          Param.Result:=G.GetIdFilesBeforeUpload(Param.Token,Param.Hash,Param.FileGetIdParam,IdFilesBeforeUpload);

          if Self.Terminated or not CheckErrorResultUpload(Param) then  exit;

          if IdFilesBeforeUpload='' then
          begin
             Param.Result:=-1097;
             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Ошибка : Пришел пустой ответ от сервера';

              log('Error.TAmClientUploadMainPhoto.UploadPhoto вернулось пустое значение Json '+Param.Result.ToString);

             exit;
          end;


          GetIdFilePars(Param,IdFilesBeforeUpload);

          if ConstAmChat.CheckIdFile(Param.IdPhoto10) then
              Param.FullPhoto10:= Param.Path_Photo  +  Param.IdPhoto10 + ConstAmChat.NameFileType.ePhotoExt;

          if ConstAmChat.CheckIdFile(Param.IdPhoto500) then
              Param.FullPhoto500:= Param.Path_Photo  +  Param.IdPhoto500 + ConstAmChat.NameFileType.ePhotoExt;

          if (Param.FullPhoto500='') or (Param.IdPhoto500='') then
          begin
             Param.Result:=-1096;
             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Ошибка : Пришел пустой idPhoto от сервера';

              log('Error.TAmClientUploadMainPhoto.UploadPhoto Пришел пустой idPhoto от сервера '+Param.Result.ToString);

             exit;
          end;
          log('TAmClientUploadMainPhoto.UploadPhoto'+ms.Size.ToString+' '+Param.FullPhoto500);
          Ms.SaveToFile(Param.FullPhoto500);


          Param.SummaSize:=Ms.Size;
          Param.SummaPos:=0;
          Param.SavePos:=0;
          Param.FileName:= Param.FullPhoto500;
          Param.IdFile:=   Param.IdPhoto500;
          Param.TypeFile:= AmPrtSockTypeFile.Image;
          Param.JsonSring:='';
          Param.FEventAbort.ResetEvent;
          self.Upload(Param);
          // log( 'TAmClientUploadMainPhoto Photo500Result '+Param.JsonSring);
          if Self.Terminated or not CheckResultUpload(Param) then exit;

          ResultExp:=true;


     except
       on e: exception do
       begin
         Param.Result:=-1095;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:= 'Error MainPhotoThr '+e.Message;
         log('ErrorCode.TAmClientUploadMainPhoto.UploadPhoto '+e.Message);
       end;
     end;

   finally
     if not ResultExp  then DeleteFile(Param.FileName);
     Ms.Free;
     G.Free;
   end;
 except
   on e: exception do
   begin

     log('ErrorCode.TAmClientUploadMainPhoto.UploadPhoto 2 '+e.Message);
   end;
 end;


end;


                          {Download}
function TAmClientFileThreadDownload.RemoveParam(var Param:TamClientDownloadParam):integer;
begin
  Result:= inherited RemoveParam(TamClientFileThreadParam(Param));
end;
function TAmClientFileThreadDownload.AddNewParam(Param:TamClientDownloadParam):integer;
begin
  Result:= AddNewParamToList(TamClientFileThreadParam(Param));
  if not PostMessageThread(AM_CLIENT_THREAD_DOWNLOAD_NEW_FILE,0,Lparam(Param))then
  begin
  Result:=-1;
  RemoveParam(Param);
  end;
end;
procedure TAmClientFileThreadDownload.WorkRead(Status:TAmToSocketSendChangeSendStatus;Position,Size,ErrorCode:int64);
var Work:TamClientFileThreadParamWorkSender;
begin
  if Assigned(FParam)and (FParam.EventWorkNeed) and (FParam.EventHandle>0) and (FParam.EventMessage>0) then
  begin
    Work:= TamClientFileThreadParamWorkSender.Create;
    Work.isUpload:=false;
    Work.Status:=Status;
    Work.Position:=Position;
    Work.Size:=Size;
    Work.ErrorCode:=ErrorCode;
    FParam.Lock;
    try
      Work.ComponentLparam:= FParam.ComponentLparam;
      Work.ComponentInDivId:=FParam.ComponentInDivId;
      Work.IdFile:= FParam.IdFile;
      Work.TypeFile:= FParam.TypeFile;
    finally
      FParam.UnLock;
    end;

   if not PostMessage(FParam.EventHandle,FParam.EventMessage,PFT.ChangeWorkDownload,lparam(Work)) then
   Work.Free;
  end;

end;

procedure TAmClientFileThreadDownload.DownloadNewFile(var Msg:Tmessage);//AM_CLIENT_THREAD_DOWNLOAD_NEW_FILE
var
Param:TamClientDownloadParam;
begin
  Param:= TamClientDownloadParam(Msg.LParam);
  if not Assigned(Param) or  Param.IsDestroy then exit;
  try
    if not Param.ValAbort.Val then Download(Param);
  finally
     if  (Param.EventHandle>0) and (Param.EventMessage>0) then
     begin
     if PostMessage(Param.EventHandle,Param.EventMessage,PFT.EndParam,lparam(Param)) then
     Param:=nil;
     end;
     if Assigned(Param) then
     RemoveParam(Param);
  end;


end;
procedure TAmClientFileThreadDownload.Download(Param:TamClientDownloadParam);
var G:TAmChatHttpFiles;
    Fs:TFileStream;
    R:boolean;
begin
  try
     if Param.FileName='' then
     begin

           Param.Result:=-1203;
           Param.ErrorIsWas:=true;
           Param.ErrorMessage:='Error.TAmClientFileThreadDownload.Download Param.FileName пуст';
        log('Error.TAmClientFileThreadDownload.Download Param.FileName пуст ');
        exit;
     end;
     R:=false;
     DeleteFile(Param.FileName);
     FS := TFileStream.Create(Param.FileName,fmCreate);
     G :=TAmChatHttpFiles.Create;
     try
       try
          FParam:= Param;
          G.Host:= Param.Host;
          G.Port:=Param.Port;
          Param.FEventAbort.ResetEvent;
          G.EventAbort:= Param.FEventAbort.Handle;
          G.OnWorkRead:= WorkRead;
          G.TimeOutConnect:=30*1000;
          Fs.Size:=0;
          Param.Result:=0;

          if Param.TypeFile = AmPrtSockTypeFile.Image  then
               Param.Result:= G.GetPhoto(Param.IdFile,Param.Token,Param.Hash,Fs)
          else
          if Param.TypeFile = AmPrtSockTypeFile.Voice  then
               Param.Result:= G.GetVoice(Param.IdFile,Param.Token,Param.Hash,Fs)
          else
          if Param.TypeFile = AmPrtSockTypeFile.Zip  then
               Param.Result:= G.GetZip(Param.IdFile,Param.Token,Param.Hash,Param.FileNameIndexZip,Fs)
          else
          begin
           Param.Result:=-1202;
           Param.ErrorIsWas:=true;
           Param.ErrorMessage:='Error.TAmClientFileThreadDownload.Download не указан TypeFile '+Param.TypeFile.tostring;
             log('Error.TAmClientFileThreadDownload.Download не указан TypeFile '+Param.TypeFile.tostring);
             exit;
          end;

          if (Param.Result = Param.TypeFile) then  R:=true
          else if (Param.Result = AmPrtSockTypeFile.Json)
          and (Fs.Size<1050*1000) then Param.JsonSring:= amStr(Fs)
          else
          begin

             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Error.TAmClientFileThreadDownload.Download  result  не файл '+Param.Result.ToString;
             log('Error.TAmClientFileThreadDownload.Download result  не файл '+Fs.Size.tostring +' Param.Result='+Param.Result.ToString);
             Param.Result:=-1201;
          end;
       except
         on e :exception do
         begin
         Param.Result:=-1200;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:='Error.TAmClientFileThreadDownload.Download 2 '+e.Message;
         if Assigned(LogMessage)then LogMessage.LogError('Error.TAmClientFileThreadDownload.Download 2 ',self,e);
         end;

       end;
     finally
       FParam:=nil;
       G.Free;
       Fs.Free;
       if not R  then DeleteFile(Param.FileName);
     end;

  except
         on e :exception do
         begin
         Param.Result:=-1204;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:='Error.TAmClientFileThreadDownload.Download '+e.Message;
          log('Error.TAmClientFileThreadDownload.Download '+e.Message);
         end;
  end;

end;

procedure TamClientUploadParam.Clear;
begin
        FileNameMainPhoto:='';

        Path_Photo:='';
        Path_Zip:='';
        Path_Voice:='';

        FullPhoto10:='';
        FullPhoto500:='';
        FullZipFile:='';
        FullVoice:='';

        FileGetIdParam:=0;
        IdPhoto10:='';
        IdPhoto500:='';
        IdZipFile:='';
        IdVoice:='';

    inherited Clear;
end;

                      {Send}

constructor TAmClientChatFilesSendParam.Create;
begin
     inherited Create;
    // ListFiles:=  TList<string>.create;
     Clear;

end;
destructor TAmClientChatFilesSendParam.Destroy;
begin
    if IsDestroy then exit;
    if  Assigned(MsVoice) then  FreeAndNil(MsVoice);
    Clear;



  //  ListFiles.Free;
   // ListFiles:=nil;
    inherited Destroy;
end;
procedure TAmClientChatFilesSendParam.Clear;
begin

         Path_Photo:='';
         Path_Zip:='';
         Path_Voice:='';






        ResultIdFilesJson:='';
        ListFilesConst.Clear;
        ListFilesEditJson:='';
        TypeContent:='';
        MsVoice:=nil;
        FileNameVoice:='';
        Comment:='';
        TypeUser:='';
        ContactUserId:='';
        Text:='';
        MaxPos:=0;
        CaptionTime:='';
        SetLength(Spectr,0);

        inherited Clear;
end;


function TAmClientChatFilesSend.RemoveParam(var Param:TAmClientChatFilesSendParam):integer;
begin
  Result:= inherited  RemoveParam(TamClientUploadParam(Param));
end;
function TAmClientChatFilesSend.AddNewParam(Param:TAmClientChatFilesSendParam):integer;
begin
  Result:= AddNewParamToList(TamClientFileThreadParam(Param));
  if not PostMessageThread(AM_CLIENT_THREAD_SEND_MESSAGE_WITH,0,Lparam(Param)) then
  begin
    Result:=-1;
    RemoveParam(Param);
  end;

end;

procedure TAmClientChatFilesSend.DoSendMessageWith(var Msg:Tmessage);// message AM_CLIENT_THREAD_SEND_MESSAGE_WITH;
var
Param:TAmClientChatFilesSendParam;
begin
  Param:= TAmClientChatFilesSendParam(Msg.LParam);
  if not Assigned(Param) or  Param.IsDestroy then exit;
  try
    if not Param.ValAbort.Val then
    begin


        if Param.TypeContent = ConstAmChat.TypeContent.Files then
        begin
           Param.FileGetIdParam:= ConstAmChat.FileGetIdParam.PhotoAndZip;
           SendMessageWithFiles(Param);
        end
        else
        if Param.TypeContent = ConstAmChat.TypeContent.Voice then
        begin
           Param.FileGetIdParam:= ConstAmChat.FileGetIdParam.Voice;
           SendMessageWithVoice(Param);
        end
        else
        if Param.TypeContent = ConstAmChat.TypeContent.Text then
        begin
           Param.FileGetIdParam:= 0;
           SendMessageWithText(Param);
        end

    end;
  finally
     if  (Param.EventHandle>0) and (Param.EventMessage>0) then
     begin
     if PostMessage(Param.EventHandle,Param.EventMessage,PFT.EndParam,lparam(Param)) then
     Param:=nil;
     end;
     if Assigned(Param) then
     RemoveParam(Param);
  end;
end;
procedure TAmClientChatFilesSend.UpdateMIMMessage(Param:TAmClientChatFilesSendParam);
begin

   if (Param.EventHandle >0)  then
   amSendMessage.SendTimeOut(Param.EventHandle,
   AM_CLIENT_EDITOR_THREAD_PFT_UPDATE_LIST,
   0,
   LParam(Param),1000);

   //showmessage(Result.ToString);
end;
procedure TAmClientChatFilesSend.SVR_SendMessage(
                            Param:TAmClientChatFilesSendParam;
                            TypeContent:string;
                            Content:string;
                            indiv:string
                            );
var Msg:PFT.TSendMessage;
begin
 if (Param.EventHandle >0) and (Param.EventMessage>0) then
 begin
    Msg:= PFT.TSendMessage.Create;
    Msg.LParamPot:=     '';
    Msg.Indiv:=indiv;
    Msg.TypeUser:=      Param.TypeUser;
    Msg.ContactUserId:= Param.ContactUserId;
    Msg.TypeContent:=   TypeContent;
    Msg.Content:=       Content;

    Param.Lock;
    try
     Msg.ComponentLparam:= Param.ComponentLparam;
    finally
      Param.UnLock;
    end;

   Content:='';
   if not PostMessage(Param.EventHandle,Param.EventMessage,PFT.SendMessageSVR,LParam(Msg))then
   Msg.Free;
 end;

end;
procedure TAmClientChatFilesSend.SendMessageWithText(Param:TAmClientChatFilesSendParam);
begin

end;
procedure TAmClientChatFilesSend.SendMessageWithVoice(Param:TAmClientChatFilesSendParam);
var //Ms:TmemoryStream;
    ContentString:String;
    ContentJson:TJsonObject;

    G:TAmChatHttpFiles;
    IdFilesBeforeUpload:string;
    FsVoice : TFileStream;
begin
  // Ms:=TmemoryStream.Create;
   G:= TAmChatHttpFiles.Create;
   try
          if not Assigned(Param.MsVoice) or (Param.MsVoice.Size<=0) then  exit;


          Param.FEventAbort.ResetEvent;
          G.Host:= Param.Host;
          G.Port:=Param.Port;
          G.LogMessage:= LogMessage;
          G.EventAbort:= Param.FEventAbort.Handle;

          Param.Result:=G.GetIdFilesBeforeUpload(Param.Token,Param.Hash,Param.FileGetIdParam,IdFilesBeforeUpload);

          if Self.Terminated or not CheckErrorResultUpload(Param) then  exit;

          if IdFilesBeforeUpload='' then
          begin
             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Ошибка : Пришел пустой ответ от сервера';

              log('Error.TAmClientChatFilesSend.SendMessageWithFiles вернулось пустое значение Json '+Param.Result.ToString);
             exit;
          end;



          GetIdFilePars(Param,IdFilesBeforeUpload);

          if not ConstAmChat.CheckIdFile(Param.IdVoice) then exit;
          Param.FullVoice:= Param.Path_Voice  +  Param.IdVoice + ConstAmChat.NameFileType.eVoiceExt;

          FsVoice := TFileStream.Create(Param.FullVoice,fmCreate);
          try
              Param.MsVoice.Position:=0;
              FsVoice.CopyFrom(Param.MsVoice,Param.MsVoice.Size);
          finally
             FsVoice.Free;
          end;

          Param.SavePos:=0;
          Param.JsonSring:='';
          Param.FileName:= Param.FullVoice;
          Param.IdFile:=   Param.IdVoice;
          Param.TypeFile:= AmPrtSockTypeFile.Voice;
          Param.JsonSring:='';
          Param.FEventAbort.ResetEvent;
          self.Upload(Param);
          //log( 'IdVoice '+Param.JsonSring);
          if Self.Terminated or not CheckResultUpload(Param) then exit;



           ContentJson:= TJsonObject.Create;
           try

              ContentJson['VoiceId'].Value:= Param.IdVoice;
              ContentJson['VoiceSpectrJson'].Value:= AmJson.ArrRealToStr(Param.Spectr);
              ContentJson['VoiceLength'].Value:= Param.MaxPos.ToString;
              ContentJson['VoiceCaption'].Value:= '';
              ContentJson['VoiceTimerSecond'].Value:= Param.CaptionTime;
             ContentString:=ContentJson.ToJSON();
           finally
             ContentJson.Free;
           end;
          SVR_SendMessage(Param,Param.TypeContent,ContentString,'');
          ContentString:='';




   finally


     G.Free;
   end;
end;

procedure TAmClientChatFilesSend.SendMessageWithFiles(Param:TAmClientChatFilesSendParam);
var Zip:TAmClientAddToArchivFilesAtSend;
    //Ms:TmemoryStream;
    ResultAdd:TAmClientAddToArchivFilesAtSend.TResult;
    ContentString:String;
    ContentJson:TJsonObject;
    JsonArray:TJsonArray;
    i:integer;
    G:TAmChatHttpFiles;
    IdFilesBeforeUpload:string;


begin


   Zip:= TAmClientAddToArchivFilesAtSend.Create;
  // Ms:=TmemoryStream.Create;
   G:= TAmChatHttpFiles.Create;


   try   {  FParam:=Param;
          for I := 0 to 50 do
            begin
               if Param.NeedAbort then break;
               WorkSend(amsockProcessing,I,50,0);
               sleep(1000);
            end;
          FParam:=nil; exit;}
     try
          Param.FEventAbort.ResetEvent;
          G.Host:= Param.Host;
          G.Port:=Param.Port;
          G.LogMessage:= LogMessage;
          G.EventAbort:= Param.FEventAbort.Handle;

          Param.Result:=G.GetIdFilesBeforeUpload(Param.Token,Param.Hash,Param.FileGetIdParam,IdFilesBeforeUpload);

          if Self.Terminated or not CheckErrorResultUpload(Param) then  exit;

          if IdFilesBeforeUpload='' then
          begin
             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Ошибка : Пришел пустой ответ от сервера';

              log('Error.TAmClientChatFilesSend.SendMessageWithFiles вернулось пустое значение Json '+Param.Result.ToString);

             exit;
          end;


          GetIdFilePars(Param,IdFilesBeforeUpload);

          if ConstAmChat.CheckIdFile(Param.IdPhoto10) then
              Param.FullPhoto10:= Param.Path_Photo  +  Param.IdPhoto10 + ConstAmChat.NameFileType.ePhotoExt;

          if ConstAmChat.CheckIdFile(Param.IdPhoto500) then
              Param.FullPhoto500:= Param.Path_Photo  +  Param.IdPhoto500 + ConstAmChat.NameFileType.ePhotoExt;

          if ConstAmChat.CheckIdFile(Param.IdZipFile) then
              Param.FullZipFile:= Param.Path_Zip  +  Param.IdZipFile + ConstAmChat.NameFileType.eFilesExt;

             // showmessage(GetCurrentThreadId.ToString());
          ResultAdd:=ZipConvert.Get(
                      Param.FullPhoto10,
                      Param.FullPhoto500,
                      Param.FullZipFile,
                      Param.ListFilesConst,
                      true,800,false,800);

          if Self.Terminated  then exit;


        Param.SummaSize:=ResultAdd.Photo10SizeStream+ ResultAdd.Photo500SizeStream+ ResultAdd.ZipSizeStream;
        Param.SummaPos:=0;
        Param.SavePos:=0;

          Param.ListFilesEditJson:= ResultAdd.ListFileOtherJson;
          UpdateMIMMessage(Param);

          if ResultAdd.Result then
          begin
            if ResultAdd.Photo10Result  then
            begin
               Param.SavePos:=0;
               Param.FileName:= Param.FullPhoto10;
               Param.IdFile:=   Param.IdPhoto10;
               Param.TypeFile:= AmPrtSockTypeFile.Image;
               Param.JsonSring:='';
               Param.FEventAbort.ResetEvent;
               self.Upload(Param);
               //log( 'Photo10Result '+Param.JsonSring);
               if Self.Terminated or not CheckResultUpload(Param) then exit;




            end;
            if ResultAdd.Photo500Result  then
            begin
               Param.SavePos:=0;
               Param.FileName:= Param.FullPhoto500;
               Param.IdFile:=   Param.IdPhoto500;
               Param.TypeFile:= AmPrtSockTypeFile.Image;
               Param.JsonSring:='';
               Param.FEventAbort.ResetEvent;
               self.Upload(Param);
             //  log( 'Photo500Result '+Param.JsonSring);
               if Self.Terminated or not CheckResultUpload(Param) then exit;


            end;


             Param.SavePos:=0;
             Param.FileName:= Param.FullZipFile;
             Param.IdFile:=   Param.IdZipFile;
             Param.TypeFile:= AmPrtSockTypeFile.Zip;
             Param.JsonSring:='';
             Param.FEventAbort.ResetEvent;
             self.Upload(Param);
            // log( 'IdZipFile '+Param.JsonSring);
             if Self.Terminated or not CheckResultUpload(Param) then exit;



          end;



          if (Param.IdPhoto10<>'') or (Param.IdPhoto500<>'') or (Param.IdZipFile<>'') or (Trim(Param.Comment)<>'') then
          begin


            ContentString:='';
            ContentJson:=  TJsonObject.Create;
            try

               if ResultAdd.Result then
               begin
                  if ResultAdd.Photo10Result  then
                 ContentJson['IdPhoto10'].Value:= Param.IdPhoto10;

                 if ResultAdd.Photo500Result  then
                 ContentJson['IdPhoto500'].Value:= Param.IdPhoto500;
                 ContentJson['IdFile'].Value:=Param.IdZipFile;
                 ContentJson['CollageSizeMax'].Value:=AmRectSize.SizeToStr(ResultAdd.CollageSizeMax);
                 ContentJson['CollageCountFile'].Value:=  ResultAdd.CountFileCollage.ToString;

                 JsonArray:= amJson.LoadArray(ResultAdd.ListFileOtherJson);
                 try
                   ContentJson.A['ListFileOther'].Assign(JsonArray);
                 finally
                   JsonArray.Free;
                 end;

                 JsonArray:= amJson.LoadArray(ResultAdd.ListFilePhotoJson);
                 try
                   ContentJson.A['ListFilePhoto'].Assign(JsonArray);
                 finally
                   JsonArray.Free;
                 end;
               end;


               ContentJson['Comment'].Value:=Trim(Param.Comment);
               ContentString:= ContentJson.ToJSON(true);
            finally
             ContentJson.Free;
            end;
            SVR_SendMessage(Param,Param.TypeContent,ContentString,'');
            ContentString:='';



          end
          else
          begin
             Param.Result:=-898;
             Param.ErrorIsWas:=true;
             Param.ErrorMessage:='Ошибка : Не удалось отправить сообщение параметры пусты';

          end;
     except
       on e: exception do
       begin
         Param.Result:=-899;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:= 'Error SendThr '+e.Message;
         log('ErrorCode.TAmClientChatFilesSend.SendMessageWithFiles '+e.Message);
       end;
     end;

   finally
     Zip.Free;
     G.Free;
     if FileExists(Param.FullZipFile) then DeleteFile(Param.FullZipFile);
     

   end;

end;









constructor TamClientFileThreadParam.Create;
begin
  inherited Create;
  FLock:= TCriticalSection.Create;
       Fid:=0;
       IsDestroy:=false;
       FNeedPause:=false;
       HashFile:='';
       FEventAbort:=TEvent.Create(nil, false, true, '');
       FEventAbort.ResetEvent;
       ValAbort:=TamVarCs<boolean>.create;
       ValAbort.Val:=false;
       Clear;

end;
destructor TamClientFileThreadParam.Destroy;
begin
   if IsDestroy then exit;
   IsDestroy:=true;
   Clear;
   inherited;
   FreeAndNil(FEventAbort);
   FreeAndNil(ValAbort);
   FreeAndNil(FLock);


end;
procedure TamClientFileThreadParam.Clear;
begin
       InDiv:='';
       ErrorMessage:='';
       ErrorIsWas:=false;
        SummaSize:=0;
        SummaPos:=0;
        SavePos:=0;

       isUpload:=false;
       Host:='';
       Port:=0;
       FileName:='';
       FileNameIndexZip:='';
       IdFile:='';
       TypeFile:=0;
       Token:='';
       Hash:='';

       ComponentLparam:=0;
       ComponentInDivId:=0;

       Result:=-1000;
       EventMessage:=0;
       EventHandle:=0;
       EventWorkNeed:=false;
       JsonSring:='';



end;
procedure TamClientFileThreadParam.Lock;
begin
  FLock.Acquire;
end;
procedure TamClientFileThreadParam.UnLock;
begin
   FLock.Leave;
end;
Function TamClientFileThreadParam.GetNeedAbort:boolean;
begin
 Result:=true;
 if Assigned(ValAbort) then Result:=ValAbort.Val;
end;
procedure TamClientFileThreadParam.SetNeedAbort(val:boolean);
begin
   if Assigned(ValAbort) and Assigned(FEventAbort) then
   begin
      ValAbort.Val:=val;
      if val then FEventAbort.SetEvent
      else FEventAbort.ResetEvent;
   end;
end;
                 {TAmClientFileThreadDownload}
constructor TAmClientFileThread.Create();
begin
  inherited Create();

  ZipConvert:= TAmClientAddToArchivFilesAtSend.Create;
  NameThr:='FileThread';
  FKindFileThread:= amcftDefault;
  FTerminateBeforeDestroy:=false;
  FListLock:= TCriticalSection.Create;
  FListParam:= TList<TamClientFileThreadParam>.create;
  FParam:=nil;
  CounterListParam:=0;
end;
destructor TAmClientFileThread.Destroy;
begin
 try
    TerminateBeforeDestroy;
    self.WaitFor;
    FParam:=nil;
    ListParamAllFree;
    FListParam.Free;
    ZipConvert.Free;
    inherited;
    FListLock.Free;
 except
    showmessage('TAmClientFileThread.Destroy');
 end;
end;
procedure TAmClientFileThread.TerminateBeforeDestroy;
begin
  if FTerminateBeforeDestroy then exit;
  FTerminateBeforeDestroy:=true;
  
    if self.Suspended then  self.Resume;
    CommponentAllNil;
    NeedAbortParamAll;
    self.Terminate;
end;
function  TAmClientFileThread.TerminatedBeforeDestroy:boolean;
begin
  Result:=FTerminateBeforeDestroy;
end;
procedure   TAmClientFileThread.Log(msg:string);
begin
   inherited Log(NameThr+' '+msg);
end;

function TAmClientFileThread.AddNewParamToList(Param:TamClientFileThreadParam):integer;
begin
   inc(CounterListParam);
   Result:= CounterListParam;
   FListLock.Enter;
   try
     Param.Fid:=CounterListParam;
     FListParam.add(Param);
   finally
     FListLock.Leave;
   end;

end;
procedure TAmClientFileThread.CommponentAllNil;
var i:integer;
begin
   FListLock.Enter;
   try
      if FListParam.Count>0 then
      begin
          // self.Suspend;
           try
              for I := 0 to FListParam.Count-1  do
              if Assigned(FListParam[i])
              and not FListParam[i].IsDestroy
              then
              begin
                  FListParam[i].Lock;
                  try
                     FListParam[i]. ComponentLparam:=0;
                     FListParam[i]. ComponentInDivId:=0;
                  finally
                    FListParam[i].UnLock;
                  end;

              end;
           finally
            // self.Resume;
           end;
      end;

   finally
     FListLock.Leave;
   end;
end;
function TAmClientFileThread.RemoveParamNoFree(var Param:TamClientFileThreadParam):integer;
begin
   Result:=-1;
   if not Assigned(Param) or  Param.IsDestroy then exit;
   Result:= Param.Id;
   FListLock.Enter;
   try
     FListParam.Remove(Param);
   finally
     FListLock.Leave;
   end;
end;
function  TAmClientFileThread.RemoveParam(var Param:TamClientFileThreadParam):integer;
begin
   Result:=RemoveParamNoFree(Param);
   Param.Free;
   Param:=nil;
end;
procedure TAmClientFileThread.NeedAbortParam(IdParam:integer);
var i:integer;
begin
   FListLock.Enter;
   try
      for I := 0 to FListParam.Count-1  do
      if Assigned(FListParam[i])
      and not FListParam[i].IsDestroy
      and  (FListParam[i].Fid=IdParam) then
      FListParam[i].NeedAbort:=true;

   finally
     FListLock.Leave;
   end;
end;
procedure TAmClientFileThread.NeedAbortParamAll;
var i:integer;
begin
   FListLock.Enter;
   try
      for I := 0 to FListParam.Count-1  do
      if Assigned(FListParam[i]) then
      begin
        if not FListParam[i].IsDestroy then
        begin
         if not FListParam[i].NeedAbort then
         FListParam[i].NeedAbort:=true;
        end;

      end;


   finally
     FListLock.Leave;
   end;

end;
procedure TAmClientFileThread.ListParamAllFree;
var i:integer;
begin
   FListLock.Enter;
   try
      for I := 0 to FListParam.Count-1  do
      if Assigned(FListParam[i])
      and not FListParam[i].IsDestroy then
      FListParam[i].Free;
      FListParam.Clear;
   finally
     FListLock.Leave;
   end;

end;





                      {Upload}

function TAmClientFileThreadUpload.RemoveParam(var Param:TamClientUploadParam):integer;
begin
  Result:= inherited RemoveParam(TamClientFileThreadParam(Param));
end;
function TAmClientFileThreadUpload.AddNewParam(Param:TamClientUploadParam):integer;
begin
  Result:= AddNewParamToList(TamClientFileThreadParam(Param));
  if not PostMessageThread(AM_CLIENT_THREAD_UPLOAD_NEW_FILE,0,Lparam(Param)) then
  begin
    result:=-1;
     RemoveParam(Param);
  end;

end;
procedure TAmClientFileThreadUpload.WorkSend(Status:TAmToSocketSendChangeSendStatus;Position,Size,ErrorCode:int64);
var Work:TamClientFileThreadParamWorkSender;
begin
  if Assigned(FParam) and (FParam.EventWorkNeed) and   (FParam.EventHandle>0) and (FParam.EventMessage>0) then
  begin
    Work:= TamClientFileThreadParamWorkSender.Create;
    Work.isUpload:=true;
    Work.Status:=Status;
    Work.Position:=Position;
    Work.Size:=Size;
    Work.ErrorCode:=ErrorCode;




    FParam.Lock;
    try
      Work.SummaSize:=FParam.SummaSize;
      FParam.SummaPos:= FParam.SummaPos +Position - FParam.SavePos ;
      Work.SummaPos:= FParam.SummaPos;
      FParam.SavePos:= Position;
      Work.ComponentLparam:= FParam.ComponentLparam;
      Work.ComponentInDivId:=FParam.ComponentInDivId;
      Work.IdFile:= FParam.IdFile;
      Work.TypeFile:= FParam.TypeFile;
    finally
      FParam.UnLock;
    end;


    if not PostMessage(FParam.EventHandle,FParam.EventMessage,PFT.ChangeWorkUpload,lparam(Work)) then
    Work.Free;
  end;

end;
procedure TAmClientFileThreadUpload.UploadNewFile(var Msg:Tmessage); //message AM_CLIENT_THREAD_UPLOAD_NEW_FILE;
var
Param:TamClientUploadParam;
begin
   try
      Param:= TamClientUploadParam(Msg.LParam);
      if not Assigned(Param) or  Param.IsDestroy then exit;
      try
       try
        if not Param.ValAbort.Val then Upload(Param);
       except
             on e :exception do
             begin
             log('Error.TAmClientFileThreadUpload.UploadNewFile '+e.Message);
             end;
       end;
      finally
         if  (Param.EventHandle>0) and (Param.EventMessage>0) then
         begin
         if PostMessage(Param.EventHandle,Param.EventMessage,PFT.EndParam,lparam(Param)) then
         Param:=nil;
         end;
         if Assigned(Param) then
         RemoveParam(Param);
      end;

   except
         on e :exception do
         begin
         log('Error.TAmClientFileThreadUpload.UploadNewFile 2 '+e.Message);
         end;
   end;
end;
procedure  TAmClientFileThreadUpload.GetPrt(var Prt: TAmProtocolSock;Param:TamClientUploadParam);
begin
   Prt.Clear;
   Prt.TypeFile:= Param.TypeFile;
   Prt.IdFile:=   ShortString(Param.IdFile);
   Prt.Token:=    ShortString(Param.Token);
   Prt.Hash:=     ShortString(Param.Hash);
   Prt.TokenAuth:=ShortString(Param.HashFile);

end;
procedure TAmClientFileThreadUpload.Upload(Param:TamClientUploadParam);
var G:TAmChatHttpFiles;
    FsUpload:TFileStream;
    MsResult:TMemoryStream;
  //  R:boolean;
    Prt: TAmProtocolSock;
begin
  try
     if (Param.FileName='') or not  fileexists(Param.FileName) then
     begin
        Param.Result:=-999;
        Param.ErrorIsWas:=true;
        Param.ErrorMessage:= 'Не найден файл '+ExtractFileName(Param.FileName);

        log('Error.TAmClientFileThreadUpload.Upload Param.FileName нет такого файла ');
        exit;
     end;
     if  AmIsFileInUse(Param.FileName) then
     begin
        Param.Result:=-998;
        Param.ErrorMessage:= 'Файл занят '+ExtractFileName(Param.FileName);
        Param.ErrorIsWas:=true;
        log('Error.TAmClientFileThreadUpload.Upload Param.FileName файл занят другим процессом ');
        exit;
     end;
//     R:=false;
     FsUpload := TFileStream.Create(Param.FileName,fmOpenReadWrite);
     MsResult:=  TMemoryStream.Create;
     G :=TAmChatHttpFiles.Create;
     try
       try
          FParam:= Param;
          G.Host:= Param.Host;
          G.Port:=Param.Port;
          G.LogMessage:= LogMessage;
          G.EventAbort:= Param.FEventAbort.Handle;
          G.OnWorkSend:= WorkSend;
          GetPrt(Prt,Param);
          //log('TAmClientFileThreadUpload.Upload start');
          Param.Result :=G.UploadFile(Prt,FsUpload,MsResult);
         // log('TAmClientFileThreadUpload.Upload end');

          Param.JsonSring:='';
          if (Param.Result = AmPrtSockTypeFile.Json)
           and (MsResult.Size<1050*1000) then
          begin
             // R:=true;
              Param.JsonSring:= amStr(MsResult)
          end
          else
          begin
             Param.Result:=-997;
             Param.ErrorMessage:= 'Response Invalid '+ExtractFileName(Param.FileName);
             Param.ErrorIsWas:=true;
             log('Error.TAmClientFileThreadUpload.Upload result  не Json Size='+
             MsResult.Size.tostring +' Param.Result='+Param.Result.ToString);
          end;

       except
         on e :exception do
         begin
         log('Error.TAmClientFileThreadUpload.Upload 2 '+e.Message);
         Param.Result:=-996;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:= 'ErrorCode Upload2 '+e.Message;
         log('Error.TAmClientFileThreadUpload.Upload ssssssssssssss ');

         end;
       end;
     finally
       FParam:=nil;
       G.Free;
       FsUpload.Free;
       MsResult.Free;
     end;

  except
         on e :exception do
         begin
         log('Error.TAmClientFileThreadUpload.Upload '+e.Message);
         Param.Result:=-995;
         Param.ErrorIsWas:=true;
         Param.ErrorMessage:= 'ErrorCode Upload '+e.Message;

         end;
  end;

end;
function  TAmClientFileThreadUpload.CheckErrorResultUpload(Param:TamClientUploadParam):boolean;
begin
    Result:=false;
    if (Param.Result<0)  or Param.ErrorIsWas then
    begin
       Param.ErrorIsWas:=true;
       Param.ErrorMessage:='Ошибка :  ErrorClient '+Param.Result.ToString +' '+Param.ErrorMessage;

        log('TAmClientChatFilesSend.CheckErrorResultUpload result <0 '+  ' HttpResult='+Param.Result.ToString);
       Exit;
    end;

    if (Param.Result <> AmPrtSockTypeFile.Json) then
    begin
       Param.ErrorIsWas:=true;
       Param.ErrorMessage:='Ошибка : Пришел не вайлидный ответ от сервера Error:'+Param.Result.ToString +' '+Param.ErrorMessage;

        log('Error.TAmClientChatFilesSend.SendMessageWithFiles result  не Json '+
      ' HttpResult='+Param.Result.ToString);
      exit;
    end;
    Result:=true;
end;
function  TAmClientFileThreadUpload.CheckResultUpload(Param:TamClientUploadParam):boolean;
var Json:TJsonObject;
begin
   Result:=CheckErrorResultUpload(Param);
   if not Result then exit;
   if Param.JsonSring='' then
   begin
     Param.ErrorMessage:='Ошибка : Пришел пустой ответ от сервера Upload';
     Param.ErrorIsWas:=true;
     exit;
   end;

    Json:= amJson.LoadText(Param.JsonSring);
    try


      if not  Json['Response']['ResultAuth'].BoolValue
      or not  Json['Response']['Result'].BoolValue
      then
      begin
       Param.ErrorIsWas:=true;
       Param.ErrorMessage:='Ошибка : Upload '+Json['Response']['ResultMsg'].Value;

      end
      else
      begin
        Result:=true;
      end;
    finally
      Json.Free;
    end;


end;

procedure TAmClientFileThreadUpload.GetIdFilePars(Param:TamClientUploadParam;var ResultJsonString:string);
var Json:TJsonObject;
  FileGetIdParam:integer;
  procedure Local_Voice;
  begin
    Param.IdVoice:= Json['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nVoice]['Id'].Value;
  end;
  procedure Local_Zip;
  begin
    Param.IdZipFile:= Json['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nFile]['Id'].Value;
  end;
  procedure Local_Photo;
  begin
    Param.IdPhoto10:=
      Json['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nPhoto]['MiniId'].Value;

    Param.IdPhoto500:=
      Json['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nPhoto]['MaxId'].Value;

  end;
  procedure Local_PhotoAndZip;
  begin
     Local_Zip;
     Local_Photo;
  end;
begin


    Json:= amJson.LoadText(ResultJsonString);
    try
      FileGetIdParam:= AmInt(Json['Response']['FileGetIdParam']['Param'].Value,0);

       if      FileGetIdParam = ConstAmChat.FileGetIdParam.Voice then       Local_Voice
       else if FileGetIdParam = ConstAmChat.FileGetIdParam.Zip then         Local_Zip
       else if FileGetIdParam = ConstAmChat.FileGetIdParam.Photo then       Local_Photo
       else if FileGetIdParam = ConstAmChat.FileGetIdParam.PhotoAndZip then Local_PhotoAndZip

    finally
      Json.Free;
    end;
end;



end.
