unit AmChatClientContactBox;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,mmsystem,AmList,Math,AmControls,ES.BaseControls, ES.Layouts, ES.Images,
  AmChatClientComponets,AmChatCustomSocket,AmGrafic;

  type
     TAmClientOneContact = class;
     TEventGetHistoryChat = procedure (OneContact:TAmClientOneContact) of object;
     //Поиск  TAmClientContact по разным входным данным  и обслуживание TScrollBox
     TAmClientContactHelp = class
      private
        FContactBox:TScrollBox;
       public
        SelectedUserId:string; // TAmClientContact.UserId которого просматривается переписка
        Procedure DeleteAllControls;
        Procedure SetIsSelectContactsFalse;
        constructor Create(aContactBox:TScrollBox); reintroduce;
     end;
     TAmClientOneContact = class(TAmClientCustomPanel)
       strict Private

       // procedure SliderMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
      //  Procedure TimerOut(sender:Tobject);
     //   procedure BoxConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);
       // procedure BoxResize(Sender: TObject);
        ColorSelected,
        ColorDefault,
        ColorMove,
        ColorClick
        :Tcolor;


        FIsSelectContact,
        FIsMoveContact:boolean;
        FGetHistoryChat:TEventGetHistoryChat;
        FOnGetOpenPopap:TEventGetHistoryChat;
        FTimeFull:string;
        FUserNameFull:string;

        FIsOnlineType:string;
        FCountNoRead:integer;
        FIsSelectRigthMouseContact:boolean;



        FTypeUser:string;


        Procedure SetTypeUser(val:string);
        Procedure SetTimeFull(val:string);
        Procedure SetUserNameFull(val:string);
        Procedure SetIsOnlineType(val:string);
        Procedure SetCountNoRead  (val:integer);
        Procedure SetIsSelectContact (val:boolean);
        Procedure SetIsMoveContact (val:boolean);





     private
        property OnGetHistoryChat:TEventGetHistoryChat  read FGetHistoryChat write FGetHistoryChat;
        property OnGetOpenPopap:TEventGetHistoryChat  read FOnGetOpenPopap write FOnGetOpenPopap;
     protected
        PanelMain:Tpanel;

        FImagePanel: Tpanel;
        FImagePhoto: TEsImage;

        TimeLabel:Tlabel;
        UserNameLabel:Tlabel;
        OnlineLabel:Tlabel;
        NoReadPanel:Tpanel;

        procedure Resize ;override;
        Procedure SelfClick (Sender: TObject);Virtual;
        procedure SelfMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);Virtual;
        procedure SelfMouseLeave(Sender: TObject);Virtual;
        procedure SelfMouseDown(Sender: TObject;Button:TMouseButton; Shift: TShiftState; X, Y: Integer);Virtual;
        procedure DoOpenPopap;Virtual;
     public

        PhotoId:string;
        //PhotoData:string;
        UserId:string;

        Message_ReadLastLocalIdMy:string;
        Message_ReadLastLocalIdHim:string;
        Message_LastId:string;

        procedure Refresh;
        Function GetPhotoLParam:Cardinal;
        property TypeUser:String read FTypeUser write SetTypeUser;
        property TimeFull:String read FTimeFull write SetTimeFull;
        property UserNameFull:String read FUserNameFull write SetUserNameFull;
        property IsOnlineType:string   read FIsOnlineType write SetIsOnlineType;
        property IsSelectContact:boolean   read FIsSelectContact write SetIsSelectContact;
        property IsMoveContact:boolean   read FIsMoveContact  write SetIsMoveContact;
        property IsSelectRigthMouseContact:boolean read FIsSelectRigthMouseContact  write FIsSelectRigthMouseContact;
        property CountNoRead:integer read FCountNoRead write SetCountNoRead;

        constructor Create(AOwner: TComponent); override;
     end;

     {cостоит из TAmClientOneContact}
     TAmClientScrollBoxContact = class(AmControls.TamScrollBoxSuper)
        private
          FcounterBoxId:integer;
          FActivContact:TAmClientOneContact;
          FActivContactRigthMouse:TAmClientOneContact;
          FGetHistoryChat:TEventGetHistoryChat;
          Procedure GetHistoryChat(OneContact:TAmClientOneContact);
          Procedure GetOpenPopap(OneContact:TAmClientOneContact);
        protected
          Procedure DoGetHistoryChat(OneContact:TAmClientOneContact);virtual;
          Procedure DoOpenPopap(OneContact:TAmClientOneContact);virtual;
          Procedure PopapClickToItem(S:Tobject;NameItem:String);virtual;
        public
          ListContact:Tlist;
          LockEventGetHistoryChat:boolean;
          Popap:TAmClientPopapMenu;
          procedure ClearContactsSelect;
          procedure ClearContactsRigthMouseSelect;
          property ActivContact:TAmClientOneContact read FActivContact;
          property ActivContactRigthMouse:TAmClientOneContact read FActivContactRigthMouse;
          procedure ClearBox;
          procedure AddContact(Contact: TAmClientOneContact;up:boolean);
          procedure DeleteContact(Contact: TAmClientOneContact);
          Function SerchId(aId,aTypeUser:string):integer;
          // при новом сообщении помешает контакт на первое место в интерфейсе
          Procedure MoviTopContact(Index:Integer); overload;
          Procedure MoviTopContact(Contact:TAmClientOneContact); overload;
          Procedure MoviTopContact(aid,aTypeUser:string); overload;
          Function  GetContact(aid,aTypeUser:string):TAmClientOneContact; overload;
          Function  GetContact(Index:Integer):TAmClientOneContact; overload;

          property OnGetHistoryChat:TEventGetHistoryChat  read FGetHistoryChat write FGetHistoryChat;
          constructor Create(AOwner: TComponent); override;
          destructor  Destroy ; override;
     end;
