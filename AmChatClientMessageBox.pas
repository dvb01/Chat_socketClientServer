unit AmChatClientMessageBox;

 {все что относится к scrollbox message здесь}
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  AmClientChatSocket,
  AmUserType,AmLogTo,
  JsonDataObjects,
  AmHandleObject,IOUtils,
  mmsystem,AmList,Math,AmControls,
  ES.BaseControls, ES.Layouts, ES.Images,
  AmChatClientComponets,
  AmChatCustomSocket,AmVoiceControl,
  ShellApi,AmMessageFilesControl,
  AmContentNoPaintObject,AmScrollBoxChat,System.Generics.Collections,AmGrafic,
  Vcl.Direct2D, Winapi.D2D1;

   type
      //виды контента при получении и отправке сообщения
    //  TAmClientOneMessageContentKind = (amConText,amConVoice,amConImage,amConVideo,amEmogji);

     // типы  юзеров
    // TAmClientTypeUser =(amtoUser,amtoChat,amtoGroop,amPublic);



     {переопределение TAmClientOneMessage}
     TAmClientOneMessage = class;
     TChatMimLoadMessage = class;

     TAmEventClientOneMessageRead = procedure (S:TAmClientOneMessage)of object;
     TAmEventClientOneMessageVoiceNotPlay  = procedure (S:TAmClientOneMessage; FileName:string;IsPlay:Boolean)of object;

     TAmClientMenuForOneMessage = class;
     {константы событий для TAmClientScrollBox от TAmClientOneMessage}
     AmClientEventOneMsg=record
         const
         WindowMsgBox = wm_user+11001;
         {TEvent.Msg}
         MainPhotoClick =1;
         MainPhotoMouseMovi =2;
         MainPhotoMouseLeave =3;

         UserNameClick =11;
         UserNameMouseMovi =12;
         UserNameMouseLeave =13;

         TimeMouseMovi =21;
         TimeMouseLeave =22;

         ReadMouseMovi =31;
         ReadMouseLeave =32;
         ReadMsg =33;

         ContentMouseDown    =41;

         VoiceNotPlay =51;


       type {через postmsessage пересылаем этот класс} {LParam}
         TEvent =  class
           Msg:Cardinal;
           Sender:TAmClientOneMessage;
           Button: TMouseButton;
           Shift: TShiftState;
           X, Y: Integer;
           FileName:string;
           IsPlay:Boolean;

         end;


     end;
    { это блок сообщений
     нужен что бы легко отлючать контролы которые не видны сейчас в Box для оптимизации
     состоит из self> HelpPanel >  ListMsg
     ListMsg список к примеру из 20 сообщений в чате TAmClientOneMessage
     ListMsg так содержит верную последвательность контролов TAmClientOneMessage как они должны отобразится в чате визуально
    }



     TAmClientBlockMessages = class(TAmClientCustomPanel)
        private

          FcounterId:integer;
       protected
          procedure AlignControls(AControl: TControl; var ARect: TRect); override;
        public
          ListMsg:TList<TAmClientOneMessage>;
        //  ListHelper:TList;
        //  HelpPanel:Tpanel;
       //   procedure IsNeedShowHideContent(Box_ClientHeight:integer;Pos:integer=0);
        //  procedure HideContent;
      //    procedure ShowContent;
        //  Procedure SetCorrectSequenceMessages;
          procedure RemoveMessage(Msg:TAmClientOneMessage);
          procedure AddMessage(Msg:TAmClientOneMessage;Up:boolean);
          constructor Create(AOwner: TComponent); override;
          destructor Destroy ; override;
     end;


   {это главный ScrollBox для message состоит из блоков TAmClientBlockMessages и самого скрола}
     TAmClientScrollBoxMessage = class(TamChatScrollBoxButtonToDown)
        private

         var
           FCounterMimId:integer;
           FcounterId:integer;
           FBlockLastBottom: TAmClientBlockMessages;

         //  FOnGetOldBlockMessages: TNotifyEvent;


           {события от одного сообщения}
           FOneMsg_MainPhotoClick : TNotifyEvent;
           FOneMsg_ReadMsg:        TAmEventClientOneMessageRead;
           FOneMsg_VoiceNotPlay:TAmEventClientOneMessageVoiceNotPlay;
           {FOnMainPhotoMouseMovi : TMouseMoveEvent;
           FOnMainPhotoMouseLeave : TNotifyEvent;

           FOnUserNameClick: TNotifyEvent;
           FOnUserNameMouseMovi : TMouseMoveEvent;
           FOnUserNameMouseLeave : TNotifyEvent;

           FOnTimeMouseMovi : TMouseMoveEvent;
           FOnTimeMouseLeave : TNotifyEvent;

           FOnReadMouseMovi : TMouseMoveEvent;
           FOnReadMouseLeave : TNotifyEvent;


           FOnContentMouseDown    : TMouseEvent; }



          procedure BoxConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
          procedure BoxResize(Sender: TObject);
          Procedure DoChangePosition(Old,New:integer);override;
          Procedure DoChangeRange(Old,New:integer);   override;
          //Procedure IsNeedShowHideBlock;
        //  Procedure SetCorrectSequenceBlock;
          procedure ClearBox;
       //   Procedure DoGetOldBlockMessages(OldPos,NewPos:integer);
       //   Procedure DoGetOldBlockMessagesPost(var Msg:Tmessage);message TAmClientScrollBoxMessage.AM_GET_OLD_BLOCK_MSG;


          // rich что бы заменить label на TrichEdit
          procedure RichCreate(s:Tobject; Rich:TAmRichEditReplaceLabel.TRichEditHelp);
          procedure RichMouseDown(Sender:Tobject;Button: TMouseButton;Shift: TShiftState;X, Y: Integer);
          procedure RichResizeRequest(Sender: TObject; Rect: TRect);
          procedure RichUrlClick (Sender:Tobject;Url:string;var CanGoUrl:boolean);
          //TAmClientOneMessage посылает сюда сообщение если что то произошло
          Procedure EventOneMsgPost(var Message:Tmessage);message AmClientEventOneMsg.WindowMsgBox;

       protected
           // парсинг сообшений от TAmClientOneMessage
           Procedure EventOneMsgPars( Msg:AmClientEventOneMsg.TEvent);
           Procedure DoOneMsg_DoMainPhotoClick(Sender:TAmClientOneMessage);
           Procedure DoOneMsg_DoReadMsg(Sender:TAmClientOneMessage);
           Procedure DoOneMsg_DoContentMouseDown(Sender:TAmClientOneMessage;Button: TMouseButton;Shift: TShiftState;X, Y: Integer);
           Procedure DoOneMsg_VoiceNotPlay(Sender:TAmClientOneMessage;FileName:string;IsPlay:boolean);



        public
          PopapMenu:TAmClientMenuForOneMessage;

          CountMsgChatMax:integer; //количество сообщений которые есть в диалоге всего
          CountMsgChat:integer; //количество сообщений которые уже загружены в Box
          LastIdMessage:integer;
          ClosingDialog: boolean; //true когда пользователь покидает этот диалог  в этот момент очишается box
          Rich:TAmRichEditReplaceLabel;
          Function GetMimId:string;

          // тот блок который в самом низу  с новыми сообщениями
          // нужен что бы занть куда добавить новое сообщениие или создать новый блок
          property    BlockLastBottom:TAmClientBlockMessages read FBlockLastBottom;
          Function    RemoveMessagePoAdress(Adress:Cardinal):boolean;
          Function    RemoveMessage(OneMessage:TAmClientOneMessage):boolean;
          procedure   AddNewMessage(NewMessage:TAmClientOneMessage;CountMaxMsgInBlock:integer);  //использую когда приходит новое сообщение что бы добавить в конец
          procedure   AddBlock(Block:TAmClientBlockMessages;Up:boolean); // использую что бы заполнить box при отрытии диалога 20-50 msg последними сообщениями и когда скролится вверх  добавить старые сообщения
          procedure   CloseDialog;//    выполнить если юзер вочет выйти и текушег диалога чтобы очистить box
          procedure   OpenDialog; //    выполнить если юзер вочет зайти какой то диалог после нее можно выполнять AddBlock и AddNewMessage
          constructor Create(AOwner: TComponent); override;
          destructor  Destroy ; override;
          // событие когда нужно подгрузить страрые сообщения в самый верх
       //   property    OnGetOldBlockMessages:TNotifyEvent read FOnGetOldBlockMessages write FOnGetOldBlockMessages;

          {события от одного сообщения}
          property    OneMsg_MainPhotoClick:TNotifyEvent read FOneMsg_MainPhotoClick write FOneMsg_MainPhotoClick;
          property    OneMsg_ReadMsg:TAmEventClientOneMessageRead read FOneMsg_ReadMsg write FOneMsg_ReadMsg;
          property    OneMsg_VoiceNotPlay:TAmEventClientOneMessageVoiceNotPlay read FOneMsg_VoiceNotPlay write FOneMsg_VoiceNotPlay;



          Function  GetOneMessage(MessageId:string):TAmClientOneMessage;
          procedure SerchIndexMessage(MessageId:string;var List:TList<TWincontrol>; var indexBlock:integer;var IndexMessage:integer);

     end;




     {это одно сообщение}
     TAmClientOneMessage = class(TAmClientCustomPanel)

        type
         TGraficLabText = record
           R:Trect;
           Visible:boolean;
           TextFull:string;
           TextView:string;
           FontColor:Tcolor;
           FontSize:integer;
           FontName:string;
           BrushColor:Tcolor;
           ParentColor:boolean;

         end;

          Type TRectObj= record
               Msg:TGraficLabText;
               Name:TGraficLabText;
               Time:TGraficLabText;
               Read:TGraficLabText;
          end;
       strict Private
        var

         FBox:TAmClientScrollBoxMessage;
         FContentType: String;
         FMsgIsMy:boolean;
         FMsgIsRead:boolean;
         FOnReadMsg: TNotifyEvent;
         //FMsgTextMemo:TamRichEditLink;
         //FMsgTextFull:string;
         FMsgVoice:TAmClientVoiceControl;
         FMsgFiles:TAmClientMessageFilesZipControl;

         FLoingMessage:TChatMimLoadMessage;
         FRichReplaceLabel :TAmRichEditReplaceLabel.TRichEditHelp;

         FResiseProcessing:boolean;

         //для оперделения что сообщения юзер прочел
         FMonitoringRead:TamIsСontrolToScreen;
         procedure WMMove(var Message: TWMMove); message WM_MOVE;
         procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
         procedure WMSize(var Message: TWMSize); message WM_SIZE;

        // procedure AMRichReplaceLabelLeave(var Message: Tmessage); message AM_RICH_REPLACE_LABEL_LEAVE;
        // procedure AMRichReplaceLabelEnter(var Message: Tmessage); message AM_RICH_REPLACE_LABEL_ENTER;


         procedure   MonitoringReadYes(S:TObject); // если прочел сработывает эта и запускает таймер на 2 сек после этого галочка станет зеленой  и запустится  OnReadMsg что бы отослать на сервер
         procedure   PostMsgToBox(Event:AmClientEventOneMsg.TEvent);




         procedure Create_ConteType_Text;
         procedure Create_ConteType_Voice;
         procedure Create_ConteType_Files;

         procedure   VoiceOnNotPlay(S:TObject; FileName:String;IsPlay:boolean);
         function    GetBox:TAmClientScrollBoxMessage;
         function    GetHandelBox:Cardinal;// что бы box отослать сообщение например о клике по тексту

         procedure   SetTimeFull(val:string);
         function    GetTimeFull :string;

         procedure   SetMsgIsMy(val:boolean);
         procedure   SetMsgIsRead(val:boolean);

         procedure   SetMsgTextFull (val:string);
         function    GetMsgTextFull :string;

         function    GetMsgTextSel :string;

         function    GetUserNameFull:string;
         procedure   SetUserNameFull(val:string);



         procedure SetCanvasFontParam(GrafText:TGraficLabText);
     private
       //  procedure   SelfResize(Sender: TObject);
     //   procedure SelfCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
        // procedure    SelfConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);

       //  procedure    TimerSelfResize(Sender: TObject);

         procedure    ResizeMsgText; virtual;
         procedure    PaintMsgText;  virtual;

         procedure    PaintUserName; virtual;
         procedure    ResizeUserName; virtual;

         procedure    PaintMsgTime;  virtual;
         procedure    ResizeMsgTime;  virtual;

         procedure    PaintMsgRead;virtual;
         procedure    ResizeMsgRead;virtual;

       //  procedure    MemoResizeRequest(Sender: TObject; Rect: TRect);
     protected
         procedure Paint;override;
         procedure Resize;override;
         procedure  CreateWnd; override;
         // реакция на события например клик по тексту чтобы отослать в box и показать popap через postmessage
         procedure   MouseDown(Button: TMouseButton;Shift: TShiftState;X, Y: Integer); override;

     public
     var RectObj:TRectObj;
        PhotoId:string;
        PhotoData:string;
        UserId:string;
        MessageId:string;
        MessagePhotoId:string;
        MessagePhotoData:string;
        MimId:string;
      //  NewLabel:Tlabel;

        property   LoingMessage:TChatMimLoadMessage read FLoingMessage write FLoingMessage;

        property   RichReplaceLabel :TAmRichEditReplaceLabel.TRichEditHelp  read FRichReplaceLabel write FRichReplaceLabel;
        property   ContentType:String read FContentType;// вид контента в сообщении
        property   UserNameFull:String read GetUserNameFull write SetUserNameFull;
        function   GetImagePhotoMain:Cardinal;
        Procedure  SetImagePanelMainColor(Col:Tcolor);
        property   TimeFull:String read GetTimeFull write SetTimeFull;

        property   MsgTextSel:String read GetMsgTextSel;
        property   MsgTextFull:String read GetMsgTextFull write SetMsgTextFull;
        property   MsgIsMy:boolean   read FMsgIsMy write SetMsgIsMy;
        property   MsgIsRead:boolean read FMsgIsRead write SetMsgIsRead;
        property   OnReadMsg: TNotifyEvent read FOnReadMsg write FOnReadMsg;
        property   HandelBox : Cardinal Read GetHandelBox;
        property   Box : TAmClientScrollBoxMessage Read GetBox;

        property   MsgVoice : TAmClientVoiceControl Read FMsgVoice;
        property   MsgFiles : TAmClientMessageFilesZipControl Read FMsgFiles;

        constructor Create(AOwner: TComponent;aContentType:String=ConstAmChat.TypeContent.Text);reintroduce;
        destructor Destroy; override;
     end;



   {попап меню при клик на контент сообщения}
    TAmClientMenuForOneMessage =  class (TAmClientPopapMenu)


      strict private
         Procedure  ClickToItem(S:Tobject;NameItem:String);
      public
        constructor Create(aParent: TWincontrol); reintroduce;
    end;

    TAmClientMenuForMIMOneMessage =  class (TAmClientPopapMenu)


      strict private
         Procedure  ClickToItem(S:Tobject;NameItem:String);
      public
        constructor Create(aParent: TWincontrol); reintroduce;
    end;

   TChatMimLoadMessage = class(TChatPanelLoadMessage)
    private

      FOnAbortSend:TNotifyEvent;
      FOnPauseSend:TNotifyEvent;
     protected
        Procedure MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);override;

        procedure  CreateWnd; override;
     public
      FilesSendParamLparam:Integer;
      Popap:TAmClientMenuForMIMOneMessage;
      OneMessage:TAmClientOneMessage;
      property OnAbortSend : TNotifyEvent read FOnAbortSend write FOnAbortSend;
      property OnPauseSend : TNotifyEvent read FOnPauseSend write FOnPauseSend;
      constructor Create(AOneMessage:TAmClientOneMessage);reintroduce;
      destructor  Destroy; Override;
   end;

