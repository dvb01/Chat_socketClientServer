unit AmChatClientComponets;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,mmsystem,AmList,Math,AmControls,ES.BaseControls, ES.Layouts, ES.Images,
  ShellApi, System.Zip,RxCtrls,AMGrafic,
  System.Generics.Collections,
  AmChatCustomSocket;

 type    {вспывающее окно на форме}
     TChatClientPopapWindow = class (Tpanel)
     strict Private
         LabelConnect:Tlabel;
         LabelClose:Tlabel;
         FForm:TForm;
         Ftimer:TTimer;
         FMessageText:string;
         FMiniText:string;
         Procedure TimerOut(sender:Tobject);
         Procedure LabelCloseClick(sender:Tobject);
     public
       SecondTimer:Integer;
       isError:boolean;
       property MessageText :string write FMessageText;
       property MiniText :string write FMiniText;
       procedure Open;
       procedure Close;
      constructor Create(Form: Tform); reintroduce;
      destructor Destroy; override;
     end;








 //type
     {Когда фоток еше нет нужно дождатся пока они появятся на диске а потом их загрузить в список Image
      перед тем как   Start нужно подготовить public переменные TChatClientTimerPhoto.free автоматическое
     }
   {  TChatClientTimerPhoto = class (TTimer)
        type TOnNeedDowloadImg = procedure (PhotoId,PhotoData:string;var ResultSend:boolean) of object;
        type TItem = Record
        Private
           IsEvent:integer;
        public
           PhotoData:string;
           PhotoId:string;
           FullFileName:string;
           ListImage:TamListVar<Cardinal>;  //ccылки на Timage в которую загрузить эту фото add как LPARAM(Image1) = type  Cardinal
           Procedure Clear;
        End;
        type TListItem =  TamListVar<TItem>;

      strict Private

       Fcount:integer;
       FOnNeedDowloadImg:TOnNeedDowloadImg;
       procedure TimerOut(Sender:Tobject);
       function CheckAll:boolean;
       function CheckOne(var Item:TChatClientTimerPhoto.TItem):boolean;
       Procedure Clear;
       Procedure Stop;
      public
       CounterMax:Integer;//Сколько ждать в секундах 30
       ObjectPhotos:TjsonObject;  //ObjUser['Data']['Photos'][FRM.PhotoId]:= FRM.PhotoData;
       List:TListItem;
       Procedure Start;
       property  OnNeedDowloadImg: TOnNeedDowloadImg  read FOnNeedDowloadImg write FOnNeedDowloadImg;
       constructor Create(Form: Tform); reintroduce;
       destructor Destroy; override;
     end;  }






    //////////////////////////////
  type
     TAmClientCustomPanel = class(TEsLayout)
       public
       IdPanel:integer;
       MyName:String;
      published
       property Canvas;
     end;

  type
   {попап меню разукращенный под чат}
    TAmClientPopapMenu =  class (TAmPopopMenuPanel)
      public
        ControlSave:Tobject;
        function    CreateItem: TAmPopopMenuPanelCustom.TItem; Override;
        Procedure   Open(aControl:Tobject;IndexStyle:integer);
        Procedure   Close; override;
        constructor Create(aParent: TWincontrol); reintroduce;
    end;



   type
    TAmClientListBoxFilesCustom = class (TamCustomListBox<string>)
      private
       FIsDestroy:boolean;
       FOnClearListBox:TNotifyEvent;
       FListGraf:Tlist<TGraphic>;
         procedure GradDel(Graf:TGraphic);
      protected
       // procedure Click;  override;

         procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
         procedure DrawItem(Index: Integer; Rect: TRect;State: TOwnerDrawState); override;
      public
       Popap:TAmClientPopapMenu;
       Procedure Clear; override;
       Procedure AddFile(FullFileName:string);
       Procedure DeleteFile(index:integer);
       procedure  RunPapkaSelectFile(FileName:string);
       procedure  RunFile(FileName:string);
       property  OnClearListBox : TNotifyEvent read FOnClearListBox write FOnClearListBox;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
    end;

  Type
  TChatPanelLoadMessage =  Class(TEsLayout)
     type
       Tsave= record
          Size:TSize;

       end;
   private
   var
    isResize:boolean;
    FTransp :integer;


    LabProcent:Tlabel;
    LabSize:Tlabel;
    procedure Trs(Awin:TWinControl;Tr:integer);
    procedure WMsize(var Msg:TWMSIZE);message WM_SIZE;
    var
    FProcentLoad:integer;
    FProcentLoadVisible:boolean;
    SaveProcent:Tsave;

    FSizeLoad:string;
    FSizeLoadVisible:boolean;
    SaveSize:Tsave;


    procedure SetProcentLoad(val:integer);
    procedure ProcentLoadResize(All:boolean);
    procedure SetProcentLoadVisible(val:boolean);

    procedure SetSizeLoad(val:string);
    procedure SizeLoadResize(All:boolean);
    procedure SetSizeLoadVisible(val:boolean);



   protected
     procedure  CreateWnd; Override;
     procedure  Resize;Override;

   public
     Property ProcentLoad:integer read FProcentLoad write SetProcentLoad;
     Property ProcentLoadVisible:boolean read FProcentLoadVisible write SetProcentLoadVisible;

     Property SizeLoad:string read FSizeLoad write SetSizeLoad;
     Property SizeLoadVisible:boolean  read FSizeLoadVisible write SetSizeLoadVisible;
     constructor Create(AOwner:TComponent);Override;
     destructor  Destroy; Override;

  End;

  type
    TAmClientMenuForDialogShare =  class (TAmClientPopapMenu)


      strict private
         Procedure  ClickToItem(S:Tobject;NameItem:String);
      public
        constructor Create(aParent: TWincontrol); reintroduce;
    end;

  type

    TAmPanelAutoVisible =  Class(TEsLayout)
     private
        FNameControlCall,FNameControlActiv:string;
        FWinControl:TWinControl;
        FOnClose:TNotifyEvent;
        procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
        procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
     protected
        procedure Resize; Override;
     public


        procedure Open(ANameControl:string;WinControl:TWinControl);
        procedure Close;
        property InNameControlCall : string Read FNameControlCall;
        property InNameControlActiv : string Read FNameControlActiv;
        property InWinControl : TWinControl Read FWinControl;
        property OnClose : TNotifyEvent Read FOnClose write FOnClose;
        constructor Create(aParent:TWincontrol);reintroduce;
        destructor  Destroy; Override;
    End;