implementation

Function TAmClientScrollBoxContact.SerchId(aId,aTypeUser:string):integer;
var i:integer;
N:TAmClientOneContact;
begin
    Result:=-1;
    if (aId='') or (aTypeUser='') then  exit;
    
    for I := 0 to ListContact.Count-1 do
    begin
        N:= TAmClientOneContact(ListContact[i]);
        if (N.UserId=aId)and (N.TypeUser=aTypeUser) then
        begin
          Result:=i;
          break;
        end;
    end;
end;
Procedure TAmClientScrollBoxContact.MoviTopContact(Index:Integer);
var P:TAmClientOneContact;
begin
 if Index>=0 then
 begin
     P:=TAmClientOneContact(ListContact[Index]);
     if Index>0 then //т.к 0 это уже сверху
     begin

      P.Top := integer.MinValue;
      ListContact.Move(Index,0);

     end;
     self.Box.ScrollInView(P);
 end;


end;
Procedure TAmClientScrollBoxContact.MoviTopContact(Contact:TAmClientOneContact);
begin
   MoviTopContact(ListContact.IndexOf(Contact));
end;
Procedure TAmClientScrollBoxContact.MoviTopContact(aid,aTypeUser:string);
var Index:integer;
begin
    Index:=SerchId(aid,aTypeUser);
    if Index>=0 then MoviTopContact(Index);
    
end;
Function  TAmClientScrollBoxContact.GetContact(aid,aTypeUser:string):TAmClientOneContact;
var Index:integer;
begin
    Result:=nil;
    Index:=SerchId(aid,aTypeUser);
    if Index>=0 then Result:=GetContact(Index);

end;
Function  TAmClientScrollBoxContact.GetContact(Index:Integer):TAmClientOneContact;
begin
   Result:=TAmClientOneContact(ListContact[Index]);