implementation

constructor TChatMimLoadMessage.Create(AOneMessage:TAmClientOneMessage);
begin
    inherited Create(AOneMessage);
    OneMessage:=AOneMessage;
    FilesSendParamLparam:=0;
    Popap:=nil;
    Parent:= AOneMessage;
    Align:=alclient;
    Popap:= TAmClientMenuForMIMOneMessage.Create(self);
end;
destructor  TChatMimLoadMessage.Destroy;
begin
    OneMessage:=nil;
    FilesSendParamLparam:=0;
    if Assigned(Popap) then
    begin
      Popap.Free;
      Popap:=nil;
    end;
    inherited;
end;
procedure  TChatMimLoadMessage.CreateWnd;
begin
   inherited;
  //
end;
Procedure TChatMimLoadMessage.MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseDown(Button,Shift,X, Y);
    Popap.Open(OneMessage,0);
end;

     {TAmClientMenuForOneMessage}
constructor TAmClientMenuForMIMOneMessage.Create(aParent: TWincontrol);
var Style:TAmClientMenuForOneMessage.TStyle;
var Element:TAmClientMenuForOneMessage.TElement;
begin
   inherited create(aParent);
   ControlSave:=nil;
   Color:=$00453830;

   self.Constraints.MinHeight:=20;
   self.Constraints.MaxHeight:=300;

   try
     Element.ItemName:='Abort';
     Element.Caption:='Отменить';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Pause';
     Element.Caption:='В конец очереди';
     Element.W:=150;
     Style.Add(Element);

   finally
     ListStyle.Add(Style);
   end;


   Self.OnClickItem:=  ClickToItem;



end;
Procedure  TAmClientMenuForMIMOneMessage.ClickToItem(S:Tobject;NameItem:String);
var Message: TAmClientOneMessage;
begin
    //showmessage('ClickToItem');
     if Assigned(ControlSave) then
     begin



        if (ControlSave is TAmClientOneMessage)then
        begin
         Message:= ControlSave as TAmClientOneMessage;
         if  not AmControlCheckWork(Message) then exit;
         if  not AmControlCheckWork(Message.LoingMessage) then exit;

         if       NameItem = 'Abort' then
         begin
           if Assigned( Message.LoingMessage.OnAbortSend) then
           Message.LoingMessage.OnAbortSend(Message);
           
            //showmessage('Abort '+Message.MimId)

         end
         else
         if       NameItem = 'Pause' then
         begin
           if Assigned( Message.LoingMessage.OnAbortSend) then
           Message.LoingMessage.OnPauseSend(Message);

            //showmessage('Abort '+Message.MimId)

         end
        end;


     end;

end;




     {TAmClientMenuForOneMessage}
constructor TAmClientMenuForOneMessage.Create(aParent: TWincontrol);
var Style:TAmClientMenuForOneMessage.TStyle;
var Element:TAmClientMenuForOneMessage.TElement;
begin
   inherited create(aParent);
   ControlSave:=nil;
   Color:=$00453830;

   self.Constraints.MinHeight:=20;
   self.Constraints.MaxHeight:=300;

   try
     Element.ItemName:='Copy';
     Element.Caption:='Копировать';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Link';
     Element.Caption:='Перейти...';
     Element.W:=150;
     Style.Add(Element);
     //....

   finally
     ListStyle.Add(Style);
   end;

   try
     Style.Clear;
     Element.ItemName:='CopySel';
     Element.Caption:='Копировать выделенное';
     Element.W:=190;
     Style.Add(Element);

     Element.ItemName:='Copy';
     Element.Caption:='Копировать все';
     Element.W:=190;
     Style.Add(Element);

     Element.ItemName:='Link';
     Element.Caption:='Перейти...';
     Element.W:=190;
     Style.Add(Element);
     //....

   finally
     ListStyle.Add(Style);
   end;

   Self.OnClickItem:=  ClickToItem;



