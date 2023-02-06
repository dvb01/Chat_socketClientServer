unit AmChatClientForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,System.Types,IdCoder, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  AmChatClientEditor,
  AmUserType,AmLogTo,
  JsonDataObjects,IdCoderMime,
  AmChatClientComponets,
  AmChatClientContactBox,
  AmChatClientPeopleBox,
  AmChatClientMessageBox,
  AmControls, ES.BaseControls, ES.Images,
  AmVoiceRecord,ShellApi,
  ES.Layouts, RxCtrls,AmGrafic,
  AmMessageFilesControl,
  AmChatCustomSocket,
  AmChatClientParticipantBox;

 type
    TImg_Att_Status =  (amsAttRec,amsAttClipSilver,amsAttClipWhite);
    TImg_Send_Status = (amsSendNoActiv,amsSendActiv,amsMicSilver,amsMicWhite,amsMicActiv,amsMicNoActiv);
type
  TChatClientForm = class(TForm)
    PanelChatClient: TPanel;
    PanelChat: TPanel;
    PanelChatTop: TPanel;
    PanelLeft: TPanel;
    PanelRigth: TPanel;
    PanelSerchTop: TPanel;
    PanelTools: TPanel;
    LogOut: TLabel;
    PanelProfile: TPanel;
    PanelProfile_UserName: TLabel;
    PanelProfile_back: TLabel;
    PanelProfile_ScreenName: TLabel;
    PanelProfile_OldPass: TEdit;
    PanelProfile_EditPass: TLabel;
    Label27: TLabel;
    PanelProfile_NewPass: TEdit;
    Label28: TLabel;
    PanelProfile_NewPass2: TEdit;
    Label29: TLabel;
    Label30: TLabel;
    PanelProfile_NotiNewMessage: TCheckBox;
    PanelProfile_NewPhoto: TLabel;
    PanelLogin: TPanel;
    PanelLogin_Main: TPanel;
    PanelReg_PReg: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Label33: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    PanelReg_Pass: TEdit;
    PanelReg_Go: TPanel;
    PanelReg_Login: TEdit;
    PanelReg_Pass2: TEdit;
    PanelReg_Email: TEdit;
    PanelReg_UserName: TEdit;
    PanelLogin_PLogin: TPanel;
    Label35: TLabel;
    Label32: TLabel;
    Label31: TLabel;
    Label34: TLabel;
    PanelLogin_Pass: TEdit;
    PanelLogin_Go: TPanel;
    PanelLogin_Remember: TCheckBox;
    PanelLogin_Login: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    PanelProfile_PanelPhoto: TPanel;
    PanelTopContacts: TPanel;
    OpenProFile: TLabel;
    PanelChatBox: TPanel;
    PanelProfile_Photo: TEsImage;
    LogOutAcc: TLabel;
    PanelSerchTop_Serch: TEdit;
    PanelSerchTop_SerchGo: TLabel;
    PanelChatTop_UserName: TLabel;
    PanelChatTop_Status: TLabel;
    Panel3: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Panel6: TPanel;
    PanelManagerFile: TPanel;
    PanelManagerFile_bottom: TPanel;
    Label2: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Edit2: TEdit;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    PanelSendFile: TPanel;
    Label7: TLabel;
    PanelSendFile_button: TPanel;
    PanelSendFile_back: TLabel;
    PanelSendFile_send: TLabel;
    Label6: TLabel;
    PanelSendFile_Comment: TEdit;
    Panel4: TPanel;
    PanelSendFile_variant: TPanel;
    PanelSendFile_AdderFile: TEsLayout;
    Label5: TLabel;
    SaveDialog1: TSaveDialog;
    OpenManagerFile: TLabel;
    PanelManagerFile_top: TPanel;
    PanelManagerFile_back: TLabel;
    PanelManagerFile_client: TPanel;
    Label4: TLabel;
    PanelManagerFile_menu: TPanel;
    PanelManagerFile_send_view: TPanel;
    Label13: TLabel;
    PanelManagerFile_send_menu: TPanel;
    PanelManagerFile_setting_menu: TPanel;
    PanelManagerFile_send_menu_label: TLabel;
    PanelManagerFile_setting_menu_label: TLabel;
    PanelManagerFile_download_menu: TPanel;
    PanelManagerFile_download_menu_label: TLabel;
    PanelManagerFile_msg_menu: TPanel;
    PanelManagerFile_msg_menu_label: TLabel;
    PanelManagerFile_download_view: TPanel;
    Label12: TLabel;
    PanelManagerFile_msg_view: TPanel;
    Label18: TLabel;
    PanelManagerFile_setting_view: TPanel;
    Label14: TLabel;
    PanelChatBottomB: TPanel;
    PanelChatBottomClient: TPanel;
    Panel76: TPanel;
    Panel77: TPanel;
    PanelChatBottom_Att: TEsImage;
    Panel78: TPanel;
    PanelChatBottom_RichSend: TRichEdit;
    PanelChatBottom_Ridth: TPanel;
    PanelChatBottom_Send: TEsImage;
    Panel5: TPanel;
    OpenObjectCreate: TLabel;
    PanelObjectCreate: TPanel;
    PanelObjectCreate_back: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    PanelObjectCreate_Groop_ScreenName: TEdit;
    PanelObjectCreate_Groop_UserName: TEdit;
    PanelObjectCreate_Groop_Type: TComboBox;
    PanelObjectCreate_Groop_Create: TPanel;
    Label16: TLabel;
    PanelObjectCreate_Groop_Error: TLabel;
    PanelChatTop_ChatShare: TLabel;
    Panel1: TPanel;
    Panel_Groop_Edit: TEsLayout;
    Label15: TLabel;
    Label21: TLabel;
    Panel10: TPanel;
    Panel_Groop_Edit_Photo: TEsImage;
    Panel_Groop_Edit_Save: TLabel;
    Label26: TLabel;
    Panel_Groop_Edit_UserName: TEdit;
    Panel11: TPanel;
    LabelBackChat: TLabel;
    LabelOpenSerch: TLabel;
    Label17: TLabel;
    procedure LogOutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure OpenProFileClick(Sender: TObject);
    procedure PanelProfile_backClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelLogin_GoClick(Sender: TObject);
    procedure UserChange(Sender: TObject);
    procedure PanelReg_GoClick(Sender: TObject);
    procedure PanelProfile_NewPhotoClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure LogOutAccClick(Sender: TObject);
    procedure PanelChatBottom_RichSendResizeRequest(Sender: TObject;
      Rect: TRect);
    procedure PanelChatBottom_SendMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelChatBottom_SendMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelChatBottom_AttMouseEnter(Sender: TObject);
    procedure PanelChatBottom_AttMouseLeave(Sender: TObject);
    procedure PanelChatBottom_RichSendChange(Sender: TObject);
    procedure PanelChatBottom_SendMouseEnter(Sender: TObject);
    procedure PanelChatBottom_SendMouseLeave(Sender: TObject);
    procedure PanelChatBottom_AttClick(Sender: TObject);
    procedure PanelSendFile_AdderFilePaint(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure PanelSendFile_backClick(Sender: TObject);
    procedure PanelSendFile_sendClick(Sender: TObject);
    procedure PanelSendFile_AdderFileClick(Sender: TObject);
    procedure PanelChatBoxResize(Sender: TObject);
    procedure OpenManagerFileClick(Sender: TObject);
    procedure PanelManagerFile_backClick(Sender: TObject);
    procedure PanelManagerFile_send_menuClick(Sender: TObject);
    procedure PanelManagerFile_download_menuClick(Sender: TObject);
    procedure PanelManagerFile_msg_menuClick(Sender: TObject);
    procedure PanelManagerFile_setting_menuClick(Sender: TObject);
    procedure PanelChatBottom_RichSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PanelSerchTop_SerchGoClick(Sender: TObject);
    procedure PanelSerchTop_SerchEnter(Sender: TObject);
    procedure PanelSerchTop_SerchExit(Sender: TObject);
    procedure OpenObjectCreateClick(Sender: TObject);
    procedure PanelObjectCreate_backClick(Sender: TObject);
    procedure PanelObjectCreate_Groop_CreateClick(Sender: TObject);
    procedure PanelChatTop_ChatShareClick(Sender: TObject);
    procedure Panel_Groop_Edit_PhotoClick(Sender: TObject);
    procedure Panel_Groop_Edit_SaveClick(Sender: TObject);
    procedure Panel_Groop_Edit_UserNameChange(Sender: TObject);
    procedure LabelBackChatClick(Sender: TObject);
  private
    { Private declarations }
     PanelLeft_SaveW:integer;
     PanelRigth_SaveW:integer;
     procedure PanelManagerFile_closeAllPanel();
     procedure AM_SendTextMessage(var Msg:TMessage);message wm_user+212;
   const
     RichSendTextBanned= 'Написать сообщение';
    var

        IsVoiceStart:boolean;
        Procedure BoxPeople_GetHistoryChat(OnePeople:TAmClientOnePeople);
        Procedure BoxContact_GetHistoryChat(OneContact:TAmClientOneContact);
        Procedure BoxMessage_GetOldBlockMessages(Sender: TObject);
        Procedure BoxMessage_ReadMessage(OneMessage:TAmClientOneMessage);
        Procedure BoxMessage_VoiceNotPlay (OneMessage:TAmClientOneMessage;FileName:string;IsPlay:boolean);

        procedure Rec_OnMax(M:integer;s:string);
        procedure Rec_OnGoodStart;
        procedure Rec_OnNotStart(Error:string);
        procedure Rec_OnStop(MaxPos:integer;CaptionTime:string);

        procedure ListBoxSendFilesOnClear(Sender: TObject);
        procedure ChatClientNeedSaveDialog(var FileName:string);
  public

    { Public declarations }
   //  BoxContactsHelp: TAmClientContactHelp;
  //   BoxContactsScroll:TAmClientScroll;
   //  BoxChatHelp: TAmClientMessageHelp;
  //   BoxChatScroll:TAmClientScroll;
  //   BoxOnlineScroll:TAmClientScroll;
      ChatClient: TChatClientEditor;
     BoxMessage:TAmClientScrollBoxMessage;
     BoxContact:TAmClientScrollBoxContact;
     BoxPeople:TAmClientScrollBoxPeople;

     //cтатусы панелей которые снизу где запись голосового и набор текста для отправки в чате
     PanelChatBottom_Att_Status: TImg_Att_Status;
     PanelChatBottom_Send_Status: TImg_Send_Status;
     PanelChatBottom_Send_StatusMouse:boolean;

     // лист бокс которые отображает файлы перед отправкой
     ListBoxFilesAtSend :TAmClientListBoxFilesAtSend;

     // чек бокс который висит около ListBoxFilesAtSend
     SendFilesToZip:TamCustomCheckBox;

     PopapMenuDialogShare:TAmClientMenuForDialogShare;
     PanelAutoVisibleParticipants:TAmPanelAutoVisible;
     BoxParticipants:TAmClientScrollBoxParticipants;

     procedure WMEnterSizeMove(var Message: TMessage);message WM_ENTERSIZEMOVE;
     procedure WMExitSizeMove(var Message: TMessage); message WM_EXITSIZEMOVE;
     procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
     procedure ChatClientStart ( aAddressSocket:string;  aPortSokect:integer;  aLog:TamLogString; MiliSecondsTimeOutSocket:Cardinal=INFINITE);
     procedure ChatClientStop ;
     Procedure  ChatClientLogIn;
     Procedure CloseAllMainPanel;
     Function  OpenPanel(Win:TPanel):Boolean; //была ли открыта панель  до вызова
     Function  ClosePanel(Win:TPanel):Boolean; //была ли открыта панель  до вызова
     Function  ReversPanel(Win:TPanel):Boolean; //Меняет visable на противоположный   Result была ли открыта панель до вызова
     Procedure ClearPanelChatClient;
     procedure PopapMenuDialogShareBeforeOpen(S:TObject;var P:TPoint);
     Procedure PopapMenuDialogShareClickToItem(S:Tobject;NameItem:String);
     Procedure PanelAutoVisibleParticipantsClose(S:Tobject);
     Procedure BoxParticipants_PopapClickToItem(S:Tobject;NameItem:String);
     Procedure BoxContact_PopapClickToItem(S:Tobject;NameItem:String);
  end;

     procedure ChatClientFormCreate(aParent:TWinControl;
                                    aAddressSocket:string;
                                    aPortSokect:integer;
                                    aLog:TamLogString);
     procedure ChatClientFormDestroy();

  var
  ChatClientForm: TChatClientForm;

implementation

{$R *.dfm}

procedure ChatClientFormCreate(aParent:TWinControl;
                                    aAddressSocket:string;
                                    aPortSokect:integer;
                                    aLog:TamLogString);
begin
    ChatClientForm:= TChatClientForm.create(nil);
    ChatClientForm.Parent:=aParent;
    //77.220.213.53 127.0.0.1
    ChatClientForm.ChatClientStart(aAddressSocket,aPortSokect,aLog,10000);
end;
procedure ChatClientFormDestroy();
begin
  if Assigned(ChatClientForm) then
  begin
    ChatClientForm.Free;
    ChatClientForm:=nil;
  end;
end;


procedure TChatClientForm.WMEnterSizeMove(var Message: TMessage); //message WM_ENTERSIZEMOVE;
begin
     inherited;
     BoxMessage.Box.SavePosBegin;
   //  showmessage('1');
   //  logmain.Log('EnterSize пользователь начал тянуть за края формы что бы изменить ее размер');
     // здесь это не работает на форме повесить эти процедуры и вызвать SavePosBegin
end;
procedure TChatClientForm.WMExitSizeMove(var Message: TMessage); //message WM_EXITSIZEMOVE;
begin
    inherited;
    BoxMessage.Box.SavePosEnd;
    //  showmessage('2');
   //  logmain.Log('ExitSize пользователь закончил тянуть за края формы что бы изменить ее размер');
     // здесь это не работает на форме повесить эти процедуры и вызвать SavePosEnd
end;
procedure TChatClientForm.WMDropFiles(var Msg: TWMDropFiles);
const
  MAXFILENAME = 255;
var
  i: integer;
  fileCount: integer;
  fileName: array [0..MAXFILENAME] of Char;
begin
  { Сколько файлов перетаскивать }
  fileCount:= DragQueryFile(
          Msg.Drop, $FFFFFFFF, fileName, MAXFILENAME);
  { Связываем с именами файлов }
  for i:= 0 to fileCount - 1 do
  begin
    DragQueryFile(Msg.Drop, i, fileName, MAXFILENAME);
    { перечисляем все файлы }
    //showmessage(fileName);
    ListBoxFilesAtSend.AddFile(fileName);

    

  end;


  { Освобождаем память }
  DragFinish(Msg.Drop);

  if ListBoxFilesAtSend.Items.Count>0 then
  begin


    PanelSendFile_AdderFile.Visible:=false;
    ListBoxFilesAtSend.Visible:=true;
    if not PanelSendFile.Visible then PanelSendFile.Visible:=true;
  end;
end;


procedure  TChatClientForm.ListBoxSendFilesOnClear(Sender: TObject);
begin
    ListBoxFilesAtSend.Visible:=false;
    PanelSendFile_AdderFile.Visible:=true;
end;
procedure TChatClientForm.PopapMenuDialogShareBeforeOpen(S:TObject;var P:TPoint);
begin
   P.X:= P.X-PopapMenuDialogShare.Width+10;
   P.Y:= P.Y-10;

end;
Procedure TChatClientForm.PopapMenuDialogShareClickToItem(S:Tobject;NameItem:String);
 function Ch(TypeUser:string):boolean;
 begin
   Result:=ChatClient.ActivDialog.Check(TypeUser);
 end;
begin
         if       NameItem = ConstAmChat.TypePanelFree.GroopList then
         begin
          if Ch(ConstAmChat.TypeUser.Groop) then
          begin
           ChatClient.SVR_Groop_GetListUsers(ChatClient.ActivDialog.UserId);
           PanelAutoVisibleParticipants.Open(ConstAmChat.TypePanelFree.GroopList,nil);
          end;

         end
         else if  NameItem = 'GroopOut'  then
         begin

         end
         else if  NameItem = ConstAmChat.TypePanelFree.GroopUserAdd  then
         begin
            if Ch(ConstAmChat.TypeUser.Groop) then
            begin
               ChatClient.ContactsCopyParticipants(ConstAmChat.TypePanelFree.GroopUserAdd);
            end
         end
         else if  NameItem = 'GroopEdit'  then
         begin
          if Ch(ConstAmChat.TypeUser.Groop) then
          begin
           Panel_Groop_Edit_UserName.Text:=ChatClient.ActivDialog.UserName;
           Panel_Groop_Edit_Photo.Picture:= TEsImage(self.BoxContact.ActivContact.GetPhotoLParam).Picture;
           Panel_Groop_Edit_Save.Visible:=false;
           PanelAutoVisibleParticipants.Open(ConstAmChat.TypePanelFree.GroopEdit,Panel_Groop_Edit);
          end;
         end
         else if  NameItem = 'ContactDelete'  then
         begin

         end



end;
procedure TChatClientForm.PanelChatTop_ChatShareClick(Sender: TObject);
begin
   if ChatClient.ActivDialog.IsActiv then
   begin
     if ChatClient.ActivDialog.TypeUser = ConstAmChat.TypeUser.User then
     PopapMenuDialogShare.Open(nil,0)
     else if ChatClient.ActivDialog.TypeUser = ConstAmChat.TypeUser.Groop then
     PopapMenuDialogShare.Open(nil,1)
   end;


end;
Procedure TChatClientForm.PanelAutoVisibleParticipantsClose(S:Tobject);
begin
    if (PanelAutoVisibleParticipants.InNameControlCall = ConstAmChat.TypePanelFree.GroopList)
    or (PanelAutoVisibleParticipants.InNameControlCall = ConstAmChat.TypePanelFree.GroopUserAdd) then
    BoxParticipants.ClearBox;

end;
Procedure TChatClientForm.BoxParticipants_PopapClickToItem(S:Tobject;NameItem:String);
var Participant:TAmClientOneParticipant;
begin
    if not ( BoxParticipants.Popap.ControlSave is TAmClientOneParticipant ) then exit;
    Participant:=  BoxParticipants.Popap.ControlSave as TAmClientOneParticipant;

    if NameItem='GroopUserAdd' then
    begin
      if ChatClient.ActivDialog.Check(ConstAmChat.TypeUser.Groop) then
         ChatClient.SVR_Groop_AddUser(ChatClient.ActivDialog.UserId,Participant.UserId,Inttostr(LParam(Participant)));
    end
    else
    if NameItem='GroopUserDelete' then
    begin
      if ChatClient.ActivDialog.Check(ConstAmChat.TypeUser.Groop) then
         ChatClient.SVR_Groop_DeleteUser(ChatClient.ActivDialog.UserId,Participant.UserId,Inttostr(LParam(Participant)));
    end
    else
    if NameItem='MessageHistory' then
    begin
      if Assigned(BoxParticipants.ActivContactRigthMouse) then
      begin

        ChatClient.SVR_Message_History(BoxParticipants.ActivContactRigthMouse.TypeUser,BoxParticipants.ActivContactRigthMouse.UserId)
      end;

    end;
    BoxParticipants.Popap.Close;
end;
Procedure TChatClientForm.BoxContact_PopapClickToItem(S:Tobject;NameItem:String);
var Contact:TAmClientOneContact;
begin
    if not ( BoxContact.Popap.ControlSave is TAmClientOneContact ) then exit;
    Contact:=  BoxContact.Popap.ControlSave as TAmClientOneContact;
    if NameItem='ContactDelete' then
    begin
      ChatClient.SVR_ContactDelete(Contact.TypeUser,Contact.UserId);


    end;
    BoxContact.Popap.Close;
end;


Procedure TChatClientForm.BoxContact_GetHistoryChat(OneContact:TAmClientOneContact);
begin
  if not PanelChat.Visible then
  begin
    PanelChat.Visible:=true;
    PanelLeft.Visible:=false;
    PanelLeft.Align:=alLeft;
  end;
   ChatClient.GetHistoryChat(OneContact);
end;
Procedure TChatClientForm.BoxPeople_GetHistoryChat(OnePeople:TAmClientOnePeople);
begin
   ChatClient.GetHistoryChat(OnePeople);
end;
Procedure TChatClientForm.BoxMessage_GetOldBlockMessages(Sender: TObject);
begin
   ChatClient.GetOldBlockMessageHistory('');
end;
Procedure TChatClientForm.BoxMessage_ReadMessage(OneMessage:TAmClientOneMessage);
begin
  ChatClient.Message_ReadOne(OneMessage);
end;
Procedure TChatClientForm.BoxMessage_VoiceNotPlay (OneMessage:TAmClientOneMessage;FileName:string;IsPlay:boolean);
begin
   ChatClient.OneMessageVoiceNotPlay(OneMessage,FileName,IsPlay);
end;

procedure TChatClientForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//



end;
procedure TChatClientForm.FormDestroy(Sender: TObject);
begin

   //
   ChatClient.free;
end;
procedure TChatClientForm.FormCreate(Sender: TObject);
begin
DragAcceptFiles(Handle, true);

PanelManagerFile_closeAllPanel;
ListBoxFilesAtSend:= TAmClientListBoxFilesAtSend.Create(self);
ListBoxFilesAtSend.Parent:=PanelSendFile_variant;
ListBoxFilesAtSend.Align:=alClient;
ListBoxFilesAtSend.Visible:=false;
ListBoxFilesAtSend.OnClearListBox:= ListBoxSendFilesOnClear;
ListBoxFilesAtSend.OnNeedOpenDialog:= PanelSendFile_AdderFileClick;



  SendFilesToZip:= TamCustomCheckBox.Create(self);
  SendFilesToZip.Parent:=PanelSendFile_button;
  SendFilesToZip.Top:=0;
  SendFilesToZip.Left:=33;
  SendFilesToZip.Font.Color:=$00E8B4B3;
  SendFilesToZip.Font.Size:=10;
  SendFilesToZip.Width:=320;
  SendFilesToZip.color:=$00423129;
  SendFilesToZip.TextBox:='Отправить файлы быстро';
  SendFilesToZip.TextCorrectY:=-1;
  SendFilesToZip.ColorBolder:= $00E8B4B3;
  SendFilesToZip.ColorBolderChecked:= $00E8B4B3;
  SendFilesToZip.ColorBolderMouseActiv:=$00E8B4B3;
  SendFilesToZip.ColorBox:= $00423129;
  SendFilesToZip.Repaint;

  PopapMenuDialogShare:= TAmClientMenuForDialogShare.create(self);
  PopapMenuDialogShare.OnBeforeOpenPosition:=PopapMenuDialogShareBeforeOpen;
  PopapMenuDialogShare.OnClickItem:= PopapMenuDialogShareClickToItem;

  PanelAutoVisibleParticipants:=  TAmPanelAutoVisible.Create(PanelChatClient);
  PanelAutoVisibleParticipants.Color:= $01443111;

     BoxParticipants:=TAmClientScrollBoxParticipants.Create(self);
     BoxParticipants.Align:=alClient;
     BoxParticipants.Parent:=nil;
     BoxParticipants.Box.Color:= $00423129;

     BoxParticipants.Color:= $00423129;
     BoxParticipants.Scroll.ColorBorder:=$00765950;
     BoxParticipants.Scroll.ColorArrowDownV:=$00423129;
     BoxParticipants.Scroll.ColorArrowUpV:=$00423129;
     BoxParticipants.Scroll.ColorScrollThumbV:=$00C9C636;// $001F161C;
     BoxParticipants.Scroll.ColorScrollAreaV:= $00503A30;
     BoxParticipants.Scroll.Width:=5;
     BoxParticipants.Popap.OnClickItem:= BoxParticipants_PopapClickToItem;
    // BoxParticipants.OnGetHistoryChat:=   BoxContact_GetHistoryChat;


 //    BoxContactsScroll:=TAmClientScroll.Create(BoxContacts,PanelTopContacts);
  //   BoxChatScroll:=TAmClientScroll.Create(BoxChat);
  //   BoxContactsHelp:=TAmClientContactHelp.create(BoxContacts);
  //   BoxChatHelp    :=TAmClientMessageHelp.create(BoxChat);
  //   BoxOnlineScroll:=TAmClientScroll.Create(BoxOnline  , nil);

      BoxMessage:=TAmClientScrollBoxMessage.Create(self);
     //BoxTest.Height := 520;
      BoxMessage.Align:=AlClient;
     // BoxTest.Width:=400;
     // BoxTest.AutoScroll:=true;

     BoxMessage.Parent:=PanelChatBox;
     BoxMessage.Box.Color:= $002D221E;

 // BoxTest.VertScrollBar.Visible:=false

     BoxMessage.Scroll.ColorBorder:=$00765950;
     BoxMessage.Scroll.ColorArrowDownV:=$0077A4FF;
     BoxMessage.Scroll.ColorArrowUpV:=$0077A4FF;
     BoxMessage.Scroll.ColorScrollThumbV:=$00C9C636;// $001F161C;
     BoxMessage.Scroll.ColorScrollAreaV:= $00503A30;
     BoxMessage.Scroll.Width:=5;
    // BoxMessage.OnGetOldBlockMessages:= BoxMessage_GetOldBlockMessages;
     BoxMessage.Box.BarRange.ScrollTo_OnDivisor:= BoxMessage_GetOldBlockMessages;
     BoxMessage.Box.BarRange.ScrollTo_DivisorMax:=3;
     BoxMessage.OneMsg_ReadMsg:=  BoxMessage_ReadMessage;
     BoxMessage.OneMsg_VoiceNotPlay := BoxMessage_VoiceNotPlay;

     BoxContact:=TAmClientScrollBoxContact.Create(self);
     BoxContact.Align:=alClient;
     BoxContact.Parent:=PanelLeft;
     BoxContact.Box.Color:= $00423129;

     BoxContact.Color:= $00423129;
     BoxContact.Scroll.ColorBorder:=$00765950;
     BoxContact.Scroll.ColorArrowDownV:=$00423129;
     BoxContact.Scroll.ColorArrowUpV:=$00423129;
     BoxContact.Scroll.ColorScrollThumbV:=$00C9C636;// $001F161C;
     BoxContact.Scroll.ColorScrollAreaV:= $00503A30;
     BoxContact.Scroll.Width:=5;
     BoxContact.OnGetHistoryChat:=   BoxContact_GetHistoryChat;
     BoxContact.Popap.OnClickItem:= BoxContact_PopapClickToItem;


     BoxPeople:=TAmClientScrollBoxPeople.Create(self);
     BoxPeople.Align:=alClient;
     BoxPeople.Parent:=self.PanelRigth;
     BoxPeople.Box.Color:= $00423129;

     BoxPeople.Color:= $00423129;
     BoxPeople.Scroll.ColorBorder:=$00765950;
     BoxPeople.Scroll.ColorArrowDownV:=clBlack;
     BoxPeople.Scroll.ColorArrowUpV:=clBlack;
     BoxPeople.Scroll.ColorScrollThumbV:= $00C9C636;// $001F161C;
     BoxPeople.Scroll.ColorScrollAreaV:= $00503A30;
     BoxPeople.Scroll.Width:=5;
     BoxPeople.OnGetHistoryChat:=   BoxPeople_GetHistoryChat;





     PanelChatBottom_RichSend.TextHint:=  '';//RichSendTextBanned;
     PanelChatBottomB.Align:=AlBottom;
     PanelProfile_ScreenName.Caption:='';

     PanelProfile_UserName.Caption:= '';
    // PanelProfile_Photo.Picture:=nil;

     ChatClient:= TChatClientEditor.create;
     ChatClient.OnNeedSaveDialogEvent:= ChatClientNeedSaveDialog;
    // ChatClient.ListThread.ClientForm:=self;
     ChatClient.PopapResult:=TChatClientPopapWindow.Create(self);
     PanelProfile_NotiNewMessage.Checked:=AmBool(ChatClient.ObjUser['Data']['NotiNewMessage'].Value,true);
     CloseAllMainPanel;
     OpenPanel(PanelLogin);



     AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'ClipSilver_Png');
     AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicSilver_Png');
     PanelChatBottom_Att_Status:=amsAttClipSilver;
     PanelChatBottom_Send_Status:=amsMicSilver;
     PanelChatBottom_Send_StatusMouse:=false;
     PanelChatTop_Status.Caption:='';
     PanelChatTop_UserName.Caption:='';


