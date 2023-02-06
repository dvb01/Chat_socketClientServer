unit AmChatServerBazaHelpType;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Win.ScktComp,AmChatCustomSocket,Winapi.WinSock,AmLIst,
  JsonDataObjects,SyncObjs,IOUtils,AmUserType,AmLogTo,
  AmMultiSockTcpCustomThread,RegularExpressions,
  System.Generics.Collections,
  AmHandleObject;


    type
     TAmBth =class
        type
        TMainResult=record
            type
               TListPort = AmLIst.TamListVar<integer>;
            var
            Result:boolean;         // некий результат выполнения baza может не использоватся
            IsSendUser:boolean;     //нужно ли отправлять ответ обратно
            IsJsonSend:boolean;     // текст отправить true false = file
            TextOutputUser:string;  // что отправлять обратно юзеру в формате json

            // если  IsJsonSend =false и IsSendUser true то файл нужно отправить
            CmdFN:int64;  //1=MsFN  ; 2 FileNameFN
            MsFN:TmemoryStream;
            FileNameFN:String;
            FileNameFNZipIndex:String;
            DirFNTime:string;

            // другим что отравлять
            IsSendOthers:boolean;   //нужно ли отправлять ответ другим  юзерам кто онлайн
            TextOutputOthers:string;// что отправлять обратно другим  юзерам кто онлайн
            ListPort:TListPort;//Список портов кому отправить  помимо текушего юзера

            procedure Clear;

      end;



       type
         TActivSeansProc = procedure (IndexAcc:integer;ObjAcc,InputObj,ResponseUser,ResponseOthers:TjsonObject;var  IsSendOthers:boolean;var ListSendPort:TMainResult.TListPort) of object;

     type
      TListActiv  = class
         type
          TSocketStatus = set of (ChScConnect,ChScDisconnect,ChScWrite);

          type
             TOneClient = record
               Thread:TAmSocketMultiServerThreadListen;
               ip:string;
               port:integer;
               WindowName:string;
               SocketStatus:TSocketStatus;
               Id:String;
               ScreenName:string;
               Email:string;
               UserName:string;
               TypeOnline:string;
               StatusPrints:boolean;

               BufferText:string;
               procedure Clear;
             end;
           type
            TSortId  = record
              Id,Port:integer;

            end;
         type
          TListClients = TList<TOneClient> ;
          TListId      = TList<TSortId> ;
         strict private
            function  CheckPort(Port:integer):boolean;
            procedure SetSocketStatus(Port:integer;val:TSocketStatus);
            function  GetSocketStatus(Port:integer): TSocketStatus;
            function  GetIp(Port:integer): string;
            function  GetPort(Index:integer): integer;
            function  GetWindowName(Port:integer): string;

            procedure SetId(Port:integer;val:string);
            function  GetId(Port:integer): string;

            procedure SetScreenName(Port:integer;val:string);
            function  GetScreenName(Port:integer): string;

            procedure SetEmail(Port:integer;val:string);
            function  GetEmail(Port:integer): string;

            procedure SetUserName(Port:integer;val:string);
            function  GetUserName(Port:integer): string;

            procedure SetTypeOnline(Port:integer;val:string);
            function  GetTypeOnline(Port:integer): string;

            procedure SetStatusPrints(Port:integer;val:boolean);
            function  GetStatusPrints(Port:integer): boolean;

            procedure SetBufferText(Port:integer;val:string);
            function  GetBufferText(Port:integer): string;

            Function IndexOfPort(Port:integer;MaxIndex:boolean):integer;
            Function  SerchPortForAdd(Port:integer):integer;

            Function  ListId_IndexOfId(aId:integer;var Index:integer):boolean;
            Function  ListId_SerchIdForAdd(aId:integer):integer;

         public
             List:TListClients ;
             ListId:TListId;

             Function  ListId_Delete(aId:integer):integer;
             Function  ListId_Add(aId,Port:integer):integer;

             Function  SerchPort(Port:integer):integer;

             Function  SerchId(aIdUser:string):integer; //index;
             procedure Add(Client:TCustomParam.TClient);
             procedure Delete(ClientPort:integer;IndexClientPort:integer);
             property  SocketStatus [Port:integer] : TSocketStatus Read GetSocketStatus Write SetSocketStatus ;
             property  Ip [Port:integer] : string Read GetIp;
             property  Port [Index:integer] : integer Read GetPort;
             property  WindowName [Port:integer] : string Read GetWindowName;

             property  Id [Port:integer] : string Read GetId Write SetId ;
             property  ScreenName [Port:integer] : string Read GetScreenName Write SetScreenName ;
             property  Email [Port:integer] : string Read GetEmail Write SetEmail ;
             property  UserName [Port:integer] : string Read GetUserName Write SetUserName ;
             property            TypeOnline [Port:integer] : string Read GetTypeOnline Write SetTypeOnline ;
             property  StatusPrints [Port:integer] : boolean Read GetStatusPrints Write SetStatusPrints ;
             property  BufferText [Port:integer] : string Read GetBufferText Write SetBufferText ;
            // procedure BufferTextAdd (Port:integer);
            constructor Create ();
            destructor Destroy;override;
      end;

      type ConstMsgText=record
            Const
              DefaultErrorMsg:string='Не известная ошибка';
              RegUser_ErrorScreenName :string ='Такой логин уже занят';
              RegUser_ErrorEmail :string ='Email уже занят или не верно указан';
              RegUser_ErrorPassword :string ='Пароль или простой или пароли не совпадают';
              RegUser_ErrorUserName :string ='Укажите свое имя и фамилию';
      end;

    strict private
      var
      ObjUsers,ObjGroops:TjsonObject;
      ListUsersScreenName: TAmStringList;
    public
      constructor Create (aObjUsers,aObjGroops:TjsonObject;AListUsersScreenName: TAmStringList);
      function StrAddCheckComma(var Source:string;val:string):boolean;
      function StrDeleteCheckComma(var Source:string;val:string):boolean;

      {File MessageHistory}
      function  MessageHistory_UserAdd(MsgHistory:TJsonObject;CheckUserId:string):integer;
      function  MessageHistory_UserDelete(MsgHistory:TJsonObject;CheckUserId:string):integer;
      function  MessageHistory_IndexOfUser(MsgHistory:TJsonObject;UserId:string;var Index:integer):boolean;
      function  MessageHistory_IndexOfLocalId(MsgHistory:TJsonObject;LocalId:string;var Index:integer):boolean;
      {obj user contacts}
      function ContactsUsers_MoviToFerst(ObjContacts:TJsonObject;IdUser,TypeUser:string):TJsonObject;
      function ContactsUsers_Delete(ObjContacts:TJsonObject;IdUser,TypeUser:string):boolean;
      function ContactsUsers_SerchIndex(ObjContact:TJsonObject;IdUser:String;TypeUser:string):integer;
      function ContactsUsers_AddListString(ObjContact:TJsonObject;IdUser:String;TypeUser:string;Index:integer):TJsonObject;
      function ContactsUsers_ResplaceListString(ObjContact:TJsonObject;IdUser:String;TypeUser:string;Index:integer):boolean;


      {get list activ port}
      function GetListActivPort_O_N(ListActiv:TListActiv;UserId:string;var List:TMainResult.TListPort): boolean;
      function GetListActivPort_O(ListActiv:TListActiv;UserId:string;var List:TMainResult.TListPort): boolean;

      {Users}
      function SerchUser_Pole(PoleName:string;Value:string;aPreId:string):integer;
      function GetUser_index(index:integer;PoleName:string):string;
      function GetUser_index2(index:integer;PoleName,PoleName2:string):string;
      procedure SetUser_index(index:integer;PoleName,Value:string);
      procedure SetUser_index2(index:integer;PoleName,PoleName2,Value:string);



      function GetUser_PhotoDataArray(indexAcc:integer;PhotoId:string):string;
      procedure SetUser_PhotoAdd(indexAcc:integer;PhotoData,PhotoId:string);

      function SerchUser_ScreenName(ScreenName:string;aPreId:string):integer;
      function SerchUser_Email(Email:string;aPreId:string):integer;
      function SerchUser_Id(Id:string;aPreId:string):integer;
      function SerchUser_Token(Token:string;aPreId:string):integer;
      function GetUser_Password(index:integer):string;
      function GetUser_Token(index:integer):string;

      {Groop}
      function SerchGroop_Pole(PoleName:string;Value:string;aPreId:string):integer;
      function SerchGroop_ScreenName(ScreenName:string;aPreId:string):integer;

      function GetGroop_index(index:integer;PoleName:string):string;
      function GetGroop_index2(index:integer;PoleName,PoleName2:string):string;
      procedure SetGroop_index(index:integer;PoleName,Value:string);
      procedure SetGroop_index2(index:integer;PoleName,PoleName2,Value:string);


    end;
    function Bth_CheckIdFileValid(val:string):boolean;
    function Bth_FileErrorAddResultMsg(JsonString:string;IndexFileError:integer;PlusVal:string):string;
    function Bth_AddResultMsg(JsonString:string;IdMsg:integer;IndexError:integer;val:string):string;
