unit AmChatClientSostavPot;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,AmChatClientComponets,DateUtils,
  AmChatCustomSocket,AmVoiceRecord,AmMessageFilesControl,AmList,
  System.Generics.Collections,
  AmMultiSockTcpCustomPrt;



implementation
(*
 Const
  AM_CLIENT_POT_ONEND = wm_user+6000;
  AM_CLIENT_POT_TO_EDITOR= wm_user+6001;




  type
    ClientPotParam = record
         type
          Indiv = record
             const
              Photo10ToMessageFile:string ='Photo10ToMessageFile';
              Photo500ToMessageFile:string ='Photo500ToMessageFile';
          end;
         type
           TParam =class
             LParamPot:string;
             Indiv:string;
           end;
           TGetIdFileUpload =class(TParam);

           TPhotoUpload =class(TParam)
             StringBase64:string;
             IsMain:boolean;

           end;
           TSendMessage =class(TParam)
              TypeUser:string;
              ContactUserId:string;
              TypeContent:string;
              Content:string

           end;
           TInfoText =class(TParam)
              Value:string;
              IsError:boolean;
           end;
           TPhotoDowload =class(TParam)
             IdPhoto:string;
           end;
           TLoad =class(TParam)
             aId,APatch,Indiv:string; LoadToObject:TObject;
           end;

          const
            NewPhotoUpload = 1;
            GetIdFileUpload = 2;
            SendMessage = 3;
            InfoText = 4;
            PhotoDowload = 5;
            Load = 6;

    end;


    // запускается поток
   type
    TAmClientPot = class(TThread)
       type
        TProcExp = procedure of object;
    private
      FProc: TProcExp;
    protected
      procedure Execute; override;
      Procedure SendToEditor(w,l:cardinal);
      function  GoSleep(Wf_Indiv:TamVarCs<string>;MaxSec:integer;indiv:string):boolean;
      Procedure SendToEditor_InfoText(Value:String;IsError:Boolean);
    public
       IdPot:integer;
       HwdList:Cardinal;
       HwdEditor:Cardinal;
       HwdForm:Cardinal;
       Wf_Value: TamVarCs<string>;
       Wf_Indiv: TamVarCs<string>;
      constructor Create(const AProc: TProcExp);
      destructor Destroy;override;
    end;



  type
   TAmClientListPot = class(TamHandleObject)
     private
      CounterIdPot:integer;
      FList: TList<TAmClientPot>;
      procedure  PotEnd(var Msg:TMessage);message AM_CLIENT_POT_ONEND;
    public
      ClientEditor : Tobject;
      ClientForm : Tobject;
      property  List:  TList<TAmClientPot> read FList;
      procedure  AddAndStart(Pot:TAmClientPot);
      function Serch (aIdPot:integer):integer;

      constructor Create;
      destructor Destroy;override;
   end;

  type
   TAmClientPot_FileSend =  class(TAmClientPot)
        private
          Procedure SendToEditor_PhotoUpload(Base64:string;indiv:string);
          Procedure SendToEditor_IdForFileUpload(indiv:string);
          Procedure SendToEditor_SendMessage( TypeUser:string;
                                              ContactUserId:string;
                                              TypeContent:string;
                                              Content:string;
                                              indiv:string
                                              );

          Procedure Send;
        public
         ListFiles:TamListVar<string>;
         Comment:string;
         TypeUser:string;
         ContactUserId:string;
         ///////////
         ///

         constructor Create;
         destructor Destroy;override;
    end;

  type
   TAmClientPot_FileDowload_Param =record
         PhotoNameOnDisk10:string;
         IdPhoto10:string;
         PhotoNameOnDisk500:string;
         IdPhoto500:string;
         IdFile:string;
         FileNameOnDisk:string;
         LoadToObject:Tobject;
         NeedStart:boolean;
         Procedure Clear;
         Procedure Copy(P:TAmClientPot_FileDowload_Param);
   end;

   TAmClientPot_FileDowload =  class(TAmClientPot)
        private
          Procedure SendToEditor_PhotoDowload(IdPhoto:string;indiv:string);
          Procedure SendToEditor_Load(aId,APatch,Indiv:string; LoadToObject:TObject);
          Procedure DownloadHelp(Indiv:string;MaxWf:integer;aId:string;APatch:string);
          Procedure Download;
        public
         Param:TAmClientPot_FileDowload_Param;

         constructor Create;
         destructor Destroy;override;
   end;








implementation
uses AmChatClientForm,AmChatClientEditor;


Procedure TAmClientPot_FileDowload_Param.Clear;
begin
         PhotoNameOnDisk10:='';
         IdPhoto10:='';
         PhotoNameOnDisk500:='';
         IdPhoto500:='';
         IdFile:='';
         FileNameOnDisk:='';
         LoadToObject:=nil;
         NeedStart:=false;
end;
Procedure TAmClientPot_FileDowload_Param.Copy(P:TAmClientPot_FileDowload_Param);
begin
         PhotoNameOnDisk10:=P.PhotoNameOnDisk10;
         IdPhoto10:=P.IdPhoto10;
         PhotoNameOnDisk500:=P.PhotoNameOnDisk500;
         IdPhoto500:=P.IdPhoto500;
         IdFile:=P.IdFile;
         FileNameOnDisk:=P.FileNameOnDisk;
         LoadToObject:=P.LoadToObject;
         NeedStart:=P.NeedStart;
end;

constructor TAmClientPot_FileDowload.Create;
begin
    inherited create(Download);
end;
destructor TAmClientPot_FileDowload.Destroy;
begin
    inherited;
end;
Procedure TAmClientPot_FileDowload.Download;
var Indiv:string;

    Fs:TMemoryStream;
    PrtTypeFile:integer;
begin

    {
      Result < 0  какая то ошибка  см const этого объекта и родителя
      Result = 0  непонятно что пришло в Stream но запрос выполнен
      Result > 0  что именно пришло в  Stream  см AmPrtSockTypeFile

    }


   {  G :=TAmChatDownload.Create;
     Fs:=TMemoryStream.Create;
     try
       G.Host:='127.0.0.1';
       G.Port:=5678;

      // PrtTypeFile:= G.GetPhoto(Param.IdPhoto10,Token,Hash,Fs);
       if PrtTypeFile = AmPrtSockTypeFile.Image  then
       begin
          showmessage(Param.IdPhoto10+' '+Fs.Size.ToString);
       end;
       


     finally
       G.Free;
       Fs.Free;
     end;}

    if (Param.IdPhoto10<>'') and (Param.PhotoNameOnDisk10<>'') then
    begin
       Indiv:=ClientPotParam.Indiv.Photo10ToMessageFile;
       DownloadHelp(Indiv,20,Param.IdPhoto10,Param.PhotoNameOnDisk10);
       if self.Terminated then  exit;
    end;
     sleep(2000);
    if (Param.IdPhoto500<>'') and (Param.PhotoNameOnDisk500<>'') then
    begin

       Indiv:=ClientPotParam.Indiv.Photo500ToMessageFile;
       DownloadHelp(Indiv,120,Param.IdPhoto500,Param.PhotoNameOnDisk500);
       if self.Terminated then  exit;
    end;
    

end;
Procedure TAmClientPot_FileDowload.DownloadHelp(Indiv:string;MaxWf:integer;aId:string;APatch:string);
var Result:boolean;
begin
       Wf_Value.Val:='';
       Wf_Indiv.Val:='';
       if       (Indiv=ClientPotParam.Indiv.Photo10ToMessageFile)  then SendToEditor_PhotoDowload(aId,Indiv)
       else if  (Indiv=ClientPotParam.Indiv.Photo500ToMessageFile) then SendToEditor_PhotoDowload(aId,Indiv);
       Result:=GoSleep(Wf_Indiv,MaxWf,Indiv);
       if self.Terminated then  exit;

       if Result and FileExists(APatch) then  SendToEditor_Load(aId,APatch,Indiv,Param.LoadToObject);
end;
Procedure TAmClientPot_FileDowload.SendToEditor_PhotoDowload(IdPhoto:string;indiv:string);
var Msg:ClientPotParam.TPhotoDowload;
begin
   Msg:= ClientPotParam.TPhotoDowload.Create;
   Msg.IdPhoto:= IdPhoto;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:=indiv;
   self.SendToEditor(ClientPotParam.PhotoDowload,LParam(Msg));

end;
Procedure TAmClientPot_FileDowload.SendToEditor_Load(aId,APatch,Indiv:string; LoadToObject:TObject);
var Msg:ClientPotParam.TLoad;
begin
   Msg:= ClientPotParam.TLoad.Create;
   Msg.aId:= aId;
   Msg.APatch:= APatch;
   Msg.LoadToObject:= LoadToObject;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:=indiv;
   self.SendToEditor(ClientPotParam.Load,LParam(Msg));

end;




               {TAmClientPot_FileSend}
constructor TAmClientPot_FileSend.Create;
begin
    inherited create(Send);
end;
destructor TAmClientPot_FileSend.Destroy;
begin
    inherited;
end;
Procedure TAmClientPot_FileSend.SendToEditor_PhotoUpload(Base64:string;indiv:string);
var Msg:ClientPotParam.TPhotoUpload;
begin
   Msg:= ClientPotParam.TPhotoUpload.Create;
   Msg.StringBase64:= Base64;
   Base64:='';
   Msg.IsMain:=false;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:=indiv;
   self.SendToEditor(ClientPotParam.NewPhotoUpload,LParam(Msg));
end;
Procedure TAmClientPot_FileSend.SendToEditor_IdForFileUpload(indiv:string);
var Msg:ClientPotParam.TGetIdFileUpload;
begin
   Msg:= ClientPotParam.TGetIdFileUpload.Create;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:=indiv;
   self.SendToEditor(ClientPotParam.GetIdFileUpload,LParam(Msg));

end;
Procedure TAmClientPot_FileSend.SendToEditor_SendMessage( TypeUser:string;
                                                          ContactUserId:string;
                                                          TypeContent:string;
                                                          Content:string;
                                                          indiv:string
                                                          );
var Msg:ClientPotParam.TSendMessage;
begin
    Msg:= ClientPotParam.TSendMessage.Create;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:=indiv;
   Msg.TypeUser:=   TypeUser;
   Msg.ContactUserId:= ContactUserId;
   Msg.TypeContent:=   TypeContent;
   Msg.Content:=       Content;
   Content:='';
   self.SendToEditor(ClientPotParam.SendMessage,LParam(Msg));

end;


Procedure TAmClientPot_FileSend.Send;
var P:TAmClientAddToArchivFilesAtSend;
    Ms:TmemoryStream;
    ResultAdd:TAmClientAddToArchivFilesAtSend.TResult;
    indiv:string;
    Id_Photo10:string;
    Id_Photo500:string;
    Id_File:string;
    ResultId_File:boolean;
    aTypeContent:string;
    ContentString:String;
    ContentJson,HobJson:TJsonObject;
    i:integer;
begin


   P:= TAmClientAddToArchivFilesAtSend.Create;
   Ms:=TmemoryStream.Create;
   try
     ResultAdd:=P.Get(Ms,ListFiles,true,500,true,500);
     if ResultAdd.Photo10Result  then
     begin
       indiv:='Photo10';
       Wf_Indiv.Val:='';
       Wf_Value.Val:='';
       SendToEditor_PhotoUpload(ResultAdd.Photo10StringBase64,indiv);
       ResultAdd.Photo10Result:= GoSleep(Wf_Indiv,20,indiv);
       Id_Photo10:= Wf_Value.Val;
     end;

     if self.Terminated then
     begin
       exit;
     end;

     if ResultAdd.Photo500Result  then
     begin
       indiv:='Photo500';
       Wf_Indiv.Val:='';
       Wf_Value.Val:='';
       SendToEditor_PhotoUpload(ResultAdd.Photo500StringBase64,indiv);
       ResultAdd.Photo500Result:= GoSleep(Wf_Indiv,180,indiv);
       Id_Photo500:= Wf_Value.Val;
     end;

     if self.Terminated then  exit;

     if Ms.Size>0 then
     begin
       indiv:='IdForFileUpload';
       Wf_Indiv.Val:='';
       Wf_Value.Val:='';
       SendToEditor_IdForFileUpload(indiv);
       ResultId_File:= GoSleep(Wf_Indiv,20,indiv);
       Id_File:= Wf_Value.Val;
     end;

     if (Id_Photo10<>'') or (Id_Photo500<>'') or (Id_File<>'') or (Trim(Comment)<>'') then
     begin
       //  Comment:string;

        ContentString:='';
        ContentJson:=  TJsonObject.Create;
        try
         //заполнить json////////////////////
         ////////////////////////////
             ContentJson['IdPhoto10'].Value:= Id_Photo10;
             ContentJson['IdPhoto500'].Value:= Id_Photo500;
             ContentJson['IdFile'].Value:=Id_File;
             ContentJson['Comment'].Value:=Trim(Comment);
             ContentJson['CollageSizeMax'].Value:=AmRectSize.SizeToStr(ResultAdd.CollageSizeMax);
             ContentJson['CollageCountFile'].Value:=  ResultAdd.CountFileCollage.ToString;
             for I := 0 to ResultAdd.ListFileOther.Count-1 do
             ContentJson.A['ListFileOther'].Add(ResultAdd.ListFileOther[i]);
             ContentString:= ContentJson.ToJSON(true);
        finally
         ContentJson.Free;
        end;
        if ((Id_Photo10<>'') or (Id_Photo500<>'') or (Id_File<>'')) and (ContentString<>'') then
        aTypeContent:= ConstAmChat.TypeContent.Files
        else
        aTypeContent:= ConstAmChat.TypeContent.Text;
        indiv:='';
        SendToEditor_SendMessage(TypeUser,ContactUserId,aTypeContent,ContentString,indiv);
        ContentString:='';



     end
     else
     begin
     SendToEditor_InfoText('Не удалось отправить сообщение параметры пусты',true);
     end;
     


    //  self.

   //  ResultAdd.

   //  showmessage(AmStr(IdPot)+' '+Ms.Size.ToString +' '+Id_Photo500 +' '+Id_Photo10 +' Id_File='+Id_File);
   //  Ms.SaveToFile('test.zip');
   finally
  // ShowMessage('Finally');
     P.Free;
     Ms.Free;
   end;


end;






     {TAmClientListPot}

constructor TAmClientListPot.Create;
begin
    inherited create;
    FList:= TList<TAmClientPot>.create;
    CounterIdPot:=0;
end;
destructor TAmClientListPot.Destroy;
var
  I: Integer;
begin
   for I := 0 to FList.count-1 do
   if Assigned(FList[i]) then
   begin
     if FList[i].Suspended  then FList[i].Resume;
     FList[i].Terminate;
   end;
   FList.Clear;
   FList.Free;
   inherited;
end;
procedure  TAmClientListPot.AddAndStart(Pot:TAmClientPot);
begin
  if not Assigned(Pot) then exit;
   inc(CounterIdPot);
   Pot.IdPot:= CounterIdPot;
   Pot.HwdList:=self.Handle;
   Pot.HwdEditor:= TChatClientEditor(ClientEditor).Handle;
   Pot.HwdForm:=   TChatClientForm(ClientForm).Handle;
   FList.add(Pot);
   if Pot.Suspended then Pot.Start;
   
end;
procedure  TAmClientListPot.PotEnd(var Msg:TMessage);//message AM_CLIENT_POT_ONEND;
var i:integer;
begin
   if Msg.WParam>0 then
   begin
     i:=serch(Msg.WParam);
     if i>=0 then
     begin
        FList.Delete(i);
     end;
   end;

end;
function TAmClientListPot.Serch (aIdPot:integer):integer;
var
  I: Integer;
begin
   result:=-1;
   for I := 0 to FList.Count-1 do
    begin
      if FList[i].IdPot= aIdPot then
      begin
        Result:=i;
        break;
      end;

    end;
end;


              {TAmClientPot}
constructor TAmClientPot.Create(const AProc: TProcExp);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  Wf_Value:= TamVarCs<string>.create;
  Wf_Indiv:= TamVarCs<string>.create;
  FProc := AProc;

end;
destructor TAmClientPot.Destroy;
begin
    inherited;
    Wf_Value.free;
    Wf_Indiv.free;
end;


procedure TAmClientPot.Execute;
begin
 try
  FProc();
 except
    showmessage('Error AmChatClientComponets.TAmClientPot.Execute');
 end;
 PostMessage(HwdList,AM_CLIENT_POT_ONEND,IdPot,LParam(self));
end;
Procedure TAmClientPot.SendToEditor(w,l:cardinal);
begin
    PostMessage(HwdEditor,AM_CLIENT_POT_TO_EDITOR,w,l);
end;
function TAmClientPot.GoSleep(Wf_Indiv:TamVarCs<string>;MaxSec:integer;indiv:string):boolean;
begin
    Result:= ToWaitFor.GoSleep(MaxSec,function : boolean begin Result:=(Wf_Indiv.Val=indiv) or Terminated  end);
end;
Procedure TAmClientPot.SendToEditor_InfoText(Value:String;IsError:Boolean);
var Msg:ClientPotParam.TInfoText;
begin
   Msg:= ClientPotParam.TInfoText.Create;
   Msg.LParamPot:=AmStr(IdPot);
   Msg.Indiv:='';
   Msg.Value:=   Value;
   Msg.IsError:= IsError;
   self.SendToEditor(ClientPotParam.InfoText,LParam(Msg));

end;

*)
end.