end;
procedure TChatClientForm.ChatClientNeedSaveDialog(var FileName:string);
begin
    SaveDialog1.FileName:= FileName;
    if not SaveDialog1.Execute then
    begin
       FileName:='';
    end
    else
    begin
       FileName:=  SaveDialog1.FileName;
    end;
    
end;

procedure TChatClientForm.ChatClientStart ( aAddressSocket:string;  aPortSokect:integer;  aLog:TamLogString; MiliSecondsTimeOutSocket:Cardinal=INFINITE);
begin
    ChatClient.Start(aAddressSocket,aPortSokect,aLog,MiliSecondsTimeOutSocket);
end;
procedure TChatClientForm.ChatClientStop ;
begin
   ChatClient.Stop;
end;
Procedure  TChatClientForm.ChatClientLogIn;
begin
    ChatClient.SVR_LogIn;
end;



Procedure TChatClientForm.CloseAllMainPanel;
begin
     ClosePanel(PanelChatClient);
     ClosePanel(PanelProfile);
     ClosePanel(PanelLogin);
     ClosePanel(PanelManagerFile);

end;
procedure TChatClientForm.OpenManagerFileClick(Sender: TObject);
begin
PanelChatClient.Visible:=false;
PanelManagerFile.Visible:=true;
end;