implementation

constructor TAmPanelAutoVisible.Create(aParent:TWincontrol);
begin

    inherited create(aParent);
    FNameControlCall:='';
    FNameControlActiv:='';
    FWinControl:=nil;
    ParentBackground := False;
    self.ParentColor:=false;
    self.BevelKind:=TBevelKind.bkNone;
    self.BevelOuter:=bvNone;
    Parent:=aParent;
    self.Visible:=false;
    self.Padding.Left:=5;
    self.Padding.Top:=5;
    self.Padding.Right:=5;
    self.Padding.Bottom:=5;
end;
destructor  TAmPanelAutoVisible.Destroy;
begin
    inherited;
end;
procedure TAmPanelAutoVisible.Open(ANameControl:string;WinControl:TWinControl);
begin
   FWinControl:=WinControl;

   if Assigned(FWinControl) then
   begin
      FWinControl.Align:=alclient;
      FWinControl.Parent:=self;
      FNameControlActiv:= ANameControl;
   end;
   FNameControlCall:=ANameControl;
   Visible:=true;
   Resize;
end;
procedure TAmPanelAutoVisible.Close;
begin
    Visible:=false;
    if Assigned(FOnClose) then FOnClose(self);
    if Assigned(FWinControl) then
    FWinControl.Parent:=nil;
    FNameControlCall:='';
    FNameControlActiv:='';
end;
procedure TAmPanelAutoVisible.CMMouseEnter(var Message: TMessage);
begin
    inherited;
end;
procedure TAmPanelAutoVisible.CMMouseLeave(var Message: TMessage);
begin
    inherited;
    if not MouseInControl(self) then Close;

end;
procedure TAmPanelAutoVisible.Resize;
var w,h,l,t:integer;
begin
   inherited;
   if not  CanFocus then exit;
   h:= Parent.Height;
   t:= 0;
   if Parent.Width<250 then
   begin
     w:= 250;
     l:=0;
   end
   else
   begin
      w:=  Parent.Width div 3;
      if w<250 then
      begin
        w:=250;
        l:= Parent.Width div 2 -125;
      end
      else l:= Parent.Width div 3;
   end;

   self.SetBounds(l,t,w,h);




end;

constructor TAmClientMenuForDialogShare.Create(aParent: TWincontrol);
var Style:TAmClientMenuForDialogShare.TStyle;
var Element:TAmClientMenuForDialogShare.TElement;
begin
   inherited create(aParent);
   ControlSave:=nil;
   Color:=$00453830;

   self.Constraints.MinHeight:=20;
   self.Constraints.MaxHeight:=300;

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
     ListStyle.Add(Style);
   end;

   // для groop
   try
    Style.Clear;
     {Element.ItemName:='GroopProfile';
     Element.Caption:='Показать профиль';
     Element.W:=150;
     Style.Add(Element);



     Element.ItemName:='ContactBlock';
     Element.Caption:='Заблокировать';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Noti';
     Element.Caption:='Вкл/Выкл. уведомления';
     Element.W:=150;
     Style.Add(Element);}

     Element.ItemName:='ContactDelete';
     Element.Caption:='Удалить контакт';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:=ConstAmChat.TypePanelFree.GroopList;
     Element.Caption:='Список участников';
     Element.W:=150;
     Style.Add(Element);

                         {
     Element.ItemName:='GroopOut';
     Element.Caption:='Покинуть группу';
     Element.W:=150;
     Style.Add(Element);}

     Element.ItemName:=ConstAmChat.TypePanelFree.GroopUserAdd;
     Element.Caption:='Добавить пользователя';
     Element.W:=200;
     Style.Add(Element);

     Element.ItemName:='GroopEdit';
     Element.Caption:='Редактировать';
     Element.W:=150;
     Style.Add(Element);
   finally
     ListStyle.Add(Style);
   end;
   Self.OnClickItem:=  ClickToItem;



end;
Procedure  TAmClientMenuForDialogShare.ClickToItem(S:Tobject;NameItem:String);
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





                   {TChatPanelLoadMessage}
constructor TChatPanelLoadMessage.Create(AOwner:TComponent);
begin
    inherited Create(AOwner);
    isResize:=false;
    FTransp:= 200;
    self.Left:=0;
    self.Top:=0;
    Color := clWhite;
    ParentBackground := False;
    self.ParentColor:=false;
    self.BevelKind:=TBevelKind.bkNone;
    self.BevelOuter:=bvNone;
    self.Color := 5387826;


    LabProcent:= Tlabel.Create(self);
    LabProcent.Parent:=  self;
    LabProcent.Left:=10;
    LabProcent.Anchors:=[akleft];
    LabProcent.Caption:='0%';
    LabProcent.Font.Size:=20;
    LabProcent.Font.Color:=clwhite;
    SaveProcent.Size.cx:=0;
    SaveProcent.Size.cy:=0;
    FProcentLoad:=0;
    FProcentLoadVisible:=true;
    LabProcent.Visible:=true;

    FSizeLoad:= '0.00/0.00 Mb';
    LabSize:= Tlabel.Create(self);
    LabSize.Parent:=  self;
    LabSize.Left:=10;
    LabSize.Anchors:=[akleft];
    LabSize.Caption:= FSizeLoad;
    LabSize.Font.Size:=8;
    LabSize.Font.Color:=clwhite;
    FSizeLoadVisible:=true;
    SaveSize.Size.cx:=0;
    SaveSize.Size.cy:=0;

end;
destructor  TChatPanelLoadMessage.Destroy;
begin
    inherited;