end;
constructor TAmClientScrollBoxContact.Create(AOwner: TComponent);
var Style:TAmClientPopapMenu.TStyle;
var Element:TAmClientPopapMenu.TElement;
begin


    inherited create(AOwner);
     LockEventGetHistoryChat:=false;
     FcounterBoxId:=0;
     ListContact:= Tlist.Create;
     FActivContact:= nil;
     FActivContactRigthMouse:=nil;



   //  self.OnConstrainedResize:=BoxConstrainedResize;
    // self.OnResize:= BoxResize;
     self.Width := 350;
     Align:=alLeft;






   Popap:= TAmClientPopapMenu.Create(TWinControl(AOwner));
   Popap.ListStyle.Clear;
   // для user
   try
    { Element.ItemName:='UserProfile';
     Element.Caption:='Показать профиль';
     Element.W:=150;
     Style.Add(Element); }

     Element.ItemName:='ContactDelete';
     Element.Caption:='Удалить контакт';
     Element.W:=150;
     Style.Add(Element);

    { Element.ItemName:='ContactBlock';
     Element.Caption:='Заблокировать';
     Element.W:=150;
     Style.Add(Element);  }

   finally
     Popap.ListStyle.Add(Style);
   end;
   Popap.OnClickItem:= PopapClickToItem;



end;
destructor TAmClientScrollBoxContact.Destroy ;
begin
    ListContact.Clear;
    inherited;
    ListContact.Free;
end;
Procedure  TAmClientScrollBoxContact.PopapClickToItem(S:Tobject;NameItem:String);
begin
   if NameItem = 'ContactDelete' then showmessage('Удалить');

end;
procedure TAmClientScrollBoxContact.ClearContactsSelect;
var R:boolean;
i:integer;
begin
   R:=false;
   if Assigned(FActivContact) and FActivContact.IsSelectContact then
   begin
       FActivContact.IsSelectContact:=false;
       R:=true;

   end;
   FActivContact:=nil;
   if not R then
   for I := 0 to ListContact.Count-1 do
   if  TAmClientOneContact(ListContact[i]).IsSelectContact then
   TAmClientOneContact(ListContact[i]).IsSelectContact:=false;   
end;
Procedure TAmClientScrollBoxContact.GetHistoryChat(OneContact:TAmClientOneContact);
begin

  ClearContactsSelect;
  FActivContact:= OneContact;
  DoGetHistoryChat(OneContact);
end;
Procedure TAmClientScrollBoxContact.DoGetHistoryChat(OneContact:TAmClientOneContact);
begin
   If not LockEventGetHistoryChat and Assigned(FGetHistoryChat) then FGetHistoryChat(OneContact);
end;
procedure TAmClientScrollBoxContact.ClearContactsRigthMouseSelect;
var R:boolean;
i:integer;
begin
   R:=false;
   if Assigned(FActivContactRigthMouse) and FActivContactRigthMouse.IsSelectRigthMouseContact then
   begin
       FActivContactRigthMouse.IsSelectRigthMouseContact:=false;
       R:=true;

   end;
   FActivContactRigthMouse:=nil;
   if not R then
   for I := 0 to ListContact.Count-1 do
   if  TAmClientOneContact(ListContact[i]).IsSelectRigthMouseContact then
   TAmClientOneContact(ListContact[i]).IsSelectRigthMouseContact:=false;

end;
Procedure TAmClientScrollBoxContact.GetOpenPopap(OneContact:TAmClientOneContact);
begin
   ClearContactsRigthMouseSelect;
   FActivContactRigthMouse:= OneContact;
   DoOpenPopap(OneContact);

end;
Procedure TAmClientScrollBoxContact.DoOpenPopap(OneContact:TAmClientOneContact);
begin
     OneContact.IsSelectRigthMouseContact:=true;
     Popap.Open(OneContact,0);
  //   showmessage('Popap '+FActivContactRigthMouse.UserId+' '+FActivContactRigthMouse.TypeUser);