Function TChatClientForm.OpenPanel(Win:TPanel):Boolean;
begin
    Result:=Win.Visible;
   // if not Result then
    Win.Visible:=true;
end;
Function TChatClientForm.ClosePanel(Win:TPanel):Boolean;
begin
    Result:=Win.Visible;
  //  if  Result then
    Win.Visible:=false;
end;
procedure TChatClientForm.PanelSendFile_AdderFileClick(Sender: TObject);
var I:integer;
begin
 if not opendialog1.Execute then exit;

 for I := 0 to opendialog1.Files.Count-1 do
    ListBoxFilesAtSend.AddFile(opendialog1.Files[i]);

  if ListBoxFilesAtSend.Items.Count>0 then
  begin
    PanelSendFile_AdderFile.Visible:=false;
    ListBoxFilesAtSend.Visible:=true;
  end;
 
end;

procedure TChatClientForm.PanelSendFile_AdderFilePaint(Sender: TObject; Canvas: TCanvas;
  Rect: TRect);
begin
   Canvas.Brush.Color:=$00423129;
   Canvas.Pen.Color:=$00E8B4B3;
   Canvas.Pen.Style := psDot;

   Canvas.Rectangle(3, 3, TWinControl(Sender).ClientWidth-3, TWinControl(Sender).ClientHeight-3);