implementation


function Bth_CheckIdFileValid(val:string):boolean;
begin
 Result:=ConstAmChat.CheckIdFile(val);
end;
function Bth_FileErrorAddResultMsg(JsonString:string;IndexFileError:integer;PlusVal:string):string;
begin
   if (IndexFileError<0) or (IndexFileError>= ConstAmChat.FileError.countVal) then
   IndexFileError:=  ConstAmChat.FileError.Def;
   Result:=Bth_AddResultMsg(JsonString,
                           ConstAmChat.File_Error_Back,
                           IndexFileError,
                           ConstAmChat.FileError.Val[IndexFileError] +PlusVal);
end;
function Bth_AddResultMsg(JsonString:string;IdMsg:integer;IndexError:integer;val:string):string;
var HobInput:Tjsonobject;
begin
    HobInput:=   amJson.LoadObjectText(JsonString);
    try

       HobInput['Response']['ResultAuth'].BoolValue:= true;
       HobInput['Response']['Result'].BoolValue:= False;
       HobInput['Response']['ResultMsg'].Value:= val;
       HobInput['Response']['Idmsg'].IntValue:=  IdMsg;
       HobInput['Response']['IndexError'].Value:= IndexError.ToString;
       Result:=   HobInput.ToJSON();
    finally
       HobInput.Free;
    end;