end;
procedure TChatPanelLoadMessage.Trs(Awin:TWinControl;Tr:integer);
begin
   SetWindowLong(Awin.Handle, GWL_EXSTYLE, GetWindowLong(Awin.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(Awin.Handle, 0, FTransp, LWA_ALPHA);
end;
procedure  TChatPanelLoadMessage.CreateWnd;
begin
    inherited;
    Trs(self,FTransp);
    // SetProcentLoadVisible(false);
end;
procedure TChatPanelLoadMessage.WMsize(var Msg:TWMSIZE);
begin
  inherited;
  //showmessage('WMsize');
  if isResize then exit;
  isResize:=true;
  try
  // self.Width:= self.Parent.Width;
  // self.Height:= self.Parent.Height;
    ProcentLoadResize(true);
    SizeLoadResize(true);

  finally
     isResize:=false;
  end;
end;
                     {Size}
procedure TChatPanelLoadMessage.SetSizeLoad(val:string);
begin
   if FSizeLoad = val then exit;
   FSizeLoad:= val;
   if CanFocus then  SizeLoadResize(false);
   LabSize.Caption:= FSizeLoad;
end;
procedure TChatPanelLoadMessage.SizeLoadResize(All:boolean);
var NewS:TSize;
Str:string;
begin
   if not FSizeLoadVisible then exit;
   NewS:= LabSize.Canvas.TextExtent(FSizeLoad);
   if All or (SaveSize.Size.cx<>NewS.cx) then LabSize.Left:=((Width div 2)- (NewS.cx div 2) );
   if All or (SaveSize.Size.cy<>NewS.cy) then
   begin
      if not FProcentLoadVisible then LabSize.Top:= ((Height div 2) - (NewS.cy div 2))
      else  LabSize.Top:=  LabProcent.Top  +SaveProcent.Size.cy+2;
   end;
   SaveSize.Size:= NewS;

end;
procedure TChatPanelLoadMessage.SetSizeLoadVisible(val:boolean);
begin
   FSizeLoadVisible:=val;
   LabSize.Visible:= val;

   if CanFocus then    
   postmessage(self.Handle,wm_size,0,0);
end;

                        {Procent}
procedure TChatPanelLoadMessage.SetProcentLoadVisible(val:boolean);
begin
   FProcentLoadVisible:=val;
   LabProcent.Visible:= val;
   if CanFocus then
   postmessage(self.Handle,wm_size,0,0);
end;
procedure TChatPanelLoadMessage.ProcentLoadResize(All:boolean);
var NewS:TSize;
Str:string;
begin
   if not FProcentLoadVisible  then exit;

    // if not Message.LoingMessage.CanFocus then exit;
   LabProcent.Font.Size:=12;
  // if (Self.Height<60) and (LabProcent.Font.Size<>12) then
  // else
  // if (Self.Height>80) and (LabProcent.Font.Size<>16) then  LabProcent.Font.Size:=16;

   Str:=  AmStr(FProcentLoad)+'%';
   NewS:= LabProcent.Canvas.TextExtent(Str);
   if All or (SaveProcent.Size.cx<>NewS.cx) then LabProcent.Left:=((Width div 2)- (NewS.cx div 2) );
   if All or (SaveProcent.Size.cy<>NewS.cy) then LabProcent.Top:= ((Height div 2) - (NewS.cy div 2));
   SaveProcent.Size:= NewS;
end;
procedure TChatPanelLoadMessage.SetProcentLoad(val:integer);
begin
   if FProcentLoad = val then exit;
   FProcentLoad:= val;
   if CanFocus then  ProcentLoadResize(false);

   LabProcent.Caption:= AmStr(FProcentLoad)+'%';


end;



procedure TChatPanelLoadMessage.Resize;

begin
     inherited;

   { if Procent.cx>Width then
    begin
      if LabProcent.Font.Size>8 then
      begin
      LabProcent.Font.Size:= LabProcent.Font.Size-1;
      Procent:= LabProcent.Canvas.TextExtent(LabProcent.Caption);
      end;
    end
    else
    begin
      if LabProcent.Font.Size<20 then
      begin
      LabProcent.Font.Size:= LabProcent.Font.Size+1;
      Procent:= LabProcent.Canvas.TextExtent(LabProcent.Caption);
      end;
    end;
     }


   //
end;


                 {TAmClientListBoxFilesCustom}

constructor TAmClientListBoxFilesCustom.Create(AOwner: TComponent);
begin
   inherited create(AOwner);
   FIsDestroy:=false;
   FListGraf:=Tlist<TGraphic>.create;
   BorderStyle:=  bsNone;
   ParentColor:=false;
   Font.Color:=clwhite;
   Font.Size:=10;
   Color:= $00423129;
   ItemsMy.Clear;

   Popap:= TAmClientPopapMenu.Create(TWincontrol(AOwner));
   Popap.ControlSave:=nil;
   Popap.Color:=$00453830;
   Popap.Constraints.MinHeight:=20;
   Popap.Constraints.MaxHeight:=300;
end;
destructor TAmClientListBoxFilesCustom.Destroy;
begin
     FIsDestroy:=true;
     Clear;
     FListGraf.Free;
     inherited ;
end;

procedure TAmClientListBoxFilesCustom.RunFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, 'open', PChar(FileName), '', nil,SW_SHOWNORMAL)
end;
procedure TAmClientListBoxFilesCustom.RunPapkaSelectFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, nil, 'explorer.exe', PChar('/select,' + FileName), nil, SW_SHOWNORMAL);
end;
procedure TAmClientListBoxFilesCustom.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseUp(Button,Shift,X, Y);
   if Button = mbRight then
   Popap.Open(self,0);
end;
procedure TAmClientListBoxFilesCustom.DrawItem(Index: Integer; Rect: TRect;State: TOwnerDrawState);
var //Icon:TIcon;
   Graf:TGraphic;