end;

procedure TChatClientForm.PanelSendFile_backClick(Sender: TObject);
begin
PanelSendFile.visible:=false;
ListBoxFilesAtSend.clear;
end;

procedure TChatClientForm.PanelSendFile_sendClick(Sender: TObject);
begin
  { P:= TAmClientPot_FileSend.create;
   P.ListFiles := ListBoxFilesAtSend.ItemsMy;
   P.Comment:=PanelSendFile_Comment.text;
   P.TypeUser:=  BoxContact.ActivContact.TypeUser;
   P.ContactUserId:= BoxContact.ActivContact.UserId;}
  // ChatClient.ListThread.AddAndStart(P);
 //for I := 0 to 10 do
   ChatClient.MIM_Message_Send_Files(
              ChatClient.ActivDialog.TypeUser,ChatClient.ActivDialog.UserId,
              PanelSendFile_Comment.text,
              ListBoxFilesAtSend.ItemsMy
   );
   PanelSendFile.Visible:=false;
end;

procedure TChatClientForm.PanelSerchTop_SerchEnter(Sender: TObject);
begin
   if PanelSerchTop_Serch.Text='Поиск' then  PanelSerchTop_Serch.Text:='';
end;

procedure TChatClientForm.PanelSerchTop_SerchExit(Sender: TObject);
begin
   if PanelSerchTop_Serch.Text='' then  PanelSerchTop_Serch.Text:='Поиск';