end;
Procedure  TAmClientMenuForOneMessage.ClickToItem(S:Tobject;NameItem:String);
var Rich: TAmRichEditReplaceLabel.TRichEditHelp;
begin
    //showmessage('ClickToItem');
     if Assigned(ControlSave) then
     begin



        if ControlSave is TAmRichEditReplaceLabel.TRichEditHelp then
        begin
         Rich:= ControlSave as TAmRichEditReplaceLabel.TRichEditHelp;

         if       NameItem = 'Copy' then  showmessage(Rich.Text)
         else if  NameItem = 'Link'  then  showmessage(Rich.UrlLastClick)
         else if  NameItem = 'CopySel'  then  showmessage(Rich.SelText)
        end;


     end;

end;




               {TAmClientOneMessage}
constructor TAmClientOneMessage.Create(AOwner: TComponent;aContentType:string);
begin
  inherited create(nil);
   FLoingMessage:=nil;
   MimId:='';
   FResiseProcessing:=false;
   FBox:=nil;
   FContentType:=  aContentType;
   FMsgIsMy:=false;
   FMsgIsRead:=false;


   Align:= Albottom;
   //Parent:= PM;
   //Tag:= Cap;
  // Top:=integer.MaxValue;

   AlignWithMargins := True;
   Width := 750;

   Height := 80;
   Margins.Left := 25;
   Margins.Top := 0 ;
   Margins.Right := 25;
   Margins.Bottom := 10 ;
   Align :=alTop ;
   BevelEdges := [] ;
   BevelOuter := bvNone;
   Color := $0049362E;//  ;
   Constraints.MaxWidth := 700 ;
   Font.Charset := DEFAULT_CHARSET ;
   Font.Color := clWindowText ;
   Font.Height := -27 ;
   Font.Name := 'Tahoma';
   Font.Style := [] ;
   ParentBackground := False ;
   ParentFont := False ;

   Font.Color:=clWhite;

//  P.Caption:='sssssssssssssss' +Cap.ToString;





    {   FUserNameLabel:=  TLabel.Create(self);
       FUserNameLabel.Parent:=  self;
       FUserNameLabel.Top := 3;
       FUserNameLabel.Left := 50;
       FUserNameLabel.Align := alCustom ;
       FUserNameLabel.Anchors:= [akTop, akLeft];
       FUserNameLabel.Caption := FUserNameFull;
       FUserNameLabel.Font.Charset := DEFAULT_CHARSET;
       FUserNameLabel.Font.Color := $00CFFF9F;
       FUserNameLabel.Font.Size:=10;
       FUserNameLabel.Font.Name := 'Arial';
       FUserNameLabel.Font.Style := [fsBold];
       FUserNameLabel.ParentBiDiMode := False;
       FUserNameLabel.ParentColor := False;
       FUserNameLabel.ParentFont := False;  }
    {
       FImagePanel:=Tpanel.Create(self);
       FImagePanel.Parent:= self;
       FImagePanel.Left := 6;
       FImagePanel.Top := 5;
       FImagePanel.Width := 34;
       FImagePanel.Height := 32;
       FImagePanel.BevelEdges := [] ;
       FImagePanel.BevelOuter := bvNone;
       FImagePanel.ParentBackground := False ;
       FImagePanel.ParentFont := False ;
       FImagePanel.Color := $00D7F0BF  ;

       FImagePhoto := TEsImage.Create(self);
       FImagePhoto.Parent:= FImagePanel;
       FImagePhoto.Align:=alclient;
       FImagePhoto.Stretch := TImageStretch.Fill;
       FImagePhoto.Transparent:=false;
       FImagePhoto.Smoth:=false;
       FImagePhoto.Picture.LoadFromFile('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\set\chat\client\photos\Photo1_7.jpg');
    }
     {  FTimeLabel:=  TLabel.Create(self);
       FTimeLabel.Parent:=  self;
       FTimeLabel.Top := 4;
       FTimeLabel.Alignment:=taRightJustify;
       FTimeLabel.Left := self.Width-20;
       FTimeLabel.Align := alNone;
       FTimeLabel.Anchors:= [akTop, akRight];
       FTimeLabel.Caption := FTimeFull;
       FTimeLabel.Font.Charset := DEFAULT_CHARSET;
       FTimeLabel.Font.Color := clSilver;
       FTimeLabel.Font.Size:=8;
       FTimeLabel.Font.Name := 'Tahoma';
       FTimeLabel.Font.Style := [];
       FTimeLabel.ParentBiDiMode := False;
       FTimeLabel.ParentColor := False;
       FTimeLabel.ParentFont := False;
            }


     {  FReadLabel:=  TLabel.Create(self);
       FReadLabel.Parent:=  self;
       FReadLabel.Top := self.Height-20;
       FReadLabel.Left := self.Width-20;
       FReadLabel.Align := alCustom ;
       FReadLabel.Anchors:= [akBottom, akRight];
       FReadLabel.Caption := '✔';
       FReadLabel.Font.Charset := DEFAULT_CHARSET;
       FReadLabel.Font.Color := $00C0FF82;
       FReadLabel.Font.Size:=10;
       FReadLabel.Font.Name := 'Tahoma';
       FReadLabel.Font.Style := [];
       FReadLabel.ParentBiDiMode := False;
       FReadLabel.ParentColor := False;
       FReadLabel.ParentFont := False;  }

       FMonitoringRead:= TamIsСontrolToScreen.Create;
       FMonitoringRead.OnFullScreenPart:=MonitoringReadYes;
       FMonitoringRead.Control:=self;



   RectObj.Name.R:= Rect(10,5,Width-70,Height);
   RectObj.Name.Visible:=true;
   RectObj.Name.TextFull:='No Name';
   RectObj.Name.TextView:='';
   RectObj.Name.FontColor:= $00CFFF9F;
   RectObj.Name.FontSize:=10;
   RectObj.Name.FontName:=  'Arial';
   RectObj.Name.BrushColor:=0;
   RectObj.Name.ParentColor:=true;



   RectObj.Time.R:= Rect(Width-40,5,Width,Height);
   RectObj.Time.Visible:=true;
   RectObj.Time.TextFull:='01.01.2000 00:00:000';
   RectObj.Time.TextView:='';
   RectObj.Time.FontColor:= clSilver;
   RectObj.Time.FontSize:=8;
   RectObj.Time.FontName:=  'Arial';
   RectObj.Time.BrushColor:=0;
   RectObj.Time.ParentColor:=true;



   RectObj.Read.R:= Rect(Width-20,Height-25,Width-10,2);
   RectObj.Read.Visible:=true;
   RectObj.Read.TextFull:='✔';
   RectObj.Read.TextView:='✔';
   RectObj.Read.FontColor:= $00C0FF82;
   RectObj.Read.FontSize:=10;
   RectObj.Read.FontName:=  'Arial';
   RectObj.Read.BrushColor:=0;
   RectObj.Read.ParentColor:=true;

     {  NewLabel:=  TLabel.Create(self);
       NewLabel.Parent:=  self;
       NewLabel.Top := 39;
       NewLabel.Left := 6;
       NewLabel.Align := alnone ;
       NewLabel.Anchors:= [akleft, akTop];
       NewLabel.Caption := 'New';
       NewLabel.Font.Charset := DEFAULT_CHARSET;
       NewLabel.Font.Color := $00FFFF80;
       NewLabel.Font.Size:=10;
       NewLabel.Font.Name := 'Verdana';
       NewLabel.Font.Style := [fsBold, fsItalic];
       NewLabel.Font.Quality := fqAntialiased;
       NewLabel.ParentBiDiMode := False;
       NewLabel.ParentColor := False;
       NewLabel.ParentFont := False;
       NewLabel.Visible:=false;       }

    //   TimerResize:=TTimer.Create(self);
     //  TimerResize.Interval:=10;
      // TimerResize.Enabled:=false;
     //  TimerResize.OnTimer:= TimerSelfResize;


    RectObj.Msg.Visible:=false;
    RectObj.Name.Visible:=true;
    RectObj.Time.Visible:=true;
    RectObj.Read.Visible:=true;


     if FContentType=     ConstAmChat.TypeContent.Text then    Create_ConteType_Text
     else if FContentType=ConstAmChat.TypeContent.Voice then   Create_ConteType_Voice
     else if FContentType=ConstAmChat.TypeContent.Files then   Create_ConteType_Files;

   //  self.OnConstrainedResize:=  SelfConstrainedResize;
  //   self.OnResize:=SelfResize;


end;
procedure TAmClientOneMessage.Create_ConteType_Text;
begin


   RectObj.Msg.R:= Rect(10,20,Width-10,25);
   RectObj.Msg.Visible:=true;
   RectObj.Msg.TextFull:='';
   RectObj.Msg.TextView:='';
   RectObj.Msg.FontColor:= $00EFEFEF;
   RectObj.Msg.FontSize:=10;
   RectObj.Msg.FontName:=  'Arial';
   RectObj.Msg.BrushColor:=0;
   RectObj.Msg.ParentColor:=true;
   RectObj.Msg.Visible:=true;
    {   FMsgTextLabel:=  TLabel.Create(self);
       FMsgTextLabel.Parent:=  self;
       FMsgTextLabel.Top := 21;
       FMsgTextLabel.Left := 55;
       FMsgTextLabel.Width:= self.Width  - FMsgTextLabel.Left - 70;

       FMsgTextLabel.Align := alCustom ;
       FMsgTextLabel.Anchors:= [akLeft, akTop];
       FMsgTextLabel.Caption := '';
       FMsgTextLabel.Font.Charset := DEFAULT_CHARSET;
       FMsgTextLabel.Font.Color := clwhite;//;$00EAEAEA;
       FMsgTextLabel.Font.Size:=10;
       FMsgTextLabel.Font.Name := 'Open Sans';
       FMsgTextLabel.Font.Style := [];
       FMsgTextLabel.ParentBiDiMode := False;
       FMsgTextLabel.ParentColor := False;
       FMsgTextLabel.ParentFont := False;
       FMsgTextLabel.OnMouseDown:= FMsgTextLabelMouseDown ;
       FMsgTextLabel.AutoSize:=true;
       FMsgTextLabel.WordWrap:=true; }