begin

   inherited DrawItem(Index,Rect,State);
 if (index>=0) and (index<FListGraf.Count) then
 begin
   Graf:= FListGraf[Index];
   if Assigned(Graf)  then
   begin
        if  (ItemHeight- Graf.Height >0)
        and (30-Graf.Width>0) then Canvas.Draw((Rect.left+(ItemHeight- Graf.Height) div 2),Rect.Top+(ItemHeight- Graf.Height) div 2,Graf)
        else Canvas.Draw(5,5,Graf);
   end;

 end;
 

   exit;
  if ItemsMy.IsIndex(Index) then
  begin
   Graf:=AmGetGraficIcon(ItemsMy[Index],24);
   if Assigned(Graf) then
   begin
        if  (ItemHeight- Graf.Height >0)
        and (30-Graf.Width>0) then Canvas.Draw(Rect.left+(ItemHeight- Graf.Height) div 2,Rect.Top+(ItemHeight- Graf.Height) div 2,Graf)
        else Canvas.Draw(5,5,Graf);

        if Graf is TBitmap then  TBitmap(Graf).Free
        else if Graf is TIcon then  TIcon(Graf).Free
        else
        Graf.Free;
   end;
   
  end;
   {
    Icon := TIcon.Create;
   try
    if ItemsMy.IsIndex(Index) then
    begin
         Icon.Handle :=AmGetFileExtAssociatedIcon(ItemsMy[Index], true,false);
       if Icon.Handle>0 then
       begin
        if  (ItemHeight- Icon.Height >0)
        and (30-Icon.Width>0) then Canvas.Draw(Rect.left+(ItemHeight- Icon.Height) div 2,Rect.Top+(ItemHeight- Icon.Height) div 2,Icon)
        else Canvas.Draw(5,5,Icon);
       end;
    end;
   finally
     Icon.Free;
   end;
    }


end;
Procedure TAmClientListBoxFilesCustom.AddFile(FullFileName:string);
begin
   self.Items.Add(ExtractFileName(FullFileName));
   self.ItemsMy.Add(FullFileName);
   FListGraf.Add(AmGetGraficIcon(FullFileName,24));
end;
Procedure TAmClientListBoxFilesCustom.DeleteFile(index:integer);
var R,Rmy,RList:boolean;
begin
    R:= (index>=0) and (index<self.Items.Count);
    Rmy:= (index>=0) and (index<self.ItemsMy.Count);
    Rmy:= (index>=0) and (index<self.ItemsMy.Count);
    RList:= (index>=0) and (index<FListGraf.Count);
    if R and Rmy and RList then
    begin
       Items.Delete(index);
       ItemsMy.Delete(index);
       GradDel( FListGraf[index] );
       FListGraf.Delete(index);
       if (Items.Count<=0) and Assigned(FOnClearListBox) then FOnClearListBox(self);

    end
    else showmessage('Не удачное удаление из списка');

end;
procedure TAmClientListBoxFilesCustom.GradDel(Graf:TGraphic);
begin
        if  Assigned(Graf) then
        begin
          if ( Graf is TBitmap) then  TBitmap(Graf).Free
          else if Graf is TIcon then  TIcon(Graf).Free
          else
          Graf.Free;
        end;
end;
Procedure TAmClientListBoxFilesCustom.Clear;
var
  I: Integer;
begin
     if not FIsDestroy  then     
     inherited Clear;
     ItemsMy.Clear;
     for I := 0 to FListGraf.Count-1 do
     GradDel( FListGraf[i] );
     FListGraf.Clear;
     if (ItemsMy.Count<=0) and not FIsDestroy and  Assigned(FOnClearListBox) then FOnClearListBox(self);
end;






     {TAmClientPopapMenu}
constructor TAmClientPopapMenu.Create(aParent: TWincontrol);
begin
   inherited create(aParent);
   ControlSave:=nil;
   Color:=$00453830;
   self.Constraints.MinHeight:=20;
   self.Constraints.MaxHeight:=300;

end;

function    TAmClientPopapMenu.CreateItem: TAmPopopMenuPanelCustom.TItem;
begin
      Result:= inherited CreateItem;
      Result.ColorActiv:=$00524238;
      Result.ColorPasiv:=$00453830;
end;
Procedure TAmClientPopapMenu.Open(aControl:Tobject;IndexStyle:integer);
begin
    inherited Open(IndexStyle);
    ControlSave:=aControl;
end;
Procedure TAmClientPopapMenu.Close;
begin
   inherited Close;
   //showmessage('Close');
   ControlSave:=nil;

end;


                  {TChatClientTimerPhoto}
                  {
Procedure TChatClientTimerPhoto.TItem.Clear;
begin
 IsEvent:=0;
 PhotoData:='';
 PhotoId:='';
 FullFileName:='';
 ListImage.Clear;
end;
Procedure TChatClientTimerPhoto.Clear;
var i:integer;
begin
   for I := List.Count-1 Downto 0 do   List[i].Clear;
   List.Clear;
end;

function TChatClientTimerPhoto.CheckOne(var Item:TChatClientTimerPhoto.TItem):boolean;
var Stream:TmemoryStream;
Img:TEsImage;
X:integer;
begin
    Result:=false;
    if (Item.PhotoId<>'')
    and (Item.FullFileName<>'')
    and (Item.ListImage.Count>0)
    and (ObjectPhotos[Item.PhotoId].Value=Item.PhotoData )
    and  fileexists(Item.FullFileName)
    then
    begin
       Stream:= TmemoryStream.Create;
       try
           Stream.LoadFromFile(Item.FullFileName);
           if Stream.Size>0 then
           begin
             Result:=true;
             for X := 0 to Item.ListImage.Count-1 do
             begin

                 Img:=TEsImage(Item.ListImage[X]);
                 if not Assigned(Img) then continue;
                 Stream.Position:=0;

                 Img.Picture.LoadFromStream(Stream);
                // Img.Smoth:=true;
             end;
           end;
       finally
           Stream.Free;
       end;
    end;

   if not Result and (Item.IsEvent<>999) and (Item.PhotoId<>'') then
   begin
     Item.IsEvent:=999;
     if Assigned(FOnNeedDowloadImg) then FOnNeedDowloadImg(Item.PhotoId,Item.PhotoData,Result);
     Result:= not Result;

   end;
    
end;
function TChatClientTimerPhoto.CheckAll:boolean;
var I:integer;
Item:TItem;
CheckOneR:Boolean;
begin
  Result:=false;
  if not Assigned(ObjectPhotos) then
  begin
      Stop;
      exit;
  end;

  I:=0;
  while i<=List.Count-1  do
  begin

    Item:=List[i];
    CheckOneR:=CheckOne(Item);
    List[i]:=Item;
    if CheckOneR then
    begin
       List.Delete(i);
       dec(i);
    end;
    inc(I);

  end;
  Result:= List.Count<=0;

   //ObjUser['Data']['Photos'][FRM.PhotoId]:= FRM.PhotoData;
end;
constructor TChatClientTimerPhoto.Create(Form: Tform);
begin
     inherited create(Form);
    Enabled:=false;
    Interval:=1000;
    CounterMax:=30;
    Fcount:=0;
    Clear;
    OnTimer:=  TimerOut;
end;
destructor TChatClientTimerPhoto.Destroy;
begin
// showmessage('TChatClientTimerPhoto.Destroy;');
    Enabled:=false;
    Clear;
    inherited Destroy;
end;
Procedure TChatClientTimerPhoto.Start;
begin
    if not  CheckAll then  Enabled:=true
    else Stop;
end;
Procedure TChatClientTimerPhoto.Stop;
begin
    Enabled:=false;
    FreeAndNil(self);
end;
procedure TChatClientTimerPhoto.TimerOut(Sender:Tobject);
var Ch:boolean;
begin
   logMain.Log('TChatClientTimerPhoto.TimerOut');
   Enabled:=false;
   inc(Fcount);
   try
        Ch:= CheckAll;
   finally
     if (Fcount<CounterMax) and not Ch then  Enabled:=true
     else Stop;
     
   end;
end;

  }