end;
procedure TAmClientScrollBoxContact.ClearBox;
begin
      FActivContact:=nil;
      FActivContactRigthMouse:=nil;
      ListContact.Clear;
      box.clearBox;

end;
procedure TAmClientScrollBoxContact.AddContact(Contact: TAmClientOneContact;up:boolean);
var aTop:integer;
SavePos:integer;
begin
     SavePos:=  self.Box.VertScrollBar.Position;
     Contact.IdPanel:=FcounterBoxId;
     inc(FcounterBoxId);
     Contact.Parent:= Box;
     Contact.OnGetHistoryChat:= GetHistoryChat;
     Contact.OnGetOpenPopap:=GetOpenPopap;
    if Up then
    begin
      aTop:= integer.MinValue;
       Contact.Top:= aTop;
       Box.VertScrollBar.Position:= SavePos+Contact.Height;
       ListContact.Insert(0,Contact);
    end
    else
    begin
       aTop:= integer.MaxValue;
       Contact.Top:= aTop;
       ListContact.Add(Contact);
    end;
    if self.CanFocus then
    PostMessage(Contact.Handle,WM_SIZE,0,0);

end;
procedure TAmClientScrollBoxContact.DeleteContact(Contact: TAmClientOneContact);
begin
  if AmCheckControl(Contact) then
  begin
     if Contact.IsSelectContact then self.ClearContactsSelect;
     if Contact.IsSelectRigthMouseContact then self.ClearContactsRigthMouseSelect;

     ListContact.Remove(Contact);
     Contact.Free;
     Contact:=nil;
     if Self.CanFocus then
     PostMessage(Handle,WM_SIZE,0,0);
  end;
end;




                 {TAmClientOneContact}


constructor TAmClientContactHelp.Create(aContactBox:TScrollBox);
begin
     inherited create();
     FContactBox:= aContactBox;

end;
Procedure TAmClientContactHelp.DeleteAllControls;
var i:integer;
begin
   for I := FContactBox.ControlCount-1 downto 0 do
   FContactBox.Controls[i].Free;

end;

Procedure TAmClientContactHelp.SetIsSelectContactsFalse;
var i:integer;
begin
   for I := FContactBox.ControlCount-1 downto 0 do
   if FContactBox.Controls[i] is TAmClientOneContact then
   if (FContactBox.Controls[i] as  TAmClientOneContact).IsSelectContact then
   (FContactBox.Controls[i] as  TAmClientOneContact).IsSelectContact:=false;

end;