end;
procedure TAmClientOneMessage.Create_ConteType_Voice;
begin
         FMsgVoice:= AmVoiceControl.TAmClientVoiceControl.Create(self);
         FMsgVoice.Parent:=self;
         FMsgVoice.Anchors:= [akLeft, akTop,akRight];
         FMsgVoice.Top:=20;
         FMsgVoice.Left:=0;
         FMsgVoice.Width:=Width-(FMsgVoice.Left)-20;
         FMsgVoice.Height:=41;

         FMsgVoice.SpectrQualityPixsel:=1200;
         FMsgVoice.Color:=$0049362E;
         self.Height:= FMsgVoice.Height+FMsgVoice.Top+5;
         FMsgVoice.OnNotPlay:= VoiceOnNotPlay;

end;
procedure TAmClientOneMessage.Create_ConteType_Files;
begin
          Create_ConteType_Text;

          FMsgFiles:= TAmClientMessageFilesZipControl.Create(self);
          FMsgFiles.Parent:=self;
          FMsgFiles.Anchors:= [akLeft, akTop,akRight];
          FMsgFiles.Top:=RectObj.Msg.R.Top+RectObj.Msg.R.Height+5;
          FMsgFiles.Left:=0;
          FMsgFiles.Width:= Width;
          FMsgFiles.Height:=30;


          FMsgFiles.Font.Color:=clWhite;
          FMsgFiles.Font.Size:=10;
        //  FMsgFiles.Color:=clblack;
end;
destructor TAmClientOneMessage.Destroy;
begin
   //logmain.log(' TAmClientOneMessage.Destroy');
    FMonitoringRead.IntupOnDestroy;
    FMonitoringRead.Free;
    inherited;
end;

procedure TAmClientOneMessage.Paint;
begin
     inherited;
   //  showmessage('TAmClientOneMessage');
   PaintMsgRead;
   PaintMsgTime;
   PaintUserName;
   PaintMsgText;
end;
procedure TAmClientOneMessage.Resize;
var NewH:integer;
begin
     inherited;
  //if FResiseProcessing then exit;
  FResiseProcessing:=true;
 try
 //    showmessage('TAmClientOneMessage Resize 1');


   ResizeMsgRead;
   ResizeMsgTime;
   ResizeUserName;
   ResizeMsgText;

   if Assigned(FMsgFiles) then  FMsgFiles.ResizeParamIntput(Width);

   NewH:=0;

     if (RectObj.Msg.R.Height>0) or (FMsgFiles<>nil) then
     begin
       if FMsgFiles<>nil then
       begin

          if RectObj.Msg.R.Top=0 then FMsgFiles.Top:=20+RectObj.Msg.R.Height+5
          else
          FMsgFiles.Top:=RectObj.Msg.R.Top+RectObj.Msg.R.Height+5;


          inc(NewH,FMsgFiles.Height+FMsgFiles.Top) ;
       end
       else if RectObj.Msg.Visible then
       begin
       inc(NewH, RectObj.Msg.R.Height+RectObj.Msg.R.Top);
        inc(NewH,5);
       end;


     end
     else if FMsgVoice<>nil then
     begin
       inc(NewH,FMsgVoice.Height+FMsgVoice.Top);
       inc(NewH,5);
     end;
     ;
    // if NewH<30 then NewH:=30;



   Height:=NewH;

   //showmessage('TAmClientOneMessage Resize 2');

 finally
   FResiseProcessing:=false;
 end;


end;
procedure  TAmClientOneMessage.CreateWnd;
begin
     inherited;
    // TimerSelfResize(self);
end;

procedure TAmClientOneMessage.SetCanvasFontParam(GrafText:TGraficLabText);
begin
    if  GrafText.ParentColor then  self.Canvas.Brush.Color:= Color
    else                             self.Canvas.Brush.Color:= GrafText.BrushColor ;
    self.Canvas.Font.Size:=        GrafText.FontSize;
    self.Canvas.Font.Color :=      GrafText.FontColor;
    self.Canvas.Font.Name :=       GrafText.FontName;
end;
procedure    TAmClientOneMessage.PaintMsgTime;
begin
      if not  RectObj.Time.Visible then exit;
      SetCanvasFontParam(RectObj.Time);
      Winapi.Windows.DrawTextW(
                        Canvas.Handle,
                        RectObj.Time.TextView,
                        Length(RectObj.Time.TextView),
                        RectObj.Time.R,
                        DT_RIGHT  or DT_SINGLELINE
                        //or DT_WORD_ELLIPSIS
     );
end;
procedure    TAmClientOneMessage.ResizeMsgTime;
var Size:TSize;
begin
    if not  RectObj.Time.Visible then
    begin
     RectObj.Time.R.Left:=0;
     RectObj.Time.R.Top:=0;
     RectObj.Time.R.Width:= 0;
     RectObj.Time.R.Height:= 0;

     exit;
    end;
    RectObj.Time.TextView:= AmWrapText.SetTexDateTime(AmDateTime(RectObj.Time.TextFull,'01.01.2000 00:00:000'));
    SetCanvasFontParam(RectObj.Time);
    Size:=Canvas.TextExtent(RectObj.Time.TextView);


    RectObj.Time.R:= self.ClientRect;
    RectObj.Time.R.Top:=5;
    RectObj.Time.R.Right:=RectObj.Read.R.Left -5 ;




    RectObj.Time.R.Left:= RectObj.Time.R.Right - Size.cx;
    RectObj.Time.R.Height:= Size.cy;



end;

procedure    TAmClientOneMessage.PaintMsgRead;

begin

    if not  RectObj.Read.Visible then exit;

     SetCanvasFontParam(RectObj.Read);

     Winapi.Windows.DrawTextW(
                        Canvas.Handle,
                        RectObj.Read.TextFull,
                        Length(RectObj.Read.TextFull),
                        RectObj.Read.R,
                        DT_RIGHT  or DT_SINGLELINE

     );


end;
procedure    TAmClientOneMessage.ResizeMsgRead;
var R:Trect;
begin
     RectObj.Read.Visible:=true;
    if not  RectObj.Read.Visible then
    begin
     RectObj.Read.R.Left:=0;
     RectObj.Read.R.Top:=0;
     RectObj.Read.R.Width:= 0;
     RectObj.Read.R.Height:= 0;
     exit;
    end;

    SetCanvasFontParam(RectObj.Read);

    R:= self.ClientRect;
    R.Top:=2;
    R.Right:=R.Width-10;
    R.Left:= R.Width-7;
    R.Height:= Winapi.Windows.DrawTextW(
                        Canvas.Handle,
                        RectObj.Read.TextFull,
                        Length(RectObj.Read.TextFull),
                        R,
                        DT_RIGHT  or DT_SINGLELINE
                        or DT_CALCRECT

     );
     RectObj.Read.R:= R;


end;

procedure    TAmClientOneMessage.PaintUserName;
begin
    if not  RectObj.Name.Visible then exit;
     SetCanvasFontParam(RectObj.Name);
     Winapi.Windows.DrawTextW(
                        Canvas.Handle,
                        RectObj.Name.TextView,
                        Length(RectObj.Name.TextView),
                        RectObj.Name.R,
                        DT_LEFT  or DT_SINGLELINE
                        //or DT_WORD_ELLIPSIS
     );


end;
procedure    TAmClientOneMessage.ResizeUserName;
var Size:TSize;
begin
    RectObj.Name.Visible:=true;
    if not  RectObj.Name.Visible then
    begin
     RectObj.Name.R.Left:=0;
     RectObj.Msg.R.Top:=0;
     RectObj.Msg.R.Width:= 0;
     RectObj.Msg.R.Height:= 0;

     exit;
    end;

   RectObj.Name.R:= self.ClientRect;
   RectObj.Name.R.Left:=10;
   RectObj.Name.R.Top:=5;
   RectObj.Name.R.Width:=  RectObj.Time.R.Left-20;
   SetCanvasFontParam(RectObj.Name);
   if RectObj.Name.TextFull='' then RectObj.Name.TextFull:='No Name';
   Size:=Canvas.TextExtent(RectObj.Name.TextFull);
   RectObj.Name.R.Height:= Size.cy;
   RectObj.Name.TextView:= AmWrapText.SetText_WidthTrim(RectObj.Name.TextFull,Size.cx,RectObj.Name.R.Width);





end;
procedure    TAmClientOneMessage.ResizeMsgText;

begin
        // showmessage('TextSelfResize');
         //exit;

          if  ( RectObj.Msg.TextFull='') or not RectObj.Msg.Visible then
          begin
           RectObj.Msg.Visible:=false;
           RectObj.Msg.R.Left:=0;
           RectObj.Msg.R.Top:=0;
           RectObj.Msg.R.Width:= 0;
           RectObj.Msg.R.Height:= 0;
           //MsgTextDC.R:= ARect;
           exit;
          end;

         RectObj.Msg.R:= self.ClientRect;
         RectObj.Msg.R.Left:=10;
         RectObj.Msg.R.Top:=20;
         RectObj.Msg.R.Width:=  RectObj.Msg.R.Width-10;
         RectObj.Msg.R.Height:= Height;
         self.Canvas.Brush.Color:=color;
         self.Canvas.Font.Size:=10;
         self.Canvas.Font.Color:=clWhite;


         RectObj.Msg.R.Height:= Winapi.Windows.DrawTextW(
                              Canvas.Handle,
                              RectObj.Msg.TextFull,
                              Length(RectObj.Msg.TextFull),
                              RectObj.Msg.R,
                              DT_LEFT  or DT_WORDBREAK or DT_CALCRECT

           );
      //  RectObj.Msg.TextView:= RectObj.Msg.TextFull;





