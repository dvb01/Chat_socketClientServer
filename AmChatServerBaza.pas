unit AmChatServerBaza;


interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,AmChatCustomSocket,Winapi.WinSock,AmLIst,
  JsonDataObjects,SyncObjs,IOUtils,AmUserType,AmLogTo,AmChatServerBazaHelpType,
  RegularExpressions,IdCoderMIME,IdCoder,AmMultiSockTcpCustomPrt,DateUtils,
  System.Zip,AmHandleObject,
  System.Generics.Collections;

   type
    TMessageVoiceParam = record
      VoiceId,
      VoiceSpectrJson,
      VoiceLength,
      VoiceCaption,
      VoiceTimerSecond :string;
    end;
   type
    TMessageFileNameParam  = record
      FileName:string;
      Size:String;
      Rect:string;
    end;

    TMessageFileParam =record
              Id_Photo10:string;
              Id_Photo500:string;
              Id_File:string;
              Comment:string;
              CollageSizeMax:string;
              CollageCountFile:string;
              ListFileOther:AmList.TamListVar<TMessageFileNameParam>;
              ListFilePhoto:AmList.TamListVar<TMessageFileNameParam>;
    end;

   type
    TAmChatServerBaza = class




    private
      FDir:string;
      FDirPhotos:string;
      FDirFiles:string;
      FDirFilesTime:string;
      FDirVoice:string;
      FDirMessageUser:string;
      FDirMessageGroop:string;
      FnListUser:string;
      FnListRoom:string;
      FnListUsersScreenName:string;
      FnListUsersName:string;
      FnListGroopScreenName:string;
      FnListGroopName:string;
      FCs : tevent;

      Bh:TAmBth;


      ObjUsers:Tjsonobject; //сортированный по id  тип поиска step min max
      ListUsersScreenName:TamStringList;//сортированный по ScreenName     ScreenName:id   тип поиска bin
      ListUsersName:TamStringList;  //сортированный по UserName           UserName:id     тип поиска bin




      ObjGroops:Tjsonobject; //сортированный по id  тип поиска step min max
      ListGroopScreenName:TamStringList;//сортированный по ScreenName     ScreenName:id   тип поиска bin
      ListGroopName:TamStringList;  //сортированный по UserName           UserName:id     тип поиска bin

      //меняется каждыйй раз как приходит запрос от какого пользователя что она была одинаковой пока выполняется код
      FClientPort:integer;
      FClientIndexPort:integer;
      FClientDataNow:string;



      {Help procedure редактирование инфы как правило они использую функции которые выше}
    //   function Help_ContactAdd(ObjectUser:TjsonObject;IdUserAdd:string):boolean;//true если был добавлен и раньше не был в контактах



      function GetClientIndexPort:integer;
      property ClientPort:integer read FClientPort;
      property ClientIndexPort:integer read GetClientIndexPort;
      property ClientDataNow:string read FClientDataNow;
      //>>>>>>>>>>>>>>>>>> приходят заросы от юзера
      {Set TypeOnline}

      //когда сворачиваем программу или помещаем в трей или выходим но соединение остается
      // или просто установка только статуса
      function SVR_TypeOnline(Token,Hash,TypeOnline:string):TAmBth.TMainResult;

      // когда покидаем акк и показывается форма входа логин пароль войти
      function SRV_LogOutAcc(Token,Hash,aId:string):TAmBth.TMainResult;

      // запускаю когда клиент неожиданно разъединился
      function SRV_LogOutPort(TypeOnline:string):TAmBth.TMainResult;

      // для выше указаных формирует список кому нужно отправить что статус изменился
      function SRV_SetTypeOnline(aId:String;TypeOnline:string):TAmBth.TMainResult;

      // переодичеки присылается что бы поддерживать конект при простое
      function SVR_UpConnect(ConnectValue:string):TAmBth.TMainResult;
      {RegUser}
      function SVR_RegUser(ScreenName,Password,Password2,Email,UserName:string):TAmBth.TMainResult;
      function RegUser_CheckScreenName(ScreenName:string):boolean;
      function RegUser_CheckEmail(Email:string):boolean;
      function RegUser_CheckPassword(Password,Password2:string):boolean;
      function RegUser_CheckUserName(UserName:string):boolean;
      function RegUser_AddToListUser(ScreenName,Password,Email,UserName:string):string;//id нового пользователя


      {AuthUser}
      function SVR_Auth(Token,ScreenName,Password,PredId:string):TAmBth.TMainResult;
      procedure SetListAvtivPortForSendOthers(var ListPort:TAmBth.TMainResult.TListPort;IndexNowAcc:integer);
      function Auth_Check(var IndexAcc:integer;Token,Hash:string):boolean;
      function Auth_Token(var Index:integer;Token:string):boolean;
      function Auth_Param(var Index:integer;ScreenName,Password:string;aPreId:string):boolean;
      function Auth_GetNewToken(index:integer):string;
      function Auth_GetNewHash(index:integer):string;
      function Auth_CheckHashFile(HashFile:string):integer;


      function DoActivSens(TokenUser,HashUser,LParamPot,Indiv:string;InputObj:TjsonObject;Proc:TAmBth.TActivSeansProc):TAmBth.TMainResult;
      {ProfileUser}
     // function  SaveStreamUserDisk(FullNameFile:string;MStream:TMemoryStream):boolean;
      //function  LoingStreamUserDisk(FullNameFile:string;MStream:TMemoryStream):boolean;


      {PhotoUpload}
      procedure SVR_File_GetIdBeforeUpload (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      procedure SVR_SetPhotoProfile(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

    //  procedure SVR_GetIdFileUpload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
     // procedure SVR_NewPhotoUpload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      //function  SavePhotoUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
    //  function  LoingPhotoUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
     // function  SaveVoiceUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
      //function  LoingVoiceUserDisk(NameFile:string;MStream:TMemoryStream):boolean;

      {Contacts}
      procedure SVR_Contacts_GetList(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      function  Contacts_Add(ObjAcc:TjsonObject;TypeUser:string;IdUserAdd:string):TjsonObject; //ContactAdd
      function  Contacts_Delete(ObjAcc:TjsonObject;TypeUser:string;IdUserDelete:string):boolean;
      procedure SVR_ContactDelete (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

      {User}
   //   procedure SVR_User_PhotoDownload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

      {Message}
      //юзер комуто отправляет сообщение
      procedure SVR_Message_UserSend(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

      function UserSend_VoiceSave(IndexAcc:integer;ObjAcc:TjsonObject;UserId:string;ContentJson:string;var MessageVoiceParam:TMessageVoiceParam):boolean;
      procedure UserSend_FilesPars(ContentJson:string;var MessageFileParam:TMessageFileParam);

      procedure SVR_Message_History(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      procedure SVR_Message_History_Offset(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);


      procedure SVR_Message_Read (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
     // procedure SVR_Voice_Download (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);


      {Others}
//       procedure Others_UserOnline (ResponseOthers:TjsonObject);
//       procedure Others_GetListAcvtivPort (var List:TMainResult.TListPort);
      procedure SVR_Serch (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      procedure Serch_ScreenName(IdNowUser,SerchSours:string; ResponseSerch:TjsonObject);
      Function  ListUsersScreenName_Add(ScreenName,Id:string):boolean;
     // Function  ListScreenName_IndexOfBin(ListTxt:TStringList;sh:string;MaxIndex:boolean):integer;
      //Function  ListGroopScreenName_Add(ScreenName,Id:string):boolean;
     // Function  ListGroopScreenName_IndexOfBin(ListTxt:TStringList;sh:string;MaxIndex:boolean):integer;

      function  Groop_CheckPrava(IndexGr,IndexUser:integer;IdGroop,IdUser,WhatFun:string):boolean;
      procedure SVR_Groop_Create(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      function  Groop_Create_CheckScreenName(ScreenName:string):boolean;
      function  Groop_Create_CheckName(Name:string):boolean;
      procedure Groop_AddList(var OutIndex:integer;var OutId:integer; ScreenName,Name:String;IdUserAdmin,TypeGroopPrivacy:string);
      procedure SVR_Groop_AddUser(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

      procedure SVR_Groop_DeleteUser(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      procedure SVR_Groop_GetListUsers(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);



      procedure SVR_Groop_SetPhoto(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
      procedure SVR_Groop_SetUserName(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);



    public
      ListActiv:TAmBth.TListActiv;

      procedure Lock;
      procedure Unlock;
      // подключается на собиытии сокета OnDiconnect
      function Diconnect(Port,IndexPort:integer):TAmBth.TMainResult;

       // главная обработка входящих  запросов  подключается на собиытии сокета OnRead
      function Pars(Port:integer;Input:string;ResultRead:boolean):TAmBth.TMainResult;


      // юзер пытается загрузить файл перед началом загрузки
      function ParsBeforeUpload(Port,TypeFile{AmPrtSockTypeFile}:integer;IdFile,Token,Hash,HashFile:string):TAmBth.TMainResult;

      function ParsAfterUpload(Port,TypeFile{AmPrtSockTypeFile}:integer;IdFile:string;ResultRead:boolean):TAmBth.TMainResult;
      // юзер прислал запрос на скачивание файла обратно ожидает получить файл или stream памяти
      function ParsDonwload(Port:integer ;JsonString:string; var PrtOut:TAmProtocolSock;ResultRead:boolean):TAmBth.TMainResult;






      constructor Create();
      destructor Destroy; override;

    end;


implementation
//uses UnitServer;


procedure TAmChatServerBaza.Lock;
begin
 FcS.WaitFor(infinite);
end;
procedure TAmChatServerBaza.Unlock;
begin
  FcS.SetEvent;
end;

function TAmChatServerBaza.ParsAfterUpload(Port,TypeFile{AmPrtSockTypeFile}:integer;IdFile:string;ResultRead:boolean):TAmBth.TMainResult;
var val:string;


    function OutMsg(val:boolean):string;
    var HobInput:Tjsonobject;
    begin
        HobInput:=   Tjsonobject.Create;
        try
         HobInput['Response']['Idmsg'].IntValue:=  ConstAmChat.File_Upload_Back;
        // HobInput['Response']['LParamPot'].Value:=  LParamPot;
         //HobInput['Response']['Indiv'].Value:=  Indiv;
         HobInput['Response']['Result'].BoolValue:= val;
         HobInput['Response']['ResultAuth'].BoolValue:= true;
         HobInput['Response']['IdFile'].Value:= IdFile;

         if val then
         HobInput['Response']['ResultMsg'].Value:= 'Файл загружен'
         else
         HobInput['Response']['ResultMsg'].Value:= 'Не удалось загрузить Файл ощибка приема данных';

         Result:=   HobInput.ToJSON();
        finally
           HobInput.Free;
        end;
    end;
begin
   FClientPort:=Port;
   FClientDataNow  :=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);
   try
        try

            Result.Clear;
            Result.Result:=true;
            Result.IsSendUser:=true;
            Result.IsJsonSend:=true;
            Result.TextOutputUser:= OutMsg(ResultRead);

        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.ParsAfterUpload ',self,e,true);
        end;
   finally
   FClientPort:=-1;
   FClientDataNow  :='';
   FClientIndexPort:=-1;
   end;

end;
function TAmChatServerBaza.ParsBeforeUpload(Port,TypeFile{AmPrtSockTypeFile}:integer;IdFile,Token,Hash,HashFile:string):TAmBth.TMainResult;
var r:integer;
  Procedure OutError(indexError:integer);
  begin

     Result.TextOutputUser:= Bth_FileErrorAddResultMsg(
                                        Result.TextOutputUser,
                                        indexError,' TypeFile='+TypeFile.ToString+ ' IdFile='+IdFile
     );

  end;
begin

   FClientPort:=Port;
   FClientDataNow  :=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);
   try
        Result.Clear;
        Result.IsSendUser:=true;
        Result.IsJsonSend:=true;
        Result.TextOutputUser:='{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
        Result.ListPort.Clear;

        try

            Result:=DoActivSens(Token,Hash,'','',nil,nil);
            if Result.Result then
            begin

              if Bth_CheckIdFileValid(IdFile) then
              begin
              //   r:=Auth_CheckHashFile(HashFile);
                  r:=1;
                 if r=1 then
                 begin
                    if TypeFile = AmPrtSockTypeFile.Image then
                    begin
                       if not  fileexists(FDirPhotos+''+IdFile+ConstAmChat.NameFileType.ePhotoExt)or true  then
                       begin
                         Result.Result:=true;
                         Result.IsSendUser:=false;
                         Result.IsJsonSend:=false;
                         Result.FileNameFN:= FDirPhotos+''+IdFile+ConstAmChat.NameFileType.ePhotoExt;

                       end
                       else OutError(ConstAmChat.FileError.uUseFile);
                    end
                    else if TypeFile = AmPrtSockTypeFile.Voice then
                    begin

                       if not  fileexists(FDirVoice+''+IdFile+ConstAmChat.NameFileType.eVoiceExt) or true then
                       begin
                         Result.Result:=true;
                         Result.IsSendUser:=false;
                         Result.IsJsonSend:=false;
                         Result.FileNameFN:= FDirVoice+''+IdFile+ConstAmChat.NameFileType.eVoiceExt;
                       end
                       else OutError(ConstAmChat.FileError.uUseFile);

                    end
                    else if TypeFile = AmPrtSockTypeFile.Zip then
                    begin

                       if not  fileexists(FDirFiles+''+IdFile+ConstAmChat.NameFileType.eFilesExt) or true then
                       begin
                         Result.Result:=true;
                         Result.IsSendUser:=false;
                         Result.IsJsonSend:=false;
                         Result.FileNameFN:= FDirFiles+''+IdFile+ConstAmChat.NameFileType.eFilesExt;
                       end
                       else OutError(ConstAmChat.FileError.uUseFile);

                    end
                    else   OutError(ConstAmChat.FileError.uTypeFile);
                 end
                 else if r=-1 then OutError(ConstAmChat.FileError.uHashFile)
                 else if r=-2 then OutError(ConstAmChat.FileError.uHashFileData)
                 else              OutError(ConstAmChat.FileError.uHashFileNull);


{
    Result:= 0;
    D:=ListUser['Data']['HashFiles'][HashFile].Value;
    if (D='') then exit(-1);
    if now < IncHour(AmDateTime(D,'01.01.2000 20:35:49:254'),1) then exit(1)
    else Result:=-2;

}

              end
              else OutError(ConstAmChat.FileError.uIdFile);

            end;






                      {

                      idmsg:=HobInput['Response']['Idmsg'].IntValue;
                      case idmsg of




                          ConstAmChat.User_PhotoDownload_Call :
                          begin
                             HelpObj:= HobInput['Response']['User']['PhotoDownload'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_User_PhotoDownload
                                                     );
                          end;


                          ConstAmChat.Voice_Download_Call:
                          begin

                             HelpObj:= HobInput['Response']['Voice'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Voice_Download
                                                     );

                          end;
                      end;

                      }

        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.ParsBeforeUpload ',self,e,true);
        end;
     //sleep(12999);
   finally
   FClientPort:=-1;
   FClientDataNow  :='';
   FClientIndexPort:=-1;
   end;

end;
function TAmChatServerBaza.ParsDonwload(Port:integer ;JsonString:string; var PrtOut:TAmProtocolSock; ResultRead:boolean):TAmBth.TMainResult;
var HobInput,HelpObj:Tjsonobject;
idmsg:integer;
Token,Hash,IdFile,Fn,FileNameDownload:string;

  Procedure OutError(indexError:integer);
  begin

     Result.TextOutputUser:= Bth_FileErrorAddResultMsg(
                                        Result.TextOutputUser,
                                        indexError,' TypeFile='+PrtOut.TypeFile.ToString+ ' IdFile='+IdFile
     );

  end;
  function CheckZipFile(FnZip,FnSerch:string):boolean;
   var Zip: TZipFile;
  begin
      Zip:=TZipFile.Create;
      try
        Zip.Open(FnZip,zmRead);
        Result:= Zip.IndexOf(FnSerch)>=0;
        Zip.Close;
      finally
        Zip.Free;
      end;
  end;
begin
   FClientPort:=Port;
   FClientDataNow  :=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);
   try



        if not ResultRead then
        begin
           OutError(11);
           exit;
        end;
        Result.Clear;
        Result.IsSendUser:=true;
        Result.IsJsonSend:=true;
        Result.TextOutputUser:='{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
        Result.ListPort.Clear;

        try
          HobInput:=   amJson.LoadObjectText(JsonString);
          try
            Token:=                HobInput['Response']['Token'].Value;
            Hash:=                 HobInput['Response']['Hash'].Value;
            FileNameDownload:=     HobInput['Response']['FileName'].Value;
            Result:=DoActivSens(Token,Hash,AmStr(PrtOut.IdThread),string(PrtOut.InDiv),nil,nil);
            if Result.Result then
            begin
              IdFile:=string( PrtOut.IdFile );
            //  IdFile:='';
              if Bth_CheckIdFileValid(IdFile) then
              begin
                  if PrtOut.TypeFile = AmPrtSockTypeFile.Image then
                  begin
                    Fn:= FDirPhotos+''+IdFile+ConstAmChat.NameFileType.ePhotoExt;
                    if  fileexists(Fn)  then
                    begin
                        if  AmFileIsFreeRead(Fn) then
                        begin
                            Result.IsJsonSend:=false;
                            Result.CmdFN:=2;
                            Result.FileNameFN:= Fn;

                        end
                        else OutError(ConstAmChat.FileError.dUseFile);
                    end
                    else OutError(ConstAmChat.FileError.dNotFile);






                  end
                  else if PrtOut.TypeFile = AmPrtSockTypeFile.Voice then
                  begin
                    Fn:= FDirVoice+''+IdFile+ConstAmChat.NameFileType.eVoiceExt;

                    if  fileexists(Fn)  then
                    begin
                        if AmFileIsFreeRead(Fn) then
                        begin
                            Result.IsJsonSend:=false;
                            Result.CmdFN:=2;
                            Result.FileNameFN:= Fn;
                        end
                        else OutError(ConstAmChat.FileError.dUseFile);
                    end
                    else OutError(ConstAmChat.FileError.dNotFile);



                  end
                  else if PrtOut.TypeFile = AmPrtSockTypeFile.Zip then
                  begin
                    Fn:= FDirFiles+''+IdFile+ConstAmChat.NameFileType.eFilesExt;

                    if  fileexists(Fn)  then
                    begin
                        if AmFileIsFreeRead(Fn) then
                        begin
                          logmain.Log(FileNameDownload);
                           if CheckZipFile(Fn,FileNameDownload) then
                           begin

                            Result.IsJsonSend:=false;
                            Result.CmdFN:=2;
                            Result.FileNameFN:= Fn;
                            Result.FileNameFNZipIndex:=FileNameDownload;
                            Result.DirFNTime:=FDirFilesTime;
                           end
                           else
                           begin
                             OutError(ConstAmChat.FileError.dNotSerchFile);
                           end;
                        end
                        else OutError(ConstAmChat.FileError.dUseFile);
                    end
                    else OutError(ConstAmChat.FileError.dNotFile);



                  end
                  else  OutError(ConstAmChat.FileError.dTypeFile);
              end
              else OutError(ConstAmChat.FileError.dIdFile);

            end;
              





                      {

                      idmsg:=HobInput['Response']['Idmsg'].IntValue;
                      case idmsg of




                          ConstAmChat.User_PhotoDownload_Call :
                          begin
                             HelpObj:= HobInput['Response']['User']['PhotoDownload'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_User_PhotoDownload
                                                     );
                          end;


                          ConstAmChat.Voice_Download_Call:
                          begin

                             HelpObj:= HobInput['Response']['Voice'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Voice_Download
                                                     );

                          end;
                      end;

                      }
          finally
            HobInput.Free;
          end;
        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.ParsDonwload ',self,e,true);
        end;
   finally
   FClientPort:=-1;
   FClientDataNow  :='';
   FClientIndexPort:=-1;
   end;
end;
   {
procedure TAmChatServerBaza.SVR_User_PhotoDownload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var
Stream:TMemoryStream;
PhotoBase64:string;
PhotoData,PhotoId:string;
begin
     IsSendOthers:=false;
     PhotoBase64:='';
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.User_PhotoDownload_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;
     Stream:= TMemoryStream.Create;
     try

        PhotoId:=InputObj['PhotoId'].Value;

       if fileexists(FDirPhotos+PhotoId+'.jpg') then
       begin

        if  LoingPhotoUserDisk(PhotoId+'.jpg',Stream)
        and AmBase64.StreamToBase64(Stream,PhotoBase64)
         then
        begin
                PhotoData:=ListUser['Data']['Photos'][PhotoId].Value;
                if PhotoData='' then
                begin
                  ListUser['Data']['Photos'][PhotoId].Value:= ClientDataNow;
                  PhotoData:=ListUser['Data']['Photos'][PhotoId].Value;
                end;

                ResponseUser['Response']['Result'].BoolValue:= true;
                ResponseUser['Response']['ResultMsg'].Value:= 'Фото получено';
                ResponseUser['Response']['PhotoId'].Value:= PhotoId;
                ResponseUser['Response']['PhotoData'].Value:= PhotoData;
                ResponseUser['Response']['PhotoBase64'].Value:= PhotoBase64;

        end
        else ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить фото на сервере';
       end
       else ResponseUser['Response']['ResultMsg'].Value:= 'Нет файла фото на сервере '+PhotoId;



     finally
       Stream.Free;
     end;


end; }
function TAmChatServerBaza.DoActivSens(TokenUser,HashUser,LParamPot,Indiv:string;InputObj:TjsonObject;Proc:TAmBth.TActivSeansProc):TAmBth.TMainResult;
var
    ResponseUser,ResponseOthers:Tjsonobject;
    RAuth:boolean;
    Index:integer;
begin
    Result.IsSendUser:=true;
    Result.TextOutputUser:='{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerAuth"}}';
    Result.IsSendOthers:=false;
    Result.TextOutputOthers:= '{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerAuth"}}';
    Result.ListPort.Clear;
    ResponseUser:= Tjsonobject.Create;
    ResponseOthers:= Tjsonobject.Create;


    try
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Auth_ActivSeans_Back;
         ResponseUser['Response']['LParamPot'].Value:=  LParamPot;
         ResponseUser['Response']['Indiv'].Value:=  Indiv;
         RAuth:=Auth_Check(Index,TokenUser,HashUser);
         Result.Result:= RAuth;
         if  RAuth then
         begin

           ResponseUser['Response']['Result'].BoolValue:= false;
           ResponseUser['Response']['ResultAuth'].BoolValue:= true;
           ResponseOthers['Response']['ResultAuth'].BoolValue:= true;
           if Assigned(Proc) then
           Proc(Index,ObjUsers['Data']['List'].Items[Index],InputObj,ResponseUser,ResponseOthers,Result.IsSendOthers,Result.ListPort);
         end
         else
         begin
            ResponseUser['Response']['Result'].BoolValue:= false;
            ResponseUser['Response']['ResultAuth'].BoolValue:= false;
            ResponseUser['Response']['ResultMsg'].Value:= 'Требуется авторизация';

         end;




         Result.TextOutputUser:= ResponseUser.ToJSON();
         Result.TextOutputOthers:= ResponseOthers.ToJSON();
    finally
     ResponseUser.Free;
     ResponseOthers.Free;
    end;
end;

function TAmChatServerBaza.Pars(Port:integer;Input:string;ResultRead:boolean):TAmBth.TMainResult;
var HobInput,HelpObj:Tjsonobject;
idmsg:integer;
begin




   FClientPort:=Port;
   FClientDataNow  :=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);
   try
  {  try
    LocalInput:=ListActiv.BufferText[FPortUser]+Input;
    WholePackage:= CustomSocketCheckWholePackage2(LocalInput,ConstAmChat.WordBegin,ConstAmChat.WordEnd);
    ListActiv.BufferText[FPortUser]:=LocalInput;
    ResultWholePackage:= Length(WholePackage)>0;
    except

       ResultWholePackage:=false;
    end;
    }
   //  LogMain.Log('BufferText='+LocalInput);

     // Setlength(Result,length(WholePackage));
      // LogMain.Log('LocalInput='+ListActiv.BufferText[FPortUser]);



        Result.Clear;
        Result.IsSendUser:=true;
        Result.IsJsonSend:=true;
        Result.TextOutputUser:='{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars ошибка чтения"}}';
        Result.IsSendOthers:=false;
        Result.TextOutputOthers:= '{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
        Result.ListPort.Clear;
        if not  ResultRead then exit;
        

        try

          HobInput:= Tjsonobject.Parse(Input) as Tjsonobject ;
          try

                      idmsg:=HobInput['Response']['Idmsg'].IntValue;
                      case idmsg of





                          ConstAmChat.UpConnect_Call :
                          begin

                             Result:=SVR_UpConnect(HobInput['Response']['UpConnect']['ConnectValue'].Value);
                          end;

                          ConstAmChat.RegUser_Call :
                          begin
                             HelpObj:= HobInput['Response']['RegUser'];
                             Result:=SVR_RegUser(HelpObj['ScreenName'].Value,HelpObj['Password'].Value,HelpObj['Password2'].Value,HelpObj['Email'].Value,HelpObj['UserName'].Value);
                          end;
                          ConstAmChat.Auth_Call :
                          begin

                             HelpObj:= HobInput['Response']['Auth'];
                             Result:=SVR_Auth(HelpObj['Token'].Value,HelpObj['ScreenName'].Value,HelpObj['Password'].Value,HelpObj['Id'].Value );

                          end;
                         ConstAmChat.SetPhotoProfile_Call :
                          begin
                             HelpObj:= HobInput['Response']['Profile'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_SetPhotoProfile
                                                     );
                          end;


                         ConstAmChat.File_GetIdBeforeUpload_Call :
                          begin
                             HelpObj:= HobInput['Response']['FileGetIdParam'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_File_GetIdBeforeUpload
                                                     );
                          end;

                         {
                          ConstAmChat.User_PhotoDownload_Call :
                          begin
                             HelpObj:= HobInput['Response']['User']['PhotoDownload'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_User_PhotoDownload
                                                     );
                          end;}

                          ConstAmChat.Profile_GetListContacts_Call :
                          begin
                             HelpObj:= HobInput['Response']['Call'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Contacts_GetList
                                                     );
                          end;

                          ConstAmChat.Message_Send_Call :
                          begin
                             HelpObj:= HobInput['Response']['Message'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Message_UserSend
                                                     );
                          end;

                          ConstAmChat.Message_History_Call :
                          begin
                             HelpObj:= HobInput['Response']['Message'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Message_History_Offset
                                                     );
                          end;

                          ConstAmChat.Message_Read_Call :
                          begin
                             HelpObj:= HobInput['Response']['Message'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Message_Read
                                                     );
                          end;

                          ConstAmChat.OnlineType_Call :
                          begin

                             Result:= SVR_TypeOnline(
                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['Online']['TypeOnline'].Value
                             );

                          end;
                          ConstAmChat.LogOut_Call :
                          begin

                             Result:= SRV_LogOutAcc(
                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['Id'].Value
                             );

                          end;

                         { ConstAmChat.Voice_Download_Call:
                          begin

                             HelpObj:= HobInput['Response']['Voice'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,
                                                      HelpObj,
                                                      SVR_Voice_Download
                                                     );

                          end; }
                           ConstAmChat.Serch_Call :
                          begin
                             HelpObj:= HobInput['Response']['Serch'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Serch
                                                     );
                          end;



                           ConstAmChat.GroopCreate_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_Create
                                                     );
                          end;
                           ConstAmChat.Groop_GetListUsers_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_GetListUsers
                                                     );
                          end;
                           ConstAmChat.GroopAddUser_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_AddUser
                                                     );
                          end;
                           ConstAmChat.GroopDeleteUser_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_DeleteUser
                                                     );
                          end;
                           ConstAmChat.Groop_SetPhoto_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_SetPhoto
                                                     );
                          end;
                           ConstAmChat.Groop_SetUserName_Call :
                          begin
                             HelpObj:= HobInput['Response']['Groop'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_Groop_SetUserName
                                                     );
                          end;
                           ConstAmChat.Profile_DeleteContacts_Call :
                          begin
                             HelpObj:= HobInput['Response']['Contact'];
                             Result:= DoActivSens(

                                                      HobInput['Response']['Token'].Value,
                                                      HobInput['Response']['Hash'].Value,
                                                      HobInput['Response']['LParamPot'].Value,
                                                      HobInput['Response']['Indiv'].Value,

                                                      HelpObj,
                                                      SVR_ContactDelete
                                                     );
                          end;


                      end;


          finally
            HobInput.Free;
          end;
        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.Pars ',self,e,true);
        end;

   finally
   FClientPort:=-1;
   FClientDataNow  :='';
   FClientIndexPort:=-1;
   end;


end;
procedure TAmChatServerBaza.SVR_Groop_GetListUsers(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var PhotoId:string;
    GroopId:string;
    UserId:string;
    Fn:string;
    IndexGroop:integer;
    MsgHistory:TJsonObject;
   // CountUserGroop:integer;
    MsgHistroryIndex:integer;


     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Groop_GetListUsers_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin

           ResponseUser['Response']['Groop']['GroopId'].Value :=GroopId;
         end;

     end;

     procedure Local_UsersList;
        type
         TRec = record
           Id:string;
           TypeOnline:string;
         end;
         procedure Local2_ListGrow(L:TList<TRec>);
         var Hob:TJsonObject;
             Arr:TJsonArray;
             i,index:integer;
             AId:string;
         begin
            ResponseUser['Response']['Groop']['GroopId'].Value:=GroopId;
            Arr:= ResponseUser['Response']['Groop'].A['List'];

            for I := 0 to L.Count-1 do
            begin
               AId:= L[i].Id;
               index:= Bh.SerchUser_Id(AId,AId);
               if index>=0 then
               begin
                 Hob:=Arr.AddObject;
                 Hob['Id'].Value:=                     L[i].Id;
                 Hob['TypeOnline'].Value:=             L[i].TypeOnline;
                 Hob['TypeUser'].Value:=               ConstAmChat.TypeUser.User;
                 Hob['ScreenName'].Value:=             Bh.GetUser_index(index,'ScreenName');
                 Hob['UserName'].Value:=               Bh.GetUser_index(index,'UserName');
                 Hob['Photos']['MainId'].Value:=       Bh.GetUser_index2(index,'Photos','MainId');
               //  Hob['Photos']['MainData'].Value:=     Bh.GetUser_index2(index,'Photos','MainData');
               end;

            end;
              

         end;

     var Count,i,index:integer;
     Arr:TJsonArray;
     var ListOn:TList<TRec>;
         ListOf:TList<TRec>;
     Rec:TRec;
     begin
         Arr:= MsgHistory['Data']['ListUser'].A['array'];
         ListOn:= TList<TRec>.create;
         ListOf:= TList<TRec>.create;
         try
             count:=Arr.Count;
             for I := 0 to count-1 do
             begin
                index:= ListActiv.SerchId(Arr[i]);
                if index>=0 then
                begin
                   Rec.Id:=Arr[i];
                   Rec.TypeOnline:= ListActiv.List[index].TypeOnline;
                   ListOn.Add(Rec);
                end
                else
                begin
                   Rec.Id:=Arr[i];
                   Rec.TypeOnline:= ConstAmChat.TypeOnline.Offline;
                   ListOf.Add(Rec);
                end;
             end;
             Local2_ListGrow(ListOn);
             Local2_ListGrow(ListOf);


         finally
            ListOf.Free;
            ListOn.Free;
         end;
     end;
begin
       UserId:=  Bh.GetUser_index(IndexAcc,'Id');
       GroopId:= InputObj['GroopId'].Value;

       IndexGroop:= Bh.SerchGroop_Pole('Id',GroopId,GroopId);
       if IndexGroop<0 then
       begin
        Local_Response_User(false,'Не найдена такая группа');
        exit;
       end;
       if Groop_CheckPrava(IndexGroop,IndexAcc,GroopId,UserId,'ListUsers') then
       begin
         MsgHistory:= amJson.LoadObjectFile(FDirMessageGroop+'message_'+ GroopId +'_.json');
         try
             //untUserGroop:=MsgHistory['Data']['ListUser']['array'].Count;
             Local_UsersList;
             Local_Response_User(True,'Список участников');
         finally
          MsgHistory.Free;
         end;
       end
       else Local_Response_User(false,'Нет прав на выполнение этой операции');

end;
procedure TAmChatServerBaza.SVR_Groop_AddUser(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var PhotoId:string;
    GroopId:string;
    UserId,AddUserId:string;
    Fn:string;
    IndexGroop:integer;
    IndexAddUserId:integer;
    MsgHistory:TJsonObject;
   // CountUserGroop:integer;
    MsgHistroryIndex:integer;
    ObjContactAdd:TJsonObject;

     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.GroopAddUser_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin
           ResponseUser['Response']['Groop']['AddUserId'].Value:= AddUserId;
           ResponseUser['Response']['Groop']['GroopId'].Value :=GroopId;
         end;
         
     end;

     procedure Local_Response_Others;
     var Count:integer;
     CounterLocalId:string;
     begin


         ResponseOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.Profile_NewContacts_Back;
         ResponseOthers['Response']['Result'].BoolValue:= true;
         ResponseOthers['Response']['ResultMsg'].Value:= 'Новый контакт';
         // Копируем сообщение

         ResponseOthers['Response']['Contact']['Id'].Value:=                     GroopId;
         ResponseOthers['Response']['Contact']['TypeUser'].Value:=               ConstAmChat.TypeUser.Groop;
         ResponseOthers['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexGroop,'ScreenName');
         ResponseOthers['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexGroop,'UserName');
         ResponseOthers['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexGroop,'Photos','MainId');
         ResponseOthers['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexGroop,'Photos','MainData');


         Count:= MsgHistory['Data']['Msg'].Count;
         if Count>0 then
         begin
            ResponseOthers['Response']['Contact']['LastActivData'].Value:=
            MsgHistory['Data']['Msg'].Items[Count-1]['Data'].Value;

            ObjContactAdd['LastActivData'].Value:=
            MsgHistory['Data']['Msg'].Items[Count-1]['Data'].Value;

            CounterLocalId:=AmStr(AmInt(MsgHistory['Data']['CounterLocalId'].Value,0));

            ResponseOthers['Response']['Contact']['Message']['LastId'].Value:=  CounterLocalId;
            ObjContactAdd['Message']['LastId'].Value:=CounterLocalId;
            ResponseOthers['Response']['Contact']['Message']['ReadLastLocalIdMy'].Value:=CounterLocalId;
            ObjContactAdd['Message']['ReadLastLocalIdMy'].Value:=CounterLocalId;
         end
         else
         begin
            ResponseOthers['Response']['Contact']['LastActivData'].Value:='';
            ResponseOthers['Response']['Contact']['Message']['LastId'].Value:='0';
            ResponseOthers['Response']['Contact']['Message']['ReadLastLocalIdMy'].Value:='0';
         end;




     end;
begin
       UserId:=  Bh.GetUser_index(IndexAcc,'Id');
       GroopId:= InputObj['GroopId'].Value;
       AddUserId:= InputObj['AddUserId'].Value;
       IndexGroop:= Bh.SerchGroop_Pole('Id',GroopId,GroopId);
       if IndexGroop<0 then
       begin
        Local_Response_User(false,'Не найдена такая группа');
        exit;
       end;




       if Groop_CheckPrava(IndexGroop,IndexAcc,GroopId,UserId,'AddUser') then
       begin
         IndexAddUserId:= Bh.SerchUser_Pole('Id',AddUserId,AddUserId);
         if IndexAddUserId>=0 then
         begin
               MsgHistory:= amJson.LoadObjectFile(FDirMessageGroop+'message_'+ GroopId +'_.json');
               try
                   //untUserGroop:=MsgHistory['Data']['ListUser']['array'].Count;


                   MsgHistroryIndex:=Bh.MessageHistory_UserAdd(MsgHistory,AddUserId);
                   if MsgHistroryIndex>=0 then
                   begin


                           //добавление в базу новового контакта
                           ObjContactAdd:=Contacts_Add(   ObjUsers['Data']['List'].Items[IndexAddUserId],
                                                          ConstAmChat.TypeUser.Groop,GroopId);
                           Local_Response_Others;
                           MsgHistory.SaveToFile(FDirMessageGroop+'message_'+ GroopId +'_.json');
                           Local_Response_User(True,'Добавлен юзер в группу');
                           IsSendOthers:=Bh.GetListActivPort_O(ListActiv,AddUserId,ListSendPort);
                   end
                   else Local_Response_User(false,'Юзер уже состоит в группе');

               finally
                MsgHistory.Free;
               end;

         end
         else Local_Response_User(false,'Не найден юзер');

       end
       else Local_Response_User(false,'Нет прав на выполнение этой операции');







end;


procedure TAmChatServerBaza.SVR_Groop_DeleteUser(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var
    GroopId:string;
    UserId,DeleteUserId:string;
   // Fn:string;
    IndexGroop:integer;
    IndexAddUserId:integer;
    MsgHistory:TJsonObject;
   // CountUserGroop:integer;
    MsgHistroryIndex:integer;


     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.GroopDeleteUser_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin
           ResponseUser['Response']['Groop']['DeleteUserId'].Value:= DeleteUserId;
           ResponseUser['Response']['Groop']['GroopId'].Value :=GroopId;
         end;

     end;

     procedure Local_Response_Others;
     begin


         ResponseOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.Profile_DeleteContacts_Back;
         ResponseOthers['Response']['Result'].BoolValue:= true;
         ResponseOthers['Response']['ResultMsg'].Value:= 'Удален контакт';
         // Копируем сообщение

         ResponseOthers['Response']['Contact']['Id'].Value:=                     GroopId;
         ResponseOthers['Response']['Contact']['TypeUser'].Value:=               ConstAmChat.TypeUser.Groop;
         ResponseOthers['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexGroop,'ScreenName');
         ResponseOthers['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexGroop,'UserName');


        // ResponseOthers['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexGroop,'Photos','MainId');
        // ResponseOthers['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexGroop,'Photos','MainData');







     end;
begin
       UserId:=  Bh.GetUser_index(IndexAcc,'Id');
       GroopId:= InputObj['GroopId'].Value;
       DeleteUserId:= InputObj['DeleteUserId'].Value;
       IndexGroop:= Bh.SerchGroop_Pole('Id',GroopId,GroopId);
       if IndexGroop<0 then
       begin
        Local_Response_User(false,'Не найдена такая группа');
        exit;
       end;
       if Groop_CheckPrava(IndexGroop,IndexAcc,GroopId,UserId,'DeleteUser') then
       begin
         IndexAddUserId:= Bh.SerchUser_Pole('Id',DeleteUserId,DeleteUserId);
         if IndexAddUserId>=0 then
         begin
               MsgHistory:= amJson.LoadObjectFile(FDirMessageGroop+'message_'+ GroopId +'_.json');
               try
                   //untUserGroop:=MsgHistory['Data']['ListUser']['array'].Count;


                   MsgHistroryIndex:=Bh.MessageHistory_UserDelete(MsgHistory,DeleteUserId);
                   if MsgHistroryIndex>=0 then
                   begin


                           //удаление с базы  контакт юзера
                          if  Contacts_Delete(   ObjUsers['Data']['List'].Items[IndexAddUserId],
                                                          ConstAmChat.TypeUser.Groop,GroopId) then
                          begin
                             Local_Response_User(True,'Юзер удален с группы');

                          end
                          else
                          begin

                             Local_Response_User(True,'У юзера нет вашего контакта');
                          end;

                          Local_Response_Others;
                          MsgHistory.SaveToFile(FDirMessageGroop+'message_'+ GroopId +'_.json');
                          IsSendOthers:=Bh.GetListActivPort_O(ListActiv,DeleteUserId,ListSendPort);




                   end
                   else Local_Response_User(false,'Юзера нет в списке участников группы');

               finally
                MsgHistory.Free;
               end;

         end
         else Local_Response_User(false,'Не найден юзер');

       end
       else Local_Response_User(false,'Нет прав на выполнение этой операции');


end;
function  TAmChatServerBaza.Groop_CheckPrava(IndexGr,IndexUser:integer;IdGroop,IdUser,WhatFun:string):boolean;
var IdUserAdmin:string;
begin
  REsult:=False;
  IdUserAdmin:=Bh.GetGroop_index(IndexGr,'IdUserAdmin');
  if IdUserAdmin = IdUser then
  begin
    REsult:=true;
    exit;
  end
  else
  begin
    if 'NewMessage'= WhatFun then
    begin
      REsult:=ConstAmChat.TypeGroopPrivacy.
      NeedVisibleAswert(
                          Bh.GetGroop_index(IndexGr,'TypeGroopPrivacy'),
                          ConstAmChat.TypeUser.User,
                          IdUserAdmin = IdUser );
    end;
    
    //if Bh.GetGroop_index(IndexGr,'IdUserAdmin') then
    
  end;
end;
procedure TAmChatServerBaza.SVR_Groop_SetUserName(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var
    GroopId,UserName:string;
    UserId:string;
    Fn:string;
    IndexGroop:integer;

     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Groop_SetUserName_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin
           ResponseUser['Response']['Groop']['GroopId'].Value:= GroopId;
           ResponseUser['Response']['Groop']['UserName'].Value :=UserName;
         end;

     end;
begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Groop_SetUserName_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;


       UserId:=  Bh.GetUser_index(IndexAcc,'Id');
       GroopId:= InputObj['GroopId'].Value;
       UserName:= InputObj['UserName'].Value;
       IndexGroop:= Bh.SerchGroop_Pole('Id',GroopId,GroopId);
       if IndexGroop<0 then
       begin
         Local_Response_User(false,'Группа не найдена');
        exit;
       end;



       if Groop_CheckPrava(IndexGroop,IndexAcc,GroopId,UserId,'SetUserName') then
       begin

           if Groop_Create_CheckName(UserName) then
           begin
                 Bh.SetGroop_index(IndexGroop,'UserName',UserName);
                 Local_Response_User(True,'Имя группы изменено');

           end
           else Local_Response_User(false,'Указано не корректоное имя');
       end
       else Local_Response_User(false,'Нет прав на выполнение этой операции');
end;
procedure TAmChatServerBaza.SVR_Groop_SetPhoto(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var PhotoId:string;
    GroopId:string;
    UserId:string;
    Fn:string;
    IndexGroop:integer;

     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Groop_SetPhoto_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin
           ResponseUser['Response']['Groop']['GroopId'].Value:= GroopId;
           ResponseUser['Response']['Groop']['PhotoId'].Value :=PhotoId;
         end;

     end;
begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Groop_SetPhoto_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;


       UserId:=  Bh.GetUser_index(IndexAcc,'Id');
       GroopId:= InputObj['GroopId'].Value;
       PhotoId:= InputObj['PhotoId'].Value;
       IndexGroop:= Bh.SerchGroop_Pole('Id',GroopId,GroopId);
       if IndexGroop<0 then
       begin
         Local_Response_User(false,'Группа не найдена');
        exit;
       end;



       if Groop_CheckPrava(IndexGroop,IndexAcc,GroopId,UserId,'SetPhoto') then
       begin
           if ConstAmChat.CheckIdFile(PhotoId) then
           begin
              Fn:= FDirPhotos+PhotoId+ConstAmChat.NameFileType.ePhotoExt;
              if FileExists(Fn) then
              begin
                 if not InputObj['IsMain'].IsNull and InputObj['IsMain'].BoolValue then
                 begin
                    Bh.SetGroop_index2(IndexGroop,'Photos','MainId',PhotoId);
                    ResponseUser['Response']['Groop']['IsMain'].BoolValue:= true;
                 end
                 else ResponseUser['Response']['Groop']['IsMain'].BoolValue:= false;

                 Local_Response_User(true,'Фото загружено');

              end
              else Local_Response_User(false,'Не найден такой файл');
           end
           else Local_Response_User(false,'Не валидный idPhoto');
       end
       else Local_Response_User(false,'Нет прав на выполнение этой операции');
       




      //   ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось загрузить фото на сервере'

end;
procedure TAmChatServerBaza.SVR_Groop_Create(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var  IndexGroop,IdGroop:integer;
     ScreenGroopName:string;
     GroopName,TypeGroopPrivacy:string;
     CheckScreenName,CheckName,CheckPrivacy:boolean;
     NewAccGroop:TjsonObject;
begin
       ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.GroopCreate_Back;
       ResponseUser['Response']['Result'].BoolValue:= false;
       ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось создать группу';
       IndexGroop:=-1;
       IdGroop:=-1;

      ScreenGroopName:=InputObj['ScreenGroopName'].Value;
      GroopName:= InputObj['GroopName'].Value;
      TypeGroopPrivacy:= InputObj['TypeGroopPrivacy'].Value;
      CheckPrivacy:=ConstAmChat.TypeGroopPrivacy.Check(TypeGroopPrivacy);

      CheckScreenName:=Groop_Create_CheckScreenName(ScreenGroopName);
      CheckName:=Groop_Create_CheckName(GroopName);
      if CheckScreenName and CheckName and CheckPrivacy then
      begin
         Groop_AddList(IndexGroop,IdGroop,ScreenGroopName,GroopName,Bh.GetUser_index(IndexAcc,'Id'),TypeGroopPrivacy);
         if (IndexGroop>=0)and (IdGroop>0) then
         begin
             Contacts_Add(ObjAcc,ConstAmChat.TypeUser.Groop,AmStr(IdGroop));
             NewAccGroop:= ObjAcc.a['Groops'].AddObject;
             NewAccGroop['Id'].Value:= Amstr(IdGroop);
             NewAccGroop['ScreenName'].Value:= ScreenGroopName;
             ResponseUser['Response']['Result'].BoolValue:= true;
             ResponseUser['Response']['ResultMsg'].Value:= 'Группа создана';
             ResponseUser['Response']['Groop']['Id'].Value:=AmStr(IdGroop);

             ResponseUser['Response']['Contact']['Id'].Value:=                     AmStr(IdGroop);
             ResponseUser['Response']['Contact']['TypeUser'].Value:=               ConstAmChat.TypeUser.Groop;
             ResponseUser['Response']['Contact']['ScreenName'].Value:=             ScreenGroopName;
             ResponseUser['Response']['Contact']['UserName'].Value:=               GroopName;
             ResponseUser['Response']['Photos']['MainId'].Value:=     '';
            // ResponseUser['Response']['Photos']['MainData'].Value:=   '';
             ResponseUser['Response']['LastActivData'].Value:= ClientDataNow;
             ResponseUser['Response']['Message']['ReadLastLocalIdMy'].Value:= '0';
             ResponseUser['Response']['Message']['LastId'].Value:='0';






         end
         else
         begin
           ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить id группы';
         end;
      end
      else
      begin
          if not CheckScreenName then  ResponseUser['Response']['ResultMsg'].Value:= 'Такое короткое имя уже есть'
          else if not CheckName then  ResponseUser['Response']['ResultMsg'].Value:= 'Такое имя группы нельзя установить'
          else if not CheckPrivacy then  ResponseUser['Response']['ResultMsg'].Value:= 'Не указан тип группы и приватность'
          else ResponseUser['Response']['ResultMsg'].Value:= 'Ошибка в создании группы'
      end;
      






end;
procedure  TAmChatServerBaza.Groop_AddList(var OutIndex:integer;var OutId:integer; ScreenName,Name:String;IdUserAdmin,TypeGroopPrivacy:string);
var Hob:TJsonObject;
    CounterId:integer;
    MsgHistory:TJsonObject;
begin
   OutIndex:=-1;
   OutId:=-1;
   if AmInt(IdUserAdmin,-1)<0 then exit;
   

   CounterId:= AmInt(ObjGroops['Data']['CounterId'].Value,0);
   inc(CounterId);
   ObjGroops['Data']['CounterId'].Value:=AmStr(CounterId);
   self.ListGroopScreenName.Add_BinSort(ScreenName,AmStr(CounterId),':');
   self.ListGroopName.Add_BinSort(Name,AmStr(CounterId),':');


   OutIndex:= ObjGroops['Data'].A['List'].Count;

   Hob:= ObjGroops['Data'].A['List'].AddObject;
   Hob['Id'].Value:=          AmStr(CounterId);
   Hob['ScreenName'].Value:=  ScreenName;
   Hob['UserName'].Value:=        Name;
   Hob['IdUserAdmin'].Value:= IdUserAdmin;
   Hob['TypeGroopPrivacy'].Value:= TypeGroopPrivacy;
   OutId:=  CounterId;

         MsgHistory:= amJson.LoadObjectFile(FDirMessageGroop+'message_'+ Amstr(CounterId) +'_.json');
         try
            Bh.MessageHistory_UserAdd(MsgHistory,IdUserAdmin);
            MsgHistory.SaveToFile(FDirMessageGroop+'message_'+ Amstr(CounterId) +'_.json');

         finally
          MsgHistory.Free;
         end;

end;
function TAmChatServerBaza.Groop_Create_CheckScreenName(ScreenName:string):boolean;
var Rx:string;
begin
 Rx:= AmReg.GetValue('\w+',ScreenName);
 Result:= (Rx=ScreenName) and  (Length(ScreenName)>4) and  (Bh.SerchGroop_ScreenName(ScreenName,'')<0);
end;
function TAmChatServerBaza.Groop_Create_CheckName(Name:string):boolean;
var Rx:string;
begin
 Rx:= AmReg.GetValue('([a-zA-я\s\d+]+)',Name);
 Result:= (Rx=Name) and  (Length(Name)>4);

end;


procedure TAmChatServerBaza.SVR_Message_UserSend(IndexAcc:integer;
                                             ObjAcc,InputObj,
                                             ResponseUser,ResponseOthers:TjsonObject;
                                             var IsSendOthers:boolean;
                                             var ListSendPort:TAmBth.TMainResult.TListPort);
var TextMessage,ContactUserId,UserId,TypeUser,TypeContent:string;
IndexContactUserId:integer;
FileName,FilePath:string;
MsgHistory,MsgNew,MsgNewHelp:Tjsonobject;
CounterLocalId,CounterGlobalMsgId:integer;
MessageVoiceParam:TMessageVoiceParam;
MessageFileParam:TMessageFileParam;




      //////////////////////////////////////////////////////////
      procedure Local_MsgHistory_CheckListUser;
      begin
           // добавление участников диалога в лист текуший пользователь и с кем общается
           //  MsgHistory это файл с историей диалога
          Bh.MessageHistory_UserAdd(MsgHistory,UserId);
          if TypeUser= ConstAmChat.TypeUser.User then
          Bh.MessageHistory_UserAdd(MsgHistory,ContactUserId);
      end;



      ////////////////////////////////////////////////////////

      procedure Local_SetNoReadAndActivPort;
      var I:integer;
      ObjContactUser:TjsonObject;
      ContactAdd:TjsonObject;
      MsgHisOneUserId:string;
      MsgHisOneUserIndex:integer;
      begin
             for I := 0 to MsgHistory['Data']['ListUser']['array'].Count-1{список все участников беседы} do
             begin
                MsgHisOneUserId:=MsgHistory['Data']['ListUser']['array'].Items[i].Value;
                if MsgHisOneUserId='' then  continue;
                
                if MsgHisOneUserId=UserId then continue;


                // установка в главной базе что у пользователя +1 контакт
                // установка в главной базе что у пользователя +1 непрочитаное
                if TypeUser=ConstAmChat.TypeUser.User then
                 begin
                   ObjContactUser:=ObjUsers['Data']['List'].Items[IndexContactUserId];
                   ContactAdd:=Contacts_Add(ObjContactUser,TypeUser,UserId);
                   ContactAdd['Message']['LastId'].Value:= AmStr(CounterLocalId);
                  // Message_AddOneNoRead(ContactAdd,AmStr(CounterGlobalMsgId),AmStr(CounterLocalId));
                 end
                 else if TypeUser=ConstAmChat.TypeUser.Groop then
                 begin

                   // установить для всех участников что от этой группы есть одно непрочитанное

                   MsgHisOneUserIndex:= bh.SerchUser_Pole('Id',MsgHisOneUserId,MsgHisOneUserId);
                   if MsgHisOneUserIndex>=0 then
                   begin
                       ObjContactUser:=ObjUsers['Data']['List'].Items[MsgHisOneUserIndex];
                       ContactAdd:=Contacts_Add(ObjContactUser,TypeUser,ContactUserId);
                        ContactAdd['Message']['LastId'].Value:= AmStr(CounterLocalId);
                   end;
                   









                  // Message_AddOneNoRead(ContactAdd,AmStr(CounterGlobalMsgId),AmStr(CounterLocalId));
                 end;




               //set activ port чтобы отправить пользователям с кем есть соединение
               Bh.GetListActivPort_O_N(ListActiv,MsgHisOneUserId,ListSendPort);



             end;
      end;
     procedure Local_Contacts_Add_Others;
     begin
       //////////////////////////////////////////////////////////////////////
         // что отправить обратно тем кто с ним в диалоге (т.е другим)
         // инфа для обноаления сообщений
         //FromUserId= от кого это сообщение
         //ContactUserId= Контакт в списке
         // для user - user они равны
         IsSendOthers:=true;
         ResponseOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_New_Back;
         ResponseOthers['Response']['Result'].BoolValue:= true;
         ResponseOthers['Response']['ResultMsg'].Value:= 'Новое Сообщение';
         // Копируем сообщение
         ResponseOthers['Response']['Message'].ObjectValue.Assign(MsgNew);


         ResponseOthers['Response']['Users'][UserId]['Id'].Value:=                     UserId;
         ResponseOthers['Response']['Users'][UserId]['TypeUser'].Value:=               TypeUser;//???????????????????
         ResponseOthers['Response']['Users'][UserId]['ScreenName'].Value:=             Bh.GetUser_index(IndexAcc,'ScreenName');
         ResponseOthers['Response']['Users'][UserId]['UserName'].Value:=               Bh.GetUser_index(IndexAcc,'UserName');
         ResponseOthers['Response']['Users'][UserId]['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexAcc,'Photos','MainId');
         ResponseOthers['Response']['Users'][UserId]['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexAcc,'Photos','MainData');



        if TypeUser = ConstAmChat.TypeUser.User then
        begin
         ResponseOthers['Response']['Contact']['Id'].Value:=                     UserId;
         ResponseOthers['Response']['Contact']['TypeUser'].Value:=               TypeUser;//???????????????????
         ResponseOthers['Response']['Contact']['ScreenName'].Value:=             Bh.GetUser_index(IndexAcc,'ScreenName');
         ResponseOthers['Response']['Contact']['UserName'].Value:=               Bh.GetUser_index(IndexAcc,'UserName');
         ResponseOthers['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexAcc,'Photos','MainId');
         ResponseOthers['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexAcc,'Photos','MainData');
         ResponseOthers['Response']['Contact']['LastActivData'].Value:=          ClientDataNow;
         ResponseOthers['Response']['Contact']['Message']['LastId'].Value:= AmStr(CounterLocalId);
        end
        else if TypeUser = ConstAmChat.TypeUser.Groop then
        begin
         ResponseOthers['Response']['Contact']['Id'].Value:=                     ContactUserId;
         ResponseOthers['Response']['Contact']['TypeUser'].Value:=               TypeUser;//???????????????????
         ResponseOthers['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexContactUserId,'ScreenName');
         ResponseOthers['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexContactUserId,'UserName');
         ResponseOthers['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexContactUserId,'Photos','MainId');
         ResponseOthers['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexContactUserId,'Photos','MainData');
         ResponseOthers['Response']['Contact']['LastActivData'].Value:=          ClientDataNow;
         ResponseOthers['Response']['Contact']['Message']['LastId'].Value:= AmStr(CounterLocalId);
        end;
             
        Local_SetNoReadAndActivPort;
     end;
     procedure Local_Contacts_Add_NowUser;
     var ContactAdd:TjsonObject;
     begin
         ContactAdd:=Contacts_Add(ObjAcc,TypeUser,ContactUserId);
         ContactAdd['Message']['LastId'].Value:= AmStr(CounterLocalId);
      //ContactAdd['Message']['ReadLastLocalIdHim'].Value:=
         ContactAdd['Message']['ReadLastLocalIdMy'].Value:= AmStr(CounterLocalId);


     /////////////////////////////////////////////////////////////////////////////////////
     // что отправить обратно тому кто сюда прислал
          //ContactUserId =   c кем общается   UserId  (кому это сообщение)
          // FromUserId кто написал (от кого это сообщение)
         //UserId отправляем сообщение обратно тому кто прислал  т.е UserId
         ResponseUser['Response']['Idmsg'].IntValue:=                          ConstAmChat.Message_New_Back;
         ResponseUser['Response']['Result'].BoolValue:=                        true;
         ResponseUser['Response']['ResultMsg'].Value:=                         'Сообщение  отправлено';

         // Копируем сообщение
         ResponseUser['Response']['Message'].ObjectValue.Assign(MsgNew);
         ResponseUser['Response']['Message']['MimId'].Value:= InputObj['MimId'].Value;
         ResponseUser['Response']['Message']['MimLparam'].Value:= InputObj['MimLparam'].Value;


         //UserId отправляем  обратно  инфу о ContactUserId для обновления сообщений
         if TypeUser = ConstAmChat.TypeUser.User then
         begin
           ResponseUser['Response']['Users'][ContactUserId]['Id'].Value:=                     ContactUserId;
           ResponseUser['Response']['Users'][ContactUserId]['TypeUser'].Value:=               TypeUser;
           ResponseUser['Response']['Users'][ContactUserId]['ScreenName'].Value:=             Bh.GetUser_index(IndexContactUserId,'ScreenName');
           ResponseUser['Response']['Users'][ContactUserId]['UserName'].Value:=               Bh.GetUser_index(IndexContactUserId,'UserName');
           ResponseUser['Response']['Users'][ContactUserId]['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexContactUserId,'Photos','MainId');
           ResponseUser['Response']['Users'][ContactUserId]['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexContactUserId,'Photos','MainData');


           //UserId отправляем  обратно  инфу о ContactUserId для обновления контактов
           ResponseUser['Response']['Contact'].ObjectValue.Assign(ContactAdd);
           ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetUser_index(IndexContactUserId,'ScreenName');
           ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetUser_index(IndexContactUserId,'UserName');
           ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexContactUserId,'Photos','MainId');
           ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexContactUserId,'Photos','MainData');


         end
         else if TypeUser = ConstAmChat.TypeUser.Groop then
         begin
           ResponseUser['Response']['Contact'].ObjectValue.Assign(ContactAdd);
           ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexContactUserId,'ScreenName');
           ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexContactUserId,'UserName');
           ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexContactUserId,'Photos','MainId');
           ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexContactUserId,'Photos','MainData');

         end;


    ///////////////////////////////////////////////////////////////////////

     end;
     var i:integer;
begin
       ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_New_Back;
       ResponseUser['Response']['Result'].BoolValue:= false;
       ResponseUser['Response']['ResultMsg'].Value:= 'Сообщение не отправлено';

      IndexContactUserId:=-1;
      UserId:= ObjAcc['Id'].Value;
      ContactUserId:= InputObj['ContactUserId'].Value;
      TypeUser:=InputObj['TypeUser'].Value;
      TypeContent:= InputObj['TypeContent'].Value;


      if not ConstAmChat.TypeUser.Check(TypeUser) then  exit;
      if not ConstAmChat.TypeContent.Check(TypeContent) then  exit;
      if Amint(UserId,-1)<0 then  exit;

      if TypeContent=ConstAmChat.TypeContent.Text then
      begin
         TextMessage:= InputObj['Content'].Value;
      end
      else if TypeContent=ConstAmChat.TypeContent.Voice then
      begin
          if not UserSend_VoiceSave(IndexAcc,ObjAcc,UserId,InputObj['Content'].Value,MessageVoiceParam) then
          begin
            ResponseUser['Response']['ResultMsg'].Value:= 'Сообщение не отправлено не загружен файл голосового сообщения VoiceId='+MessageVoiceParam.VoiceId;
            exit;
          end;
      end
      else if TypeContent=ConstAmChat.TypeContent.Files then
      begin
          UserSend_FilesPars(InputObj['Content'].Value,MessageFileParam);
      end;


      if TypeUser = ConstAmChat.TypeUser.User then
      begin
          FilePath:=FDirMessageUser;
          IndexContactUserId:= Bh.SerchUser_Pole('Id',ContactUserId,ContactUserId);

          if IndexContactUserId<0 then  exit;

          if Amint(ContactUserId,-1)<0 then  exit;
          if Amint(UserId)<  Amint(ContactUserId)  then    FileName:= 'message_'+UserId+'_'+ ContactUserId +'_.json'
          else                                        FileName:= 'message_'+ContactUserId+'_'+UserId +'_.json';

      end
      else if TypeUser = ConstAmChat.TypeUser.Groop then
      begin
          FilePath:=FDirMessageGroop;
          IndexContactUserId:= Bh.SerchGroop_Pole('Id',ContactUserId,ContactUserId);


          if IndexContactUserId<0 then  exit;

          if Amint(ContactUserId,-1)<0 then  exit;

          FileName:= 'message_'+ ContactUserId +'_.json';

          if  not Groop_CheckPrava(IndexContactUserId,IndexAcc,ContactUserId,UserId,'NewMessage') then
          begin
            exit;
          end;

      end
      else exit;
           



     MsgHistory:= amJson.LoadObjectFile(FilePath+FileName);
     try


      //set counters Local
      CounterLocalId:=AmInt(MsgHistory['Data']['CounterLocalId'].Value,0);
      inc(CounterLocalId);
      MsgHistory['Data']['CounterLocalId'].Value:=  AmStr(CounterLocalId);

      //set counters Global
      CounterGlobalMsgId:= AmInt(ObjUsers['Data']['CounterGlobalMsgId'].Value,0);
      inc(CounterGlobalMsgId);
      ObjUsers['Data']['CounterGlobalMsgId'].Value:=  AmStr(CounterGlobalMsgId);

      // set FileName
      if MsgHistory['Data']['FileName'].Value<>FileName then MsgHistory['Data']['FileName'].Value:=FileName;
      if MsgHistory['Data']['FilePath'].Value<>FilePath then MsgHistory['Data']['FilePath'].Value:=FilePath;

      // set ListUsers  check and add
      Local_MsgHistory_CheckListUser;

      if MsgHistory['Data']['Msg'].Count>1500 then MsgHistory['Data'].A['Msg'].Delete(0);

      //set one new msg
      MsgNew:=MsgHistory['Data'].A['Msg'].AddObject;
      MsgNew['IdGlobal'].Value:= AmStr(CounterGlobalMsgId);//глобальный  id всех сообщений в программе
      MsgNew['IdLocal'].Value:= AmStr(CounterLocalId);     //локальный  id сообщения между участниками диалога или чата
      MsgNew['IdFrom'].Value:= UserId; //от кого это сообщение
      //кому это сообщение указывать смысла нет   имя файла содержит эту инфу
      MsgNew['Data'].Value:= ClientDataNow;
   //   MsgNew['IsRead'].Value:= BooltoStr(False);
      MsgNew['TypeContent'].Value:= TypeContent;

      if TypeContent=ConstAmChat.TypeContent.Text then
      begin
         MsgNew['Content']['Text'].Value:= TextMessage;
      end
      else if TypeContent=ConstAmChat.TypeContent.Voice then
      begin
          MsgNew['Content']['VoiceId'].Value:= MessageVoiceParam.VoiceId;
          MsgNew['Content']['VoiceSpectrJson'].Value:= MessageVoiceParam.VoiceSpectrJson;
          MsgNew['Content']['VoiceLength'].Value:= MessageVoiceParam.VoiceLength;
          MsgNew['Content']['VoiceCaption'].Value:= MessageVoiceParam.VoiceCaption;
          MsgNew['Content']['VoiceTimerSecond'].Value:= MessageVoiceParam.VoiceTimerSecond;
      end
      else if TypeContent=ConstAmChat.TypeContent.Files then
      begin
          MsgNew['Content']['IdPhoto10'].Value:= MessageFileParam.Id_Photo10;
          MsgNew['Content']['IdPhoto500'].Value:= MessageFileParam.Id_Photo500;
          MsgNew['Content']['IdFile'].Value:= MessageFileParam.Id_File;
          MsgNew['Content']['Comment'].Value:= MessageFileParam.Comment;
          MsgNew['Content']['CollageSizeMax'].Value:= MessageFileParam.CollageSizeMax;
          MsgNew['Content']['CollageCountFile'].Value:= MessageFileParam.CollageCountFile;
          for I := 0 to MessageFileParam.ListFileOther.Count-1 do
          begin
           MsgNewHelp:= MsgNew['Content'].A['ListFileOther'].AddObject;
           MsgNewHelp['FileName'].Value:=  MessageFileParam.ListFileOther[i].FileName;
           MsgNewHelp['Size'].Value:=  MessageFileParam.ListFileOther[i].Size;
          end;
          for I := 0 to MessageFileParam.ListFilePhoto.Count-1 do
          begin
           MsgNewHelp:= MsgNew['Content'].A['ListFilePhoto'].AddObject;
           MsgNewHelp['FileName'].Value:=  MessageFileParam.ListFilePhoto[i].FileName;
           MsgNewHelp['Size'].Value:=  MessageFileParam.ListFilePhoto[i].Size;
           MsgNewHelp['Rect'].Value:=  MessageFileParam.ListFilePhoto[i].Rect;
          end;

      end;



      MsgHistory.SaveToFile(FilePath+FileName);

         //текущему добавить контакт того кому он написал и составить ответ что отправлять
         Local_Contacts_Add_NowUser;

         // порты тех кому отправить
         // установить в главной базе занчения
         Local_Contacts_Add_Others;



     finally
       MsgHistory.Free;
     end;





end;


Function TAmChatServerBaza.ListUsersScreenName_Add(ScreenName,Id:string):boolean;
var
index:integer;

begin

      REsult:=false;
        try

               index:= ListUsersScreenName.Add_BinSort(ScreenName,Id,':');
               result:=true;
               {
               index:= ListScreenName_IndexOfBin(List,ScreenName,true);
               if (index<0) or (index>=List.Count)  then List.Add(ScreenName+':'+Id)
               else List.Insert(index,ScreenName+':'+Id);
               }
            //   Result:= ListUsersScreenName.SaveToFileAm(FDir+FnListBazaScreenName,10)=1;


        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.ListUsersScreenName_Add ',self,e,true);
        end;

end;
procedure TAmChatServerBaza.SVR_Serch (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
begin
     IsSendOthers:=false;

     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Serch_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;




     if InputObj['Metod'].Value='ScreenName' then
     begin
        try


           Serch_ScreenName( Bh.GetUser_index(IndexAcc,'Id'),
                             InputObj['Val'].Value,
                             ResponseUser['Response']['Serch']);
           ResponseUser['Response']['Result'].BoolValue:= true;


        except
         on e:Exception do
         LogMain.LogError('Error TAmChatServerBaza.SVR_Serch ',self,e,true);
        end;
     end;



end;
procedure TAmChatServerBaza.Serch_ScreenName(IdNowUser,SerchSours:string; ResponseSerch:TjsonObject);
var index:integer;
    TypeUser:string;

      Procedure Add(ValStr:String);
      var  Hob:TJsonObject;
      aId,aScr:string;
      R_Index:integer;
      R_UserName:string;
      R_Id:string;
      R_Scr,R_Privaty:string;
      begin
         aId:=  ValStr.Split([':'])[1];
         aScr:= ValStr.Split([':'])[0];
         if AmInt(aId,0)=0 then exit;
         if aScr='' then exit;

         if (IdNowUser=aId) and (TypeUser= ConstAmChat.TypeUser.User)   then exit;
         if (TypeUser= ConstAmChat.TypeUser.User) then
         begin
             R_Index:= Bh.SerchUser_Pole('Id',aId,aId);
             if R_Index<0 then exit;
             R_Id:=Bh.GetUser_index(R_Index,'Id');
             R_UserName:= Bh.GetUser_index(R_Index,'UserName');
             R_Scr:= Bh.GetUser_index(R_Index,'ScreenName');
         end
         else if (TypeUser= ConstAmChat.TypeUser.Groop) then
         begin
             R_Index:= Bh.SerchGroop_Pole('Id',aId,aId);
             if R_Index<0 then exit;
             R_Id:=Bh.GetGroop_index(R_Index,'Id');
             R_UserName:= Bh.GetGroop_index(R_Index,'UserName');
             R_Scr:= Bh.GetGroop_index(R_Index,'ScreenName');
             R_Privaty:= Bh.GetGroop_index(R_Index,'TypeGroopPrivacy');
             if not ConstAmChat.TypeGroopPrivacy.CheckOpen(R_Privaty) then exit;
         end
         else exit;

         if aId<>R_Id then exit;
         if aScr<>R_Scr then exit;
         Hob:= ResponseSerch.A['Items'].AddObject;
         Hob['Id'].Value:= R_Id;
         Hob['TypeUser'].Value:= TypeUser;
         Hob['UserName'].Value:= R_UserName;
         Hob['ScreenName'].Value:= R_Scr;

      end;
 var i:integer;
     s:string;

begin
    if AmInt(IdNowUser,0)=0 then exit;


    TypeUser := ConstAmChat.TypeUser.Groop;
    index:= amSerch.StrList_Bin_KeyValue_IndexOf(ListGroopScreenName,SerchSours,':',true);
    if index<0 then
    else
    begin

         for I :=  index to ListGroopScreenName.Count-1 do
         begin
             s:=ListGroopScreenName[i];
            if (s<>'') and  (pos(':',s)<>0) then
            begin
              s:=s.Split([':'])[0];
              if pos(AnsiLowerCase(SerchSours),AnsiLowerCase(s))=1 then
              begin
                Add(ListGroopScreenName[i]);
              end
              else break;
            end
            else break;


         end;
    end;

    TypeUser := ConstAmChat.TypeUser.User;
    index:= amSerch.StrList_Bin_KeyValue_IndexOf(ListUsersScreenName,SerchSours,':',true);
    if index<0 then
    else
    begin

         for I :=  index to ListUsersScreenName.Count-1 do
         begin
             s:=ListUsersScreenName[i];
            if (s<>'') and  (pos(':',s)<>0) then
            begin
              s:=s.Split([':'])[0];
              if pos(AnsiLowerCase(SerchSours),AnsiLowerCase(s))=1 then
              begin
                Add(ListUsersScreenName[i]);
              end
              else break;
            end
            else break;


         end;
    end;
end;


 (*
procedure TAmChatServerBaza.SVR_Voice_Download (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var PhotoCountId:integer;
ObjHelp:TjsonObject;
Stream:TMemoryStream;
VoiceBase64:string;
VoiceId:string;
begin
     IsSendOthers:=false;
     VoiceBase64:='';
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Voice_Download_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;
     Stream:= TMemoryStream.Create;
     try

        VoiceId:=InputObj['VoiceId'].Value;

       if (VoiceId<>'') and fileexists(FDirVoice+VoiceId+'.mp3') then
       begin

        if  LoingVoiceUserDisk(VoiceId+'.mp3',Stream)
        and AmBase64.StreamToBase64(Stream,VoiceBase64)
         then
        begin

                ResponseUser['Response']['Result'].BoolValue:= true;
                ResponseUser['Response']['ResultMsg'].Value:= 'Voice получено';
                ResponseUser['Response']['Voice'].ObjectValue.Assign(InputObj);
                ResponseUser['Response']['Voice']['VoiceBase64'].Value:= VoiceBase64;


        end
        else ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить Voice на сервере';
       end
       else ResponseUser['Response']['ResultMsg'].Value:= 'Нет файла Voice на сервере '+VoiceId;



     finally
       Stream.Free;
     end;



end; *)
function TAmChatServerBaza.Diconnect(Port,IndexPort:integer):TAmBth.TMainResult;
begin

    FClientPort:=Port;
    FClientIndexPort:=IndexPort;
    FClientDataNow  :=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);
    try
      Result.Clear;
      try
            Result.IsSendUser:=False;
           // Result.TextOutputUser:='{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
            Result.IsSendOthers:=false;
            Result.TextOutputOthers:= '{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
            Result.ListPort.Clear;
            Result:=SRV_LogOutPort(ConstAmChat.TypeOnline.Offline);
            Result.Result:=true;
            Result.IsJsonSend:=true;
      except
       on e:Exception do
       LogMain.Log('Error TAmChatServerBaza.Diconnect '+e.Message);
      end;
    finally
     FClientPort:=-1;
     FClientDataNow  :='';
     FClientIndexPort:=-1;
    end;


end;
function TAmChatServerBaza.SRV_LogOutPort(TypeOnline:string):TAmBth.TMainResult;
var idUser:string;
begin
 if ClientIndexPort<0 then exit;
 try
    idUser:= ListActiv.List[ClientIndexPort].Id;
 except
    logmain.Log(' TAmChatServerBaza.SRV_LogOutPort.List')
 end;

 try
    Result:=SRV_SetTypeOnline(idUser,TypeOnline);
  except
    logmain.Log(' TAmChatServerBaza.SRV_LogOutPort.SRV_SetTypeOnline')
  end;
end;
function TAmChatServerBaza.SRV_SetTypeOnline(aId:String;TypeOnline:string):TAmBth.TMainResult;
var IndexAcc:integer;
ObjOthers:TJsonObject;
var OneClient:TAmBth.TListActiv.TOneClient;
begin
    if aId='' then exit;
    IndexAcc:=Bh.SerchUser_Pole('Id',aId,aId);
    if IndexAcc<0 then exit;
    SetListAvtivPortForSendOthers(Result.ListPort,IndexAcc);
    if Result.ListPort.Count<=0 then exit;

    ConstAmChat.TypeOnline.Check(TypeOnline);
    if ClientIndexPort<0 then exit;

    OneClient:=ListActiv.List[ClientIndexPort];
    OneClient.TypeOnline:= TypeOnline;
    ListActiv.List[ClientIndexPort]:=OneClient;
    //LogMain.Log(ListActiv.List[ClientIndexPort].TypeOnline);

    Result.IsSendOthers:=true;
    ObjOthers := TJsonObject.Create;
    try
        ObjOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.OnlineType_Back;
        ObjOthers['Response']['Result'].BoolValue:=true;
        ObjOthers['Response']['ResultMsg'].Value:= ''+Bh.GetUser_index(IndexAcc,'UserName')+ ' Офлайн';
        ObjOthers['Response']['ResultAuth'].BoolValue:= true;

        ObjOthers['Response']['Online']['Id'].Value:=  aId;
        ObjOthers['Response']['Online']['ScreenName'].Value:=  Bh.GetUser_index(IndexAcc,'ScreenName');
        ObjOthers['Response']['Online']['UserName'].Value:=  Bh.GetUser_index(IndexAcc,'UserName');
        ObjOthers['Response']['Online']['TypeOnline'].Value :=TypeOnline;
        Result.TextOutputOthers:= ObjOthers.ToJSON();
    finally
      ObjOthers.Free;
    end;

end;
function TAmChatServerBaza.SRV_LogOutAcc(Token,Hash,aId:string):TAmBth.TMainResult;
begin
    Result:= SVR_TypeOnline(Token,Hash,ConstAmChat.TypeOnline.Offline);
end;
function TAmChatServerBaza.SVR_TypeOnline(Token,Hash,TypeOnline:string):TAmBth.TMainResult;
var IndexAcc:integer;
LocalHash:string;
RAuth:boolean;
IdNowUser:string;
begin
//   SRV_LogOutId(aId:String;TypeOnline:string)

         Result.IsSendUser:=False;
         Result.TextOutputUser:='{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
         Result.IsSendOthers:=false;
         Result.TextOutputOthers:= '{"Response":{"Idmsg":10000,"ResultMsg":"Error ServerPars"}}';
         Result.ListPort.Clear;


         RAuth:=Auth_Token(IndexAcc,Token);
         LocalHash:=Bh.GetUser_index(IndexAcc,'Hash');
         if  RAuth and (Hash<>'') and (Hash=LocalHash) then
         begin
             IdNowUser:=Bh.GetUser_index(IndexAcc,'Id');
             Result:=SRV_SetTypeOnline(IdNowUser,TypeOnline);
         end;
end;

procedure TAmChatServerBaza.SVR_Message_Read(
                                                  IndexAcc:integer;
                                                  ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;
                                                  var IsSendOthers:boolean;
                                                  var ListSendPort:TAmBth.TMainResult.TListPort);
var TypeMetodReadMessage,UserId:string;
TypeUser,ContactUserId,UserIdMessage,IdLocalMessage:string;
IndexHimUserId,IndexContactMy:integer;
ObjContacts:TjsonObject;
begin
      ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_Read_Back;
      ResponseUser['Response']['Result'].BoolValue:= false;
      ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить прочитать сообщение';
      IsSendOthers:=false;

      UserId:= ObjAcc['Id'].Value;
      TypeMetodReadMessage:= InputObj['TypeMetodReadMessage'];
      TypeUser:=             InputObj['TypeUser'];
      ContactUserId:=        InputObj['ContactUserId'];
      UserIdMessage:=        InputObj['UserIdMessage'];
      IdLocalMessage:=       InputObj['IdLocalMessage'];
      IndexHimUserId:=-1;

      if not ConstAmChat.TypeUser.Check(TypeUser) then  exit;
      if not ConstAmChat.TypeMetodReadMessage.Check(TypeMetodReadMessage) then  exit;

      if Amint(UserId,-1)<0 then  exit;
      if Amint(ContactUserId,-1)<0 then  exit;
      if Amint(UserIdMessage,-1)<0 then  exit;
      if Amint(IdLocalMessage,-1)<0 then  exit;

      if TypeUser = ConstAmChat.TypeUser.User then
      begin
      //    IndexHimUserId:= Bh.SerchUser_Pole('Id',ContactUserId,ContactUserId);
      end;

     // if IndexHimUserId<0 then  exit;

      IndexContactMy:=Bh.ContactsUsers_SerchIndex(ObjAcc['Contacts'],ContactUserId,TypeUser);
      if IndexContactMy<0 then  exit;

     ObjContacts:= ObjAcc['Contacts']['List'].Items[IndexContactMy];

     if AmInt(ObjContacts['Message']['ReadLastLocalIdMy'].Value,0)< AmInt(IdLocalMessage,0) then
     begin
       ObjContacts['Message']['ReadLastLocalIdMy'].Value:= IdLocalMessage;
     end;

     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_Read_Back;
     ResponseUser['Response']['Result'].BoolValue:= true;
     ResponseUser['Response']['ResultMsg'].Value:= 'Прочитали сообщение';

     ResponseUser['Response']['Message']['ContactUserId'].Value:=         ContactUserId;
     ResponseUser['Response']['Message']['TypeUser'].Value:=              TypeUser;
     ResponseUser['Response']['Message']['IsMy'].Value:= BoolTostr(True);
     ResponseUser['Response']['Message']['IdLocalMessage'].Value:= IdLocalMessage;



     if TypeUser = ConstAmChat.TypeUser.User then
     begin
         ResponseOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_Read_Back;
         ResponseOthers['Response']['Result'].BoolValue:= true;
         ResponseOthers['Response']['ResultMsg'].Value:= 'Контакт Прочитал ваше сообщение';

         ResponseOthers['Response']['Message']['ContactUserId'].Value:=         UserId;
         ResponseOthers['Response']['Message']['TypeUser'].Value:=              'User';
         ResponseOthers['Response']['Message']['IsMy'].Value:= BoolTostr(False);
         ResponseOthers['Response']['Message']['IdLocalMessage'].Value:= IdLocalMessage;
         IsSendOthers:=true;

         Bh.GetListActivPort_O(ListActiv,ContactUserId,ListSendPort);


     end
     else IsSendOthers:=False;






    //  ContactAdd['Message']['ReadLastLocalIdMy'].Value:= AmStr(CounterLocalId);


end;





procedure TAmChatServerBaza.UserSend_FilesPars(ContentJson:string;var MessageFileParam:TMessageFileParam);
var FileObj,Hob:TJsonObject;
    I:integer;
    Fn:TMessageFileNameParam;
begin
    FileObj:= AmJson.LoadObjectText(ContentJson);
    try

      MessageFileParam.Id_Photo10:=        FileObj['IdPhoto10'].Value;
      MessageFileParam.Id_Photo500:=       FileObj['IdPhoto500'].Value;
      MessageFileParam.Id_File:=           FileObj['IdFile'].Value;
      MessageFileParam.Comment:=           FileObj['Comment'].Value;
      MessageFileParam.CollageSizeMax:=    FileObj['CollageSizeMax'].Value;
      MessageFileParam.CollageCountFile:=  FileObj['CollageCountFile'].Value;



          for I := 0 to FileObj['ListFileOther'].Count-1 do
          begin
           Hob:=  FileObj['ListFileOther'].Items[i];

           Fn.FileName:= Hob['FileName'].Value;
           Fn.Size:= Hob['Size'].Value;
           Fn.Rect:='';
           MessageFileParam.ListFileOther.Add(Fn);
          end;

          for I := 0 to FileObj['ListFilePhoto'].Count-1 do
          begin
           Hob:=  FileObj['ListFilePhoto'].Items[i];

           Fn.FileName:= Hob['FileName'].Value;
           Fn.Size:= Hob['Size'].Value;
           Fn.Rect:=Hob['Rect'].Value;
           MessageFileParam.ListFilePhoto.Add(Fn);
          end;
    finally
      FileObj.Free;
    end;
end;
function TAmChatServerBaza.UserSend_VoiceSave(IndexAcc:integer;ObjAcc:TjsonObject;UserId:string;ContentJson:string;var MessageVoiceParam:TMessageVoiceParam):boolean;
var VoiceObj:TJsonObject;
begin

    VoiceObj:= AmJson.LoadObjectText(ContentJson);
    try
      MessageVoiceParam.VoiceId:=           VoiceObj['VoiceId'].Value;
      MessageVoiceParam.VoiceSpectrJson:=   VoiceObj['VoiceSpectrJson'].Value;
      MessageVoiceParam.VoiceLength:=       VoiceObj['VoiceLength'].Value;
      MessageVoiceParam.VoiceCaption:=      VoiceObj['VoiceCaption'].Value;
      MessageVoiceParam.VoiceTimerSecond:=  VoiceObj['VoiceTimerSecond'].Value;


    finally
      VoiceObj.Free;
    end;
    Result:= FileExists(FDirVoice+MessageVoiceParam.VoiceId+ConstAmChat.NameFileType.eVoiceExt);


end;


procedure TAmChatServerBaza.SVR_Message_History_Offset(
                                                  IndexAcc:integer;
                                                  ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;
                                                  var IsSendOthers:boolean;
                                                  var ListSendPort:TAmBth.TMainResult.TListPort);
var UserId,TypeUser,ContactUserId,FilePath,FileName:string;
IndexContactUser,IndexToListContact,IndexContactUserToListContact:integer;
MsgHistory:Tjsonobject;

  procedure Local_ListUsers;
  var i:integer;
  IdIn:string;
  IndexIn:integer;
  begin
     for I := 0 to MsgHistory['Data']['ListUser']['array'].Count-1 do
     begin
      IdIn:=  MsgHistory['Data']['ListUser']['array'].Items[i].Value;
      if IdIn=UserId then continue;

      IndexIn:= bh.SerchUser_Id(IdIn,IdIn);
      if IndexIn<0 then continue;


      ResponseUser['Response']['Users'][IdIn]['Id'].Value:=                      IdIn;
      ResponseUser['Response']['Users'][IdIn]['TypeUser'].Value:=               'User';
      ResponseUser['Response']['Users'][IdIn]['ScreenName'].Value:=             Bh.GetUser_index(IndexIn,'ScreenName');
      ResponseUser['Response']['Users'][IdIn]['UserName'].Value:=               Bh.GetUser_index(IndexIn,'UserName');
      ResponseUser['Response']['Users'][IdIn]['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexIn,'Photos','MainId');
      ResponseUser['Response']['Users'][IdIn]['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexIn,'Photos','MainData');

     end;

  end;
  var Message_StartIdLocal,Message_GetCount:integer;
  Message_IndexLast:integer;
  Message_IsBegin:boolean;
begin
       ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_History_Back;
       ResponseUser['Response']['Result'].BoolValue:= false;
       ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить историю чата';
       IsSendOthers:=false;
       UserId:= ObjAcc['Id'].Value;  // id текущего юзера  т.е я
       TypeUser:= InputObj['TypeUser'].Value;
       ContactUserId:=InputObj['ContactUserId'].Value; // id контакта для которого получить историю переписки т.е он
       Message_StartIdLocal:=AmInt(InputObj['StartIdLocal'].Value,-1);
       Message_GetCount:=AmInt(InputObj['GetCount'].Value,0);
       Message_IsBegin:=  AmBool(InputObj['IsBegin'].Value,false);

       if (Message_StartIdLocal<0) or (Message_GetCount<=0) then exit;
       

       if not ConstAmChat.TypeUser.Check(TypeUser) then  exit;

      IndexContactUser:=-1;   // index в гл базе он
      IndexToListContact:=-1;  // его index в списке контактов у меня
      IndexContactUserToListContact:=-1;  // мой index в списке контактов у него

      if TypeUser = ConstAmChat.TypeUser.User then
      begin
          FilePath:=FDirMessageUser;
          IndexContactUser:= Bh.SerchUser_Pole('Id',ContactUserId,ContactUserId);

          if IndexContactUser<0 then  exit;

          if Amint(UserId,-1)<0 then  exit;
          if Amint(ContactUserId,-1)<0 then  exit;
          if Amint(UserId)<  Amint(ContactUserId)  then    FileName:= 'message_'+UserId+'_'+ ContactUserId +'_.json'
          else                                          FileName:= 'message_'+ContactUserId+'_'+UserId +'_.json';

      end
      else if TypeUser = ConstAmChat.TypeUser.Groop then
      begin
          FilePath:=FDirMessageGroop;
          IndexContactUser:= Bh.SerchGroop_Pole('Id',ContactUserId,ContactUserId);

          if IndexContactUser<0 then  exit;

          if Amint(UserId,-1)<0 then  exit;
          if Amint(ContactUserId,-1)<0 then  exit;
          FileName:= 'message_'+ ContactUserId +'_.json';
      end
      else exit;




       // его index в списке контактов у меня
      IndexToListContact:= Bh.ContactsUsers_SerchIndex(ObjAcc['Contacts'],ContactUserId,TypeUser);

     //  мой index в списке контактов у него
      if TypeUser = ConstAmChat.TypeUser.User then
      IndexContactUserToListContact:= Bh.ContactsUsers_SerchIndex(ObjUsers['Data']['List'].Items[IndexContactUser]['Contacts'],UserId,TypeUser);

      MsgHistory:= amJson.LoadObjectFile(FilePath+FileName);
     try
        ResponseUser['Response']['StartIdLocal'].Value:=AmStr(Message_StartIdLocal);
        ResponseUser['Response']['GetCount'].Value:=AmStr(Message_GetCount);
        ResponseUser['Response']['IsBegin'].Value:=AmStr(Message_IsBegin);
        if Message_IsBegin then
        begin
          Message_IndexLast:= MsgHistory['Data'].A['Msg'].Count-1;
          if Message_IndexLast>=0 then
            ResponseUser['Response']['Message']['List'].A['Msg']
            .AssignRevers(MsgHistory['Data'].A['Msg'],Message_IndexLast,Message_GetCount);

           Local_ListUsers;


           if TypeUser = ConstAmChat.TypeUser.User then
           begin

             ResponseUser['Response']['Contact']['Id'].Value:=                     ContactUserId;
             ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;
             ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetUser_index(IndexContactUser,'ScreenName');
             ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetUser_index(IndexContactUser,'UserName');
             ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexContactUser,'Photos','MainId');
             ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexContactUser,'Photos','MainData');

           end
           else if TypeUser = ConstAmChat.TypeUser.Groop then
           begin

             ResponseUser['Response']['Contact']['Id'].Value:=                     ContactUserId;
             ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;
             ResponseUser['Response']['Contact']['TypeGroopPrivacy'].Value:=       Bh.GetGroop_index(IndexContactUser,'TypeGroopPrivacy');
             ResponseUser['Response']['Contact']['IsAdmin'].Value:=                AmStr(Bh.GetGroop_index(IndexContactUser,'IdUserAdmin') = UserId);

             ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexContactUser,'ScreenName');
             ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexContactUser,'UserName');
             ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexContactUser,'Photos','MainId');
             ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexContactUser,'Photos','MainData');

           end;


           if IndexToListContact>=0 then
           begin

                ResponseUser['Response']['Contact']['LastActivData'].Value:=
                ObjAcc['Contacts']['List'].Items[IndexToListContact]['LastActivData'].Value ;

                ResponseUser['Response']['Contact']['Message']['LastId'].Value:=
                ObjAcc['Contacts']['List'].Items[IndexToListContact]['Message']['LastId'].Value;

                ResponseUser['Response']['Contact']['Message']['ReadLastLocalIdMy'].Value:=
                ObjAcc['Contacts']['List'].Items[IndexToListContact]['Message']['ReadLastLocalIdMy'].Value;

              if (IndexContactUserToListContact>=0)
              and (TypeUser = ConstAmChat.TypeUser.User) then
              begin
                ResponseUser['Response']['Contact']['Message']['ReadLastLocalIdHim'].Value:=
                ObjUsers['Data']['List'].Items[IndexContactUser]['Contacts']['List']
                .Items[IndexContactUserToListContact]['Message']['ReadLastLocalIdMy'].Value;

              end;
           end
           else ResponseUser['Response']['Contact']['LastActivData'].Value:='NotContact';

          ResponseUser['Response']['Result'].BoolValue:= true;
          ResponseUser['Response']['ResultMsg'].Value:= 'История чата';
        end
        else
        begin
              if  (Message_StartIdLocal>0) then
              begin
                  if bh.MessageHistory_IndexOfLocalId(MsgHistory,AmStr(Message_StartIdLocal),Message_IndexLast) then
                  begin

                  ResponseUser['Response']['Message']['List'].A['Msg']
                  .AssignRevers(MsgHistory['Data'].A['Msg'],Message_IndexLast,Message_GetCount);



                  end;
              end;
            ResponseUser['Response']['Contact']['Id'].Value:=                     ContactUserId;
            ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;
            if TypeUser = ConstAmChat.TypeUser.Groop then
            begin
             ResponseUser['Response']['Contact']['TypeGroopPrivacy'].Value:=       Bh.GetGroop_index(IndexContactUser,'TypeGroopPrivacy');
             ResponseUser['Response']['Contact']['IsAdmin'].Value:=                AmStr(Bh.GetGroop_index(IndexContactUser,'IdUserAdmin') = UserId);
            end;
            ResponseUser['Response']['Result'].BoolValue:= true;
            ResponseUser['Response']['ResultMsg'].Value:= 'История чата';

        end;




     // JSonAssing.A['List'].AssignRevers(JSon.a['List'],c,Strtoint(Edit2.Text));







     finally
       MsgHistory.Free;
     end;


end;
procedure TAmChatServerBaza.SVR_Message_History(
                                                  IndexAcc:integer;
                                                  ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;
                                                  var IsSendOthers:boolean;
                                                  var ListSendPort:TAmBth.TMainResult.TListPort);
var UserId,TypeUser,ContactUserId,FilePath,FileName:string;
IndexContactUser,IndexToListContact,IndexContactUserToListContact:integer;
MsgHistory:Tjsonobject;

  procedure Local_ListUsers;
  var i:integer;
  IdIn:string;
  IndexIn:integer;
  begin
     for I := 0 to MsgHistory['Data']['ListUser']['array'].Count-1 do
     begin
      IdIn:=  MsgHistory['Data']['ListUser']['array'].Items[i].Value;
      if IdIn=UserId then continue;

      IndexIn:= bh.SerchUser_Id(IdIn,IdIn);
      if IndexIn<0 then continue;


      ResponseUser['Response']['Users'][IdIn]['Id'].Value:=                      IdIn;
      ResponseUser['Response']['Users'][IdIn]['TypeUser'].Value:=               'User';
      ResponseUser['Response']['Users'][IdIn]['ScreenName'].Value:=             Bh.GetUser_index(IndexIn,'ScreenName');
      ResponseUser['Response']['Users'][IdIn]['UserName'].Value:=               Bh.GetUser_index(IndexIn,'UserName');
      ResponseUser['Response']['Users'][IdIn]['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexIn,'Photos','MainId');
      ResponseUser['Response']['Users'][IdIn]['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexIn,'Photos','MainData');

     end;

  end;
begin
       ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Message_History_Back;
       ResponseUser['Response']['Result'].BoolValue:= false;
       ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить историю чата';
       exit;
       IsSendOthers:=false;
       UserId:= ObjAcc['Id'].Value;  // id текущего юзера  т.е я
       TypeUser:= InputObj['TypeUser'].Value;
       ContactUserId:=InputObj['ContactUserId'].Value; // id контакта для которого получить историю переписки т.е он
       if not ConstAmChat.TypeUser.Check(TypeUser) then  exit;

      IndexContactUser:=-1;   // index в гл базе он
      IndexToListContact:=-1;  // его index в списке контактов у меня
      IndexContactUserToListContact:=-1;  // мой index в списке контактов у него

      if TypeUser = ConstAmChat.TypeUser.User then
      begin
          FilePath:=FDirMessageUser;
          IndexContactUser:= Bh.SerchUser_Pole('Id',ContactUserId,ContactUserId);

          if IndexContactUser<0 then  exit;

          if Amint(UserId,-1)<0 then  exit;
          if Amint(ContactUserId,-1)<0 then  exit;
          if Amint(UserId)<  Amint(ContactUserId)  then    FileName:= 'message_'+UserId+'_'+ ContactUserId +'_.json'
          else                                          FileName:= 'message_'+ContactUserId+'_'+UserId +'_.json';

      end
      else if TypeUser = ConstAmChat.TypeUser.Groop then
      begin
          FilePath:=FDirMessageGroop;
          IndexContactUser:= Bh.SerchGroop_Pole('Id',ContactUserId,ContactUserId);

          if IndexContactUser<0 then  exit;

          if Amint(UserId,-1)<0 then  exit;
          if Amint(ContactUserId,-1)<0 then  exit;
          FileName:= 'message_'+ ContactUserId +'_.json';
      end
      else exit;
           



       // его index в списке контактов у меня
      IndexToListContact:= Bh.ContactsUsers_SerchIndex(ObjAcc['Contacts'],ContactUserId,TypeUser);

     //  мой index в списке контактов у него
      if TypeUser = ConstAmChat.TypeUser.User then
      IndexContactUserToListContact:= Bh.ContactsUsers_SerchIndex(ObjUsers['Data']['List'].Items[IndexContactUser]['Contacts'],UserId,TypeUser);

      MsgHistory:= amJson.LoadObjectFile(FilePath+FileName);
     try
     // ResponseUser['Response']['Message']['TypeUser'].value:=TypeUser;
     // ResponseUser['Response']['Message']['ContactUserId'].value:=ContactUserId;
      ResponseUser['Response']['Message']['List'].A['Msg'].Assign(MsgHistory['Data'].A['Msg']);


      //т.к сейчас мы находимя в процедуре получения истории переписки
      // то нужно так же получить те сообщения которые он не прочитал что бы мне показать их
      // IndexContactUserToListContact для этого что бы обратится
      //к нему в аккаунт и взять то что я отправил а он не прочел

      {if IndexContactUserToListContact>0 then
      begin
        // копируем все id непрочитанных им сообщений
        ResponseUser['Response']['Message']['List'].A['NoReadList']
        .Assign(

            ListUser['Data']['List'].Items[IndexContactUser]['Contacts']
            ['List'].Items[IndexContactUserToListContact].A['NoReadList']
        );
      end;}




       Local_ListUsers;

       if TypeUser = ConstAmChat.TypeUser.User then
       begin

         ResponseUser['Response']['Contact']['Id'].Value:=                     ContactUserId;
         ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;
         ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetUser_index(IndexContactUser,'ScreenName');
         ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetUser_index(IndexContactUser,'UserName');
         ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetUser_index2(IndexContactUser,'Photos','MainId');
         ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetUser_index2(IndexContactUser,'Photos','MainData');

       end
       else if TypeUser = ConstAmChat.TypeUser.Groop then
       begin

         ResponseUser['Response']['Contact']['Id'].Value:=                     ContactUserId;
         ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;
         ResponseUser['Response']['Contact']['ScreenName'].Value:=             Bh.GetGroop_index(IndexContactUser,'ScreenName');
         ResponseUser['Response']['Contact']['UserName'].Value:=               Bh.GetGroop_index(IndexContactUser,'UserName');
         ResponseUser['Response']['Contact']['Photos']['MainId'].Value:=       Bh.GetGroop_index2(IndexContactUser,'Photos','MainId');
         ResponseUser['Response']['Contact']['Photos']['MainData'].Value:=     Bh.GetGroop_index2(IndexContactUser,'Photos','MainData');

       end;


       if IndexToListContact>=0 then
       begin

            ResponseUser['Response']['Contact']['LastActivData'].Value:=
            ObjAcc['Contacts']['List'].Items[IndexToListContact]['LastActivData'].Value ;

            ResponseUser['Response']['Contact']['Message']['LastId'].Value:=
            ObjAcc['Contacts']['List'].Items[IndexToListContact]['Message']['LastId'].Value;

            ResponseUser['Response']['Contact']['Message']['ReadLastLocalIdMy'].Value:=
            ObjAcc['Contacts']['List'].Items[IndexToListContact]['Message']['ReadLastLocalIdMy'].Value;

          if (IndexContactUserToListContact>=0)
          and (TypeUser = ConstAmChat.TypeUser.User) then
          begin
            ResponseUser['Response']['Contact']['Message']['ReadLastLocalIdHim'].Value:=
            ObjUsers['Data']['List'].Items[IndexContactUser]['Contacts']['List']
            .Items[IndexContactUserToListContact]['Message']['ReadLastLocalIdMy'].Value;

          end;
       end
       else ResponseUser['Response']['Contact']['LastActivData'].Value:='NotContact';


      ResponseUser['Response']['Result'].BoolValue:= true;
      ResponseUser['Response']['ResultMsg'].Value:= 'История чата';
     finally
       MsgHistory.Free;
     end;


end;







procedure TAmChatServerBaza.SVR_Contacts_GetList(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var  RespObjBack,RespNewContact,ObjAccItem:TjsonObject;
I:integer;
sourID,sourTypeUser:string;
sourIndex,ListActivIndexPort:integer;
begin


    try

          ObjAcc['Contacts']['UpData']:=ClientDataNow;
          //Bh.SetUser_index2(IndexAcc,'Contacts','UpData',FDataNow);

          ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Profile_GetListContacts_Back;
          ResponseUser['Response']['Result'].BoolValue:= true;
          ResponseUser['Response']['ResultMsg'].Value:= 'Контакты получены';
          RespObjBack:=  ResponseUser['Response']['Contacts'];


         ///////////////////////////////////////////////////////////
         RespObjBack['UpData'].Value:= ClientDataNow;
          // строкое представление списка контактов с id
         RespObjBack['ListString'].Value:= ObjAcc['Contacts']['ListString'].Value;



         for I := 0 to  ObjAcc['Contacts']['List'].Count-1 do
         begin

            ObjAccItem:= ObjAcc['Contacts']['List'].Items[i];
            sourTypeUser:= ObjAccItem['TypeUser'].Value;
            sourID:=       ObjAccItem['Id'].Value;


            if sourTypeUser = ConstAmChat.TypeUser.User then
            begin
                sourIndex:= Bh.SerchUser_Pole('Id',sourID,sourID);
                if sourIndex<0 then continue;

                RespNewContact:=RespObjBack.A['List'].AddObject;
                RespNewContact['Id'].Value:=                   sourID;
                RespNewContact['TypeUser'].Value:=             sourTypeUser;
                RespNewContact['ScreenName'].Value:=           Bh.GetUser_index(sourIndex,'ScreenName');
                RespNewContact['UserName'].Value:=             Bh.GetUser_index(sourIndex,'UserName');
                RespNewContact['Photos']['MainId'].Value:=     Bh.GetUser_index2(sourIndex,'Photos','MainId');
                RespNewContact['Photos']['MainData'].Value:=   Bh.GetUser_index2(sourIndex,'Photos','MainData');
                // дата последнего сообщения в диалоге нужно что бы вывести контакт выше или ниже в интерфейсе
                RespNewContact['LastActivData'].Value:=        ObjAccItem['LastActivData'].Value;

                //id последне прочитанного сообщения и id последнего сообщения в диалоге
               //передам в запросе истроии диалога  RespNewContact['Message']['ReadLastLocalIdHim'].Value:= ObjAccItem['Message']['ReadLastLocalIdHim'].Value;
                RespNewContact['Message']['ReadLastLocalIdMy'].Value:=  ObjAccItem['Message']['ReadLastLocalIdMy'].Value;
                RespNewContact['Message']['LastId'].Value:=   ObjAccItem['Message']['LastId'].Value;



                ListActivIndexPort:=ListActiv.SerchId(sourID);
                if ListActivIndexPort>=0 then
                begin
                  RespNewContact['TypeOnline'].Value:=        ListActiv.List[ListActivIndexPort].TypeOnline;

                  if ListActiv.List[ListActivIndexPort].TypeOnline =  ConstAmChat.TypeOnline.Online then
                  RespNewContact['StatusPrints'].Value:=        BoolTostr(ListActiv.List[ListActivIndexPort].StatusPrints)
                  else
                  RespNewContact['StatusPrints'].Value:=  BoolTostr(False);
                end
                else
                begin
                    RespNewContact['StatusOnline'].Value:=  BoolTostr(False);
                    RespNewContact['StatusPrints'].Value:=  BoolTostr(False);
                end;
            end
            else if sourTypeUser = ConstAmChat.TypeUser.Groop then
            begin
                sourIndex:= Bh.SerchGroop_Pole('Id',sourID,sourID);
                if sourIndex<0 then continue;

                RespNewContact:=RespObjBack.A['List'].AddObject;
                RespNewContact['Id'].Value:=                   sourID;
                RespNewContact['TypeUser'].Value:=             sourTypeUser;
                RespNewContact['ScreenName'].Value:=           Bh.GetGroop_index(sourIndex,'ScreenName');
                RespNewContact['UserName'].Value:=             Bh.GetGroop_index(sourIndex,'UserName');
                RespNewContact['Photos']['MainId'].Value:=     Bh.GetGroop_index2(sourIndex,'Photos','MainId');
                RespNewContact['Photos']['MainData'].Value:=   Bh.GetGroop_index2(sourIndex,'Photos','MainData');
                // дата последнего сообщения в диалоге нужно что бы вывести контакт выше или ниже в интерфейсе
                RespNewContact['LastActivData'].Value:=        ObjAccItem['LastActivData'].Value;

                //id последне прочитанного сообщения и id последнего сообщения в диалоге
               //передам в запросе истроии диалога  RespNewContact['Message']['ReadLastLocalIdHim'].Value:= ObjAccItem['Message']['ReadLastLocalIdHim'].Value;
                RespNewContact['Message']['ReadLastLocalIdMy'].Value:=  ObjAccItem['Message']['ReadLastLocalIdMy'].Value;
                RespNewContact['Message']['LastId'].Value:=   ObjAccItem['Message']['LastId'].Value;

            end;









           //устарело RespNewContact.A['NoReadList'].Assign(ObjAccItem.A['NoReadList']); // кол во не прочитанных
           // showmessage(Fdatanow);
         end;





         //ResponseUser['Response']['Back']['Users']   TEncoding
    finally

    end;


end;
function  TAmChatServerBaza.Contacts_Add(ObjAcc:TjsonObject;TypeUser:string;IdUserAdd:string):TjsonObject; //ContactAdd
begin
   Result:=Bh.ContactsUsers_MoviToFerst(ObjAcc['Contacts'],IdUserAdd,TypeUser);
   Result['LastActivData'].Value:=ClientDataNow;
end;
function  TAmChatServerBaza.Contacts_Delete(ObjAcc:TjsonObject;TypeUser:string;IdUserDelete:string):boolean;
begin
   Result:=Bh.ContactsUsers_Delete(ObjAcc['Contacts'],IdUserDelete,TypeUser);
end;
procedure TAmChatServerBaza.SVR_ContactDelete (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var

    UserId,DeleteUserId,TypeUser:string;
    MsgHistory:TJsonObject;
    MsgHistroryIndex:integer;


     procedure Local_Response_User(Result:boolean;Str:string);
     begin
         ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Profile_DeleteContacts_Back;
         ResponseUser['Response']['Result'].BoolValue:= Result;
         ResponseUser['Response']['ResultMsg'].Value:= Str;

         if Result then
         begin
         ResponseUser['Response']['Contact']['Id'].Value:=                     DeleteUserId;
         ResponseUser['Response']['Contact']['TypeUser'].Value:=               TypeUser;


         end;

     end;

begin
       UserId:=  Bh.GetUser_index(IndexAcc,'Id');

       DeleteUserId:= InputObj['Id'].Value;
       TypeUser:= InputObj['TypeUser'].Value;



      if TypeUser = ConstAmChat.TypeUser.User then
      begin

      end
      else if TypeUser = ConstAmChat.TypeUser.Groop then
      begin
          MsgHistory:= amJson.LoadObjectFile(FDirMessageGroop+'message_'+ DeleteUserId +'_.json');
          try
          MsgHistroryIndex:=Bh.MessageHistory_UserDelete(MsgHistory,UserId);
          MsgHistory.SaveToFile(FDirMessageGroop+'message_'+ DeleteUserId +'_.json');
          finally
          MsgHistory.Free;
          end;


      end
      else exit;

     //удаление с базы  контакт юзера
      if  Contacts_Delete(  ObjAcc, TypeUser,DeleteUserId) then
      begin
       Local_Response_User(True,'Удален контакт');
      end
      else
      begin

       Local_Response_User(True,'У вас нет такого контакта');
      end;

end;





procedure TAmChatServerBaza.SVR_File_GetIdBeforeUpload (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);

var
   FileGetIdParam:integer;
   function GetIdFiles(NameFileType,DefDir:string):string;
   var Counter,i:integer;
   NameExt:string;
   begin
      if not ConstAmChat.NameFileType.checkName(NameFileType) then exit('');
      NameExt:= ConstAmChat.NameFileType.GetExt(NameFileType);

      i:=0;
      while True do
      begin
        inc(i);
        Result:='';
        Counter:=Amint(ObjAcc[NameFileType+'s']['CountId'].Value,0);
        Inc(Counter);
        ObjAcc[NameFileType+'s']['CountId'].Value:= AmStr(Counter);
        Result:=ObjAcc['Id'].Value+'_'+AmStr(Counter);
        if not FileExists(DefDir+Result+NameExt) then break;
        if i>100 then break;
      end;

   end;
   function  Local_SetResult(R:boolean):boolean;
   begin
      if R then
      begin
       ResponseUser['Response']['Result'].BoolValue:= true;
       ResponseUser['Response']['ResultMsg'].Value:= 'Id для загрузки получено';
      end
      else
      begin
       ResponseUser['Response']['Result'].BoolValue:= false;
       ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить Id для загрузки файлов';
      end;
   end;
   function  Local_Voice:boolean;
   var StrFileId:string;
   begin

      StrFileId:= GetIdFiles(ConstAmChat.NameFileType.nVoice,FDirVoice);
      ResponseUser['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nVoice]['Id'].Value:= StrFileId;
      Result:=Bth_CheckIdFileValid(StrFileId);
   end;
   function  Local_Zip:boolean;
   var StrFileId:string;
   begin
      StrFileId:= GetIdFiles(ConstAmChat.NameFileType.nFile,FDirFiles);
      ResponseUser['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nFile]['Id'].Value:= StrFileId;
      Result:=Bth_CheckIdFileValid(StrFileId);
   end;
   function  Local_Photo:boolean;
   var StrFileId:string;
   begin
      StrFileId:= GetIdFiles(ConstAmChat.NameFileType.nPhoto,FDirPhotos);
      ResponseUser['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nPhoto]['MiniId'].Value:= StrFileId;
      Result:=Bth_CheckIdFileValid(StrFileId);



      StrFileId:= GetIdFiles(ConstAmChat.NameFileType.nPhoto,FDirPhotos);
      ResponseUser['Response']['FileGetIdParam']
      [ConstAmChat.NameFileType.nPhoto]['MaxId'].Value:= StrFileId;

      if  Result then
      Result:=Bth_CheckIdFileValid(StrFileId);
   end;
   function  Local_PhotoAndZip:boolean;
   begin
       Result:=Local_Zip;
       if  Result then
       Result:=Local_Photo;
   end;

begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.File_GetIdBeforeUpload_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;
     ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить Id для загрузки файлов';


     FileGetIdParam:=AmInt(InputObj['Param'].Value,0);
     ResponseUser['Response']['FileGetIdParam']['Param'].Value:= AmStr(FileGetIdParam);

     if      FileGetIdParam = ConstAmChat.FileGetIdParam.Voice then       Local_SetResult(Local_Voice)
     else if FileGetIdParam = ConstAmChat.FileGetIdParam.Zip then         Local_SetResult(Local_Zip)
     else if FileGetIdParam = ConstAmChat.FileGetIdParam.Photo then       Local_SetResult(Local_Photo)
     else if FileGetIdParam = ConstAmChat.FileGetIdParam.PhotoAndZip then Local_SetResult(Local_PhotoAndZip)
     else ;


end;
 {
procedure TAmChatServerBaza.SVR_GetIdFileUpload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var CountId,i:integer;
FileId:string;
begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.GetIdFileUpload_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;
     ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось получить Id для загрузки файла';
      i:=0;
      while True do
      begin
         CountId:=AmInt( ObjAcc['Files']['CountId'].Value ,0);
         inc(CountId);
         ObjAcc['Files']['CountId'].Value:=AmStr(CountId);
         FileId:='File'+ObjAcc['Id']+'_'+AmStr(CountId);
         if not FileExists(FDirFiles+FileId+'.zip') then break;
         inc(i);
         if i>100 then
         begin
           FileId:='';
           break;
         end;

      end;
      if FileId<>'' then
      begin
       ResponseUser['Response']['Result'].BoolValue:= true;
       ResponseUser['Response']['ResultMsg'].Value:= 'Id для загрузки получено';
       ResponseUser['Response']['Profile']['NewFile']['FileId'].Value:= FileId;
      end;

end; }

procedure TAmChatServerBaza.SVR_SetPhotoProfile(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var
ObjHelp:TjsonObject;
Fn,PhotoId:string;

begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.SetPhotoProfile_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;




       PhotoId:= InputObj['PhotoId'].Value;

       if ConstAmChat.CheckIdFile(PhotoId) then
       begin
          Fn:= FDirPhotos+PhotoId+ConstAmChat.NameFileType.ePhotoExt;
          if FileExists(Fn) then
          begin
             if not InputObj['IsMain'].IsNull and InputObj['IsMain'].BoolValue then
             begin
                ObjAcc['Photos']['MainId']:=PhotoId;
                ResponseUser['Response']['Profile']['IsMain'].BoolValue:= true;
             end
             else ResponseUser['Response']['Profile']['IsMain'].BoolValue:= false;

                 ResponseUser['Response']['Result'].BoolValue:= true;
                 ResponseUser['Response']['ResultMsg'].Value:= 'Фото загружено';
                 ResponseUser['Response']['Profile']['PhotoId'].Value:= PhotoId;
          end;
       end;
       
      //   ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось загрузить фото на сервере'


end;
{
procedure TAmChatServerBaza.SVR_NewPhotoUpload(IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var IsSendOthers:boolean;var ListSendPort:TAmBth.TMainResult.TListPort);
var PhotoCountId:integer;
ObjHelp:TjsonObject;
Stream:TMemoryStream;
PhotoBase64:string;
DataSave,PhotoId:string;
begin
     IsSendOthers:=false;
     ResponseUser['Response']['Idmsg'].IntValue:=  ConstAmChat.NewPhotoUpload_Back;
     ResponseUser['Response']['Result'].BoolValue:= false;
     Stream:= TMemoryStream.Create;
     try
       //новый index photo
       PhotoCountId:=AmInt( ObjAcc['Photos']['CountId'].Value ,0);
       inc(PhotoCountId);
       ObjAcc['Photos']['CountId'].Value:=AmStr(PhotoCountId);



       PhotoId:='Photo'+ObjAcc['Id']+'_'+AmStr(PhotoCountId);
       PhotoBase64:= InputObj['PhotoBase64'].Value;


        if AmBase64.Base64ToStream(Stream,PhotoBase64)
        and SavePhotoUserDisk(PhotoId+'.jpg',Stream) then
        begin



                 DataSave:= ClientDataNow;

                 if not InputObj['IsMain'].IsNull and InputObj['IsMain'].BoolValue then
                 begin
                   ObjAcc['Photos']['MainId']:=PhotoId;
                   ObjAcc['Photos']['MainData']:=DataSave;
                   ResponseUser['Response']['Profile']['NewPhoto']['IsMain'].BoolValue:= true;
                 end
                 else ResponseUser['Response']['Profile']['NewPhoto']['IsMain'].BoolValue:= false;

                 ResponseUser['Response']['Result'].BoolValue:= true;
                 ResponseUser['Response']['ResultMsg'].Value:= 'Фото загружено';
                 ResponseUser['Response']['Profile']['NewPhoto']['PhotoData'].Value:= DataSave;
                 ResponseUser['Response']['Profile']['NewPhoto']['PhotoId'].Value:= PhotoId;


                 ListUser['Data']['Photos'][PhotoId]:=DataSave;

                // ObjHelp:=ObjAcc['Photos'].A['List'].AddObject;
                // ObjHelp['Id']:=AmStr(PhotoCountId);
                 //ObjHelp['Data']:=DataSave;
                 //ObjHelp['PhotoId']:=PhotoId;




        end
        else ResponseUser['Response']['ResultMsg'].Value:= 'Не удалось загрузить фото на сервере'


        
     finally
       Stream.Free;
     end;





end; } {
function  TAmChatServerBaza.SaveStreamUserDisk(FullNameFile:string;MStream:TMemoryStream):boolean;
begin
    Result:= false;
    try
       MStream.SaveToFile(FullNameFile);
       Result:= true;
    except
       on E:Exception do
       LogMain.Log('Error TAmChatServerBaza.SaveStreamUserDisk '+FullNameFile +' '+E.Message);
    end;
end;
function  TAmChatServerBaza.LoingStreamUserDisk(FullNameFile:string;MStream:TMemoryStream):boolean;
begin
    Result:= false;
    try
       if fileexists(FullNameFile) then
       begin
        MStream.LoadFromFile(FullNameFile);
        if MStream.Size>0 then  Result:= true;
       end;

    except
       on E:Exception do
       LogMain.Log('Error TAmChatServerBaza.LoingStreamUserDisk '+FullNameFile +' '+E.Message);
    end;
end;
function  TAmChatServerBaza.SavePhotoUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
begin
                   Result:= SaveStreamUserDisk(FDirPhotos+NameFile,MStream);
end;
function  TAmChatServerBaza.LoingPhotoUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
begin
                   Result:= LoingStreamUserDisk(FDirPhotos+NameFile,MStream);
end;
function  TAmChatServerBaza.SaveVoiceUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
begin
                   Result:= SaveStreamUserDisk(FDirVoice+NameFile,MStream);
end;
function  TAmChatServerBaza.LoingVoiceUserDisk(NameFile:string;MStream:TMemoryStream):boolean;
begin
                   Result:= LoingStreamUserDisk(FDirVoice+NameFile,MStream);
end;
 }



    {Auth}
procedure TAmChatServerBaza.SetListAvtivPortForSendOthers(var ListPort:TAmBth.TMainResult.TListPort;
                                                          IndexNowAcc:integer);
    var I: Integer;
    IdUserLA:string;
    ObjNowUserBaza: Tjsonobject;
    ArrContact:TJsonArray;
begin
       ObjNowUserBaza:=ObjUsers['Data']['List'].Items[IndexNowAcc];
       if not Assigned(ObjNowUserBaza) or ObjNowUserBaza['Contacts'].IsNull then exit;
       ArrContact:= ObjNowUserBaza['Contacts'].A['List'];

       for I := 0 to ArrContact.Count-1 do
       begin
         if ArrContact[i]['TypeUser'].Value<>ConstAmChat.TypeUser.User then continue;
         IdUserLA:= ArrContact[i]['Id'].Value;
         Bh.GetListActivPort_O_N(ListActiv,IdUserLA,ListPort);
       end;




     {
        for I := 0 to ListActiv.List.Count-1 do
        begin
            // showmessage(ListActiv.List[i].port.ToString);
            if ListActiv.List[i].port=ClientPort then continue;
            if not (
                     (ListActiv.List[i].TypeOnline =  ConstAmChat.TypeOnline.Online)
                    // or
                    // (ListActiv.List[i].TypeOnline =  ConstAmChat.TypeOnline.Nearby)
                   ) then continue;
            IdUserLA:=  ListActiv.List[i].Id;
            if IdUserLA='' then continue;
            IndexContact:= Bh.SerchContactIndex(ObjNowUserBaza['Contacts'],IdUserLA,ConstAmChat.TypeUser.User);
            if IndexContact>=0 then
            ListPort.Add(ListActiv.List[i].port);


           {
            IndexUserBaza:=Bh.SerchUser_Pole('Id',IdUserLA,IdUserLA);
            if IndexUserBaza<0 then continue;
            ObjUserBaza:=ListUser['Data']['List'].Items[IndexUserBaza];
            if not Assigned(ObjUserBaza) or ObjUserBaza['Contacts'].IsNull then continue;
            IndexContact:= Bh.SerchContactIndex(ObjUserBaza['Contacts'],IdNowUser,ConstAmChat.TypeUser.User);
            if IndexContact>=0 then
            Result.ListPort.Add(ListActiv.List[i].port);  }

       { end; }

end;
function TAmChatServerBaza.SVR_Auth(Token,ScreenName,Password,PredId:string):TAmBth.TMainResult;
var IdNowUser:string;
    Index:integer;
    (*
    Procedure AdderListPort;
    var I: Integer;
    IdUserLA:string;
    IndexContact:integer;
    ObjNowUserBaza: Tjsonobject;
    begin
        ObjNowUserBaza:=ListUser['Data']['List'].Items[Index];
        if not Assigned(ObjNowUserBaza) or ObjNowUserBaza['Contacts'].IsNull then exit;

        for I := 0 to ListActiv.List.Count-1 do
        begin
            // showmessage(ListActiv.List[i].port.ToString);
            if ListActiv.List[i].port=FPortUser then continue;
            if not ListActiv.List[i].StatusOnline then continue;
            IdUserLA:=  ListActiv.List[i].Id;
            if IdUserLA='' then continue;
            IndexContact:= Bh.SerchContactIndex(ObjNowUserBaza['Contacts'],IdUserLA,ConstAmChat.TypeUser.User);
            if IndexContact>=0 then
            Result.ListPort.Add(ListActiv.List[i].port);


           {
            IndexUserBaza:=Bh.SerchUser_Pole('Id',IdUserLA,IdUserLA);
            if IndexUserBaza<0 then continue;
            ObjUserBaza:=ListUser['Data']['List'].Items[IndexUserBaza];
            if not Assigned(ObjUserBaza) or ObjUserBaza['Contacts'].IsNull then continue;
            IndexContact:= Bh.SerchContactIndex(ObjUserBaza['Contacts'],IdNowUser,ConstAmChat.TypeUser.User);
            if IndexContact>=0 then
            Result.ListPort.Add(ListActiv.List[i].port);  }

        end;
    end;
    *)

var
    ObjUser,ObjOthers:Tjsonobject;
    RAuth:boolean;

    OneClient:TAmBth.TListActiv.TOneClient;
begin
    Result.IsSendUser:=true;
    Result.TextOutputUser:='{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerAuth"}';
    Result.IsSendOthers:=false;
    Result.TextOutputOthers:= '{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerAuth"}';
    Result.ListPort.Clear;


  ObjUser:= Tjsonobject.Create;
  ObjOthers:= Tjsonobject.Create;
  try

     if ScreenName='' then RAuth:=Auth_Token(Index,Token)
     else RAuth:= Auth_Param(Index,ScreenName,Password,PredId);


     IdNowUser:=Bh.GetUser_index(Index,'Id');
     ObjUser['Response']['Idmsg'].IntValue:=  ConstAmChat.Auth_Back;


     if RAuth and (IdNowUser<>'')and (ClientIndexPort>=0) then
     begin
        ObjUser['Response']['Result'].BoolValue:=true;



        ObjUser['Response']['ResultMsg'].Value:= 'Успешная авторизация';

        if ScreenName<>'' then ObjUser['Response']['Auth']['Token'].Value:=  Auth_GetNewToken(Index)
        else ObjUser['Response']['Auth']['Token'].Value:= Token;

        ObjUser['Response']['Auth']['Hash'].Value:=  Auth_GetNewHash(Index);
        ObjUser['Response']['Auth']['Id'].Value:=  IdNowUser;
        ObjUser['Response']['Auth']['ScreenName'].Value:=  Bh.GetUser_index(Index,'ScreenName');
        ObjUser['Response']['Auth']['UserName'].Value:=  Bh.GetUser_index(Index,'UserName');
        ObjUser['Response']['Auth']['PhotoId'].Value:=  Bh.GetUser_index2(Index,'Photos','MainId');
        ObjUser['Response']['Auth']['PhotoData'].Value:=  Bh.GetUser_index2(Index,'Photos','MainData');
        ObjUser['Response']['Auth']['Contacts']['UpData'].Value:=  Bh.GetUser_index2(Index,'Contacts','UpData');


        OneClient:=ListActiv.List[ClientIndexPort];
        try
          OneClient.Id:= IdNowUser;
          OneClient.ScreenName:= Bh.GetUser_index(Index,'ScreenName');
          OneClient.Email:= Bh.GetUser_index(Index,'Email');
          OneClient.UserName:= Bh.GetUser_index(Index,'UserName');
          //OneClient.StatusOnline:= true;
          OneClient.TypeOnline :=  ConstAmChat.TypeOnline.Online;
          OneClient.StatusPrints:= false;

        finally
          ListActiv.List[ClientIndexPort]:=OneClient;
        end;
        ListActiv.ListId_Add(AmInt(IdNowUser,-1),ClientPort);


        Result.IsSendOthers:=true;
        ObjOthers['Response']['Idmsg'].IntValue:=  ConstAmChat.OnlineType_Back;
        ObjOthers['Response']['Result'].BoolValue:=true;
        ObjOthers['Response']['ResultMsg'].Value:= ''+Bh.GetUser_index(Index,'UserName')+ ' онлайн';
        ObjOthers['Response']['ResultAuth'].BoolValue:= true;

        ObjOthers['Response']['Online']['Id'].Value:=  IdNowUser;
        ObjOthers['Response']['Online']['ScreenName'].Value:=  Bh.GetUser_index(Index,'ScreenName');
        ObjOthers['Response']['Online']['UserName'].Value:=  Bh.GetUser_index(Index,'UserName');
        ObjOthers['Response']['Online']['TypeOnline'].Value :=ConstAmChat.TypeOnline.Online;


        Result.TextOutputOthers:= ObjOthers.ToJSON();

         SetListAvtivPortForSendOthers(Result.ListPort,Index);
       // AdderListPort;

     end
     else
     begin

        ObjUser['Response']['Result'].BoolValue:=false;
        if ScreenName<>'' then  ObjUser['Response']['ResultMsg'].Value:= 'Вы ввели не верный логин пароль'
        else              ObjUser['Response']['ResultMsg'].Value:= 'Требуется авторизация'

     end;

    Result.TextOutputUser:= ObjUser.ToJSON();
  finally
    ObjUser.Free;
    ObjOthers.Free;
  end;
     


end;
function TAmChatServerBaza.Auth_CheckHashFile(HashFile:string):integer;
var D:String;
begin
    Result:= 0;
    D:=ObjUsers['Data']['HashFiles'][HashFile].Value;
    if (D='') then exit(-1);
    if now < IncHour(AmDateTime(D,'01.01.2000 20:35:49:254'),1) then exit(1)
    else Result:=-2;
end;
function TAmChatServerBaza.Auth_Check(var IndexAcc:integer;Token,Hash:string):boolean;
var LocalHash:string;
begin
         Result:=Auth_Token(IndexAcc,Token);
         LocalHash:=Bh.GetUser_index(IndexAcc,'Hash');
         Result:=  Result and (Token<>'') and (Hash=LocalHash);
end;
function TAmChatServerBaza.Auth_Token(var Index:integer;Token:string):boolean;
var UId:string;
begin
     Index:=-1;
     if Token<>'' then
     begin
       UId :=ObjUsers['Data']['Tokens'][Token].Value;
       Index:=Bh.SerchUser_Pole('Token',Token,UId);
      
     end;
     Result:= (Index>=0) and (Bh.GetUser_Token(Index) = Token) and (UId = Bh.GetUser_index(index,'Id'));
    
end;
function TAmChatServerBaza.Auth_Param(var Index:integer;ScreenName,Password:string;aPreId:string):boolean;
var
    p:string;
begin
     Result:=false;
     Index:=-1;
     if ScreenName<>'' then
     begin
       if pos('@',ScreenName)<>0 then
       begin
           Index:=Bh.SerchUser_Email(ScreenName,aPreId);
           if Index<0 then  Index:=Bh.SerchUser_ScreenName(ScreenName,aPreId);
       end
       else
       begin
           Index:=Bh.SerchUser_ScreenName(ScreenName,aPreId)  ;
           if Index<0 then Index:=Bh.SerchUser_Email(ScreenName,aPreId);
       end;
     end;
     if Index>=0 then
     begin
         p:=Bh.GetUser_Password(Index);
         Result:= p=Password;
     end;
end;
function TAmChatServerBaza.Auth_GetNewToken(index:integer):string;
var
  I: Integer;
  OldToken:string;
begin
     

     for I := 0 to 10 do
      begin
        Result:=generatPass(25);
    
        
        if ObjUsers['Data']['Tokens'][Result].Value<> '' then Result:=''
        else 
        begin
          OldToken:= Bh.GetUser_index(index,'Token');
          if OldToken<>'' then
          ObjUsers['Data']['Tokens'].ObjectValue.Remove(OldToken);
          Bh.SetUser_index(index,'Token',Result);
          ObjUsers['Data']['Tokens'][Result].Value:=  Bh.GetUser_index(index,'Id');
          break;
        end;
      end;  

end;
function TAmChatServerBaza.Auth_GetNewHash(index:integer):string;
var
  I: Integer;
  OldHash:string;
begin
     

     for I := 0 to 10 do
      begin
        Result:=generatPass(25);

        if ObjUsers['Data']['Hashs'][Result].Value<> '' then Result:=''
        else 
        begin
          OldHash:= Bh.GetUser_index(index,'Hash');
          if OldHash<>'' then          
          ObjUsers['Data']['Hashs'].ObjectValue.Remove(OldHash);
          Bh.SetUser_index(index,'Hash',Result);
          ObjUsers['Data']['Hashs'][Result].Value:=  Bh.GetUser_index(index,'Id');
          break;
        end;

                
        {if  SerchUser_Pole('Hash',Result,'') >=0 then Result:=''
        else
        begin 
          SetUser_index(index,'Hash',Result);
          break;
        end;}
      end; 

end;




function TAmChatServerBaza.SVR_UpConnect(ConnectValue:string):TAmBth.TMainResult;
var ResultObj:Tjsonobject;
begin
    Result.IsSendUser:=true;
    Result.TextOutputUser:='{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerRegUser"}}';
    Result.IsSendOthers:=false;
    Result.TextOutputOthers:= '{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerRegUser"}}';
    Result.ListPort.Clear;
    ResultObj:= Tjsonobject.Create;
    try
        ResultObj['Response']['Idmsg'].IntValue:=  ConstAmChat.UpConnect_Back;
        ResultObj['Response']['Result'].BoolValue:=true;
        ResultObj['Response']['ResultMsg'].Value:= 'Connected';
        ResultObj['Response']['ConnectValue'].Value:= 'Connected';
        Result.TextOutputUser:= ResultObj.ToJSON();
    finally
    ResultObj.Free;
    end;
end;


         {RegUser}

function TAmChatServerBaza.SVR_RegUser(ScreenName,Password,Password2,Email,UserName:string):TAmBth.TMainResult;
var ResultObj:Tjsonobject;
RScreenName,REmail,RPassword,RUserName:boolean;
NewID:string;
  procedure Local_AddGroop(idGr:string);
  var IndexGr:integer;
      IndexAdmin:integer;
      IdAdmin:string;
      ObjAdmin,Input,R1,R2:TJsonObject;
      IsNeedSend:boolean;
      List:TAmBth.TMainResult.TListPort;
  begin
       IndexGr:= bh.SerchGroop_Pole('Id',IdGr,IdGr);
       if IndexGr<0 then exit;
       IdAdmin:=bh.GetGroop_index(IndexGr,'IdUserAdmin');
       IndexAdmin:= bh.SerchUser_Id(IdAdmin,IdAdmin);
       if IndexAdmin<0 then exit;
       ObjAdmin:=ObjUsers['Data']['List'].Items[IndexAdmin];
       Input:=TJsonObject.Create;
       R1:= TJsonObject.Create;
       R2:= TJsonObject.Create;
       IsNeedSend:=false;
       List.Clear;
       try
         Input['GroopId'].Value:=idGr;
         Input['AddUserId'].Value:=NewID;
         SVR_Groop_AddUser(IndexAdmin,ObjAdmin,Input,R1,R2,IsNeedSend,List);
       finally
         Input.Free;
         R1.Free;
         R2.Free;
       end;


  end;
begin
    Result.IsSendUser:=true;
    Result.TextOutputUser:='{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerRegUser"}}';
    Result.IsSendOthers:=false;
    Result.TextOutputOthers:= '{"Response":{"Idmsg":10001,"ResultMsg":"Error ServerRegUser"}}';
    Result.ListPort.Clear;

  ResultObj:= Tjsonobject.Create;
  try

    RScreenName:=RegUser_CheckScreenName(ScreenName);
    REmail:=RegUser_CheckEmail(Email);
    RPassword:=RegUser_CheckPassword(Password,Password2);
    RUserName:=RegUser_CheckUserName(UserName);


    ResultObj['Response']['Idmsg'].IntValue:=  ConstAmChat.RegUser_Back;
    if RScreenName and REmail and RPassword and RUserName then
    begin




        NewID:=RegUser_AddToListUser(ScreenName,Password,Email,UserName);
        ResultObj['Response']['Result'].BoolValue:=true;
        ResultObj['Response']['ResultMsg'].Value:= 'Успешная регистрация';
        ResultObj['Response']['RegUser']['Id'].Value:= NewID;
        ListUsersScreenName_Add(ScreenName,NewID);
        ListUsersName.Add_BinSort(UserName,NewID,':');
        Local_AddGroop('1');
        Local_AddGroop('18');
    end
    else
    begin
       ResultObj['Response']['Result'].BoolValue:=false;


       if not RScreenName then ResultObj['Response']['ResultMsg'].Value:= TAmBth.ConstMsgText.RegUser_ErrorScreenName
       else if  not REmail then ResultObj['Response']['ResultMsg'].Value:= TAmBth.ConstMsgText.RegUser_ErrorEmail
       else if  not RPassword then ResultObj['Response']['ResultMsg'].Value:= TAmBth.ConstMsgText.RegUser_ErrorPassword
       else if  not RUserName then ResultObj['Response']['ResultMsg'].Value:= TAmBth.ConstMsgText.RegUser_ErrorUserName
       else    ResultObj['Response']['ResultMsg'].Value:= TAmBth.ConstMsgText.DefaultErrorMsg;


    end;

    Result.TextOutputUser:= ResultObj.ToJSON();
  finally
    ResultObj.Free;
  end;

end;
function TAmChatServerBaza.RegUser_AddToListUser(ScreenName,Password,Email,UserName:string):string;
var NewUser:TjsonObject;
CountId:integer;
begin
   CountId:=AmInt(ObjUsers['Data']['CountId'].Value,0);
   inc(CountId);
   ObjUsers['Data']['CountId'].Value :=AmStr(CountId);
   NewUser:= ObjUsers['Data'].a['List'].AddObject;
   
   NewUser['Id'].Value:=AmStr(CountId);
   NewUser['Token'].Value:='';
   NewUser['Hash'].Value:='';
   NewUser['ScreenName'].Value:= ScreenName;
   NewUser['Password'].Value:= Password;
   NewUser['Email'].Value:= Email;
   NewUser['UserName'].Value:= UserName;
   Result:= AmStr(CountId);
   ObjUsers.SaveToFile(FDir+FnListUser);
end;
function TAmChatServerBaza.RegUser_CheckScreenName(ScreenName:string):boolean;
var Rx:string;
begin
 Rx:= AmReg.GetValue('\w+',ScreenName);
 Result:= (Rx=ScreenName) and (Length(ScreenName)>4) and  (Bh.SerchUser_ScreenName(ScreenName,'')<0);
end;
function TAmChatServerBaza.RegUser_CheckEmail(Email:string):boolean;
begin
    Result:= Bh.SerchUser_Email(Email,'')<0;
    if Result then Result:= AmReg.GetValue('\w+\@\w+.\w+',Email)<>'';
end;
function TAmChatServerBaza.RegUser_CheckPassword(Password,Password2:string):boolean;
begin
  Result:= (Password<>'') and (Password=Password2)
end;
function TAmChatServerBaza.RegUser_CheckUserName(UserName:string):boolean;
begin
   Result:= UserName<>''
end;













constructor TAmChatServerBaza.Create();
begin
   inherited create;
   FcS  := tevent.create(nil, false, true, '');


      FDir:=ExtractFileDir(Application.ExeName)+'\set\chat\server\';
      FDirMessageUser:=FDir+'msguser\';
      FDirMessageGroop:=FDir+'msggroop\';
      FDirPhotos:=  FDir+'photos\';
      FDirVoice:=   FDir+'voice\';
      FDirFiles:=   FDir+'files\';
      FDirFilesTime:= FDirFiles+'__time\';
      FnListUser:='ListUser.json';
      FnListRoom:='ListRoom.json';
      FnListUsersScreenName:= 'ListUsers_ScreenName.txt';
      FnListUsersName:=       'ListUsers_Name.txt';
      FnListGroopScreenName:= 'ListGroop_ScreenName.txt';
      FnListGroopName:=       'ListGroop_Name.txt';


      if not TDirectory.Exists(FDir) then  TDirectory.CreateDirectory(FDir);
      if not TDirectory.Exists(FDirPhotos) then  TDirectory.CreateDirectory(FDirPhotos);
      if not TDirectory.Exists(FDirVoice) then  TDirectory.CreateDirectory(FDirVoice);
      if not TDirectory.Exists(FDirFiles) then  TDirectory.CreateDirectory(FDirFiles);
      if not TDirectory.Exists(FDirFilesTime) then  TDirectory.CreateDirectory(FDirFilesTime);
      if not TDirectory.Exists(FDirMessageUser) then  TDirectory.CreateDirectory(FDirMessageUser);
      if not TDirectory.Exists(FDirMessageGroop) then  TDirectory.CreateDirectory(FDirMessageGroop);

      ObjUsers:=amJson.LoadObjectFile(FDir+FnListUser);

      ListUsersScreenName:= TamStringList.Create;
      ListUsersScreenName.LoadFromFileAm(FDir+FnListUsersScreenName);

      ListUsersName:= TamStringList.Create;
      ListUsersName.LoadFromFileAm(FDir+FnListUsersName);

      ObjGroops:=amJson.LoadObjectFile(FDir+FnListRoom) ;

      ListGroopScreenName:= TamStringList.Create;
      ListGroopScreenName.LoadFromFileAm(FDir+FnListGroopScreenName);

      ListGroopName:= TamStringList.Create;
      ListGroopName.LoadFromFileAm(FDir+FnListGroopName);




      ListActiv:=TAmBth.TListActiv.Create;
      ListActiv.List.Clear;
      Bh:= TAmBth.Create(ObjUsers,ObjGroops,ListUsersScreenName);
end;
destructor TAmChatServerBaza.Destroy;
begin

   ObjUsers.SaveToFile(FDir+FnListUser);
   ObjGroops.SaveToFile(FDir+FnListRoom);
   ListUsersScreenName.SaveToFileAm(FDir+FnListUsersScreenName);
   ListUsersName.SaveToFileAm(FDir+FnListUsersName);
   ListGroopScreenName.SaveToFileAm(FDir+FnListGroopScreenName);
   ListGroopName.SaveToFileAm(FDir+FnListGroopName);

   ListActiv.List.Clear;
   Bh.Free;
   ObjUsers.Free;
   ObjGroops.Free;
   ListActiv.Free;
   ListUsersScreenName.Free;
   ListUsersName.Free;
   ListGroopScreenName.Free;
   ListGroopName.Free;


   inherited Destroy;
   FcS.Free;
end;


function TAmChatServerBaza.GetClientIndexPort:integer;
begin
    if FClientIndexPort<0 then FClientIndexPort:= ListActiv.SerchPort(ClientPort);
    Result:= FClientIndexPort;
end;



end.