end;

procedure TChatClientForm.PanelSerchTop_SerchGoClick(Sender: TObject);
begin
ChatClient.SVR_Serch(PanelSerchTop_Serch.Text)
end;

procedure TChatClientForm.Panel_Groop_Edit_PhotoClick(Sender: TObject);
begin
 if ChatClient.ActivDialog.Check(ConstAmChat.TypeUser.Groop) and OpenDialog1.Execute then
 begin
  ChatClient.Groop_PhotoUpload(OpenDialog1.FileName,ChatClient.ActivDialog.UserId,LParam(Panel_Groop_Edit_Photo));
 end;
end;

procedure TChatClientForm.Panel_Groop_Edit_SaveClick(Sender: TObject);
begin
    if ChatClient.ActivDialog.Check(ConstAmChat.TypeUser.Groop) then
    begin
       if (Panel_Groop_Edit_UserName.Text<>ChatClient.ActivDialog.UserName)
       and (Length(Panel_Groop_Edit_UserName.Text)>4) then
       begin
          ChatClient.SVR_Groop_SetUserName(ChatClient.ActivDialog.UserId,Panel_Groop_Edit_UserName.Text);
       end;
       
    end;

end;

procedure TChatClientForm.Panel_Groop_Edit_UserNameChange(Sender: TObject);
begin
 if not   Panel_Groop_Edit_Save.Visible then  Panel_Groop_Edit_Save.Visible:=true;
 
end;

Function  TChatClientForm.ReversPanel(Win:TPanel):Boolean;
begin
     Result:=Win.Visible;
     if  Result then Win.Visible:=false
     else  Win.Visible:=true

end;


procedure TChatClientForm.UserChange(Sender: TObject);
var Names:String;
begin
   Names:= TWinControl(Sender).Name;
   Names:= Names.Split(['_'])[1];
   if Sender is TCheckBox then
   begin
     ChatClient.ObjUser['Data'][Names].Value:= BoolToStr(TCheckBox(Sender).Checked);
   end;



end;

Procedure TChatClientForm.ClearPanelChatClient;
begin

end;



procedure TChatClientForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var Box:TamWinControlVertScroll;
begin
  Handled:=true;
  Box:=nil;
  if MouseInControl(ListBoxFilesAtSend) then
  begin
    // logMain.log('ListBoxFilesAtSend');
  end
  else if MouseInControl(BoxParticipants) then
  begin
    BoxParticipants.Box.VertScrollBar.Position:=  BoxParticipants.Box.VertScrollBar.Position -  ( WheelDelta div 2) ;
   // logMain.log('BoxParticipants');
  end
  else if MouseInControl(BoxMessage) then
  begin
    BoxMessage.Box.BarRange.Position:=  BoxMessage.Box.BarRange.Position +  ( WheelDelta div 2) ;
   // logMain.log('BoxMessage');
  end
  else if MouseInControl(BoxContact) then
  begin
    BoxContact.Box.VertScrollBar.Position:=  BoxContact.Box.VertScrollBar.Position -  ( WheelDelta div 2) ;
    ///logMain.log('BoxContact');
  end
  else if MouseInControl(BoxPeople) then
  begin
    BoxPeople.Box.VertScrollBar.Position:=  BoxPeople.Box.VertScrollBar.Position -  ( WheelDelta div 2) ;
   // logMain.log('BoxPeople');
  end

  else Handled:=False;
  //  logMain.log('FormMouseWheel');
  {
  if Assigned(Box) then
  Box.VertScrollBar.Position:=  Box.VertScrollBar.Position-WheelDelta
  else Handled:=False;
   }



