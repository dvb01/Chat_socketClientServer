unit AmChatClientParticipantBox;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,mmsystem,AmList,Math,AmControls,ES.BaseControls, ES.Layouts, ES.Images,
  AmChatClientComponets,AmChatCustomSocket,AmGrafic,AmChatClientContactBox;

  type

     TAmClientOneParticipant = class(TAmClientOneContact)
     strict Private
     private

     protected

     public
        LabelResponse:  TLabel;
        TypePanelFree:string ;
        constructor Create(AOwner: TComponent); override;
     end;

     {cостоит из TAmClientOneParticipant}
     TAmClientScrollBoxParticipants = class(TAmClientScrollBoxContact)
        private
          Function GetActivContact:TAmClientOneParticipant;
          Function GetActivContactRigthMouse:TAmClientOneParticipant;
          Procedure OpenPopap(OneContact:TAmClientOneParticipant);
        protected
          Procedure DoOpenPopap(OneContact:TAmClientOneContact); override;
          Procedure DoGetHistoryChat(OneContact:TAmClientOneContact);override;
          Procedure PopapClickToItem(S:Tobject;NameItem:String);override;
        public
          property ActivContactRigthMouse:TAmClientOneParticipant read GetActivContactRigthMouse;
          property ActivContact:TAmClientOneParticipant read GetActivContact;
          procedure AddContact(Contact: TAmClientOneParticipant;up:boolean);
          Function  GetContact(aid,aTypeUser:string):TAmClientOneParticipant;
          constructor Create(AOwner: TComponent); override;
          destructor  Destroy ; override;
     end;

  type

     TAmClientGroopEdit = class(TEsLayout)
     strict Private
     private

     protected

     public
        LabelResponse:  TLabel;

       // constructor Create(AOwner: TComponent); override;
     end;




implementation


constructor TAmClientOneParticipant.Create(AOwner: TComponent);
begin
    inherited create(AOwner);
    TimeLabel.Visible:=false;
    NoReadPanel.Visible:=false;

       LabelResponse:=  TLabel.Create(PanelMain);
       LabelResponse.Parent:=  PanelMain;
       LabelResponse.Top := 20;
       LabelResponse.Left := 55;
       LabelResponse.Caption := '';
       //OnlineLabel.Font.Charset := SYMBOL_CHARSET;
       LabelResponse.Font.Color := clSilver;
       LabelResponse.Font.Size := 8 ;
       LabelResponse.Font.Name := 'Verdana';
       LabelResponse.Font.Style := [];
       LabelResponse.ParentFont := False;
       LabelResponse.OnClick:=SelfClick;
       LabelResponse.OnMouseMove:=selfMouseMove;
       LabelResponse.OnMouseLeave:=selfMouseLeave;
       LabelResponse.OnMouseDown:=SelfMouseDown;
end;





constructor TAmClientScrollBoxParticipants.Create(AOwner: TComponent);
var Style:TAmClientPopapMenu.TStyle;
var Element:TAmClientPopapMenu.TElement;
begin
    inherited create(AOwner);

    Popap.ListStyle.Clear;
   // для user
   try
     Element.ItemName:='MessageHistory';
     Element.Caption:='Написать сообщение';
     Element.W:=200;
     Style.Add(Element);

     Element.ItemName:='GroopUserDelete';
     Element.Caption:='Удалить с группы';
     Element.W:=150;
     Style.Add(Element);
                         {
     Element.ItemName:='GroopUserBlock';
     Element.Caption:='Заблокировать';
     Element.W:=150;
     Style.Add(Element);}

   finally
     Popap.ListStyle.Add(Style);
   end;

   try
     Style.Clear;
     Element.ItemName:='MessageHistory';
     Element.Caption:='Написать сообщение';
     Element.W:=200;
     Style.Add(Element);

     Element.ItemName:='GroopUserAdd';
     Element.Caption:='Добавить в группу';
     Element.W:=150;
     Style.Add(Element);
                         {
     Element.ItemName:='GroopUserBlock';
     Element.Caption:='Заблокировать';
     Element.W:=150;
     Style.Add(Element);}

   finally
     Popap.ListStyle.Add(Style);
   end;

end;
destructor  TAmClientScrollBoxParticipants.Destroy ;
begin
   inherited;
end;
Function TAmClientScrollBoxParticipants.GetActivContact:TAmClientOneParticipant;
begin
   Result:= inherited ActivContact as TAmClientOneParticipant
end;
Function TAmClientScrollBoxParticipants.GetActivContactRigthMouse:TAmClientOneParticipant;
begin
   Result:= inherited ActivContactRigthMouse as TAmClientOneParticipant
end;
procedure TAmClientScrollBoxParticipants.AddContact(Contact: TAmClientOneParticipant;up:boolean);
begin
   inherited AddContact(Contact,up);
end;
Function  TAmClientScrollBoxParticipants.GetContact(aid,aTypeUser:string):TAmClientOneParticipant;
begin
   Result:= inherited  GetContact(aid,aTypeUser)as TAmClientOneParticipant;
end;
Procedure TAmClientScrollBoxParticipants.DoOpenPopap(OneContact:TAmClientOneContact);
begin
   self.ClearContactsSelect;
   OneContact.IsSelectContact:=true;

end;
Procedure TAmClientScrollBoxParticipants.DoGetHistoryChat(OneContact:TAmClientOneContact);
begin
  OneContact.IsSelectRigthMouseContact:=true;
  OpenPopap(OneContact as TAmClientOneParticipant);
end;
Procedure TAmClientScrollBoxParticipants.OpenPopap(OneContact:TAmClientOneParticipant);
var Index:integer;
begin
     Index:=-1;
    if OneContact.TypePanelFree = ConstAmChat.TypePanelFree.GroopList then Index:= 0
    else if OneContact.TypePanelFree = ConstAmChat.TypePanelFree.GroopUserAdd then Index:= 1;

    
    if Index>=0 then    
    self.Popap.Open(OneContact,Index);
end;
Procedure TAmClientScrollBoxParticipants.PopapClickToItem(S:Tobject;NameItem:String);
var OneContact:TAmClientOneParticipant;
begin
   if NameItem='GroopUserAdd' then  showmessage('Add');

end;


end.