end;

constructor TAmBth.Create (aObjUsers,aObjGroops:TjsonObject;AListUsersScreenName: TAmStringList);
begin
    inherited create;
    ObjUsers:=aObjUsers;
    ObjGroops:=aObjGroops;
    ListUsersScreenName:=AListUsersScreenName;
end;
function TAmBth.StrAddCheckComma(var Source:string;val:string):boolean;
begin
 Result:=false;
 if pos(','+val+',',Source)=0 then
 begin
  if Source='' then Source:=','+val+','
  else   Source:=Source+val+',';
  Result:=true;
 end;
end;
function TAmBth.StrDeleteCheckComma(var Source:string;val:string):boolean;
begin
 Result:=false;
 if pos(','+val+',',Source)<>0 then
 begin
   Source := Source.Replace(val+',','');
   if Source=',' then Source:='';
   Result:=true;
 end;
end;


function TAmBth.GetListActivPort_O_N(ListActiv:TListActiv;UserId:string;var List:TMainResult.TListPort): boolean;
var IndexActivPort:integer;
begin
                Result:=false;
                IndexActivPort:= ListActiv.SerchId( UserId );
                if (IndexActivPort>=0)
                and
                   (
                      (ListActiv.List[IndexActivPort].TypeOnline  = ConstAmChat.TypeOnline.Online)
                      or
                      (ListActiv.List[IndexActivPort].TypeOnline  = ConstAmChat.TypeOnline.Nearby)
                   )
                then
                begin
                List.Add(ListActiv.Port[IndexActivPort]);
                Result:=true;
                end;
end;
function TAmBth.GetListActivPort_O(ListActiv:TListActiv;UserId:string;var List:TMainResult.TListPort): boolean;
var IndexActivPort:integer;
begin
                Result:=false;
                IndexActivPort:= ListActiv.SerchId( UserId );
                if (IndexActivPort>=0) and (ListActiv.List[IndexActivPort].TypeOnline  = ConstAmChat.TypeOnline.Online)
                then
                begin
                   List.Add(ListActiv.Port[IndexActivPort]);
                   Result:=true;
                end;


end;

{File MessageHistory}

{function TAmBth.MessageHistory_CheckListUser(MsgHistory:TJsonObject;CheckUserId:string;Metod:String):boolean;
var ListUserStr:string;
begin
   Result:=false;
   if Metod='Add' then
   begin



       ListUserStr:= MsgHistory['Data']['ListUser']['string'].Value;
       if StrAddCheckComma(ListUserStr,CheckUserId) then
       begin
        MsgHistory['Data']['ListUser'].A['array'].Add(CheckUserId);
        MsgHistory['Data']['ListUser']['string'].Value:= ListUserStr;
        Result:=true;
       end;
   end
   else if Metod='Delete' then
   begin
       ListUserStr:= MsgHistory['Data']['ListUser']['string'].Value;
       if StrDeleteCheckComma(ListUserStr,CheckUserId) then
       begin
        MsgHistory['Data']['ListUser'].A['array'].Add(CheckUserId);
        MsgHistory['Data']['ListUser']['string'].Value:= ListUserStr;
        Result:=true;
       end;
   end;

end;
}
function  TAmBth.MessageHistory_UserAdd(MsgHistory:TJsonObject;CheckUserId:string):integer;
var R:Boolean;
    Arr:TJsonArray;