end;

function TextExtent22(const Text: string; FFontHandle:IDWriteTextFormat): TSize;
var
  TextLayout: IDWriteTextLayout;
  TextMetrics: TDwriteTextMetrics;
begin
   DWriteFactory.CreateTextLayout(PWideChar(Text), Length(text),
    FFontHandle, 0, 0, TextLayout);
  TextLayout.SetWordWrapping(DWRITE_WORD_WRAPPING_WRAP);
  TextLayout.SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_NEAR);
 TextLayout.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);

  TextLayout.GetMetrics(TextMetrics);

  Result.cx := Round(TextMetrics.widthIncludingTrailingWhitespace);
  Result.cy := Round(TextMetrics.height);
end;
procedure    TAmClientOneMessage.PaintMsgText;
const
  str: string = 'sadada asd ыыва ыв аылвалыв жаыв‍‍‍';
  D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT = 4;
var
  c: TDirect2DCanvas;
  r: D2D_RECT_F;
  strText:string;
begin
 {if  ( RectObj.Msg.TextFull='') then exit;


  strText:=RectObj.Msg.TextFull+'';
  c := TDirect2DCanvas.Create(Canvas.Handle, ClientRect);
  c.BeginDraw;
  try
    RectObj.Msg.R.Height:= TextExtent22(strText,c.Font.Handle).cy;
    r.left := RectObj.Msg.R.left;
    r.top := RectObj.Msg.R.Top;
    r.right := RectObj.Msg.R.Right;
    r.bottom := r.top+RectObj.Msg.R.Height;


    // Brush determines the font color.


         c.Brush.Color:=clWhite;
         c.Font.Size:=10;
         c.Font.Color:=clWhite;

    c.RenderTarget.DrawText(
      PWideChar(strText), Length(strText), c.Font.Handle, r, c.Brush.Handle,
      D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT);
  finally
    c.EndDraw;
    c.Free;
  end;

    exit;   }
         //showmessage('Paint');
         if  ( RectObj.Msg.TextFull='') then exit;
         self.Canvas.Brush.Color:=color;
         self.Canvas.Font.Size:=10;
         self.Canvas.Font.Color:=clWhite;
         Winapi.Windows.DrawTextW(
                              Canvas.Handle,
                              RectObj.Msg.TextFull,
                              Length(RectObj.Msg.TextFull),
                              RectObj.Msg.R,
                              DT_LEFT  or DT_WORDBREAK
                              //or DT_WORD_ELLIPSIS

           );



end;





 {
procedure TAmClientOneMessage.MemoResizeRequest(Sender: TObject; Rect: TRect);
begin
 Height := FMsgTextMemo.Top + Rect.Height+20 ;
end; }  {
procedure TAmClientOneMessage.SelfConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);
var  H:integer;
begin
    //MaxWidth := 250 ;
    if Self.Parent=nil then exit;






end; }
function TAmClientOneMessage.GetUserNameFull:string;
begin
   Result:= RectObj.Name.TextFull;
end;
procedure TAmClientOneMessage.SetUserNameFull(val:string);
begin
     if RectObj.Name.TextFull<>val  then
     RectObj.Name.TextFull:=val;
end;
procedure TAmClientOneMessage.SetMsgTextFull (val:string);
begin
     if RectObj.Msg.TextFull<>val  then
     begin
         RectObj.Msg.TextFull:= val.Trim;

         if self.canFocus then
         begin
              Postmessage(Self.Handle,wm_size,0,0);
              Postmessage(Self.Parent.Handle,wm_size,0,0);
             // self.Perform(wm_size,0,0)
         end;


       //  ResizeMsgText;
       //  self.Invalidate;
         
       // if Self.Parent<>nil then TimerSelfResize(nil);


        if (FRichReplaceLabel<>nil) then
        begin
            if  (FRichReplaceLabel.IsWinCreate=999)  then  FRichReplaceLabel.Text:= RectObj.Msg.TextFull
            else   FRichReplaceLabel.TextWaitFor:= RectObj.Msg.TextFull;
        end;
     end;


end;
function    TAmClientOneMessage.GetMsgTextFull :string;
begin
   Result:=  RectObj.Msg.TextFull;
end;
function  TAmClientOneMessage.GetMsgTextSel :string;
begin
   Result:='';
   { if (FMsgTextMemo<>nil) then
   if FMsgTextMemo.IsWinCreate=999 then  Result:=FMsgTextMemo.SelText;}
end;
function TAmClientOneMessage.GetImagePhotoMain:Cardinal;
begin
  // Result:= LPARAM(FImagePhoto);
end;
Procedure TAmClientOneMessage.SetImagePanelMainColor(Col:Tcolor);
begin
   //FImagePanel.Color:= Col;
end;
procedure TAmClientOneMessage.SetTimeFull(val:string);
begin
    if RectObj.Time.TextFull<>val then  RectObj.Time.TextFull:= val;
end;
function TAmClientOneMessage.GetTimeFull :string;
begin
    Result:= RectObj.Time.TextFull;
end;
procedure   TAmClientOneMessage.SetMsgIsMy(val:boolean);
begin
    FMsgIsMy:= val;
    if FMsgIsMy then
    begin
      // FReadLabel.Visible:=true;
       self.Color:=  $00795535;//$0051442D;//$00795535;//$00795535;  //голубое
       if Assigned(FMsgVoice) then
       FMsgVoice.Color:=self.Color;
        if Assigned(FMsgFiles) then
        FMsgFiles.Color:=self.Color;
    end
    else
    begin
        //FReadLabel.Visible:=false;
        self.Color:=  $0051412F;//$00584627//$0049362E;  //cинее
        if Assigned(FMsgVoice) then
        FMsgVoice.Color:=self.Color;
        if Assigned(FMsgFiles) then
        FMsgFiles.Color:=self.Color;


    end;
end;
procedure   TAmClientOneMessage.SetMsgIsRead(val:boolean);
begin


    FMsgIsRead:= val;


    RectObj.Read.TextFull := '✔';
    RectObj.Read.TextView := '✔';
    if FMsgIsRead then RectObj.Read.FontColor := $00C0FF82//зеленый
    else RectObj.Read.FontColor := $006F6FFF; //красный
   self.Repaint;

end;
function    TAmClientOneMessage.GetBox:TAmClientScrollBoxMessage;
var W:TWinControl;
begin
    Result:=FBox;

     if  (Result=nil) or (not  Assigned(Result))  then
     begin

          W:=self;
          while True do
          begin
            W:=W.Parent;
            if  (W<>nil) and Assigned(W) and  (W is TAmClientScrollBoxMessage) then
            begin
                FBox:= W as TAmClientScrollBoxMessage;
                Result:=FBox;
                break;
            end
            else if W=nil then break;


          end;
     end;

end;

function   TAmClientOneMessage.GetHandelBox:Cardinal;
var W:TAmClientScrollBoxMessage;
begin
    Result:=0;
    W:=GetBox;
    if  (W<>nil) and Assigned(W) then Result :=W.Handle;
end;

procedure   TAmClientOneMessage.MouseDown( Button: TMouseButton;Shift: TShiftState;X, Y: Integer);
var Event: AmClientEventOneMsg.TEvent;
begin
      inherited MouseDown(Button, Shift,X, Y);
exit;

    if  RectObj.Msg.R.Contains(Point(X, Y)) then
    begin

       Event:=  AmClientEventOneMsg.TEvent.Create;
       Event.Msg:= AmClientEventOneMsg.ContentMouseDown;
       Event.Sender:=self;
       Event.Button:= Button;
       Event.Shift:= Shift;
       Event.X:=X;
       Event.Y:=Y;
       PostMsgToBox(Event);
    end;

end;


     {
procedure TAmClientOneMessage.AMRichReplaceLabelLeave(var Message: Tmessage); //message AM_RICH_REPLACE_LABEL_LEAVE;
begin
    Message.Result:=  AM_RICH_REPLACE_LABEL_LEAVE;
    FRichReplaceLabel:=nil;
   // showmessage('AMRichReplaceLabelLeave TAmClientOneMessage');

 //  RectObj.Msg.Visible:=true;
//  RePaint;
  // self.SelfResize(nil);

end;
procedure TAmClientOneMessage.AMRichReplaceLabelEnter(var Message: Tmessage); //message AM_RICH_REPLACE_LABEL_ENTER;
begin
    Message.Result:=  AM_RICH_REPLACE_LABEL_ENTER;
    FRichReplaceLabel:=TAmRichEditReplaceLabel.TRichEditHelp(Message.WParam);

   // Tlabel(Message.LParam).Visible:=false;
   // self.SelfResize(nil);
   // showmessage('AM_RICH_REPLACE_LABEL_ENTER TAmClientOneMessage');
end; }

procedure TAmClientOneMessage.WMMove(var Message: TWMMove); //message WM_MOVE;
begin
     if self.Parent=nil then exit;
    inherited;
    if not MsgIsMy and not MsgIsRead  and self.Visible  and self.CanFocus then
    begin
      FMonitoringRead.IntupOnMovi;

    end;

end;
procedure TAmClientOneMessage.WMPaint(var Message: TWMPaint); //message WM_PAINT;
var H:integer;
begin
   if self.Parent=nil then exit;
    inherited;
   if not MsgIsMy and not MsgIsRead  and self.Visible  and self.CanFocus then
   begin
     // logmain.Log('WMPaint');
      FMonitoringRead.IntupOnPaint;

   end;
 //  SelfResize(nil);