constructor TChatClientPopapWindow.Create(Form: Tform);
var PCh: PwideChar;
begin
    inherited create(Form);
     isError:=false;
     SecondTimer:=10;

     FForm:=Form;

     self.Anchors:=  [akLeft,akBottom];
     Width:=         197;
     Height:=        50;
     ParentBackground:=false;
     Font.Color:=ClWhite;
     font.Size:=10;
     ParentColor:=false;
     BevelKind:=bkNone;
     BevelOuter:=bvnone;
     Caption:='';
     parent:=Form;


     Ftimer:= TTimer.Create(self);
     Ftimer.Enabled:=false;
     Ftimer.Interval:=1000*SecondTimer;
     Ftimer.OnTimer:=  TimerOut;

     LabelConnect:= TLabel.Create(self);
     LabelConnect.Parent:=self;
     LabelConnect.Anchors:= [akLeft,akTop];
     LabelConnect.Left:=5;
     LabelConnect.Top:=5;
     LabelConnect.Font.Size:=8;
     LabelConnect.Font.Color:=$00B3F09B;
     FMiniText:='Offline';

     LabelClose:= TLabel.Create(self);
     LabelClose.Parent:=self;
     LabelClose.Anchors:= [akRight,akTop];
     LabelClose.Left:=Width-10;
     LabelClose.Top:=5;
     LabelClose.Font.Size:=8;
     LabelClose.Font.Color:=$008080FF;
     LabelClose.Caption:='X';
     LabelClose.OnClick:= LabelCloseClick;
     Close;
   // StrPCopy(PCh,'E:\Red 10.3\Projects\socketClientServer\Win32\Debug\FPC_Ride_FDrk_003.wav');
   // PCh:=PwideChar('FPC_Ride_FDrk_003.wav');
// PlaySound(PChar('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\FPC_Ride_FDrk_003.wav'), 0, SND_SYNC);
  //sndPlaySound('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\FPC_Ride_FDrk_003.wav',SND_ASYNC );

 // mciSendString(PChar('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\FPC_Ride_FDrk_003.wav'),nil,0,0);
end;
procedure TChatClientPopapWindow.Open;
var  h:integer;
begin
   h:= abs( self.Font.size )-2;
   //showmessage(h.ToString);
   h:=(length(FMessageText)*h)+10;
   //showmessage(h.ToString);
   if h<197 then h:=197;
   Width:=         h;



  Ftimer.Interval:=10000*SecondTimer;
  if isError then Color:=$007B7BDF
  else  Color:=          $0051412F; // красный-$007B7BDF   зеленый - $00B3F09B;

  Left:=          0;
  Top:=           FForm.Height-self.Height;
  LabelConnect.Caption:= FMiniText;
  Caption:= FMessageText;
  Ftimer.Enabled:=false;
  Ftimer.Enabled:=true;
  self.Visible:=true;
  self.BringToFront;
end;
procedure TChatClientPopapWindow.Close;
begin
  Ftimer.Enabled:=false;
  self.Visible:=false;
end;
Procedure TChatClientPopapWindow.LabelCloseClick(sender:Tobject);
begin
  Close;
end;

Procedure TChatClientPopapWindow.TimerOut(sender:Tobject);
begin
 //logMain.Log('TChatClientPopapWindow.TimerOut');

    Close;
end;
destructor TChatClientPopapWindow.Destroy;
begin
    Ftimer.Enabled:=false;
    Ftimer.Free;
    inherited Destroy;

end;
end.