begin
    R:= MessageHistory_IndexOfUser(MsgHistory,CheckUserId,Result);
    if  not R then
    begin
       Arr:=  MsgHistory['Data']['ListUser'].A['array'];
       if (Result<0) or (Result>=Arr.Count)  then
       begin
         Arr.Add(CheckUserId);
         Result:= Arr.Count-1;
       end
       else Arr.Insert(Result,CheckUserId);
    end
    else Result:=-1;
end;
function  TAmBth.MessageHistory_UserDelete(MsgHistory:TJsonObject;CheckUserId:string):integer;
var R:Boolean;
    Arr:TJsonArray;
begin
    R:= MessageHistory_IndexOfUser(MsgHistory,CheckUserId,Result);
    if  R then
    begin
     Arr:=  MsgHistory['Data']['ListUser'].A['array'];
     if (Result>=0) and (Result<Arr.Count)  then  Arr.Delete(Result)
     else Result:=-1;
    end
    else Result:=-1;
end;

function  TAmBth.MessageHistory_IndexOfUser(MsgHistory:TJsonObject;UserId:string;var Index:integer):boolean;
var IntUserId: Integer;
begin
    Result:=False;
    Index:=-1;
    IntUserId:= AmInt(UserId,-1);
    if IntUserId<=0 then exit;
    Result:= amSerch.Json_Bin_StrToInt_IndexOf(Index,IntUserId, MsgHistory['Data']['ListUser'].A['array']);
end;
function  TAmBth.MessageHistory_IndexOfLocalId(MsgHistory:TJsonObject;LocalId:string;var Index:integer):boolean;
var IntLocalId: Integer;
begin
    Result:=False;
    Index:=-1;
    IntLocalId:= AmInt(LocalId,-1);
    if IntLocalId<=0 then exit;
    dec(IntLocalId);
    Index:= amSerch.Json_StepMinMax_Object_IndexOf(MsgHistory['Data'].A['Msg'],'IdLocal',LocalId,IntLocalId);
    if Index>=0 then Result:=true;
    

end;





                      {ContactsUsers}
function TAmBth.ContactsUsers_Delete(ObjContacts:TJsonObject;IdUser,TypeUser:string):boolean;
var IndexContact:integer;
begin
   Result:=False;
   IndexContact:= ContactsUsers_SerchIndex(ObjContacts,IdUser,TypeUser);
   if IndexContact>=0 then
   begin
      ObjContacts.A['List'].Delete(IndexContact);
      Result:=true;
   end;
   ContactsUsers_ResplaceListString(ObjContacts,IdUser,TypeUser,-1000);
end;
function TAmBth.ContactsUsers_MoviToFerst(ObjContacts:TJsonObject;IdUser,TypeUser:string):TJsonObject;
var IndexContact:Integer;
ContactMovi: TjsonObject;
CountContact:integer;
begin
                  // установка в главной базе что у пользователя +1 контакт
                  // добавление только если его нет
                  // устанавливается текущая дата что бы верно отобразить в списке контактов в интерфейсе
                  // выполняется сортировка по дате
                  // возвращается Object контакта ContactAdd кто  написал т.е текущий кто пишет

   if ObjContacts['ListString'].Value='' then ObjContacts['ListString'].Value:='';


   CountContact:= ObjContacts['List'].Count;
   IndexContact:= ContactsUsers_SerchIndex(ObjContacts,IdUser,TypeUser);
   if IndexContact>=0 then
   begin
     if IndexContact<CountContact-1 then
     begin
       ContactMovi:=  ObjContacts.A['List'].ExtractObject(IndexContact);
       Result:=   ObjContacts.A['List'].AddObject;
       Result.Assign(ContactMovi);
       ContactMovi.Free;
       ContactsUsers_ResplaceListString(ObjContacts,IdUser,TypeUser,CountContact-1);

     end
     else
     begin
        Result:=ObjContacts['List'].Items[CountContact-1];
     end;

   end
   else
   begin
     Result:=ContactsUsers_AddListString(ObjContacts,IdUser,TypeUser,CountContact);
   end;