end;

procedure TChatClientForm.FormResize(Sender: TObject);
var i:integer;

begin
       {
       //111
       if PanelLeft.Visible and PanelChat.Visible and PanelRigth.Visible then
       begin
         if (Width<800)  then
         begin


           LabelOpenSerch.Visible:=true;
           PanelRigth_SaveW:= PanelRigth.Width;
           PanelRigth.Visible:=false;
         end;


         if (Width<500)  then
         begin
           LabelBackChat.Visible:=true;
           PanelLeft_SaveW:= PanelLeft.Width;
           PanelLeft.Visible:=false;
         end;

       end
       else
       //110
       if PanelLeft.Visible and PanelChat.Visible and  not PanelRigth.Visible then
       begin
         if (Width>800)  then
         begin
           LabelOpenSerch.Visible:=false;
           if PanelRigth_SaveW<=0 then PanelRigth_SaveW:=200;
           PanelRigth.Width:=PanelRigth_SaveW;
           PanelRigth.Visible:=true;
         end;
         if (Width<500)  then
         begin
           LabelBackChat.Visible:=true;
           PanelLeft_SaveW:= PanelLeft.Width;
           PanelLeft.Visible:=false;
         end;

       end
       else
       //100
       if PanelLeft.Visible and not PanelChat.Visible and  not PanelRigth.Visible then
       begin
         if (Width>800)  then
         begin
           LabelOpenSerch.Visible:=false;
           if PanelRigth_SaveW<=0 then PanelRigth_SaveW:=200;
           PanelRigth.Width:=PanelRigth_SaveW;
           PanelRigth.Visible:=true;
         end;
         if (Width>500)  then
         begin
           LabelBackChat.Visible:=false;
           PanelLeft.Align:=alLeft;
           if PanelLeft_SaveW<=0 then PanelLeft_SaveW:=200;
           PanelLeft.Width:=PanelLeft_SaveW;
           PanelChat.Visible:=true;
         end;

       end
       else
       //101
       if PanelLeft.Visible and not PanelChat.Visible and   PanelRigth.Visible then
       begin

         if (Width>800)  then
         begin
           LabelBackChat.Visible:=false;
           PanelLeft.Align:=alLeft;
           if PanelLeft_SaveW<=0 then PanelLeft_SaveW:=200;
           PanelLeft.Width:=PanelLeft_SaveW;
           PanelChat.Visible:=true;



         end;

       end
      ////////////////////

 
       else
       //011
       if not PanelLeft.Visible and PanelChat.Visible and PanelRigth.Visible then
       begin
         if (Width<500)  then
         begin


           LabelOpenSerch.Visible:=true;
           PanelRigth_SaveW:= PanelRigth.Width;
           PanelRigth.Visible:=false;
         end;


         if (Width<500)  then
         begin
           LabelBackChat.Visible:=true;
           PanelLeft_SaveW:= PanelLeft.Width;
           PanelLeft.Visible:=false;
         end;

       end
       else
       //110
       if PanelLeft.Visible and PanelChat.Visible and  not PanelRigth.Visible then
       begin
         if (Width>800)  then
         begin
           LabelOpenSerch.Visible:=false;
           if PanelRigth_SaveW<=0 then PanelRigth_SaveW:=200;
           PanelRigth.Width:=PanelRigth_SaveW;
           PanelRigth.Visible:=true;
         end;
         if (Width<500)  then
         begin
           LabelBackChat.Visible:=true;
           PanelLeft_SaveW:= PanelLeft.Width;
           PanelLeft.Visible:=false;
         end;

       end
       else
       //100
       if PanelLeft.Visible and not PanelChat.Visible and  not PanelRigth.Visible then
       begin
         if (Width>800)  then
         begin
           LabelOpenSerch.Visible:=false;
           if PanelRigth_SaveW<=0 then PanelRigth_SaveW:=200;
           PanelRigth.Width:=PanelRigth_SaveW;
           PanelRigth.Visible:=true;
         end;
         if (Width>500)  then
         begin
           LabelBackChat.Visible:=false;
           PanelLeft.Align:=alLeft;
           if PanelLeft_SaveW<=0 then PanelLeft_SaveW:=200;
           PanelLeft.Width:=PanelLeft_SaveW;
           PanelChat.Visible:=true;
         end;

       end
       else
       //101
       if PanelLeft.Visible and not PanelChat.Visible and   PanelRigth.Visible then
       begin

         if (Width>800)  then
         begin
           LabelBackChat.Visible:=false;
           PanelLeft.Align:=alLeft;
           if PanelLeft_SaveW<=0 then PanelLeft_SaveW:=200;
           PanelLeft.Width:=PanelLeft_SaveW;
           PanelChat.Visible:=true;



         end;

       end
       }
end;
procedure TChatClientForm.LabelBackChatClick(Sender: TObject);
begin
    PanelChat.Visible:=false;
    PanelLeft.Visible:=true;
    PanelLeft.Align:=alClient;
end;

procedure TChatClientForm.LogOutAccClick(Sender: TObject);
begin
   ChatClient.SVR_LogOut(True);
end;

procedure TChatClientForm.LogOutClick(Sender: TObject);
begin
  Close;
  ChatClient.SVR_LogOut(False);
end;

procedure TChatClientForm.OpenProFileClick(Sender: TObject);
begin
PanelChatClient.Visible:=false;
PanelProfile.Visible:=true;
end;



procedure TChatClientForm.PanelChatBottom_RichSendResizeRequest(Sender: TObject;
  Rect: TRect);
var DeltaPM:integer;
NeH:integer;
const Ph :integer = 43;
const Mh :integer = 16;
begin
 DeltaPM:= Ph-Mh;
 NeH:=Rect.Height+DeltaPM;
 if NeH<52 then  NeH:=Ph;
 if NeH>300 then  NeH:=300;
 PanelChatBottomB.Height:=NeH;

end;

procedure TChatClientForm.PanelChatBottom_SendMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (PanelChatBottom_Send_Status=amsMicSilver)
  or (PanelChatBottom_Send_Status=amsMicWhite)
  then
  begin
     AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicActiv_Png');
     PanelChatBottom_Send_Status:= amsMicActiv;

      IsVoiceStart:=true;
      PanelChatBottom_RichSend.ReadOnly:=True;
      DestroyCaret();
      //начать запись голосового
       AmBass.Record_LevelVolume:= 99;
       AmBass.Record_OnChangePosition:= Rec_OnMax;
       AmBass.Record_OnGoodStart:= Rec_OnGoodStart;
       AmBass.Record_OnNotStart:= Rec_OnNotStart;
       AmBass.Record_OnEnd:=  Rec_OnStop;
       AmBass.Record_Start;
  end;



