unit AmChatClientPeopleBox;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,mmsystem,AmList,Math,AmControls,ES.BaseControls, ES.Layouts, ES.Images,
  AmChatClientComponets,AmChatCustomSocket,AmGrafic;

  type
     TAmClientOnePeople = class;
     TEventGetHistoryChatPeople = procedure (OneContact:TAmClientOnePeople) of object;

     TAmClientOnePeople = class(TAmClientCustomPanel)
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


        FIsSelectPeople,
        FIsMovePeople:boolean;
        FGetHistoryChat:TEventGetHistoryChatPeople;

        FUserNameFull:string;
        FScreenNameFull:string;


        UserNameLabel:Tlabel;
        ScreenNameLabel:Tlabel;





        Procedure SetUserNameFull(val:string);
        Procedure SetScreenNameFull(val:string);

        Procedure SetIsSelectPeople (val:boolean);
        Procedure SetIsMovePeople (val:boolean);

        procedure SelfResize(Sender: TObject);
        Procedure SelfClick (Sender: TObject);
        procedure SelfMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
        procedure SelfMouseLeave(Sender: TObject);
     private
        property OnGetHistoryChat:TEventGetHistoryChatPeople  read FGetHistoryChat write FGetHistoryChat;
     public


        UserId:string;
        TypeUser:string;




        property UserNameFull:String read FUserNameFull write SetUserNameFull;
        property ScreenNameFull:String read FScreenNameFull write SetScreenNameFull;


        property IsSelectPeople:boolean   read FIsSelectPeople write SetIsSelectPeople;
        property IsMovePeople:boolean   read FIsMovePeople  write SetIsMovePeople;


        constructor Create(AOwner: TComponent); override;
     end;

     {cостоит из TAmClientOneContact}
     TAmClientScrollBoxPeople = class(AmControls.TamScrollBoxSuper)
        private
          FcounterBoxId:integer;
          FActivPeople:TAmClientOnePeople;
          FGetHistoryChat:TEventGetHistoryChatPeople;
          Procedure GetHistoryChat(OneContact:TAmClientOnePeople);
        protected
        public
          ListPeople:Tlist;
          procedure ClearContactsSelect;
          property ActivContact:TAmClientOnePeople read FActivPeople;
          procedure ClearBox;
          procedure AddContact(Contact: TAmClientOnePeople;up:boolean);
          Function SerchId(aId,aTypeUser:string):integer;
          // при новом сообщении помешает контакт на первое место в интерфейсе
          Procedure MoviTopContact(Index:Integer); overload;
          Procedure MoviTopContact(Contact:TAmClientOnePeople); overload;
          Procedure MoviTopContact(aid,aTypeUser:string); overload;
          Function  GetPeople(aid,aTypeUser:string):TAmClientOnePeople; overload;
          Function  GetPeople(Index:Integer):TAmClientOnePeople; overload;

          property OnGetHistoryChat:TEventGetHistoryChatPeople  read FGetHistoryChat write FGetHistoryChat;
          constructor Create(AOwner: TComponent); override;
          destructor  Destroy ; override;
     end;
implementation

Function TAmClientScrollBoxPeople.SerchId(aId,aTypeUser:string):integer;
var i:integer;
N:TAmClientOnePeople;
begin
    Result:=-1;
    if (aId='') or (aTypeUser='') then  exit;

    for I := 0 to ListPeople.Count-1 do
    begin
        N:= TAmClientOnePeople(ListPeople[i]);
        if (N.UserId=aId)and (N.TypeUser=aTypeUser) then
        begin
          Result:=i;
          break;
        end;
    end;
end;
Procedure TAmClientScrollBoxPeople.MoviTopContact(Index:Integer);
var P:TAmClientOnePeople;
begin
 if Index>0 then //т.к 0 это уже сверху
 begin
  P:=TAmClientOnePeople(ListPeople[Index]);
  P.Top := integer.MinValue;
  ListPeople.Move(Index,0);
 end;
end;
Procedure TAmClientScrollBoxPeople.MoviTopContact(Contact:TAmClientOnePeople);
begin
   MoviTopContact(ListPeople.IndexOf(Contact));