end;
procedure TAmClientOneMessage.WMSize(var Message: TWMSize); //message WM_SIZE;
begin
   //logmain.Log('TAmClientOneMessage.WMSize');
   if self.Parent=nil then exit;
   
   inherited ;
end;
procedure   TAmClientOneMessage.MonitoringReadYes(S:TObject);
var Event: AmClientEventOneMsg.TEvent;
begin
 // logmain.Log('ReadYes');
  MsgIsRead:=true;

   Event:=  AmClientEventOneMsg.TEvent.Create;
   Event.Msg:= AmClientEventOneMsg.ReadMsg;
   Event.Sender:=self;
   PostMsgToBox(Event);
  if Assigned(FOnReadMsg) then FOnReadMsg(self);
end;
procedure   TAmClientOneMessage.VoiceOnNotPlay(S:TObject; FileName:String;IsPlay:boolean);
var Event: AmClientEventOneMsg.TEvent;
begin
 // logmain.Log('VoiceOnNotPlay');
   Event:=  AmClientEventOneMsg.TEvent.Create;
   Event.Msg:= AmClientEventOneMsg.VoiceNotPlay;
   Event.Sender:=self;
   Event.FileName:= FileName;
   Event.IsPlay:= IsPlay;
   PostMsgToBox(Event);

end;
procedure   TAmClientOneMessage.PostMsgToBox(Event:AmClientEventOneMsg.TEvent);
var
H:Cardinal;
R:boolean;
begin
  H:= GetHandelBox;
  if H>0 then
  begin
   R:= PostMessage(H,AmClientEventOneMsg.WindowMsgBox,0,Lparam(Event));
   if not R then Event.Free;
  end
  else Event.Free;
end;








         {TAmClientScrollBox}
constructor TAmClientScrollBoxMessage.Create(AOwner: TComponent);
begin
    inherited create(AOwner);
   //  FGetOldBlockMessagesProcessing:=false;
     ClosingDialog:=false;
     LastIdMessage:=-1;
     CountMsgChatMax:=10;
    // ListBlocks:= TList.Create;
     FcounterId:=0;
     FCounterMimId:=0;
   //  self.OnConstrainedResize:=BoxConstrainedResize;
     self.OnResize:= BoxResize;
     Height := 520;
     Align:=altop;
     FBlockLastBottom:=nil;
     PopapMenu:=  TAmClientMenuForOneMessage.Create(TWinControl(AOwner));
     Rich:=TAmRichEditReplaceLabel.Create(self);
     Rich.OnRichCreate:= RichCreate;





end;

destructor TAmClientScrollBoxMessage.Destroy ;
begin
  //  ListBlocks.Clear;
  //  ListBlocks.Free;
    inherited Destroy;

end;
Function TAmClientScrollBoxMessage.GetMimId:string;
begin
    inc(FCounterMimId);
    Result:= AmStr(FCounterMimId);
end;
Function  TAmClientScrollBoxMessage.GetOneMessage(MessageId:string):TAmClientOneMessage;
var indexBlock,IndexMessage:integer;
var List:TList<TWincontrol>;
begin
     Result:=nil;
     List:=nil;
     SerchIndexMessage(MessageId,List,indexBlock,IndexMessage);

     if (indexBlock>=0) and (IndexMessage>=0)and Assigned(List) then
     Result:= TAmClientOneMessage( TAmClientBlockMessages( List[indexBlock] ).ListMsg[IndexMessage] );




end;
procedure TAmClientScrollBoxMessage.SerchIndexMessage(MessageId:string;var List:TList<TWincontrol>; var indexBlock:integer;var IndexMessage:integer);
var i:integer;
Br:Boolean;
  procedure SrBlock(B:TAmClientBlockMessages);
  var x:integer;
  Msg:TAmClientOneMessage;
  begin
       for x := B.ListMsg.Count-1 downto 0 do
       begin
          Msg:=TAmClientOneMessage(B.ListMsg[x]);
          if Msg.MessageId=MessageId then
          begin
            Br:=true;

            IndexBlock:=I;
            IndexMessage:=X;
            break;
          end;

       end;
  end;
begin
   indexBlock:=-1;
   IndexMessage:=-1;
   Br:=false;
   if MessageId='' then exit;
   
   for I := box.Lmid.Count-1 downto 0 do
   begin
       SrBlock(TAmClientBlockMessages(box.Lmid[I]));
       if Br then
       begin
         List:= box.Lmid;
         break;
       end;
   end;
   if (IndexBlock>=0) and (IndexMessage>=0 )then exit;

   for I := box.Lbot.List.Count-1 downto 0 do
   begin
       SrBlock(TAmClientBlockMessages(box.Lbot.List[I]));
       if Br then
       begin
         List:= box.Lbot.List;
         break;
       end;
   end;
   if (IndexBlock>=0) and (IndexMessage>=0 )then exit;





end;


procedure TAmClientScrollBoxMessage.CloseDialog;
begin

  ClosingDialog:=true;
  CountMsgChatMax:=-1;
  CountMsgChat:=-1;
  LastIdMessage:=-1;
  FBlockLastBottom:=nil;
  ClearBox;
end;
procedure TAmClientScrollBoxMessage.ClearBox;
begin
      Rich.Rich.Visible:=false;
      Rich.Rich.Parent:=box;
      box.ClearScrollBox;
end;
procedure TAmClientScrollBoxMessage.OpenDialog;
begin
    CloseDialog;
    ClosingDialog:=false;
end;
Procedure TAmClientScrollBoxMessage.DoChangePosition(Old,New:integer);
begin

    ButtonToDown.Visible:=true;
   inherited DoChangePosition(Old,New);

 //  if Old<>New then
  // DoGetOldBlockMessages(Old,New);
end;
Procedure TAmClientScrollBoxMessage.DoChangeRange(Old,New:integer);
begin


  // if Old<>New then
 //  IsNeedShowHideBlock;

   inherited DoChangeRange(Old,New);
end;
{Procedure TAmClientScrollBoxMessage.DoGetOldBlockMessages(OldPos,NewPos:integer);
var RangeVert:integer;
ExportedNewMsg:boolean;
begin
   //что бы получить блок старых сообщений при прокрутке скрола подключимся к событию  OnGetOldBlockMessages
   // отправляем postMessage самому себе что бы овободить этот поток процедур

  ExportedNewMsg:=false;
  if not FGetOldBlockMessagesProcessing then
  begin
    if OldPos>NewPos then
    begin
      RangeVert:= Box.VertScrollBar.CalcPageRange;
      if RangeVert<=0 then RangeVert:=1;
      if NewPos < RangeVert div 7 then  ExportedNewMsg:=true;
    end;

    if ExportedNewMsg then
    begin
          FGetOldBlockMessagesProcessing:=true;// что бы не получать тысячи старых блоков а только 1 блок скажем по 40 msg
         // self.Scroll.Enabled:=false;
          ScrolingCan:= False;
          PostMessage(self.Handle,AM_GET_OLD_BLOCK_MSG,0,0);
         // FGetOldBlockMessagesProcessing:=false;
    end;
  end;


end;
Procedure TAmClientScrollBoxMessage.DoGetOldBlockMessagesPost(var Msg:Tmessage);//message AM_GET_OLD_BLOCK_MSG;
begin
  try
   if Assigned(FOnGetOldBlockMessages) then
   begin
     FOnGetOldBlockMessages(self);

   end;
  finally
    FGetOldBlockMessagesProcessing:=false;

     ScrolingCan:= True;
  end;

end; }
(*Procedure TAmClientScrollBoxMessage.SetCorrectSequenceBlock;
var i:integer;
var Bl:TAmClientBlockMessages;
MinTop:Integer;
Exr:boolean;
BlockT,BlockH:integer;
Ht:integer;

begin
 Ht:=0;
   MinTop:=integer.MaxValue;
  if ListBlocks.Count>0 then  
 MinTop:=  TAmClientBlockMessages(ListBlocks[0]).Top    ;
 if MinTop< Smallint.MinValue then MinTop:= Smallint.MinValue;

    //    logmain.Log('<>' +' MinTop='+MinTop.ToString);
  {
   for I := 0 to ListBlocks.Count-1 do
    begin
     Bl:=TAmClientBlockMessages(ListBlocks[i]);
     if MinTop>Bl.Top then  MinTop:=Bl.Top;
    end; }
 //   logmain.Log('MinTop='+MinTop.ToString);
    I := 0;
    while I<= ListBlocks.Count-1 do
    begin
        Bl:=TAmClientBlockMessages(ListBlocks[i]);
      //  BlockT:=Bl.Top;
       //
       //
       Bl.IsNeedShowHideContent(Box.ClientHeight,0);

        inc(I);
         continue;

       // if (BlockT<-1000) and (BlockT>1000) then
      //  begin

      //  end;
        



         Bl:=TAmClientBlockMessages(ListBlocks[i]);




        inc(Ht,Bl.Height);
        continue;


       Exr:=false;
       if MinTop<0 then
       Exr:= (not( (Bl.Top < (MinTop+10)) and (Bl.Top > MinTop-10 ))) else
       Exr:= (not( (Bl.Top > MinTop-10 ) and (Bl.Top < MinTop+10  )));




       if Exr and (MinTop>-10000) and (MinTop<10000)  then
       begin
         logmain.Log('<>' +Bl.Top.ToString +' I='+I.ToString +' MinTop='+MinTop.ToString);

         Bl.Top:= MinTop;
       end;

      MinTop:= Bl.Top+Bl.Height;
      if Bl.AlignWithMargins then MinTop:= MinTop+Bl.Margins.Bottom +Bl.Margins.Top ;


      Bl.IsNeedShowHideContent(Box.ClientHeight,0);
    end;

end; *)
{Procedure TAmClientScrollBoxMessage.IsNeedShowHideBlock;
  var Block:TAmClientBlockMessages;
  i:integer;
begin  SetCorrectSequenceBlock;
     exit;
    logmain.log('ListBlocks.Count'+ListBlocks.Count.ToString);
    for I := ListBlocks.Count-1 downto 0 do
    begin
       Block:= TAmClientBlockMessages(ListBlocks[i]);
       Block.IsNeedShowHideContent(Box.ClientHeight,0);//Box.VertScrollBar.Position
    end;
end; }
procedure TAmClientScrollBoxMessage.AddBlock(Block:TAmClientBlockMessages;Up:boolean);
var aTop,i:integer;
begin  //showmessage(NeedDelay.ToString());
 // Box.Visible:=false;
    Box.AddControl(Block,Up);


  {

     Block.IdPanel:=FcounterId;
     inc(FcounterId);
     Block.HelpPanel.Parent:= Block;
     Block.SetCorrectSequenceMessages;
     Block.Parent:= self.Box;
    //Box.InsertControl(Block);
    if Up then
    begin
      aTop:= integer.MinValue;
       Block.Top:= aTop;

       self.ScrolingCanIgnor:=true;
       Box.VertScrollBar.Position:= SavePos+Block.Height;
       self.ScrolingCanIgnor:=false;
       ListBlocks.Insert(0,Block);

       if NeedDelay then
      // delay(500);

    end
    else
    begin
       aTop:= integer.MaxValue;
       Block.Top:= aTop;
       ListBlocks.Add(Block);
    end;

  //  if ListBlocks.Count=1 then FBlockLastBottom:= Block
   // else if not Up then FBlockLastBottom:= Block;



 //Box.Visible:=true;


    for I := 0 to Block.ListMsg.Count-1 do
    begin
        if TAmClientOneMessage(Block.ListMsg[i]).MsgFiles<>nil then
        begin
          TAmClientOneMessage(Block.ListMsg[i]).MsgFiles.ListImg.UpdSize;
        end;
       // TAmClientOneMessage(Block.ListMsg[i]).SelfResize(nil);
    end;
         }