end;

procedure TChatClientForm.PanelChatBottom_SendMouseEnter(Sender: TObject);
begin
PanelChatBottom_Send_StatusMouse:=true;
    if (PanelChatBottom_Send_Status<>amsSendActiv)
    and (PanelChatBottom_Send_Status<>amsMicWhite)
    then
    begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicWhite_Png');
      PanelChatBottom_Send_Status:= amsMicWhite;
    end;

end;

procedure TChatClientForm.PanelChatBottom_SendMouseLeave(Sender: TObject);
begin
PanelChatBottom_Send_StatusMouse:=false;
    if (PanelChatBottom_Send_Status<>amsSendActiv)
    and (PanelChatBottom_Send_Status<>amsMicSilver)
    then
    begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicSilver_Png');
      PanelChatBottom_Send_Status:= amsMicSilver;
    end;
end;

procedure TChatClientForm.PanelChatBottom_SendMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if IsVoiceStart then
  begin
     IsVoiceStart:=false;
      //окончить запись голосового
       AmBass.Record_Stop;

  end
  else
  begin
      if MouseInControl(PanelChatBottom_Ridth) then
      begin
         Postmessage(self.Handle,wm_user+212,0,0);
      end;
  end;
end;
procedure TChatClientForm.PanelChatBoxResize(Sender: TObject);
begin
  if PanelSendFile.visible then
  begin
   PanelSendFile.Left:= PanelChatBox.Width div 2 - PanelSendFile.Width div 2;
   PanelSendFile.Top:= PanelChatBox.Height - PanelSendFile.Height - 30;
  end;


end;


procedure TChatClientForm.PanelChatBottom_AttClick(Sender: TObject);
begin
   if (PanelChatBottom_Att_Status = amsAttRec)  then exit;

   PanelSendFile.Left:= PanelChatBox.Width div 2 - PanelSendFile.Width div 2;
   PanelSendFile.Top:= PanelChatBox.Height - PanelSendFile.Height - 30;

   PanelSendFile.visible:=true;
   PanelSendFile.BringToFront;
end;

procedure TChatClientForm.PanelChatBottom_AttMouseEnter(Sender: TObject);
begin
  if (PanelChatBottom_Att_Status <> amsAttRec)
  and (PanelChatBottom_Att_Status = amsAttClipSilver)
  then
  begin
   AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'ClipWhite_Png');
   PanelChatBottom_Att_Status := amsAttClipWhite;
  end;



end;

procedure TChatClientForm.PanelChatBottom_AttMouseLeave(Sender: TObject);
begin
  if (PanelChatBottom_Att_Status <> amsAttRec)
  and (PanelChatBottom_Att_Status = amsAttClipWhite)
  then
  begin
   AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'ClipSilver_Png');
   PanelChatBottom_Att_Status := amsAttClipSilver;
  end;
end;

procedure TChatClientForm.PanelChatBottom_RichSendChange(Sender: TObject);
begin
  if (PanelChatBottom_Send_Status<> amsMicActiv) and (PanelChatBottom_Send_Status<> amsMicNoActiv) then
  begin
   if (PanelChatBottom_RichSend.Text<>'')
   and (PanelChatBottom_Send_Status<>amsSendActiv)
   then
   begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'SendActiv_png');
      PanelChatBottom_Send_Status:= amsSendActiv;
   end
   else if (PanelChatBottom_RichSend.Text='') and PanelChatBottom_Send_StatusMouse  then
   begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicWhite_Png');
      PanelChatBottom_Send_Status:= amsMicWhite;
   end
   else if (PanelChatBottom_RichSend.Text='') and not PanelChatBottom_Send_StatusMouse  then
   begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicSilver_Png');
      PanelChatBottom_Send_Status:= amsMicSilver;
   end;
  end;


	 //    AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'ClipSilver_Png');
   //  AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicSilver_Png');
    // PanelChatBottom_Att_Status:=amsAttClipSilver;
end;
procedure  TChatClientForm.AM_SendTextMessage(var Msg:TMessage);//message wm_user+212;
var Text:string;
begin


   Text:= PanelChatBottom_RichSend.Text;
   PanelChatBottom_RichSend.Text:='';
   ChatClient.MIM_Message_Send_Text(ChatClient.ActivDialog.TypeUser,ChatClient.ActivDialog.UserId, Text) ;

end;
procedure TChatClientForm.PanelChatBottom_RichSendKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
  var Sd:boolean;
begin
  Sd:=false;
  if (Key =13)  then
  begin
     Sd:= not ( ssShift in Shift);
  end;

  if Sd then
   begin
      if PanelChatBottom_RichSend.Focused then
      begin
        Key:=0;
        Postmessage(self.Handle,wm_user+212,0,0);
      end;
   end;

end;

procedure TChatClientForm.Rec_OnMax(M:integer;s:string);
begin

   PanelChatBottom_RichSend.text:= s;
   DestroyCaret();
end;
procedure TChatClientForm.Rec_OnGoodStart;
begin
  if (PanelChatBottom_Att_Status <> amsAttRec) then
  begin
   AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'Rec_png');
   PanelChatBottom_Att_Status := amsAttRec;
  end;
   //Label94.Caption:='R';
  // Label94.Font.Color:=$008080FF;
end;
procedure  TChatClientForm.Rec_OnNotStart(Error:string);
begin
      ChatClient.PopapInfoSetText(Error,true);
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicNoActiv_png');
      PanelChatBottom_Send_Status:= amsMicNoActiv;
end;
procedure TChatClientForm.Rec_OnStop(MaxPos:integer;CaptionTime:string);
var ms:TMemoryStream;

var Spectr:TAmBassSpectrMono;
VoiceObj:TJsonObject;
  procedure CrArr;
  var i:integer;
  begin
    for I := 0 to Length(Spectr)-1 do
    VoiceObj['VoiceSpectr'].A['List'].Add(FloatTostr(Spectr[i]));
  end;

begin
      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Att.Picture,'ClipSilver_Png');
      PanelChatBottom_Att_Status := amsAttClipSilver;

      AmUSerType.TamResource.LoadToPicture(PanelChatBottom_Send.Picture,'MicSilver_Png');
      PanelChatBottom_Send_Status:= amsMicSilver;

      PanelChatBottom_RichSend.Text:='';
      PanelChatBottom_RichSend.ReadOnly:=False;
 if MaxPos>1 then
 begin
       ms:= TMemoryStream.Create;
       ms.LoadFromStream(AmBass.Record_GetStream);
       AmBass.Spectr_GetBufferMono(ms,Spectr,100);
       ChatClient.MIM_Message_Send_Voice(ChatClient.ActivDialog.TypeUser,ChatClient.ActivDialog.UserId,ms,MaxPos,CaptionTime,Spectr);

      {
       ms:= AmBass.Record_GetStream;
       ChatClient.BufferConteiner.Clear;
       ChatClient.BufferConteiner.LoadFromStream(ms);



       if  AmBase64.StreamToBase64(ms,StringBase64) then
       begin
           VoiceObj:= TJsonObject.Create;
           try
             VoiceObj['VoiceBase64'].Value:= StringBase64;
             VoiceObj['VoiceLength'].Value:= MaxPos.ToString;
             VoiceObj['VoiceCaption'].Value:='';
             VoiceObj['VoiceTimerSecond'].Value:=CaptionTime;
             CrArr;
             StringBase64:=VoiceObj.ToJSON();
           finally
             VoiceObj.Free;
           end;

         ChatClient.SVR_Message_Send('User',BoxContact.ActivContact.UserId,'Voice',StringBase64) ;
         PanelChatBottom_RichSend.Text:='';

       end;
      // logMain.log(StringBase64);
        }

    //   showmessage(ms.Size.ToString);
     //  ms.SaveToFile('1.mp3');
      // AmBass.Play_Start(ms);
      // showmessage('Отправка голосового');
 end;