constructor TAmClientOneContact.Create(AOwner: TComponent);
begin
       inherited create(AOwner);

        FTimeFull:='';
        FUserNameFull:='No Name';
        FIsOnlineType:=ConstAmChat.TypeOnline.Offline;
        FCountNoRead:=0;
        PhotoId:='';
        //PhotoData:='';
        UserId:='';
        FGetHistoryChat:=nil;
        FIsSelectContact:=false;
        FIsMoveContact:=false;
        FIsSelectRigthMouseContact:=false;

        ColorSelected:=  $00795535;
        ColorDefault:=  $00423129;
        ColorMove:=   $00594237;
        ColorClick:=$00785849;


       Align:=AlTop;
      // Top:= word.MaxValue;
       Height := 40;
       ParentBackground:=false;
       ParentColor:=true;
       BevelKind:=bkNone;
       BevelOuter:=bvnone;
       Caption:='';
       OnClick:=SelfClick;
       self.OnMouseMove:=selfMouseMove;
       self.OnMouseLeave:=selfMouseLeave;
       self.OnMouseDown:=SelfMouseDown;

       PanelMain:= Tpanel.Create(self);
       PanelMain.parent:=self;
       PanelMain.Align:=AlClient;
       PanelMain.ParentBackground:=false;
       PanelMain.ParentColor:=false;
       PanelMain.BevelKind:=bkNone;
       PanelMain.BevelOuter:=bvnone;
       PanelMain.Caption:='';
       PanelMain.Color := ColorDefault;
       PanelMain.OnClick:=SelfClick;
       PanelMain.OnMouseMove:=selfMouseMove;
       PanelMain.OnMouseLeave:=selfMouseLeave;
       PanelMain.OnMouseDown:=SelfMouseDown;

       FImagePanel:=Tpanel.Create(self);
       FImagePanel.Parent:= PanelMain;
       FImagePanel.Left := 6;
       FImagePanel.Width := 34;
       FImagePanel.Height := 32;
       FImagePanel.Top := 4;
       FImagePanel.BevelEdges := [] ;
       FImagePanel.BevelOuter := bvNone;
       FImagePanel.ParentBackground := False ;
       FImagePanel.ParentFont := False ;
       FImagePanel.Color := $00D7F0BF  ;

       FImagePhoto := TEsImage.Create(self);
       FImagePhoto.Parent:= FImagePanel;
       FImagePhoto.Align:=alclient;
       FImagePhoto.Transparent:=true;
       FImagePhoto.Smoth:=false;
       FImagePhoto.Opacity:=255;
       FImagePhoto.Stretch := TImageStretch.FiLL;
     //  FImagePhoto.Picture.LoadFromFile('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\set\chat\client\photos\Photo1_7.jpg');
       FImagePhoto.OnClick:=SelfClick;


       FImagePhoto.OnMouseMove:=selfMouseMove;
       FImagePhoto.OnMouseLeave:=selfMouseLeave;
       FImagePhoto.OnMouseDown:=SelfMouseDown;
        {
       PhotoImage := Timage.Create(PanelMain);
       PhotoImage.Parent:= PanelMain;
       PhotoImage.Left := 6;
       PhotoImage.Top := 5;
       PhotoImage.Width := 34;
       PhotoImage.Height := 32;
       PhotoImage.Stretch := True;
       PhotoImage.Picture.LoadFromFile('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\set\chat\client\photos\Photo1_7.jpg');
       PhotoImage.OnClick:=SelfClick;
       PhotoImage.OnMouseMove:=selfMouseMove;
       PhotoImage.OnMouseLeave:=selfMouseLeave;
         }

       TimeLabel:=  TLabel.Create(PanelMain);
       TimeLabel.Parent:=  PanelMain;
       TimeLabel.Top := 3;
       TimeLabel.Alignment:=taRightJustify;
      // TimeLabel.Left := PanelMain.Width-40;
       TimeLabel.AlignWithMargins:=true;
       TimeLabel.Margins.Top:=3;
       TimeLabel.Margins.Right:=9;
       TimeLabel.Align := alRight ;
       TimeLabel.Anchors:= [akTop, akRight];
       TimeLabel.Caption := '19:24';
       TimeLabel.Font.Charset := DEFAULT_CHARSET;
       TimeLabel.Font.Color := clSilver;
       TimeLabel.Font.Size:=8;
       TimeLabel.Font.Name := 'Tahoma';
       TimeLabel.Font.Style := [];
       TimeLabel.ParentBiDiMode := False;
       TimeLabel.ParentColor := False;
       TimeLabel.ParentFont := False;
       TimeLabel.OnClick:=SelfClick;
       TimeLabel.OnMouseMove:=selfMouseMove;
       TimeLabel.OnMouseLeave:=selfMouseLeave;
       TimeLabel.OnMouseDown:=SelfMouseDown;


       UserNameLabel:=  TLabel.Create(PanelMain);
       UserNameLabel.Parent:=  PanelMain;
       UserNameLabel.Top := 3;
       UserNameLabel.Left := 46;
       UserNameLabel.Align := alCustom ;
       UserNameLabel.Anchors:= [akTop, akLeft];
       UserNameLabel.Caption := 'No Name';
       UserNameLabel.Font.Charset := DEFAULT_CHARSET;
       UserNameLabel.Font.Color := clWhite;
       UserNameLabel.Font.Size:=10;
       UserNameLabel.Font.Name := 'Tahoma';
       UserNameLabel.Font.Style := [];
       UserNameLabel.ParentBiDiMode := False;
       UserNameLabel.ParentColor := False;
       UserNameLabel.ParentFont := False;
       UserNameLabel.OnClick:=SelfClick;
       UserNameLabel.OnMouseMove:=selfMouseMove;
       UserNameLabel.OnMouseLeave:=selfMouseLeave;
       UserNameLabel.OnMouseDown:=SelfMouseDown;


       OnlineLabel:=  TLabel.Create(PanelMain);
       OnlineLabel.Parent:=  PanelMain;
       OnlineLabel.Top := 20;
       OnlineLabel.Left := 42;
       OnlineLabel.Caption := '◆';
       //OnlineLabel.Font.Charset := SYMBOL_CHARSET;
       OnlineLabel.Font.Color := clSilver;
       OnlineLabel.Font.Size := 12 ;
       OnlineLabel.Font.Name := 'Verdana';
       OnlineLabel.Font.Style := [];
       OnlineLabel.ParentFont := False;
       OnlineLabel.OnClick:=SelfClick;
       OnlineLabel.OnMouseMove:=selfMouseMove;
       OnlineLabel.OnMouseLeave:=selfMouseLeave;
       OnlineLabel.OnMouseDown:=SelfMouseDown;


       NoReadPanel:= Tpanel.Create(self);
       NoReadPanel.parent:=PanelMain;
       NoReadPanel.Top := 20;
       NoReadPanel.Left := PanelMain.Width-40;
       NoReadPanel.Align := alNone ;
       NoReadPanel.Anchors:= [akTop, akRight];
       NoReadPanel.Width := 30;
       NoReadPanel.Height := 15;
       NoReadPanel.ParentBackground:=false;
       NoReadPanel.ParentColor:=false;
       NoReadPanel.BevelKind:=bkNone;
       NoReadPanel.BevelOuter:=bvnone;
       NoReadPanel.Caption:='0';
       NoReadPanel.Color := $00FF9933;
       NoReadPanel.Font.Size:=8;
       NoReadPanel.Font.Style := [fsBold];
       NoReadPanel.Font.Color:=  clWhite;
       NoReadPanel.Visible:=false;
       NoReadPanel.OnClick:=SelfClick;
       NoReadPanel.OnMouseMove:=selfMouseMove;
       NoReadPanel.OnMouseLeave:=selfMouseLeave;
       NoReadPanel.OnMouseDown:=SelfMouseDown;