(*
    type
     TamScrollVisible = (amsAllVisible, amsAutoVisible, amsNoVisible);

     TAmClientScroll = class(Tpanel)
       strict Private
        FAutoVisible: TamScrollVisible;
        PanelParent:Tpanel;
        PanelParentBox: Tpanel;

        Box:TScrollBox;
        Ftimer:TTimer;
        IsHideScroll:boolean;
        procedure SliderMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);

        procedure BoxConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);
        procedure BoxResize(Sender: TObject);
        procedure HideScroll;
        function GetSliderHeight :integer;


        procedure SetAutoVisible(val:TamScrollVisible);
        procedure CheckAutoVisible;
     public
        Slider: Tpanel;
       Procedure PositionUpdateTopSlider(sender:Tobject);
       Property AutoVisible:TamScrollVisible read FAutoVisible write SetAutoVisible;
       constructor Create(aBox:TScrollBox;PanelTop:TPanel=nil;PanelBottom:TPanel=nil); reintroduce;
     end;


    type
     TAmClientMessageHelp = class
      private
        FChatBox:TScrollBox;
       public
      //  SelectedUserId:string; // TAmClientContact.UserId которого просматривается переписка
        Procedure DeleteAllControls;
      //  Procedure SetIsSelectContactsFalse;
        constructor Create(aChatBox:TScrollBox); reintroduce;
     end;
     TAmClientMessage = class(TAmClientTpanel)
       strict Private

       // procedure SliderMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
      //  Procedure TimerOut(sender:Tobject);
     //   procedure BoxConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);

        TimerResize:Ttimer;
        TimerConstrainedResize:Ttimer;
        IsExrTimerResize:integer;
        FTimeFull:string;
        FUserNameFull:string;
        FMessageTextFull:string;
        FersResize:integer;

        FMessageIsMy:boolean;
        FMessageIsRead:boolean;




        Procedure SetTimeFull(val:string);
        Procedure SetUserNameFull(val:string);
        Procedure SetMessageTextFull(val:string);
        Procedure SetMessageIsMy(val:boolean);
        Procedure SetMessageIsRead  (val:boolean);
        procedure SelfResize(Sender: TObject);
        procedure SelfCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
        procedure SelfConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);

        procedure TimerSelfResize(Sender: TObject);
        procedure TimerSelfConstrainedResize(Sender: TObject);
     public

        PhotoId:string;
        PhotoData:string;
        MessageId:string;
        MessagePhotoId:string;
        MessagePhotoData:string;
        UserId:string;
        PanelMain:Tpanel;
        PhotoImage: TImage;
        PhotoMessage: TImage;
        TimeLabel:Tlabel;
        ReadLabel:Tlabel;
        Memo:TRichEdit;

        UserNameLabel:Tlabel;
        MessageLabel:Tlabel;
        Function GetPhotoLParam:Cardinal;
        Function GetMessagePhotoLParam:Cardinal;


        property TimeFull:String read FTimeFull write SetTimeFull;
        property UserNameFull:String read FUserNameFull write SetUserNameFull;
        property MessageTextFull:String read FMessageTextFull write SetMessageTextFull;
        property MessageIsMy:boolean   read FMessageIsMy write SetMessageIsMy;
        property MessageIsRead:boolean read FMessageIsRead write SetMessageIsRead;
        constructor Create(AOwner: TComponent); override;
     end;








constructor TAmClientScroll.Create(aBox:TScrollBox;PanelTop:TPanel=nil;PanelBottom:TPanel=nil);
begin
       inherited create(Parent);

       FAutoVisible:= amsAllVisible;
       PanelParent:= Tpanel.Create(aBox.Parent);
       PanelParent.parent:=aBox.Parent;
       PanelParent.Align:= aBox.Align ;
       if  (aBox.Align = alNone) or ( aBox.Align = alCustom) then
       begin

         PanelParent.Top:= aBox.Top;
         PanelParent.Left:= aBox.Left;
         PanelParent.Height:= aBox.Height;
         PanelParent.Width:= aBox.Width;

       end
       else if aBox.Align =  alLeft then
       begin
         PanelParent.Width:= aBox.Width;
       end
       else if aBox.Align =  alRight then
       begin
         PanelParent.Width:= aBox.Width;
       end;


      //  alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom


      PanelParent.ParentBackground:=false;
      PanelParent.ParentColor:=false;
      PanelParent.BevelKind:=bkNone;
      PanelParent.BevelOuter:=bvnone;
   //   PanelParent.Color:= aBox.Color; // красный-$007B7BDF   зеленый - $00B3F09B;
      PanelParent.Caption:='';
      PanelParent.BringToFront;




       parent:=PanelParent;
       Align:=alRight;
       Width:=         6;
       ParentBackground:=false;
       ParentColor:=false;
       BevelKind:=bkNone;
       BevelOuter:=bvnone;
       Color:=         $00604040;//$00413129 ; // красный-$007B7BDF   зеленый - $00B3F09B;
       Caption:='';


       slider:=  Tpanel.Create(self);
       slider.parent:=self;

       slider.Width:=        Width*4 ;
       slider.Height:=50;
       slider.Left:=-(slider.Width div 2);
       slider.ParentBackground:=false;
       slider.ParentColor:=false;
       slider.BevelKind:=bkNone;
       slider.BevelOuter:=bvnone;
       slider.Color:=       $008B5C5C;// $00815656 ; //$009CA3F3; // красный-$007B7BDF   зеленый - $00B3F09B;
       slider.Caption:='';
       slider.OnMouseDown:= SliderMouseDown;

       Ftimer:=TTimer.Create(self);
       Ftimer.Enabled:=false;
       Ftimer.Interval:=50;
       Ftimer.OnTimer:= PositionUpdateTopSlider;








      PanelParentBox:= Tpanel.Create(aBox.Parent);
      PanelParentBox.parent:=PanelParent;
      PanelParentBox.Align:= AlClient;
      PanelParentBox.ParentBackground:=false;
      PanelParentBox.ParentColor:=false;
      PanelParentBox.BevelKind:=bkNone;
      PanelParentBox.BevelOuter:=bvnone;
      PanelParentBox.Color:= aBox.Color; // красный-$007B7BDF   зеленый - $00B3F09B;
      PanelParentBox.Caption:='';







       Box:=aBox;
       Box.Parent:=PanelParentBox;
       Box.Align:= alClient;
       IsHideScroll:=false;

       Box.OnConstrainedResize:= BoxConstrainedResize;
       Box.OnResize:=  BoxResize;


     //  HideScroll;

      if PanelBottom<>nil then
      begin
         PanelBottom.parent:=PanelParentBox;
         PanelBottom.Align:=alBottom;
      end;
      if paneltop<>nil then
      begin
         PanelTop.parent:=PanelParentBox;
         PanelTop.Align:=alTop;
      end;
end;
procedure TAmClientScroll.HideScroll;
begin
    if not IsHideScroll and
    Box.VertScrollBar.IsScrollBarVisible then
    begin
      IsHideScroll:=true;
      ShowScrollBar(Box.Handle, SB_VERT, False);
    end
   // else if not Box.VertScrollBar.IsScrollBarVisible then  IsHideScroll:=false;

end;
Procedure TAmClientScroll.PositionUpdateTopSlider(sender:Tobject);
begin
 logMain.Log('TAmClientScroll.TimerOut');
   Box.VertScrollBar.Position:= Round(slider.Top/(Box.ClientHeight / Box.VertScrollBar.Range));
end;
procedure TAmClientScroll.BoxConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
begin
  CheckAutoVisible;
  HideScroll;
  GetSliderHeight;



 // LogMain.log('BoxConstrainedResize');
end;
procedure TAmClientScroll.BoxResize(Sender: TObject);
begin


  if Box.VertScrollBar.IsScrollBarVisible then
   ShowScrollBar(Box.Handle, SB_VERT, False);