end;
function  TAmBth.ContactsUsers_AddListString(ObjContact:TJsonObject;IdUser:String;TypeUser:string;Index:integer):TJsonObject;//ContactAdd
var ListString:string;
begin
    ListString:=  ObjContact['ListString'].Value;
    ListString:=  ListString+TypeUser+'_'+IdUser+':'+AmStr(Index)+'|';
    ObjContact['ListString'].Value:=ListString;

    Result:=ObjContact.A['List'].AddObject;
    Result['Id'].Value:=IdUser;
    Result['TypeUser'].Value:=TypeUser;
    Result['FirstAdd'].Value:=FormatDateTime('dd.mm.yyyy" "hh:nn:ss:zzz',now);


end;
function TAmBth.ContactsUsers_ResplaceListString(ObjContact:TJsonObject;IdUser:String;TypeUser:string;Index:integer):boolean ;
var ListString,NewValue,Resgulur:string;
begin
     ListString:=  ObjContact['ListString'].Value;
     if Index<>-1000 then
     NewValue:= TypeUser+'_'+IdUser+':'+Amstr(Index)+'|'
     else NewValue:='';

     Resgulur:=''+TypeUser+'\_'+IdUser+'\:\d+\|';
     ListString:=AmUserType.AmReg.Replace(Resgulur,ListString,NewValue);
     ObjContact['ListString'].Value:=ListString;
     Result:=true;
end;


function TAmBth.ContactsUsers_SerchIndex(ObjContact:TJsonObject;IdUser:String;TypeUser:string):integer;
var ListString:string;
Resgulur:string;
Response:string;
Index:integer;
begin
    //User_1:2|
    Result:=-1;
    if AmInt(IdUser,-1)<=0 then exit;

    ListString:=  ObjContact['ListString'].Value;

    Resgulur:=''+TypeUser+'\_'+IdUser+'\:\d+\|';
    Response:=AmUserType.AmReg.GetValue(Resgulur,ListString);
    if Response<>'' then
    begin
        Index:= AmInt(Response.Split([':'])[1].Split(['|'])[0],-1);
        if Index>=0 then
        begin
         Result:=amSerch.StepMinMax (
                      ObjContact['List'].Count,
                      Index,
                      function (ind:integer) :boolean
                      begin
                         Result:= (ObjContact['List'].Items[ind]['Id'].Value=IdUser)
                         and      (ObjContact['List'].Items[ind]['TypeUser'].Value=TypeUser)

                      end );

          {if Result>=0 then
          begin
             if Result<>Index then
             begin
                 NewValue:= TypeUser+'_'+IdUser+':'+Amstr(Result)+'|';
                 ListString:= ListString.Replace(Response,NewValue);
                 ObjContact['ListString'].Value:=ListString;
             end;
          end; }


                      
        end;
        

    end;
    
end;








  {Get Serch}
function TAmBth.SerchUser_Pole(PoleName:string;Value:string;aPreId:string):integer;
var PreIndex: integer;
begin
  Result:=-1;
  try
     if PoleName='' then exit;
     PreIndex:=AmInt(aPreId,0);
     if PreIndex<0 then exit;

     dec(PreIndex);
     Result:=amSerch.Json_StepMinMax_Object_IndexOf(ObjUsers['Data'].A['List'],PoleName,Value,PreIndex);
  except
  showmessage('Error TAmBth.SerchUser_Pole');

  end;
{  exit;

  Result:=-1;
  try
     if PoleName='' then exit;
     
     //   showmessage(PoleName+' Cделать что кажлый запрос передавал PredId этоо оказалось не нужным т.к это нужно только при авторизации ');
         PreIndex:=AmInt(aPreId,0);
         dec(PreIndex);
         Result:=amSerch.StepMinMax (
                      ObjUsers['Data']['List'].Count,
                      PreIndex,
                      function (ind:integer) :boolean
                      begin  Result:= ObjUsers['Data']['List'].Items[ind][PoleName].Value=Value end
         );



  except
  showmessage('Error TAmBth.GetUser_Pole');

  end;
       }
end;







function TAmBth.GetUser_index(index:integer;PoleName:string):string;
begin
     if (index>=0) and (index<ObjUsers['Data']['List'].Count) then
     Result:=ObjUsers['Data']['List'].Items[index][PoleName].Value;