end;
procedure TAmClientOneContact.Refresh;
begin
  if (Visible or (csDesigning in ComponentState) and
    not (csNoDesignVisible in ControlStyle)) and (Parent <> nil) and
    Parent.HandleAllocated and CanFocus then
    PostMessage(self.Handle,wm_size,0,0);
    inherited Refresh;

end;
Procedure TAmClientOneContact.SetCountNoRead  (val:integer);
begin
     if FCountNoRead<>val then
     begin
        FCountNoRead:=val;
        if FCountNoRead>0 then
        begin
           NoReadPanel.Caption:=AmStr(FCountNoRead);
           NoReadPanel.Visible:=true;
        end
        else
        begin
           NoReadPanel.Caption:=AmStr(FCountNoRead);
           NoReadPanel.Visible:=false;
        end;

     end;

end;
Procedure TAmClientOneContact.SetIsOnlineType(val:string);
begin
    ConstAmChat.TypeOnline.Check(val);


    if (FIsOnlineType<>val) then
    begin
       FIsOnlineType:=val;
       if FIsOnlineType = ConstAmChat.TypeOnline.Online  then
       OnlineLabel.Font.Color:= $00C8DD7D // зеленый
       else if FIsOnlineType = ConstAmChat.TypeOnline.Nearby  then
       OnlineLabel.Font.Color:= $0079DBD9 // желтый
       else if FIsOnlineType = ConstAmChat.TypeOnline.Offline then
       OnlineLabel.Font.Color:=   $008C8A66     // темно серый
       else OnlineLabel.Font.Color:=  clSilver //  серый
    end;