end;
function TAmClientScroll.GetSliderHeight :integer;
//Info: TScrollInfo;
begin
     //Info.cbSize := SizeOf(Info);
    // Info.fMask := SIF_POS or SIF_RANGE or SIF_PAGE;
  //   Win32Check(GetScrollInfo(Box.Handle, SB_VERT, Info));
     //Result := Info.nPos >=  Info.nMax - Info.nMin - Info.nPage;


  slider.Top:=   Round(Box.VertScrollBar.Position*(Box.ClientHeight / Box.VertScrollBar.Range));
  slider.Height:=   Round(Box.ClientHeight*(Box.ClientHeight / Box.VertScrollBar.Range));



end;


procedure TAmClientScroll.SliderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //LogMain.log('SliderMouseDown');
  GetSliderHeight;

  Ftimer.Enabled:=true;
 try
  ReleaseCapture;
  SendMessage(TwinControl(Sender).Handle, WM_SysCommand, $F012, 0);
  slider.Left:=-(slider.Width div 2);
  if slider.Top<0 then slider.Top:=0;
  if slider.Top>Height-slider.Height then slider.Top:=Height-slider.Height;
 finally
  Ftimer.Enabled:=false;
 end;


end;
procedure TAmClientScroll.SetAutoVisible(val:TamScrollVisible);
begin
   if FAutoVisible<>val then
   begin
     FAutoVisible:=val;
     if FAutoVisible=amsNoVisible then self.Visible:=false
     else if (FAutoVisible = amsAutoVisible) then  CheckAutoVisible
     else if (FAutoVisible = amsAllVisible) and not Visible then
     begin
      IsHideScroll:=true;
      ShowScrollBar(Box.Handle, SB_VERT, False);
      Visible:=true;
     end;



   end;

end;
procedure TAmClientScroll.CheckAutoVisible;
begin
   if FAutoVisible=amsAutoVisible then
  begin
    if  (slider.Height-1 >= Box.ClientHeight) and Visible then  Self.Visible:=false
    else if (slider.Height-1 < Box.ClientHeight) and not Visible then
    begin
       Visible:=true;
      IsHideScroll:=true;
      ShowScrollBar(Box.Handle, SB_VERT, False);
    end;
  end;

  //amsAllVisible, amsAutoVisible, amsNoVisible

end;










constructor TAmClientMessage.Create(AOwner: TComponent);
begin
       inherited create(AOwner);
        FTimeFull:='';
        FUserNameFull:='No Name';
        FMessageTextFull:='';
        FMessageIsMy:=false;
        FMessageIsRead:=true;
        PhotoId:='';
        PhotoData:='';
        MessageId:='';
        MessagePhotoId:='';
        MessagePhotoData:='';
        UserId:='';
       FersResize:=0;
       TimerResize:=TTimer.Create(self);
       TimerResize.Interval:=50;
       TimerResize.Enabled:=false;
       TimerResize.OnTimer:= TimerSelfResize;
       IsExrTimerResize:=0;

       TimerConstrainedResize:=TTimer.Create(self);
       TimerConstrainedResize.Interval:=10;
       TimerConstrainedResize.Enabled:=false;
       //TimerConstrainedResize.OnTimer:= TimerSelfConstrainedResize;


       //parent:=aBox;
      // Align:=AlBottom;
     //  self.Width:= aBox.Width;
       //Top:= integer.MinValue;
       Height := 60;
       ParentBackground:=false;
       ParentColor:=true;
       BevelKind:=bkNone;
       BevelOuter:=bvnone;
       Caption:='';

       PanelMain:= Tpanel.Create(self);
       PanelMain.parent:=self;
        if self.Width>600 then
        PanelMain.Margins.Right := self.Width -570
        else   PanelMain.Margins.Right :=30;

       PanelMain.AlignWithMargins := True;
        PanelMain.Align:=AlClient;
       PanelMain.Margins.Left := 30;
       PanelMain.Margins.Top := 0;
       PanelMain.Margins.Right := 30;
       PanelMain.Margins.Bottom := 10 ;
       PanelMain.ParentBackground:=false;
       PanelMain.ParentColor:=false;
       PanelMain.BevelKind:=bkNone;
       PanelMain.BevelOuter:=bvnone;
       PanelMain.Caption:='';
       PanelMain.Color := $0049362E;









       PhotoImage := Timage.Create(PanelMain);
       PhotoImage.Parent:= PanelMain;
       PhotoImage.Left := 6;
       PhotoImage.Top := 5;
       PhotoImage.Width := 34;
       PhotoImage.Height := 32;
       PhotoImage.Stretch := True;
   //    PhotoImage.Picture.LoadFromFile('F:\обучение\системы клиентов\ольга\посты на стену\1\Без имени-1.jpg');

       TimeLabel:=  TLabel.Create(PanelMain);
       TimeLabel.Parent:=  PanelMain;
       TimeLabel.Top := 4;
       TimeLabel.Left := PanelMain.Width-50;
       TimeLabel.Align := alCustom ;
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



       ReadLabel:=  TLabel.Create(PanelMain);
       ReadLabel.Parent:=  PanelMain;
       ReadLabel.Top := PanelMain.Height-10;
       ReadLabel.Left := PanelMain.Width-20;
       ReadLabel.Align := alCustom ;
       ReadLabel.Anchors:= [akBottom, akRight];
       ReadLabel.Caption := '*';
       ReadLabel.Font.Charset := DEFAULT_CHARSET;
       ReadLabel.Font.Color := clSilver;
       ReadLabel.Font.Size:=8;
       ReadLabel.Font.Name := 'Tahoma';
       ReadLabel.Font.Style := [];
       ReadLabel.ParentBiDiMode := False;
       ReadLabel.ParentColor := False;
       ReadLabel.ParentFont := False;


       UserNameLabel:=  TLabel.Create(PanelMain);
       UserNameLabel.Parent:=  PanelMain;
       UserNameLabel.Top := 3;
       UserNameLabel.Left := 46;
       UserNameLabel.Align := alCustom ;
       UserNameLabel.Anchors:= [akTop, akLeft];
       UserNameLabel.Caption := 'No Name';
       UserNameLabel.Font.Charset := DEFAULT_CHARSET;
       UserNameLabel.Font.Color := $00CFFF9F;
       UserNameLabel.Font.Size:=10;
       UserNameLabel.Font.Name := 'Arial';
       UserNameLabel.Font.Style := [fsBold];
       UserNameLabel.ParentBiDiMode := False;
       UserNameLabel.ParentColor := False;
       UserNameLabel.ParentFont := False;




       MessageLabel:=  TLabel.Create(PanelMain);
       MessageLabel.Parent:=  PanelMain;
       MessageLabel.Top := 21;
       MessageLabel.Left := 46;
       MessageLabel.Align := alCustom ;
       MessageLabel.Anchors:= [akTop, akLeft];
       MessageLabel.Caption := '';
       MessageLabel.Font.Charset := DEFAULT_CHARSET;
       MessageLabel.Font.Color := clWhite;
       MessageLabel.Font.Size:=10;
       MessageLabel.Font.Name := 'Arial';
       MessageLabel.Font.Style := [];
       MessageLabel.ParentBiDiMode := False;
       MessageLabel.ParentColor := False;
       MessageLabel.ParentFont := False;

       Memo:=    TRichEdit.Create(PanelMain);
        Memo.Parent:= PanelMain;
       Memo.Top := 21;
       Memo.Align:=alcLient;
       Memo.AlignWithMargins:=true;
       Memo.Margins.Bottom:=10;
       Memo.Margins.Top:=21;
       Memo.Margins.Left:=50;
     //  Memo.a
       Memo.Left := 46;
       Memo.Font.Color := clWhite;
       Memo.Font.Size:=10;
       Memo.Font.Name := 'Arial';

      Memo.BevelInner := bvNone;
      Memo.BevelOuter := bvNone;
      Memo.BorderStyle := bsNone;
      //OnResize:=SelfResize;
     //  OnCanResize:= SelfCanResize;
      // OnConstrainedResize:= SelfConstrainedResize;