end;
procedure TAmBth.SetUser_index(index:integer;PoleName,Value:string);
begin
     if (index>=0) and (index<ObjUsers['Data']['List'].Count) then
     ObjUsers['Data']['List'].Items[index][PoleName].Value:=Value;
end;
function TAmBth.GetUser_index2(index:integer;PoleName,PoleName2:string):string;
begin
     if (index>=0) and (index<ObjUsers['Data']['List'].Count) then
     Result:=ObjUsers['Data']['List'].Items[index][PoleName][PoleName2].Value;
end;
procedure TAmBth.SetUser_index2(index:integer;PoleName,PoleName2,Value:string);
begin
     if (index>=0) and (index<ObjUsers['Data']['List'].Count) then
     ObjUsers['Data']['List'].Items[index][PoleName][PoleName2].Value:=Value;
end;

function TAmBth.GetUser_PhotoDataArray(indexAcc:integer;PhotoId:string):string;
begin
    Result:='';
    if (indexAcc>=0) and (indexAcc<ObjUsers['Data']['List'].Count) and (PhotoId<>'') then
    begin
       Result:=ObjUsers['Data']['List']['Photos'][PhotoId].Value;


    end;
end;
procedure TAmBth.SetUser_PhotoAdd(indexAcc:integer;PhotoData,PhotoId:string);
begin

end;


function TAmBth.GetUser_Token(index:integer):string;
begin
    Result:=GetUser_index(index,'Token');
end;
function TAmBth.SerchUser_Token(Token:string;aPreId:string):integer;
begin
    Result:= SerchUser_Pole('Token',Token,aPreId);
end;

function TAmBth.GetUser_Password(index:integer):string;
begin
     Result:=GetUser_index(index,'Password');
end;

function TAmBth.SerchUser_ScreenName(ScreenName:string;aPreId:string):integer;
var i:integer;
    s:string;
begin
     Result:=-1;
     if aPreId='' then
     begin

      i:=ListUsersScreenName.IndexOf_BinSort(ScreenName,':');
      if (i>=0) and (Pos(':',ListUsersScreenName[i])<>0) then
      aPreId:= ListUsersScreenName[i].Split([':'])[1];

     end;
     if aPreId<>'' then
     Result:= SerchUser_Pole('ScreenName',ScreenName,aPreId);
end;
function TAmBth.SerchUser_Email(Email:string;aPreId:string):integer;
begin
   Result:= SerchUser_Pole('Email',Email,aPreId);
end;
function TAmBth.SerchUser_Id(Id:string;aPreId:string):integer;
begin
  Result:= SerchUser_Pole('Id',Id,aPreId);
end;

        {Groop}
function TAmBth.SerchGroop_ScreenName(ScreenName:string;aPreId:string):integer;
begin
  Result:= SerchGroop_Pole('ScreenName',ScreenName,aPreId);
end;
function TAmBth.SerchGroop_Pole(PoleName:string;Value:string;aPreId:string):integer;
var PreIndex: integer;
begin
  Result:=-1;
  try
     if PoleName='' then exit;
     PreIndex:=AmInt(aPreId,0);
     if PreIndex<=0 then exit;
     
     dec(PreIndex);
     Result:=amSerch.Json_StepMinMax_Object_IndexOf(ObjGroops['Data'].A['List'],PoleName,Value,PreIndex);

             {
         dec(PreIndex);
         Result:=amSerch.StepMinMax (
                      ObjGroops['Data']['List'].Count,
                      PreIndex,
                      function (ind:integer) :boolean
                      begin  Result:= ObjGroops['Data']['List'].Items[ind][PoleName].Value=Value end
         ); }

  except
  showmessage('Error TAmBth.SerchGroop_Pole');

  end;

end;
function TAmBth.GetGroop_index(index:integer;PoleName:string):string;
begin
     if (index>=0) and (index<ObjGroops['Data']['List'].Count) then
     Result:=ObjGroops['Data']['List'].Items[index][PoleName].Value;
end;
procedure TAmBth.SetGroop_index(index:integer;PoleName,Value:string);
begin
     if (index>=0) and (index<ObjGroops['Data']['List'].Count) then
     ObjGroops['Data']['List'].Items[index][PoleName].Value:=Value;
end;
function TAmBth.GetGroop_index2(index:integer;PoleName,PoleName2:string):string;
begin
     if (index>=0) and (index<ObjGroops['Data']['List'].Count) then
     Result:=ObjGroops['Data']['List'].Items[index][PoleName][PoleName2].Value;