end;
Function  TAmClientScrollBoxMessage.RemoveMessage(OneMessage:TAmClientOneMessage):boolean;
var
Block:TAmClientBlockMessages;
begin
       Result:=false;
       if  Amcontrols.AmControlCheckWork(OneMessage)
       and Amcontrols.AmControlCheckWork(OneMessage.Parent)
       and (OneMessage.Parent is TAmClientBlockMessages) then
       begin
        Block:= TAmClientBlockMessages(OneMessage.Parent);
        Block.RemoveMessage(OneMessage);
        Result:=true;
       end;

end;
Function   TAmClientScrollBoxMessage.RemoveMessagePoAdress(Adress:Cardinal):boolean;
begin
   Result:= RemoveMessage(TAmClientOneMessage(Adress));
end;
procedure TAmClientScrollBoxMessage.AddNewMessage(NewMessage:TAmClientOneMessage;CountMaxMsgInBlock:integer);
var Block:TAmClientBlockMessages;
savePos:Integer;
GoDownPos:Boolean;
begin
    GoDownPos:=false;
  //  savePos:=Box.VertScrollBar.Position;
//    GoDownPos:=savePos>=Box.VertScrollBar.CalcPageRange;


    if (FBlockLastBottom=nil) or (FBlockLastBottom.ListMsg.Count>=CountMaxMsgInBlock)  then
    begin
        Block:= TAmClientBlockMessages.Create(self);
        Block.AddMessage(NewMessage,false);
        AddBlock(Block,false);
    end
    else
    begin
        FBlockLastBottom.AddMessage(NewMessage,false);

        if LParam(FBlockLastBottom.Parent) <> LParam(Box)  then
        begin
           AddBlock(FBlockLastBottom,false);
           LogMain.Log('ERRRRRRRRRRRRRRRAddNewMessageAddNewMessageAddNewMessageAddNewMessageAddNewMessage');
        end
        else
        begin
          //  FBlockLastBottom.SetCorrectSequenceMessages;
           // PostMessage(FBlockLastBottom.Handle,WM_SIZE,0,0);
        end;
    end;
    //if GoDownPos then Box.VertScrollBar.SmoothScrollOnPosition(Box.VertScrollBar.CalcPageRange,50);


end;
procedure TAmClientScrollBoxMessage.BoxConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
begin

end;
procedure TAmClientScrollBoxMessage.BoxResize(Sender: TObject);
begin
    //ShowScrollBar(Handle, SB_VERT, False);
end;


procedure TAmClientScrollBoxMessage.RichCreate(s:Tobject; Rich:TAmRichEditReplaceLabel.TRichEditHelp);
begin
   Rich.OnUrlClick:=RichUrlClick;
   Rich.OnMouseDown:= RichMouseDown;
   Rich.OnResizeRequest:= RichResizeRequest;
end;
procedure TAmClientScrollBoxMessage.RichMouseDown(Sender:Tobject;Button: TMouseButton;Shift: TShiftState;X, Y: Integer);
begin
    if Button=mbRight then
    begin
       if TAmRichEditReplaceLabel.TRichEditHelp(Sender).SelText<>'' then PopapMenu.Open(Sender,1)
       else PopapMenu.Open(Sender,0);
    end
   // else if Button=mbLeft then Rich.ReplaceLabel(Sender.LabelMsgText);
end;
procedure  TAmClientScrollBoxMessage.RichResizeRequest(Sender: TObject; Rect: TRect);
begin
//  Sender = TrichEdit;
//TwinControl(Sender).Parent  = TAmClientOneMessage

  if (TwinControl(Sender).Parent is TAmClientOneMessage) then
  begin
  (TwinControl(Sender).Parent as TAmClientOneMessage).Height := TwinControl(Sender).Top + Rect.Height+20 ;
  end;
end;
procedure TAmClientScrollBoxMessage.RichUrlClick (Sender:Tobject;Url:string;var CanGoUrl:boolean);
begin
   CanGoUrl:=true;
   // showmessage(Url);
end;

Procedure TAmClientScrollBoxMessage.EventOneMsgPost(var Message:Tmessage);//message AmClientEventOneMsg.WindowMsgBox;
var Msg:AmClientEventOneMsg.TEvent;
begin
  if Message.LParam<=0 then exit;
  Msg:= AmClientEventOneMsg.TEvent(Message.LParam);
  if Assigned(Msg) then  try EventOneMsgPars(Msg); finally  Msg.Free;  end;
end;
Procedure TAmClientScrollBoxMessage.EventOneMsgPars( Msg:AmClientEventOneMsg.TEvent);
begin
    case Msg.Msg of
        AmClientEventOneMsg.MainPhotoClick  :  DoOneMsg_DoMainPhotoClick(Msg.Sender);
        AmClientEventOneMsg.ReadMsg         :  DoOneMsg_DoReadMsg(Msg.Sender);
        AmClientEventOneMsg.ContentMouseDown:  DoOneMsg_DoContentMouseDown(Msg.Sender,Msg.Button,Msg.Shift,Msg.X,Msg.Y);
       AmClientEventOneMsg.VoiceNotPlay     :  DoOneMsg_VoiceNotPlay(Msg.Sender,Msg.FileName,Msg.IsPlay);

    end;
end;
Procedure TAmClientScrollBoxMessage.DoOneMsg_DoMainPhotoClick(Sender:TAmClientOneMessage);
begin
    if Assigned(FOneMsg_MainPhotoClick) then FOneMsg_MainPhotoClick(Sender);
end;
Procedure TAmClientScrollBoxMessage.DoOneMsg_DoReadMsg(Sender:TAmClientOneMessage);
begin
    if Assigned(FOneMsg_ReadMsg) then FOneMsg_ReadMsg(Sender);
end;
Procedure TAmClientScrollBoxMessage.DoOneMsg_DoContentMouseDown(Sender:TAmClientOneMessage;Button: TMouseButton;Shift: TShiftState;X, Y: Integer);
var Las: TAmClientOneMessage;
 ARich:TAmRichEditReplaceLabel.TRichEditHelp;
begin

     {
    if Button=mbRight then
    begin
       if Sender.MsgTextSel<>'' then PopapMenu.Open(Sender,1)
       else PopapMenu.Open(Sender,0);
    end
    else if Button=mbLeft then
    }
  Box.Visible:=false;
  ARich:= Rich.Rich;
  ARich.Visible:=false;
  TRY
    if ARich.Parent <> TWinControl(Sender) then
    begin
      if AmCheckControl(ARich.Parent) then
      begin
         if ARich.Parent is TAmClientOneMessage then
         begin
             Las:=  TAmClientOneMessage(ARich.Parent);
             if AmCheckControl(Las) then
             begin
               Las.RichReplaceLabel:=nil;
             end;
         end;
        ARich.Visible:=FALSE;
        ARich.Parent:= Sender;
        Sender.RichReplaceLabel:= ARich;
        ARich.BoundsRect:= Sender.RectObj.msg.R;

        ARich.Width:=  Sender.Width  - ARich.Left - 10;
        ARich.Left:=ARich.Left-1;
        ARich.Anchors := [akLeft, akTop, akRight];
        Box.Visible:=true;
        ARich.Visible:=true;
        ARich.Text :=Sender.MsgTextFull;

         ARich.Font.Size:= Sender.RectObj.msg.FontSize;
        ARich.Font.Name:= Sender.RectObj.msg.FontName;
        ARich.Font.Color:=Sender.RectObj.msg.FontColor;
      end;



    end;

  FINALLY

    ARich.Visible:=true;
    Box.Visible:=true;
    if Button=mbRight then  PostMessage (ARich.Handle,WM_RBUTTONDOWN,0,0 )
    else if Button=mbLeft then     PostMessage (ARich.Handle,WM_LBUTTONDOWN,0,0 );
  END;





   //
       { FMsgTextMemo:=  TamRichEditLink.create(self);
       FMsgTextMemo.Parent:=self;
       FMsgTextMemo.Top := 21;
       FMsgTextMemo.Left := 55;
       FMsgTextMemo.Width:=  self.Width  - FMsgTextMemo.Left - 70;
       FMsgTextMemo.Anchors := [akLeft, akTop, akRight, akBottom];
       FMsgTextMemo.BevelEdges := [];
       FMsgTextMemo.BevelInner := bvNone;
       FMsgTextMemo.BevelOuter := bvNone;
       FMsgTextMemo.BorderStyle := bsNone;
       FMsgTextMemo.Font.Charset := DEFAULT_CHARSET;
       FMsgTextMemo.Font.Color := clWhite;
       FMsgTextMemo.Font.Size:=10;
       FMsgTextMemo.Font.Name := 'Arial';
       FMsgTextMemo.Font.Style := [];
       FMsgTextMemo.ParentColor := False;
       FMsgTextMemo.ParentFont := False;
       FMsgTextMemo.ColorWaitFor:=   $0049362E;//
       FMsgTextMemo.ReadOnly:=true;
       FMsgTextMemo.EnableCaret:= false;}