end;

procedure TChatClientForm.PanelLogin_GoClick(Sender: TObject);
begin
   if not ChatClient.IsServerOnlineSave then
   begin
      ChatClient.PopapInfoSetText('Попробуйте позже.');
      exit;
   end;
   ChatClient.PopapInfoSetText('Выполняется...');
   ChatClient.SVR_LogInParam(PanelLogin_Login.Text,PanelLogin_Pass.Text,PanelLogin_Remember.Checked);
end;

procedure TChatClientForm.PanelManagerFile_backClick(Sender: TObject);
begin
PanelChatClient.Visible:= true;
PanelManagerFile.Visible:=false;
end;

procedure TChatClientForm.PanelManagerFile_send_menuClick(Sender: TObject);
begin
PanelManagerFile_closeAllPanel;
PanelManagerFile_send_menu.Color:= $0093973E;
PanelManagerFile_send_view.Color:= $0093973E;
PanelManagerFile_send_view.Align:=alclient;
PanelManagerFile_send_view.Visible:=true;
end;
procedure TChatClientForm.PanelManagerFile_setting_menuClick(Sender: TObject);
begin
PanelManagerFile_closeAllPanel;
PanelManagerFile_setting_menu.Color:= $0062712D;
PanelManagerFile_setting_view.Color:= $0062712D;
PanelManagerFile_setting_view.Align:=alclient;
PanelManagerFile_setting_view.Visible:=true;
end;

procedure TChatClientForm.PanelObjectCreate_backClick(Sender: TObject);
begin
PanelChatClient.Visible:= true;
PanelObjectCreate.Visible:=false;
end;

procedure TChatClientForm.PanelObjectCreate_Groop_CreateClick(Sender: TObject);
var index:integer;
  TypeChat:string;
begin
  PanelObjectCreate_Groop_Error.Caption:='';
  index:=PanelObjectCreate_Groop_Type.ItemIndex;
  if       index=0 then TypeChat:=  ConstAmChat.TypeGroopPrivacy.OpenChat
  else if  index=1 then TypeChat:=  ConstAmChat.TypeGroopPrivacy.CloseChat
  else if  index=2 then TypeChat:=  ConstAmChat.TypeGroopPrivacy.OpenChanell
  else if  index=3 then TypeChat:=  ConstAmChat.TypeGroopPrivacy.CloseChanell
  else
  begin
     Delay(500);
     PanelObjectCreate_Groop_Error.Visible:=true;
     PanelObjectCreate_Groop_Error.Caption:='Укажите тип группы';
     exit;
  end;

  ChatClient.SVR_Groop_Create(
    PanelObjectCreate_Groop_ScreenName.Text,
    PanelObjectCreate_Groop_UserName.Text,TypeChat);


end;
procedure TChatClientForm.OpenObjectCreateClick(Sender: TObject);
begin
PanelChatClient.Visible:=false;
PanelObjectCreate_Groop_UserName.Text:='';
PanelObjectCreate_Groop_ScreenName.Text:='';
PanelObjectCreate_Groop_Type.ItemIndex:=0;
PanelObjectCreate_Groop_Error.Caption:='';
PanelObjectCreate.Visible:=true;


end;

procedure TChatClientForm.PanelManagerFile_closeAllPanel();
begin
  PanelManagerFile_send_menu.Color:=$00423129;
  PanelManagerFile_download_menu.Color:=$00423129;
  PanelManagerFile_msg_menu.Color:=$00423129;
  PanelManagerFile_setting_menu.Color:=$00423129;

  PanelManagerFile_send_view.Visible:=false;
  PanelManagerFile_download_view.Visible:=false;
  PanelManagerFile_msg_view.Visible:=false;
  PanelManagerFile_setting_view.Visible:=false;
end;

procedure TChatClientForm.PanelManagerFile_download_menuClick(Sender: TObject);
begin
PanelManagerFile_closeAllPanel;
PanelManagerFile_download_menu.Color:= $00485E96;
PanelManagerFile_download_view.Color:= $00485E96;
PanelManagerFile_download_view.Align:=alclient;
PanelManagerFile_download_view.Visible:=true;
end;

procedure TChatClientForm.PanelManagerFile_msg_menuClick(Sender: TObject);
begin
PanelManagerFile_closeAllPanel;
PanelManagerFile_msg_menu.Color:= $0095594D;
PanelManagerFile_msg_view.Color:= $0095594D;
PanelManagerFile_msg_view.Align:=alclient;
PanelManagerFile_msg_view.Visible:=true;
end;

procedure TChatClientForm.PanelProfile_backClick(Sender: TObject);
begin
PanelChatClient.Visible:=true;
PanelProfile.Visible:= false;
end;

procedure TChatClientForm.PanelProfile_NewPhotoClick(Sender: TObject);
//var Stream:TMemoryStream;
//StringBase64:string;
begin

  if OpenDialog1.Execute then
  begin
    ChatClient.Profile_PhotoUpload(OpenDialog1.FileName,true,0);
     exit;
     {
      Stream:=TMemoryStream.Create;
      try
        try
         Stream.LoadFromFile(OpenDialog1.FileName);
       //  showmessage(Stream.Size.ToString);
         amScaleImage.GetJpeg(Stream,150);

         if AmBase64.StreamToBase64(Stream,StringBase64) then
         begin
            PanelProfile_Photo.Picture.LoadFromStream(Stream);
            ChatClient.SVR_NewPhotoUpload(StringBase64,true,'','');
            ChatClient.PopapInfoSetText('Выпоняется...');
         end
         else ChatClient.PopapInfoSetText('Не выходит загрузить фото на сервер',true);;


        except
           ChatClient.PopapInfoSetText('Не выходит загрузить фото',true);
        end;
      finally

        Stream.Free;
      end;
       }

  end;

end;

procedure TChatClientForm.PanelReg_GoClick(Sender: TObject);
begin
   if not ChatClient.IsServerOnlineSave then
   begin
      ChatClient.PopapInfoSetText('Попробуйте позже.');
      exit;
   end;

   ChatClient.PopapInfoSetText('Выполняется...');
   ChatClient.SVR_Reg(PanelReg_Login.Text,PanelReg_Email.Text,
   PanelReg_Pass.Text,PanelReg_Pass2.Text,PanelReg_UserName.Text);
end;

end.