end;
procedure TAmBth.SetGroop_index2(index:integer;PoleName,PoleName2,Value:string);
begin
     if (index>=0) and (index<ObjGroops['Data']['List'].Count) then
     ObjGroops['Data']['List'].Items[index][PoleName][PoleName2].Value:=Value;
end;

                {TMainResult}
procedure TAmBth.TMainResult.Clear;
begin
            Result:=false;
            IsSendUser:=false;
            IsJsonSend:=false;
            TextOutputUser:='';


            CmdFN:=0;
            MsFN:=nil;
            FileNameFN:='';
            FileNameFNZipIndex:='';
            DirFNTime:='';


            IsSendOthers:=false;
            TextOutputOthers:='';
            ListPort.Clear;
end;

   {TListActiv}
constructor TAmBth.TListActiv.Create ();
begin
  inherited Create;
  List:=TListClients.create;
  ListId:=TListId.Create;
end;
destructor TAmBth.TListActiv.Destroy;
begin
  List.Clear;
  List.Free;
  List:=nil;
  ListId.Clear;
  ListId.Free;
  ListId:=nil;
 inherited Destroy;
end;
procedure TAmBth.TListActiv.TOneClient.Clear;
begin
               Thread:=nil;
               ip:='';
               port:=0;
               WindowName:='';
              // SocketStatus:=;
               Id:='';
               ScreenName:='';
               Email:='';
               UserName:='';
               TypeOnline:=ConstAmChat.TypeOnline.Unknown;
               StatusPrints:=false;
               //StatusAuth:=false;
               BufferText:='';
end;
function  TAmBth.TListActiv.CheckPort(Port:integer):boolean;
begin
    Result:=  Port>0;
end;
procedure TAmBth.TListActiv.SetSocketStatus(Port:integer;val:TSocketStatus);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then  exit;
    Cl:=list[i];
    Cl.SocketStatus:= val;
    list[i]:=Cl;
end;
function  TAmBth.TListActiv.GetSocketStatus(Port:integer): TSocketStatus;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.SocketStatus;