end;
Function TAmClientOneContact.GetPhotoLParam:Cardinal;
begin
    Result:=LPARAM(FImagePhoto);
end;

Procedure TAmClientOneContact.SetTypeUser(val:string);
begin
   if ConstAmChat.TypeUser.Check(val) then
   begin
     FTypeUser:=val;
   end
   else
   begin
     FTypeUser:= ConstAmChat.TypeUser.User;
   end;

   if FTypeUser = ConstAmChat.TypeUser.User then OnlineLabel.Caption := '◆'
   else if FTypeUser = ConstAmChat.TypeUser.Groop then OnlineLabel.Caption := '◆≗'
        


end;
Procedure TAmClientOneContact.SetTimeFull(val:string);
begin
    if (FTimeFull<>val) and (val<>'')  then
    begin
       FTimeFull:=val;
       TimeLabel.Caption:= amWrapText.SetTexDateAndTime( MyStrToDateTime(FTimeFull));
    end;

end;
Procedure TAmClientOneContact.SetUserNameFull(val:string);
begin
    if (FUserNameFull<>val) and (val<>'')  then
    begin
       FUserNameFull:=val;
        if FUserNameFull='' then  FUserNameFull:='No Name';

    end;
end;
Procedure TAmClientOneContact.SetIsSelectContact (val:boolean);
begin
     if FIsSelectContact<>val then
     begin
        if val  and Assigned(FGetHistoryChat) then FGetHistoryChat(self);
        
        FIsSelectContact:=val;

        if FIsSelectContact then
        begin
         PanelMain.Color:= self.ColorSelected ;

        end
        else if FIsMoveContact then   PanelMain.Color:= self.ColorMove
        else  PanelMain.Color:= self.ColorDefault;
     end
     else
     begin
        PanelMain.Color:=ColorClick;
        delay(100);
        if FIsSelectContact then  PanelMain.Color:= self.ColorSelected
        else if FIsMoveContact then   PanelMain.Color:= self.ColorMove
        else  PanelMain.Color:= self.ColorDefault;

     end;

end;
Procedure TAmClientOneContact.SetIsMoveContact (val:boolean);
begin
     if FIsMoveContact<>val then
     begin
        FIsMoveContact:=val;

        if not FIsSelectContact then
        begin
             if FIsMoveContact then   PanelMain.Color:= self.ColorMove
             else PanelMain.Color:= self.ColorDefault;
        end
     end;
end;


procedure TAmClientOneContact.Resize ;
var
  frm,frmImg: HRGN;
begin
  // круглые края
   inherited Resize;
  //у фото
  frmImg := CreateRoundRectRgn(0,0,FImagePanel.width-1,FImagePanel.height-1,5,5);
  SetWindowRgn(FImagePanel.Handle,frmImg,true);
  UserNameLabel.Caption:=  amWrapText.SetTextLabelTrim( FUserNameFull ,UserNameLabel,50);

end;
Procedure TAmClientOneContact.SelfClick (Sender: TObject);
begin

    IsSelectContact:=true;

end;
procedure TAmClientOneContact.SelfMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
    IsMoveContact:=true;
end;
procedure TAmClientOneContact.SelfMouseLeave(Sender: TObject);
begin
   IsMoveContact:=false;
end;
procedure TAmClientOneContact.SelfMouseDown(Sender: TObject;Button:TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = TMouseButton.mbRight then
   DoOpenPopap;
   
end;
procedure TAmClientOneContact.DoOpenPopap;
begin
   IsSelectRigthMouseContact:=true;
   if Assigned(FOnGetOpenPopap) then FOnGetOpenPopap(self);
   
end;


end.