end;
Procedure TAmClientScrollBoxPeople.MoviTopContact(aid,aTypeUser:string);
var Index:integer;
begin
    Index:=SerchId(aid,aTypeUser);
    if Index>=0 then MoviTopContact(Index);

end;
Function  TAmClientScrollBoxPeople.GetPeople(aid,aTypeUser:string):TAmClientOnePeople;
var Index:integer;
begin
    Result:=nil;
    Index:=SerchId(aid,aTypeUser);
    if Index>=0 then Result:=GetPeople(Index);

end;
Function  TAmClientScrollBoxPeople.GetPeople(Index:Integer):TAmClientOnePeople;
begin
   Result:=TAmClientOnePeople(ListPeople[Index]);
end;
constructor TAmClientScrollBoxPeople.Create(AOwner: TComponent);
begin

    inherited create(AOwner);
     FcounterBoxId:=0;
     ListPeople:= Tlist.Create;
     FActivPeople:= nil;


   //  self.OnConstrainedResize:=BoxConstrainedResize;
    // self.OnResize:= BoxResize;
     self.Width := 350;
     Align:=alLeft;
    // PopapMenu:=  TAmClientMenuForText.Create(TWinControl(AOwner));

end;
destructor TAmClientScrollBoxPeople.Destroy ;
begin
    ListPeople.Clear;
    inherited;
    ListPeople.Free;
end;
procedure TAmClientScrollBoxPeople.ClearContactsSelect;
var R:boolean;
i:integer;
begin
   R:=false;
   if Assigned(FActivPeople) and FActivPeople.IsSelectPeople then
   begin
       FActivPeople.IsSelectPeople:=false;
       R:=true;

   end;
   FActivPeople:=nil;
   if not R then
   for I := 0 to ListPeople.Count-1 do
   if  TAmClientOnePeople(ListPeople[i]).IsSelectPeople then
   TAmClientOnePeople(ListPeople[i]).IsSelectPeople:=false;
end;
Procedure TAmClientScrollBoxPeople.GetHistoryChat(OneContact:TAmClientOnePeople);
begin

  ClearContactsSelect;
  FActivPeople:= OneContact;
  If Assigned(FGetHistoryChat) then FGetHistoryChat(OneContact);
end;
procedure TAmClientScrollBoxPeople.ClearBox;
begin
      FActivPeople:=nil;
      ListPeople.Clear;
      box.clearBox;

end;
procedure TAmClientScrollBoxPeople.AddContact(Contact: TAmClientOnePeople;up:boolean);
var aTop:integer;
SavePos:integer;
begin
     SavePos:=  self.Box.VertScrollBar.Position;
     Contact.IdPanel:=FcounterBoxId;
     inc(FcounterBoxId);
     Contact.Parent:= Box;
     Contact.OnGetHistoryChat:= GetHistoryChat;

    if Up then
    begin
      aTop:= integer.MinValue;
       Contact.Top:= aTop;
       Box.VertScrollBar.Position:= SavePos+Contact.Height;
       ListPeople.Insert(0,Contact);
    end
    else
    begin
       aTop:= integer.MaxValue;
       Contact.Top:= aTop;
       ListPeople.Add(Contact);
    end;
    PostMessage(Contact.Handle,WM_SIZE,0,0);

end;




                 {TAmClientOnePeople}