end;
function  TAmBth.TListActiv.GetIp(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.Ip;

end;
function  TAmBth.TListActiv.GetPort(Index:integer): integer;
var
Cl: TOneClient;
begin
    Result:=-1;
    if (Index >=0) and (Index<list.Count) then
    begin
        Cl:=list[Index];
        Result:=Cl.Port
    end;

end;
function  TAmBth.TListActiv.GetWindowName(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.WindowName;

end;
Function  TAmBth.TListActiv.SerchPort(Port:integer):integer;
begin
   Result:=IndexOfPort(Port,false);
end;
Function  TAmBth.TListActiv.SerchPortForAdd(Port:integer):integer;
begin
   Result:=IndexOfPort(Port,true);
end;
Function TAmBth.TListActiv.IndexOfPort(Port:integer;MaxIndex:boolean):integer;
var Iter: Integer;
begin
   // logmain.log('IndexOfPort');
    Result:=-1;
    if Port<0 then exit;
 {
    for I := 0 to List.Count-1 do
    if List[i].port= port then
    begin
      result:=i;
      break;
    end;
   }


  try

    Result:= amSerch.BinaryIndex2(0,List.Count-1,MaxIndex,Iter,
    function(ind:integer):real
    var p,p2:integer;
    var C:TOneClient;
    begin
      C:= List[ind];
      p:= C.port;
      p2:= Port;
      Result:= p-p2 ;
    end);

  except
    logmain.Log('IndexOfPort ErrorRRRRRRRRRRRRRRRRRRRRRRRRRRRRR='+Result.ToString);
  end;

end;
Function TAmBth.TListActiv.ListId_IndexOfId(aId:integer;var Index:integer):boolean;
begin
   // logmain.log('ListId_IndexOfId:'+aId.ToString);
  Index:=-1;
  Result:=False;
  if aId<0 then exit;
  try

    Result:= amSerch.BinaryIndex3(Index,0,ListId.Count-1,
    function(ind:integer):real
    var p,p2:integer;
    var C:TSortId;
    begin
      C:= ListId[ind];
      p:= C.Id;
      p2:= aId;
      Result:= p-p2 ;
    end);

  except
    logmain.Log('ListId_IndexOfId ErrorRRRRRRRRRRRRRRRRRRRRRRRRRRRRR='+Result.ToString);
  end;

end;
Function  TAmBth.TListActiv.ListId_SerchIdForAdd(aId:integer):integer;
begin
   ListId_IndexOfId(aId,Result);
end;
Function TAmBth.TListActiv.SerchId(aIdUser:string):integer; //index;
var i,IntId,APort:integer;
    R:boolean;
//Cl:TOneClient;
begin
    Result:=-1;
    IntId:=AmInt(aIdUser,-1);
    if IntId<0 then exit;

    R:=ListId_IndexOfId(IntId,i);
    if R then
    begin
      APort:=ListId[i].Port;
      i:=self.SerchPort(APort);
      if i>=0 then Result:=i;
    end;


    {for I := 0 to List.Count-1 do
      begin
         Cl:=  List[i];
         if Cl.Id=aIdUser then
         begin
           Result:=I;
           break;
         end;

      end; }

end;
Function  TAmBth.TListActiv.ListId_Delete(aId:integer):integer;
var R:boolean;
begin
   R:=ListId_IndexOfId(aId,Result);
   if R then ListId.Delete(Result)
   else Result:=-1;
end;
Function  TAmBth.TListActiv.ListId_Add(aId,Port:integer):integer;
var C:TSortId;
    R:boolean;
begin
    Result:=-1;
    if aId<0 then exit;
    
    C.Id:= aId;
    C.Port:= Port;
    R:=ListId_IndexOfId(aId,Result);
    if R then
    begin
      ListId[Result]:=C;
    end
    else
    begin
      if (Result<0) or (Result>=ListId.Count)  then ListId.Add(C)
      else ListId.Insert(Result,C);
    end;
    
end;

procedure TAmBth.TListActiv.SetId(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.Id:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetId(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.Id;

end;

procedure TAmBth.TListActiv.SetScreenName(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.ScreenName:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetScreenName(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.ScreenName;

end;

procedure TAmBth.TListActiv.SetEmail(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.Email:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetEmail(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.Email;

end;

procedure TAmBth.TListActiv.SetBufferText(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.BufferText:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetBufferText(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.BufferText;

end;




procedure TAmBth.TListActiv.SetUserName(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.UserName:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetUserName(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.UserName;

end;

procedure TAmBth.TListActiv.SetTypeOnline(Port:integer;val:string);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    ConstAmChat.TypeOnline.Check(val);
    Cl.TypeOnline:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetTypeOnline(Port:integer): string;
var i:integer;
Cl: TOneClient;
begin

    i:=SerchPort(Port);
    if i<0 then exit;

    Cl:=list[i];
    Result:=Cl.TypeOnline;

end;

procedure TAmBth.TListActiv.SetStatusPrints(Port:integer;val:boolean);
var i:integer;
Cl: TOneClient;
begin
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Cl.StatusPrints:=val;
    list[i]:=Cl;

end;
function  TAmBth.TListActiv.GetStatusPrints(Port:integer): boolean;
var i:integer;
Cl: TOneClient;
begin
    Result:=false;
    i:=SerchPort(Port);
    if i<0 then exit;
    Cl:=list[i];
    Result:=Cl.StatusPrints;

end;

procedure  TAmBth.TListActiv.Add(Client:TCustomParam.TClient);
var Cl:TOneClient;
    Index:integer;
begin
   if Client.port<0 then exit;  
   Cl.Thread:= Client.Thread;
   Cl.ip:= Client.ip;
   Cl.port:=Client.port;
   Cl.WindowName:= Client.WinName;
   Cl.SocketStatus:= [ChScWrite];
   Cl.ScreenName:='';
   Cl.Id:='';
   Cl.Email:='';
   Cl.UserName:='';
   Cl.TypeOnline:=ConstAmChat.TypeOnline.Unknown;
   Cl.StatusPrints:=false;
   Cl.BufferText:='';
   Index:=SerchPortForAdd(Cl.port);
   if (Index>=List.Count) or (Index<0) then  List.Add(Cl)
   else List.Insert(Index,Cl);


end;
procedure  TAmBth.TListActiv.Delete(ClientPort:integer;IndexClientPort:integer);
begin
    if (ClientPort<0) and (IndexClientPort<0) then exit;
    try
        if IndexClientPort<0 then        
        IndexClientPort:=SerchPort(ClientPort);
        if IndexClientPort>=0 then
        begin
            list[IndexClientPort].clear;
            list.Delete(IndexClientPort);
        end;
    except
      showmessage('TListActiv.Delete');
    end;


end;
end.