end;
Procedure TAmClientScrollBoxMessage.DoOneMsg_VoiceNotPlay(Sender:TAmClientOneMessage;FileName:string;IsPlay:boolean);
begin
    if Assigned(FOneMsg_VoiceNotPlay) then FOneMsg_VoiceNotPlay(Sender,FileName,IsPlay);
end;





            {TAmClientBlockMessages}

constructor TAmClientBlockMessages.Create(AOwner: TComponent);
begin
     inherited create(AOwner);

     Height:=50;
     AutoSize:=false;
     Font.Color:=clwhite;
    // Constraints.MaxWidth:=450;
     Width:=450;
     Font.Size:=14;
    // ParentBackground:=false;
   //  ParentColor:=false;
    // Color:=MAth.randomrange(0,1000000);
     FcounterId:=0;
     ListMsg:= TList<TAmClientOneMessage>.Create;
end;
destructor TAmClientBlockMessages.Destroy ;
begin
    ListMsg.Clear;
    ListMsg.Free;
    inherited;

end;
procedure TAmClientBlockMessages.AlignControls(AControl: TControl; var ARect: TRect);
var X,atop,I,aH:integer;
begin
   inherited AlignControls(AControl,ARect);
exit;
 // showmessage('1');
 //X:= ListMsg.IndexOf(TAmClientOneMessage(AControl) );
// if X>=0 then
 begin



     atop:= 0;
     aH:=   ListMsg[0].Height;
     ListMsg[0].SetBounds(20,atop,Width-40,aH);

     for I := 1 to  ListMsg.Count-1 do
     begin
        inc(atop,aH+5);

        ListMsg[I].SetBounds(20,atop,Width-40,ListMsg[i].Height);
        aH:=   ListMsg[i].Height;
        atop:= ListMsg[i].Top;

     end;




 end;
end;
procedure TAmClientBlockMessages.RemoveMessage(Msg:TAmClientOneMessage);
var Box: TamChatScrollBoxOpt;
i:integer;
begin
   i:=ListMsg.Remove(Msg);
   Msg.Free;
   Msg:=nil;

   if (i>=0) and (Parent is TamChatScrollBoxOpt) then
   begin
     Box:=  TamChatScrollBoxOpt(Parent);
     if AmControlCheckWork(Box) then
     Box.RefreshControl(self);
   end;



end;
procedure TAmClientBlockMessages.AddMessage(Msg:TAmClientOneMessage;Up:boolean);
var aTop:integer;
begin


    Msg.IdPanel:=FcounterId;
    inc(FcounterId);
   // Msg.Align:=alnone;
    Msg.Parent:= self;
    // HelpPanel.InsertControl(P);
    if Up then
    begin
       aTop:= integer.MinValue;
       ListMsg.Insert(0,Msg);
    end
    else
    begin
       aTop:= integer.MaxValue;
       ListMsg.Add(Msg);
    end;
    Msg.Top:= aTop;

   // if self.Parent<>nil then
 //   Msg.SelfResize(nil);


end;


 {
procedure TAmClientOneMessage.SelfResize(Sender: TObject);
//var
  //frm,frmImg: HRGN;
begin
 exit;
  showmessage('Resize');





  if FIfReSizingComponent then exit;
  if Self.Parent=nil then exit;


 FIfReSizingComponent:=true;
 try
  // круглые края

  //у панели
 // frm := CreateRoundRectRgn(0,0,width-1,height-1,10,10);
 // SetWindowRgn(Handle,frm,true);
  //у фото


  if FImagePanel<>nil then
  begin
  frmImg := CreateRoundRectRgn(0,0,FImagePanel.width-1,FImagePanel.height-1,5,5);
  SetWindowRgn(FImagePanel.Handle,frmImg,true);
  end;


   if FImagePanel<>nil then
  FUserNameLabel.Caption:=  amWrapText.SetTextLabelTrim( FUserNameFull ,FUserNameLabel,70);

  //TextSelfResize;
//  TimerSelfResize(sender);
  // if not TimerResize.Enabled then   TimerResize.Enabled:=true;

 finally
   FIfReSizingComponent:=false;
 end;
end; }

(*
procedure TAmClientBlockMessages.HideContent;
var i:integer;
var m:TAmClientOneMessage;
    mh:TAmClientOneMessageHelper;
begin
 if FVisibleContent then
 begin
     FVisibleContent:=false;
     AutoSize:=false;
     Height:=  HelpPanel.Height;
     HelpPanel.Parent:=nil;
     HelpPanel.Visible:=false;
     if ListHelper.Count<>ListMsg.Count then showmessage('HideContent <>>>>>>>>>');
   try
     for I := 0 to ListHelper.Count-1  do
     begin
         mh:= TAmClientOneMessageHelper(ListHelper[i]);


        // ListMsg.Delete(i);

         m:=TAmClientOneMessage(ListMsg[i]);
         if m=nil then continue;
         

        // m.Visible:=false;

        // m.Parent:=nil;
         mh.Text:= m.MsgTextFull;
         m.Free;
         ListMsg[i]:=nil;


    // m.Owner:=nil;
     end;
   except
      showmessage('HideContent');
   end;
         //  if  TAmClientOneMessage(ListMsg[i]).MsgFiles<>nil then
         //  TAmClientOneMessage(ListMsg[i]).MsgFiles.ListImg.ShowImg;
 end;
end;
procedure TAmClientBlockMessages.ShowContent;
var i:integer;
var m:TAmClientOneMessage;
begin
 if not FVisibleContent then
 begin
   try
       for I := 0 to ListHelper.Count-1 do
       begin
       m:=  TAmClientOneMessage.Create(self,'Text');
       ListMsg[i]:= m;
       m.MsgTextFull:= TAmClientOneMessageHelper(ListHelper[i]).Text;
       m.Parent:=HelpPanel;
       m.Visible:=true;
      // logmain.Log('ShowContent');
       end;
   except
      showmessage('ShowContent');
   end;

        {
        if self.Parent<>nil then
        begin
         for I := 0 to ListMsg.Count-1 do
         begin
           if  TAmClientOneMessage(ListMsg[i]).MsgFiles<>nil then
           begin
            // TAmClientOneMessage(ListMsg[i]).MsgFiles.ListImg.ShowImg;

           end;
           m:=TAmClientOneMessage(ListMsg[i]);

           m.Parent:=HelpPanel;
            m.Visible:=true;
            //TAmClientOneMessage(ListMsg[i]).SelfResize(nil);
         end;
        end;
              }
     FVisibleContent:=true;

     HelpPanel.Parent:=self;
     HelpPanel.Visible:=true;
     AutoSize:=true;

     SetCorrectSequenceMessages;


       


 end;
end;
procedure TAmClientBlockMessages.IsNeedShowHideContent(Box_ClientHeight:integer;Pos:integer=0);
var Ots:integer;
begin
//logmain.Log('Box_ClientHeight='+Box_ClientHeight.ToString +' '+Top.ToString);
        Ots:=150;
        if (Top+Height>-Ots +Pos)
        and (Top< Box_ClientHeight+Ots+Pos)

      
        then ShowContent else  HideContent;


end;
Procedure TAmClientBlockMessages.SetCorrectSequenceMessages;
var i:integer;
var Msg:TAmClientOneMessage;
MinTop:Integer;
Exr:boolean;
begin
exit;
   MinTop:=integer.MaxValue;
   for I := 0 to ListMsg.Count-1 do
    begin
     Msg:=TAmClientOneMessage(ListMsg[i]);
     if Msg<>nil then
     if MinTop>Msg.Top then  MinTop:=Msg.Top;
    end;

    I := 0;
    while I<= ListMsg.Count-1 do
    begin

       if Msg=nil then  continue;
       Msg:=TAmClientOneMessage(ListMsg[i]);
       Exr:=false;
       if MinTop<0 then
       Exr:= (not( (Msg.Top < (MinTop+10)) and (Msg.Top > MinTop-10 ))) else
       Exr:= (not( (Msg.Top > MinTop-10 ) and (Msg.Top < MinTop+10  )));




       if Exr then
       begin
       //logmain.Log('<>' +Msg.Top.ToString +' I='+I.ToString +' MinTop='+MinTop.ToString);
       Msg.Top:= MinTop;
       end;

      MinTop:= Msg.Top+Msg.Height;
      if Msg.AlignWithMargins then MinTop:= MinTop+Msg.Margins.Bottom +Msg.Margins.Top ;
       inc(I);
    end;

end;
    *)
end.