constructor TAmClientOnePeople.Create(AOwner: TComponent);
begin
       inherited create(AOwner);

        FUserNameFull:='No Name';


        UserId:='';
        FGetHistoryChat:=nil;
        FIsSelectPeople:=false;
        FIsMovePeople:=false;

        ColorSelected:=  $00795535;
        ColorDefault:=  $00423129;
        ColorMove:=   $00594237;
        ColorClick:=$00785849;


       Align:=AlTop;
      // Top:= word.MaxValue;
       Height := 32;
       ParentBackground:=false;
       ParentColor:=False;
       BevelKind:=bkNone;
       BevelOuter:=bvnone;
       Caption:='';
       Color:=  $00423129;
       OnClick:=SelfClick;
       self.OnMouseMove:=selfMouseMove;
       self.OnMouseLeave:=selfMouseLeave;


       UserNameLabel:=  TLabel.Create(self);
       UserNameLabel.Parent:=  self;
       UserNameLabel.Top := 2;
       UserNameLabel.Left := 15;
       UserNameLabel.Align := alCustom ;
       UserNameLabel.Anchors:= [akTop, akLeft];
       UserNameLabel.Caption := 'No Name';
       UserNameLabel.Font.Charset := DEFAULT_CHARSET;
       UserNameLabel.Font.Color := $00DADADA;
       UserNameLabel.Font.Size:=10;
       UserNameLabel.Font.Name := 'Tahoma';
       UserNameLabel.Font.Style := [];
       UserNameLabel.ParentBiDiMode := False;
       UserNameLabel.ParentColor := False;
       UserNameLabel.ParentFont := False;
       UserNameLabel.OnClick:=SelfClick;
       UserNameLabel.OnMouseMove:=selfMouseMove;
       UserNameLabel.OnMouseLeave:=selfMouseLeave;

       ScreenNameLabel:=  TLabel.Create(self);
       ScreenNameLabel.Parent:=  self;
       ScreenNameLabel.Top := 16;
       ScreenNameLabel.Left := 15;
       ScreenNameLabel.Align := alCustom ;
       ScreenNameLabel.Anchors:= [akTop, akLeft];
       ScreenNameLabel.Caption := '';
       ScreenNameLabel.Font.Charset := DEFAULT_CHARSET;
       ScreenNameLabel.Font.Color := clGray;
       ScreenNameLabel.Font.Size:=8;
       ScreenNameLabel.Font.Name := 'Tahoma';
       ScreenNameLabel.Font.Style := [];
       ScreenNameLabel.ParentBiDiMode := False;
       ScreenNameLabel.ParentColor := False;
       ScreenNameLabel.ParentFont := False;
       ScreenNameLabel.OnClick:=SelfClick;
       ScreenNameLabel.OnMouseMove:=selfMouseMove;
       ScreenNameLabel.OnMouseLeave:=selfMouseLeave;



       OnResize:=SelfResize;
end;




Procedure TAmClientOnePeople.SetUserNameFull(val:string);
begin
    if (FUserNameFull<>val) and (val<>'')  then
    begin
       FUserNameFull:=val;
        if FUserNameFull='' then  FUserNameFull:='No Name';

    end;
end;
Procedure TAmClientOnePeople.SetScreenNameFull(val:string);
begin
    if (FScreenNameFull<>val) and (val<>'')  then
    begin
       FScreenNameFull:=val;

       if TypeUser = ConstAmChat.TypeUser.User then ScreenNameLabel.Caption:=  FScreenNameFull
       else if TypeUser = ConstAmChat.TypeUser.Groop then ScreenNameLabel.Caption:= '≗ '+ FScreenNameFull;
    end;
end;
Procedure TAmClientOnePeople.SetIsSelectPeople (val:boolean);
begin
     if FIsSelectPeople<>val then
     begin
        if val and Assigned(FGetHistoryChat) then FGetHistoryChat(self);

        FIsSelectPeople:=val;

        if FIsSelectPeople then
        begin
         Color:= self.ColorSelected ;

        end
        else if FIsMovePeople then   Color:= self.ColorMove
        else  Color:= self.ColorDefault;
     end
     else
     begin
        Color:=ColorClick;
        delay(100);
        if FIsSelectPeople then  Color:= self.ColorSelected
        else if FIsMovePeople then   Color:= self.ColorMove
        else  Color:= self.ColorDefault;

     end;

end;
Procedure TAmClientOnePeople.SetIsMovePeople (val:boolean);
begin
     if FIsMovePeople<>val then
     begin
        FIsMovePeople:=val;

        if not FIsSelectPeople then
        begin
             if FIsMovePeople then   Color:= self.ColorMove
             else Color:= self.ColorDefault;
        end
     end;
end;

procedure TAmClientOnePeople.SelfResize(Sender: TObject);
begin

  UserNameLabel.Caption:=  amWrapText.SetTextLabelTrim( FUserNameFull ,UserNameLabel,50);

end;
Procedure TAmClientOnePeople.SelfClick (Sender: TObject);
begin

    IsSelectPeople:=true;

end;
procedure TAmClientOnePeople.SelfMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
    IsMovePeople:=true;
end;
procedure TAmClientOnePeople.SelfMouseLeave(Sender: TObject);
begin
   IsMovePeople:=false;
end;


end.