end;
Function TAmClientMessage.GetPhotoLParam:Cardinal;
begin
    Result:=LPARAM(PhotoImage);
end;
Function TAmClientMessage.GetMessagePhotoLParam:Cardinal;
begin
   Result:=LPARAM(PhotoMessage);
end;
Procedure TAmClientMessage.SetTimeFull(val:string);
begin
    if (FTimeFull<>val) and (val<>'')  then
    begin
       FTimeFull:=val;
       TimeLabel.Caption:= amWrapText.SetTexDateTime( MyStrToDateTime(FTimeFull));
    end;

end;
Procedure TAmClientMessage.SetUserNameFull(val:string);
begin
    if (FUserNameFull<>val) and (val<>'')  then
    begin
       FUserNameFull:=val;
        if FUserNameFull='' then  FUserNameFull:='No Name';
       UserNameLabel.Caption:=  amWrapText.SetTextLabelTrim( FUserNameFull ,UserNameLabel,70);
    end;
end;
Procedure TAmClientMessage.SetMessageTextFull(val:string);
var   after : amWrapText.TTextForLabelResult;
begin
    if (FMessageTextFull<>val)  then
    begin

        FMessageTextFull:=val;

        try

        after:= amWrapText.SetTextLabelWrap(FMessageTextFull,MessageLabel);
        //Height:=Height+after.DeltaHeight;
        Height:=after.DeltaHeight;
         postmessage(self.Parent.Handle,WM_SIZE,0,0);
        finally

        end;

    end;
end;
Procedure TAmClientMessage.SetMessageIsMy(val:boolean);
begin
    if (FMessageIsMy<>val)  then
    begin
       FMessageIsMy:=val;
       if FMessageIsMy then PanelMain.Color:=$00795535
       else PanelMain.Color:=$0049362E;
    end;
end;
Procedure TAmClientMessage.SetMessageIsRead  (val:boolean);
begin
    if (FMessageIsRead<>val)  then
    begin
       FMessageIsRead:=val;
       if FMessageIsRead then ReadLabel.Caption:='**'
       else ReadLabel.Caption:='*';
    end;


end;

procedure TAmClientMessage.SelfCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
var S:TWinControl;
begin

   S:= self.Parent ;

   Resize:= ( self.top  < S.ClientHeight+550)    // Bottom
   and( self.top+self.Height>-550);

   Resize:=true;
end;
procedure TAmClientMessage.SelfResize(Sender: TObject);
begin


  TimerSelfResize(self);





end;
procedure TAmClientMessage.SelfConstrainedResize(Sender: TObject; var MinWidth,MinHeight, MaxWidth, MaxHeight: Integer);
var S:TScrollBox;
begin
 exit;
   S:= self.Parent as TScrollBox;

   if ( self.top  < S.ClientHeight+550)    // Bottom
   and( self.top+self.Height>-550)
   then
   begin
        TimerConstrainedResize.Enabled:=false;
        TimerConstrainedResize.Enabled:=true;
   end;





end;
procedure TAmClientMessage.TimerSelfConstrainedResize(Sender: TObject);
 var   after : amWrapText.TTextForLabelResult;
begin
         TimerConstrainedResize.Enabled:=false;
          exit;
        LogMain.Log('   TAmClientMessage.TimerSelfConstrainedResize');
        after:= amWrapText.SetTextLabelWrap(FMessageTextFull,MessageLabel);
        Height:=after.DeltaHeight;

end;
procedure TAmClientMessage.TimerSelfResize(Sender: TObject);
 var   after : amWrapText.TTextForLabelResult;
begin
     TimerResize.Enabled:=false;

    // LogMain.Log('   TAmClientMessage.TimerSelfResize');


        if self.Width>600 then
        PanelMain.Margins.Right := self.Width -570
        else   PanelMain.Margins.Right :=30;



        after:= amWrapText.SetTextLabelWrap(FMessageTextFull,MessageLabel);
        Height:=after.DeltaHeight;
      //  showmessage('SelfResize'+MessageLabel.Height.ToString);
        postmessage(self.Parent.Handle,WM_SIZE,0,0);
        UserNameLabel.Caption:=  amWrapText.SetTextLabelTrim( FUserNameFull ,UserNameLabel,70);

         IsExrTimerResize:=0;
end;




*)
