unit AmChatScrollBox;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,System.Generics.Collections,
  math,AmLogTo,ES.BaseControls,ES.Layouts,AmHandleObject,amusertype,AmControls;

  type


    TamScrollChange = procedure (Sender: TObject; OldPosition,NewPosition: integer) of object;
    TamChatScrollBoxCustom = class;

  {TamChatScrollRange}//это не визуальный скрол бар в основном хранит range и меняет позицию
   TamChatScrollRange = class (TamHandleObject)
      type
        TTimerEvent = Class (TTimer)
          Private
           SaveOldPosition:integer;
        end;
   private
          Const  WM_CHANGE_POSITION = wm_user+1;
          Const  SCROLL_ONMIN = wm_user+2;
          Const  SCROLL_ONMAX = wm_user+3;
          Const  SCROLL_ONDIVIZOR = wm_user+4;
          var
          FTimerChangePosition:TTimerEvent;

          FControl: TamChatScrollBoxCustom;
          FPos: Integer;
          FControlListPos:integer;
          FControlListPosOld:integer;

          FRange: Integer;
          FControlListRange:integer;
          FCalcRange: Integer;
          FControlListCalcPageRange:integer;
          FUpdateNeeded: Boolean;
          FUpSetPosition:Boolean;
          FChangePosition:TamScrollChange;
          FChangeRange: TamScrollChange;
          FControlListChangeRange:  TamScrollChange;
          FControlListChangePosition:TamScrollChange;
//          FTimerScrollOnPosition:TTimer;
        //  FTimerScrollOnPositionFinish:integer;


          FScrollTo_Timer : TTimer;
          FScrollTo_Timer_Up:boolean;
          FScrollTo_Timer_Lock:boolean;
          FScrollTo_OnMin : TNotifyEvent;
          FScrollTo_OnMax : TNotifyEvent;
          FScrollTo_CorrectMinMax:integer;
          FScrollTo_DivisorMax:integer;
          FScrollTo_OnDivisor: TNotifyEvent;
          FScrollTo_DivisorProcessing:boolean;
          FScrollTo_Lock:boolean;

          procedure   ScrollTo_Timer(S:Tobject);
          procedure   DoScrollTo_OnMin;
          procedure   DoScrollTo_OnMinPost(Var Msg:TMessage); message SCROLL_ONMIN;
          procedure   DoScrollTo_OnMax;
          procedure   DoScrollTo_OnMaxPost(Var Msg:TMessage); message SCROLL_ONMAX;

          procedure   DoScrollTo_OnDivisor(old,new:integer);
          procedure   DoScrollTo_OnDivisorPost(Var Msg:TMessage); message SCROLL_ONDIVIZOR;

          procedure   TimerPositionEvent(S:Tobject);

          constructor Create(AControl: TamChatScrollBoxCustom);
          procedure   CalcAutoRange;
         // function    ControlSize(): Integer;
          procedure   DoSetRange(Value: Integer);

          procedure   SetPos(Value: Integer);
          procedure   SetPosition(Value: Integer);

          procedure   DoChangePosition(Old:integer);
          procedure   SetRange(Value: Integer);

          procedure   DoControlListChangePosition(Old:integer;New:Integer);

          procedure   SetControlListPosition(Value: Integer);
          // в этом модуле корректируется позиция программно только само число
          property    FPosition: Integer read FPos write SetPos default 0;

        protected
        public
        published
           destructor Destroy; override;

          // относяся к самому сколл боксу
          property  Position: Integer read FPos write SetPosition default 0;
          property  Range: Integer read FRange  default 0;
          property  CalcPageRange: Integer read FCalcRange default 0;

          property  OnChangePosition :TamScrollChange read FChangePosition write FChangePosition;
          property  OnChangeRange :TamScrollChange read FChangeRange write FChangeRange;

         // относятся у учетом всех листов
          property  ControlListPosition: Integer read FControlListPos write SetControlListPosition default 0;
          property  ControlListRange: Integer read FControlListRange  default 0;
          property  ControlListCalcPageRange: Integer read FControlListCalcPageRange default 0;

          property  OnControlListChangePosition :TamScrollChange read FControlListChangePosition write FControlListChangePosition;
          property  OnControlListChangeRange :TamScrollChange read FControlListChangeRange write FControlListChangeRange;







          //  c  учетом всех листов

          //проскролить вниз вверх с эффектом прокрутки через таймер
          procedure ScrollTo_StartTimer(Up:boolean);

          // срабатывает когда позиция в самом низу = 0 от любого скрола
          property  ScrollTo_OnMin : TNotifyEvent   read FScrollTo_OnMin write FScrollTo_OnMin;

          // срабатывает когда позиция в самом верху от любого скрола
          property  ScrollTo_OnMax : TNotifyEvent   read FScrollTo_OnMax write FScrollTo_OnMax;


          // если позиция меньше  ScrollToDown_CorrectMinEvent сработает событие   ScrollToDown_OnMin 1 раз пока не станет больше
          property  ScrollTo_CorrectMinMax:integer  read FScrollTo_CorrectMinMax write FScrollTo_CorrectMinMax;



          //делитель порога события при скроле вверх что нужно погружить например
          //более старые сообщения  чем больше тем выше нужно поднятся начните с 3х  value от 1 до 100
          property  ScrollTo_DivisorMax :integer  read FScrollTo_DivisorMax write FScrollTo_DivisorMax;


          // срабатывает когда достигли порога когда нужно что то погрузить в самый верх (например более старые сообщения)
          // исключена возможность повторного срабатывания пока  ScrollTo_OnDivisor выполняется
          property  ScrollTo_OnDivisor : TNotifyEvent   read FScrollTo_OnDivisor write FScrollTo_OnDivisor;

          // скролить true = запрещено или разрещено = false используется внешне когда например выполняется событие ScrollTo_OnDivisor
          property  ScrollTo_Lock:boolean read FScrollTo_Lock write FScrollTo_Lock;






    end;




    {TamChatScrollBoxCustom} // наделен разными базовыми способностями в основлном что бы верно скролить элементы и не тормозить при большом их количестве
    TamChatScrollBoxCustom = class (TEsCustomLayout)     //TWincontrol  TEsCustomLayout Tpanel TEsCustomControl

       Const AM_CHANGE_SHOW =wm_user+1;
       type
        THelpList = class
           SaveHeight:integer;
           List:TList<TWincontrol>;
        end;
        type
         TTimerControlList = Class (Ttimer)
           Private
           DirectionUp:boolean;IfNewBlock:boolean;
           LockExp:boolean;
           CountErr:integer;
           IErr:integer;
          public
            property LockMe:boolean read LockExp;

         End;
     private

        FVertRangeBar:TamChatScrollRange;
        SaveWidth:integer;
        SaveHeight:integer;
        FReDrawStateLock:boolean;
        FReDrawTurnOnInnerLock:boolean;
        FCountOfStockInvisiblePixels:integer;
        FTimerControlList:TTimerControlList;
        function GetMaxTop:integer;
        function GetMinTop:integer;
//        procedure UpdateTopContent(Delta:integer;up:boolean);
        procedure WMSize(var Message: TWMSize); message WM_SIZE;
        procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
        procedure CMShowingChanged(var Message: TMessage); message wm_ParentNotify;
        procedure AMShow(var Message: TMessage); message AM_CHANGE_SHOW;
        property  MaxTop:Integer read  GetMaxTop;
        property  MinTop:Integer read  GetMinTop;
        procedure SetCountOfStockInvisiblePixels(val:integer);
     protected
        procedure AlignControls(AControl: TControl; var ARect: TRect); override;
        procedure CalcAutoRange(); virtual;
        procedure Resize; override;
        procedure ResizeBlock(ItemClient:TWincontrol); virtual;

        // любой скрол должен проходить черз эту
        procedure ScrollByChat(DeltaX, DeltaY: Integer);virtual;

        // вызывается только при смене позиции в  FVertRangeBar
        procedure ScrollByRangeBar(DeltaX, DeltaY: Integer); virtual;

        // управление Ltop Lmid Lbot
        function ControlList_NeedCheck(DirectionUp:boolean;IfNewBlock:boolean):boolean; virtual;
        function ControlList_HideContent(Index:integer;AControl:TWinControl;ToListTop:boolean;IfNewBlock:boolean):boolean; virtual;
        function ControlList_ShowContent(ToListTop:boolean):boolean; virtual;
        procedure ControlList_Timer(S:Tobject);
        procedure ControlList_TimerStart(DirectionUp,IfNewBlock:boolean);

        procedure ControlList_Add(Control:TWincontrol;Up:boolean); virtual;
        procedure ControlList_Clear; virtual;
        procedure ControlList_ScrollTo(Up:boolean);

        Procedure ReDrawLock; virtual;
        Procedure ReDrawUnLock;virtual;
     public

       //хранит то что сверху не видно
       Ltop: THelpList;

       //хранит то что в скрол боксе
       Lmid: TList<TWincontrol>;

        //хранит то что снизу не видно
       Lbot: THelpList;


       MaxWidthBlock:integer;
       MinWidthBlock:integer;



       //после запуска  ReDrawUnLockUser потребуется resize
       Procedure ReDrawLockUser;
       Procedure ReDrawUnLockUser;
       Function  ReDrawStateLock:boolean;
      // включить  внутри модуля блокироку перерисовки  можно временно отключать когда в цикле большое кол-во блоков добавляется и самостоятельно запускать  ReDrawLockUser ReDrawUnLockUser
       property  ReDrawTurnOnInnerLock: boolean read FReDrawTurnOnInnerLock write FReDrawTurnOnInnerLock;


       // количество пикселей высоты и топа ребенка скролл бокса при котором  его либо скрывать или показывать
       // если топ с верху больше чем  CountOfStockInvisiblePixels то скрыть или показать
       // расчитывать так что бы максимальная высота блока не была больше CountOfStockInvisiblePixels
       // в модуле это не как не обрабатывается не верные настройки либо заблокируют скрол при скроле или же в Lmid будет слишком много детей что будет вызывать фризы и тормоза
       property  CountOfStockInvisiblePixels: integer read FCountOfStockInvisiblePixels write SetCountOfStockInvisiblePixels ;

       procedure ClearScrollBox;

       procedure ControlListCheck2(IfNewControl:boolean);
       procedure AddControl(Control:TWincontrol;Up:boolean);
       property  BarRange: TamChatScrollRange read FVertRangeBar ;
       procedure RefreshControl(Control:TWincontrol);
       procedure Refresh;





       property TimerControlList : TTimerControlList read FTimerControlList;

       constructor Create (AOwner:TComponent); override;
       destructor Destroy; override;
    end;


    // параметры для липучки при скроле к контролу задяются в начале изменения   размера в конце превращаются в nil
    TamChatScrollBoxSavePos_Param=record
      Block:Twincontrol;
      Content:Twincontrol;
      Bottom:integer;
    end;

     // наделен  способностью прилипать к контролу при resize  + TamChatScrollBoxCustom
    TamChatScrollBoxSavePos = class (TamChatScrollBoxCustom)
       private
         StateSavePos:boolean;
         SaveControlAtScroll:TamChatScrollBoxSavePos_Param;
         procedure ScrollInViewSavePos(AControl: TControl);
         procedure WMEnterSizeMove(var Message: TMessage); message WM_ENTERSIZEMOVE;
         procedure WMExitSizeMove(var Message: TMessage); message WM_EXITSIZEMOVE;
       protected
         procedure Resize; override;
       public
         procedure ScrollInViewToTop(AControl: TControl);

         //что бы при resize прилипалось к контролу запустить  SavePosBegin в начале изменения размера  TamChatScrollBoxSavePos
         // в конце запустить SavePosEnd
         // это котрол сам это не может сделать а только форма или другая логика
         // пример отпределения начало Resize и конец в процедурах  WMEnterSizeMove  WMExitSizeMove на форму вешать их нужно
         procedure SavePosBegin;
         procedure SavePosEnd;
         ////////////////////////


         constructor Create (AOwner:TComponent); override;
         destructor Destroy; override;
    published
        property OnCanResize;
        property OnClick;
        property OnConstrainedResize;
        property OnContextPopup;
        property OnDblClick;
        property OnDockDrop;
        property OnDockOver;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDock;
        property OnEndDrag;
        property OnEnter;
        property OnExit;
        property OnGesture;
        property OnGetSiteInfo;
        property OnMouseActivate;
        property OnMouseDown;
        property OnMouseEnter;
        property OnMouseLeave;
        property OnMouseMove;
        property OnMouseUp;
        property OnMouseWheel;
        property OnMouseWheelDown;
        property OnMouseWheelUp;
        property OnResize;
        property OnStartDock;
        property OnStartDrag;
        property OnUnDock;
    end;



    TamChatScrollBoxOpt = class (TamChatScrollBoxSavePos)

    end;




   type
     TamChatButtonToDown = class;

     {сам TscrollBox }
     TamChatScrollBoxOptimus = class (TEsLayout)

     strict Private
        FUpSetPosition:Boolean;
        FOnChangePosition,
        FOnChangeRange:TamScrollChange;
        FScroll:TamScrollSuper;
        FBox:TamChatScrollBoxOpt;



        Procedure ChangeRange(S:Tobject;Old,New:integer);
        Procedure ChangePositionBoxBar(S:Tobject;Old,New:integer);
        Procedure ChangePositionScroll(S:Tobject;Old,New:integer);

    protected
        Procedure DoChangePosition(Old,New:integer); virtual;
        Procedure DoChangeRange(Old,New:integer);   virtual;
     public

        property Scroll: TamScrollSuper read FScroll;
        property Box: TamChatScrollBoxOpt read FBox;


        property OnChangePosition: TamScrollChange read FOnChangePosition write FOnChangePosition;
        property OnChangeRange: TamScrollChange read FOnChangeRange write FOnChangeRange;
        constructor Create(AOwner: TComponent); override;

     end;




    TamChatScrollBoxButtonToDown = class (TamChatScrollBoxOptimus)
     private
       FButtonToDown: TamChatButtonToDown;
     protected
    //   procedure ScrollMouseMove(s:Tobject;Shift: TShiftState; X, Y: Integer);virtual;
     public
      property ButtonToDown:TamChatButtonToDown read FButtonToDown ;
      constructor Create(AOwner: TComponent); override;
    end;



    TamChatButtonToDown = class  (TEsLayout)
      private
        FTimer:TTimer;
        FBitMap:TBitMap;
        FBox: TamChatScrollBoxButtonToDown;
        FCaption:string;
        procedure PaintArrow;
        procedure PaintCaption;
        procedure SetCaptions(val:string);
        procedure SetVisible(val:boolean);
        function  GetVisible:boolean;
        procedure TimerNotVisible(S:Tobject);
      protected
        procedure Paint; override;
       // procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure Click; override;

      public
       property Visible   read GetVisible write SetVisible;
       property Captions: string read FCaption write SetCaptions;
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
    end;

implementation

//////////////////////////////////////////////////////////

            {TamChatScrollBoxButtonToDown}
constructor TamChatScrollBoxButtonToDown.Create(AOwner: TComponent);
begin
      inherited create(AOwner);

       FButtonToDown :=TamChatButtonToDown.Create(self);
       FButtonToDown.Height := 50;
       FButtonToDown.Width:=50;
       FButtonToDown.ParentBackground:=false;
       FButtonToDown.ParentColor:=true;
       FButtonToDown.Parent:=self;
       FButtonToDown.BringToFront;
       FButtonToDown.Anchors:= [ akRight, akBottom];
       FButtonToDown.Left:= Width- FButtonToDown.Width - (Scroll.Width*2);
       FButtonToDown.Top:=  Height  - FButtonToDown.Height -  (Scroll.Width);
       FButtonToDown.FBox:=self;
       FButtonToDown.Visible:=false;
      // Scroll.OnMouseMove:=ScrollMouseMove;
end; {
procedure TamChatScrollBoxButtonToDown.ScrollMouseMove(s:Tobject;Shift: TShiftState; X, Y: Integer);
begin
  //FButtonToDown.Visible:=true;
end;}




constructor TamChatButtonToDown.Create(AOwner: TComponent);
begin
     inherited create(AOwner);
     FBitMap:=  TBitMap.Create;
     FTimer:= TTimer.Create(nil);
     FTimer.Enabled:=false;
     FTimer.Interval:=5000;
     FTimer.OnTimer:= TimerNotVisible;
end;
destructor TamChatButtonToDown.Destroy;
begin
    FTimer.Enabled:=false;
    freeAndNil(FTimer);
    freeAndNil(FBitMap);
    inherited;
end;
procedure TamChatButtonToDown.SetVisible(val:boolean);
begin
    if Visible<>val then
    inherited Visible:= val;

    if Visible then
    begin
       FTimer.Enabled:=false;
       FTimer.Enabled:=true;
    end
    else FTimer.Enabled:=false;

end;
procedure TamChatButtonToDown.TimerNotVisible(S:Tobject);
begin
    FTimer.Enabled:=false;
    Visible:=false;

end;
function  TamChatButtonToDown.GetVisible:boolean;
begin
   Result:= inherited Visible;
end;
procedure TamChatButtonToDown.SetCaptions(val:string);
begin
   FCaption:= val;
   Repaint;
end;
procedure TamChatButtonToDown.Paint;
begin
   inherited;
  // Canvas.FillRect(ClientRect);

  if FBitMap<>nil then
  begin

   PaintArrow;
   PaintCaption;
  // Canvas.Draw(0,0,FBitMap);
  end;
end;
procedure TamChatButtonToDown.PaintArrow;
var R:Trect;

    procedure AmoveTo(X,Y:integer);
    begin
      Canvas.moveTo(R.Left+ X ,  R.Top+Y );
    end;
    procedure ALineTo(X,Y:integer);
    begin
       Canvas.LineTo( R.Left+ X , R.Top+Y );
    end;
begin
   R:= self.ClientRect;

   FBitMap.Width:=40;
   FBitMap.Height:=40;

    //with FBitMap do
    begin
   Canvas.Brush.Color := $00372322;
   Canvas.FillRect(Rect(0, 0, Width, Height));
       Canvas.Pen.Color := $00FFEC70;
       Canvas.Pen.Width := 3;
       Canvas.Pen.Style:= psDot;
      // if self.Width=50 then
       begin
          R.Left:=5;
          R.Top:=15;
          R.Right:=5;
          R.Bottom:=5;


          AmoveTo(10,10);
          ALineTo(20,20);
          ALineTo(30,10);



       end;

     end;

end;
procedure TamChatButtonToDown.PaintCaption;
begin
     Canvas.Font.Color := clwhite;
     Canvas.Font.Size:=10;
     Canvas.TextOut(21,7,FCaption);
end;
procedure TamChatButtonToDown.Click;
begin
  inherited;
  if not Assigned(FBox) then exit;

  FBox.Box.BarRange.ScrollTo_StartTimer(false);
end;



          {TamChatScrollBoxOptimus}
constructor TamChatScrollBoxOptimus.Create(AOwner: TComponent);
begin

  inherited create(AOwner);



       FUpSetPosition:=false;




       FScroll:= TamScrollSuper.Create(self);
       FScroll.Kind:= sbVertical;
       FScroll.Parent:=  self;
       FScroll.Align:=alRight;
       FScroll.Width:= 15;
       FScroll.Position:=0;
       FScroll.VerticalScrollRevers:=true;


       Height := 100;
       Width:=100;
       ParentBackground:=false;
       ParentColor:=true;
       BevelKind:=bkNone;
       BevelOuter:=bvnone;
       Caption:='';



       FBox:= TamChatScrollBoxOpt.Create(self);
       FBox.parent:=self;
       FBox.Align:=alClient;
       FBox.BufferedChildren:=true;



       FBox.ParentBackground:=false;
       FBox.ParentColor:=false;
       FBox.BevelKind:=bkNone;
       FBox.BevelOuter:=bvnone;
       FBox.Caption:='';




       FBox.BarRange.OnControlListChangeRange:= ChangeRange;
       FBox.BarRange.OnControlListChangePosition:=ChangePositionBoxBar;
       FScroll.OnChangePosition:= ChangePositionScroll;



       {
       Scroll.ColorBorder:=$008080FF;
       Scroll.ColorArrowDownV:=$006F6151;
       Scroll.ColorArrowUpV:=$006F6151;
       Scroll.ColorScrollThumbV:= $008080FF;
       Scroll.ColorScrollAreaV:= $00503A30;   }




end;


Procedure TamChatScrollBoxOptimus.ChangeRange(S:Tobject;Old,New:integer);
begin
    Scroll.Max:=New ;
    Scroll.Min:= 1;
    Scroll.PageSize:= Box.ClientHeight ;
    DoChangeRange(Old,New);
end;
Procedure TamChatScrollBoxOptimus.DoChangeRange(Old,New:integer);
begin
  //logmain.Log('DoChangeRange');
      if Assigned(FOnChangeRange) then FOnChangeRange(self,Old,New);
end;
Procedure TamChatScrollBoxOptimus.ChangePositionBoxBar(S:Tobject;Old,New:integer);
begin
 if not FUpSetPosition then
 begin
  try
   FUpSetPosition:=true;
   Scroll.Position:= New;
   DoChangePosition(Old,New);
  finally
    FUpSetPosition:=false;
  end;
 end;
end;
Procedure  TamChatScrollBoxOptimus.ChangePositionScroll(S:Tobject;Old,New:integer);
begin
 if not FUpSetPosition then
 begin
  try
   FUpSetPosition:=true;
   FBox.BarRange.ControlListPosition:=  New;
   DoChangePosition(Old,New);
  finally
    FUpSetPosition:=false;
  end;
 end;

end;
Procedure TamChatScrollBoxOptimus.DoChangePosition(Old,New:integer);
begin
 // logmain.Log('DoChangePosition');
    if Assigned(FOnChangePosition) then FOnChangePosition(self,Old,New);
end;



///////////////////////////////////////////////////////////




             {TamChatScrollBoxSavePos}
constructor TamChatScrollBoxSavePos.Create (AOwner:TComponent);
begin
    inherited create(AOwner);
    SavePosEnd;
end;
destructor TamChatScrollBoxSavePos.Destroy;
begin
   SavePosEnd;
   inherited;
end;
procedure TamChatScrollBoxSavePos.Resize;
begin
    inherited Resize;
    if (Width<MaxWidthBlock) and (Width>MinWidthBlock)
    and Assigned(SaveControlAtScroll.Block)
    and Assigned(SaveControlAtScroll.Content)
    and SaveControlAtScroll.Block.CanFocus
    and SaveControlAtScroll.Content.CanFocus then ScrollInViewSavePos(SaveControlAtScroll.Content);

end;
procedure TamChatScrollBoxSavePos.SavePosBegin;
var
i,x,Atop,Atop2,SvIndexI,SvIndexX:integer;
    procedure Local_Save;
    begin
         SaveControlAtScroll.Content:= LMid[i].Controls[x] as TwinControl;
         SaveControlAtScroll.Block:= LMid[i];
         SaveControlAtScroll.Bottom:=  self.ClientHeight - ( Atop+Atop2 );
    end;
begin
       if StateSavePos then  exit;


        for I := Lmid.Count-1 downto 0 do
        begin
           Atop:=  Lmid[i].Top;
           for x := Lmid[i].ControlCount-1 downto 0 do
           begin

               Atop2:= Lmid[i].Controls[x].Top + Lmid[i].Controls[x].Height;

               if (Atop+Atop2<self.ClientHeight) then
               begin
                 Local_Save;
                 break;
               end;
           end;

           if SaveControlAtScroll.Content<>nil then break;


        end;
        if SaveControlAtScroll.Content=nil then
        for I := 0 to Lmid.Count-1 do
        begin
           Atop:=  Lmid[i].Top;
           for x :=  0 to Lmid[i].ControlCount-1 do
           begin

               Atop2:= Lmid[i].Controls[x].Top + Lmid[i].Controls[x].Height;



               if (Atop+ Lmid[i].Controls[x].Top>0) or (Atop+ Atop2>0) then
               begin
                 Local_Save;
                 break;
               end;
           end;

           if SaveControlAtScroll.Content<>nil then break;


        end;

        if SaveControlAtScroll.Content<>nil then
        begin
          StateSavePos:=true;
        end;


end;
procedure TamChatScrollBoxSavePos.SavePosEnd;
begin
      StateSavePos:=false;
      SaveControlAtScroll.Block:=nil;
      SaveControlAtScroll.Content:=nil;
      SaveControlAtScroll.Bottom:=0;
end;
procedure TamChatScrollBoxSavePos.ScrollInViewSavePos(AControl: TControl);
var
  Rect: TRect;
  pos,deltaClient:integer;
begin
  if AControl = nil then Exit;
  Rect := AControl.ClientRect;
//  Dec(Rect.Left, HorzScrollBar.Margin);
//  Inc(Rect.Right, HorzScrollBar.Margin);
  Rect.Left:=0;
  Rect.Right:=0;
  Dec(Rect.Top, 0);
  Inc(Rect.Bottom, 0);
  Rect.TopLeft := ScreenToClient(AControl.ClientToScreen(Rect.TopLeft));
  Rect.BottomRight := ScreenToClient(AControl.ClientToScreen(Rect.BottomRight));



  deltaClient:= ClientHeight - SaveControlAtScroll.Bottom ;
  if Rect.Bottom <> deltaClient then
  begin
    with FVertRangeBar do Position := Position - (Rect.Bottom - deltaClient);
  end;

end;
procedure TamChatScrollBoxSavePos.ScrollInViewToTop(AControl: TControl);
var
  Rect: TRect;
begin
  if AControl = nil then Exit;
  Rect := AControl.ClientRect;
//  Dec(Rect.Left, HorzScrollBar.Margin);
//  Inc(Rect.Right, HorzScrollBar.Margin);
  Rect.Left:=0;
  Rect.Right:=0;
  Dec(Rect.Top, 0);
  Inc(Rect.Bottom, 0);
  Rect.TopLeft := ScreenToClient(AControl.ClientToScreen(Rect.TopLeft));
  Rect.BottomRight := ScreenToClient(AControl.ClientToScreen(Rect.BottomRight));


  if Rect.Top < 0 then
    with FVertRangeBar do Position := Position - Rect.Top
  else if Rect.Bottom > ClientHeight  then
  begin
    if (Rect.Bottom ) - Rect.Top > ClientHeight  then
      Rect.Bottom := Rect.Top + ClientHeight;
    with FVertRangeBar do Position := Position - Rect.Bottom - ClientHeight;
  end;
end;
procedure TamChatScrollBoxSavePos.WMEnterSizeMove(var Message: TMessage); //message WM_ENTERSIZEMOVE;
begin
     inherited;
     SavePosBegin;
   //  logmain.Log('EnterSize пользователь начал тянуть за края формы что бы изменить ее размер');
     // здесь это не работает на форме повесить эти процедуры и вызвать SavePosBegin
end;
procedure TamChatScrollBoxSavePos.WMExitSizeMove(var Message: TMessage); //message WM_EXITSIZEMOVE;
begin
    inherited;
    SavePosEnd;
   //  logmain.Log('ExitSize пользователь закончил тянуть за края формы что бы изменить ее размер');
     // здесь это не работает на форме повесить эти процедуры и вызвать SavePosEnd
end;





/////////////////////////////////////////////////////////////////////


     {TamChatScrollBoxCustom}
constructor TamChatScrollBoxCustom.Create (AOwner:TComponent);
begin
      inherited create(AOwner);
      FTimerControlList:= TTimerControlList.Create(AOwner);
      FTimerControlList.Enabled:=false;
      FTimerControlList.CountErr:=5;
      FTimerControlList.LockExp:=false;
      FTimerControlList.Interval:=20;
      FTimerControlList.DirectionUp:=false;
      FTimerControlList.IfNewBlock:=false;
      FTimerControlList.OnTimer:= ControlList_Timer;

      FReDrawStateLock:=false;
      FReDrawTurnOnInnerLock:=true;
      FCountOfStockInvisiblePixels:=2000;
      SaveWidth:=0;
      SaveHeight:=0;
      FVertRangeBar := TamChatScrollRange.Create(Self);
      Lmid:= TList<TWincontrol>.create;

      LBot:=  THelpList.create;
      LBot.List:= TList<TWincontrol>.create;
      LBot.SaveHeight:=0;

      LTop:=  THelpList.create;
      LTop.List:=  TList<TWincontrol>.create;
      LTop.SaveHeight:=0;

      MaxWidthBlock:=500;
      MinWidthBlock:=200;

      ParentBackground:=false;
      ParentColor:=false;
      Align:=alTop;
      Color:= $004B3029;
      self.Height:=350;
      self.BevelOuter:=bvNone;
   //   self.BorderStyle:=bsNone;

end;
destructor TamChatScrollBoxCustom.Destroy;
begin
   FTimerControlList.Enabled:=false;
   LBot.List.Free;
   LBot.Free;

   LTop.List.Free;
   LTop.Free;

   Lmid.Free;
   FreeAndNil(FVertRangeBar);
   inherited;
end;
procedure TamChatScrollBoxCustom.Refresh;
var
  I: Integer;
begin
 for I := 0 to Lmid.Count-1 do
    Lmid[i].Realign;
  inherited  Refresh;
end;
procedure TamChatScrollBoxCustom.RefreshControl(Control:TWincontrol);
var Rect:TRect;
begin
   Rect:= ClientRect;
   AlignControls(Control, Rect);
end;
procedure TamChatScrollBoxCustom.ClearScrollBox;
begin
    FTimerControlList.Enabled:=false;
    FTimerControlList.LockExp:=true;
    BarRange.FTimerChangePosition.Enabled:=false;
    BarRange.FScrollTo_Timer.Enabled:=false;
    BarRange.FScrollTo_Timer_Lock:=true;
    BarRange.FScrollTo_DivisorProcessing:=true;
    BarRange.FScrollTo_Lock:=true;

    try
        ControlList_Clear;
    finally
      FTimerControlList.LockExp:=false;
      BarRange.FScrollTo_Timer_Lock:=false;
      BarRange.FScrollTo_DivisorProcessing:=false;
      BarRange.FScrollTo_Lock:=false;
    end;


end;
procedure TamChatScrollBoxCustom.ControlList_Clear;
var i:integer;
begin
       Ltop.SaveHeight:=0;
       Lbot.SaveHeight:=0;
       for I := Ltop.List.Count-1 downto 0  do Ltop.List[i].Free;
       for I := Lmid.Count-1 downto 0  do Lmid[i].Free;
       for I := Lbot.List.Count-1 downto 0  do Lbot.List[i].Free;
       Ltop.List.Clear;
       Lmid.Clear;
       Lbot.List.Clear;
end;

procedure TamChatScrollBoxCustom.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
//  showmessage('CMVisibleChanged');
  if Visible then   Refresh;
 //   UpdateScrollBars;
end;
procedure TamChatScrollBoxCustom.CMShowingChanged(var Message: TMessage);
begin
    inherited;
    PostMEssage(Self.Handle,AM_CHANGE_SHOW,0,0);


  

end;
procedure TamChatScrollBoxCustom.AMShow(var Message: TMessage); //message AM_CHANGE_SHOW;
begin
    inherited;
   if self.CanFocus then  Refresh;

end;


procedure TamChatScrollBoxCustom.ScrollByChat(DeltaX, DeltaY: Integer);
var
  IsVisible: Boolean;
  I: Integer;
  Control: TControl;
begin

  IsVisible := (Handle <> 0) and IsWindowVisible(Handle);
  if IsVisible then
  if ScrollWindow(Handle, DeltaX, -DeltaY, nil, nil) then
  begin
   //  MaxTop:=  MaxTop+DeltaY;
  end;

 // Realign;
end;

procedure TamChatScrollBoxCustom.ControlList_Add(Control:TWincontrol;Up:boolean);
var
  Rect: TRect;

begin



   if Control.Align<>alNone then Control.Align:= alNone;
   if Control.Height<0 then  Control.Height:=0;

   if FReDrawTurnOnInnerLock then   ReDrawLock;
   try
       ResizeBlock(Control);
       Control.Parent:= self;


  //
       if Up then
       begin
         Control.Top:= MinTop-Control.Height;
         Lmid.Insert(0,Control);
       end
       else
       begin

          if Lmid.Count=0 then Control.Top:= MaxTop - Control.Height
          else Control.Top:= MaxTop;
          Lmid.Add(Control);

       end;
   finally
    if FReDrawTurnOnInnerLock then ReDrawUnLock;
   end;
   Rect:= ClientRect;
   AlignControls(Control, Rect);






end;
procedure TamChatScrollBoxCustom.AddControl(Control:TWincontrol;Up:boolean);
 var  SvPos:integer;
begin

   SvPos:=  BarRange.Position;
   ControlList_Add(Control,Up);


  // сместить позицию в самый низ если до добавляния была в самом низу
  if       not up  and (SvPos<10) and  (BarRange.Position>0) then    BarRange.Position:=0
  else ControlList_NeedCheck(not up,true);
end;
procedure TamChatScrollBoxCustom.ControlListCheck2(IfNewControl:boolean);
begin
       ControlList_NeedCheck(true,IfNewControl);
       ControlList_NeedCheck(False,IfNewControl);
end;
procedure  TamChatScrollBoxCustom.ControlList_TimerStart(DirectionUp,IfNewBlock:boolean);
begin
    if (FTimerControlList.DirectionUp<>DirectionUp) or (IfNewBlock<>FTimerControlList.IfNewBlock) then
    begin
      FTimerControlList.Enabled:=false;
      FTimerControlList.LockExp:=false;
    end;

    if FTimerControlList.LockExp then exit;
    FTimerControlList.DirectionUp:= DirectionUp;
    FTimerControlList.IfNewBlock:=  IfNewBlock;
    FTimerControlList.IErr:=0;
    FTimerControlList.Interval:=20;
    FTimerControlList.LockExp:=true;
    FTimerControlList.Enabled:=true;

end;
procedure TamChatScrollBoxCustom.ControlList_Timer(S:Tobject);
var R:boolean;
begin
  //logmain.Log('ControlList_Timer');
  R:=false;
  FTimerControlList.Enabled:=R;
 try
  R:= ControlList_NeedCheck(FTimerControlList.DirectionUp,FTimerControlList.IfNewBlock);
 finally

   //if  not R then R:=    (Lmid.Count >  FTimerControlList.CountErr)
   if not R then inc(FTimerControlList.IErr);

   if  FTimerControlList.IErr>20 then R:=false;
   FTimerControlList.Enabled:=R;
   FTimerControlList.LockExp:=R;

 end;
end;
procedure TamChatScrollBoxCustom.ScrollByRangeBar(DeltaX, DeltaY: Integer);
begin
    ScrollByChat(DeltaX,DeltaY);
    ControlList_TimerStart(DeltaY<=0,false);




     //   ScrollByChat(DeltaX,DeltaY);
       // Application.ProcessMessages;
      //  if DeltaY=0 then exit;

     //
       // ControlList_NeedCheck(DeltaY<0,false);
       // Application.ProcessMessages;
       // delay(20);

end;
function TamChatScrollBoxCustom.ControlList_NeedCheck(DirectionUp:boolean;IfNewBlock:boolean):boolean;
var AbsTop,AbsHeight:integer;
R1,R2,R3,R4:boolean;
ContrSizeInt,Stock,ClientH:integer;
begin

      Result:=false;
      R1:=false;
      R2:=false;
      R3:=false;
      R4:=false;
      if (LMid.Count=0) and (Ltop.List.Count=0) and (Lbot.List.Count=0) then exit;
      // написать что бы при большом изменении позиции скрола подгружались верные сообщения
      // есть идея сделать через цикл пока будет возвращатся true перебирать и перекидывать с листа в лист блоки
     //exit;

      ContrSizeInt:= 32767 - 5000;
      Stock:=FCountOfStockInvisiblePixels;
      Stock:=440;
      ClientH:= self.ClientHeight;

          if not DirectionUp then  // если скролим вниз
          begin

              // проверка что сверху нужно скрыть контент
              if LMid.Count>=2 then
              begin
                 AbsTop:=     Lmid[0].Top;
                 AbsHeight:=  Lmid[0].Height;


                 if (   AbsTop+AbsHeight < -   Stock  )
                 or (   AbsTop           < -   ContrSizeInt      )
                 then   R1:=ControlList_HideContent(0,Lmid[0],true,IfNewBlock)
                // else if AbsTop>0 then  showmessage('первый топ больше 0 при скрытии');


              end;



               // проверка что снизу нужно показать контент
               if (LMid.Count>0) then
               begin
                 AbsTop:=     Lmid[Lmid.Count-1].Top;
                 AbsHeight:=  Lmid[Lmid.Count-1].Height;
               end
               else
               begin
                 AbsTop:= 1;
                 AbsHeight:=1;
               end;
               if (AbsTop+AbsHeight < Stock + ClientH) {or (LMid.Count<=3)} then
               R2:=ControlList_ShowContent(false)







          end
          else  // если скролим вверх
          begin


              // проверка что снизу нужно скрыть контент
             {  if LMid.Count>=3 then
               begin
                 AbsTop:= (Lmid[Lmid.Count-1].Top);
                 if AbsTop>=0 then
                 begin
                  if AbsTop<>0 then
                  AbsTop:= Abs(AbsTop);
                  if AbsTop>FCountOfStockInvisiblePixels then
                  R3:=ControlList_HideContent(Lmid.Count-1,Lmid[Lmid.Count-1],false,IfNewBlock);
                 end;
               end;}

               // проверка что снизу нужно скрыть контент
              if LMid.Count>=2 then
              begin
                 AbsTop:=     Lmid[Lmid.Count-1].Top;
                 AbsHeight:=  Lmid[Lmid.Count-1].Height;


                 if (   AbsTop               >   Stock + ClientH  )
                 or (   AbsTop +AbsHeight    >   ContrSizeInt      )
                 then   R3:=ControlList_HideContent(Lmid.Count-1,Lmid[Lmid.Count-1],false,IfNewBlock)
               //  else if AbsTop>0 then  showmessage('первый топ больше 0 при скрытии');


              end;


                // проверка что сверху нужно показать контент
               {if (LMid.Count>0) then  AbsTop:= (Lmid[0].Top)
               else                    AbsTop:= -1;
               AbsTop:= Abs(AbsTop);
               if (AbsTop<FCountOfStockInvisiblePixels) or (LMid.Count<=3) then
               R4:=ControlList_ShowContent(true);
                }



               // проверка что сверху нужно показать контент
               if (LMid.Count>0) then
               begin
                  AbsTop:=     Lmid[0].Top;
                  AbsHeight:=  Lmid[0].Height;
               end
               else
               begin
                AbsTop:= 1;
                AbsHeight:=1;
               end;

               if (   AbsTop+AbsHeight > - Stock  )
               then  R4:=ControlList_ShowContent(true)

          end;

      Result:=  R1 or R2 or R3 or R4;



end;
function TamChatScrollBoxCustom.ControlList_ShowContent(ToListTop:boolean):boolean;
var HelpList:THelpList;
    AControl:TWinControl;
    Index:integer;
begin
      Result:=false;

     if ToListTop then
     begin
       HelpList:=LTop;
       Index:= HelpList.List.Count-1;
     end
     else
     begin
         HelpList:=LBot;
         Index:=HelpList.List.Count-1;
     end;

     if HelpList.List.Count=0 then
     begin
        HelpList.SaveHeight:=0;
        exit;
     end;



     AControl:= HelpList.List[Index];
     HelpList.List.Delete(Index);
     HelpList.SaveHeight:= HelpList.SaveHeight -  AControl.Height;


     ControlList_Add(AControl,ToListTop);
     Result:=true;

end;
function TamChatScrollBoxCustom.ControlList_HideContent(Index:integer;AControl:TWinControl;ToListTop:boolean;IfNewBlock:boolean):boolean;
var HelpList:THelpList;
begin
      Result:=false;
     if ToListTop then HelpList:=LTop
     else   HelpList:=LBot;

     HelpList.SaveHeight:=  HelpList.SaveHeight +  AControl.Height;
     Lmid.Delete(Index);

     if IfNewBlock
     then  HelpList.List.Insert(0,AControl)
     else  HelpList.List.Add(AControl);

     ReDrawLock;
     try
       AControl.Parent:= nil;
     finally
       ReDrawUnLock
     end;
     CalcAutoRange();
     Result:=true;
    // AControl.Parent:=nil;



end;
procedure  TamChatScrollBoxCustom.ControlList_ScrollTo(Up:boolean);
begin
      if (LMid.Count=0) and (Ltop.List.Count=0) and (Lbot.List.Count=0) then exit;


end;


function TamChatScrollBoxCustom.GetMaxTop:integer;
begin
   Result:=0;
   if Lmid.Count>0 then Result:=  Lmid[Lmid.Count-1].Top+ Lmid[Lmid.Count-1].Height
   else Result:= self.ClientHeight;
end;
function TamChatScrollBoxCustom.GetMinTop:integer;
begin
   if Lmid.Count>0 then  Result:=  Lmid[0].Top
   else  Result:= self.ClientHeight;
end;
procedure TamChatScrollBoxCustom.SetCountOfStockInvisiblePixels(val:integer);
begin
   if (val>=500) and (val<=10000) then FCountOfStockInvisiblePixels:=val
   else raise Exception.Create('TamChatScrollBoxCustom.SetCountOfStockInvisiblePixels val>500 and val<10000');

end;
procedure TamChatScrollBoxCustom.WMSize(var Message: TWMSize); //message WM_SIZE;
begin

   // logmain.Log('WMSize '+self.Width.ToString+ ' '+inttostr(SaveWidth));

    inherited ;


end;

procedure TamChatScrollBoxCustom.AlignControls(AControl: TControl; var ARect: TRect);
var i,X:integer;
atop:integer;
AWinControl:TWinControl;
NewAutoH:integer;

begin
   // вызывается автоматически классом Twincontrol когда какое было изменение в дочерних елементах TamChatScrollBoxOpt
   if AControl=nil then exit;
   if AControl is TwinControl then
   AWinControl:= TwinControl(AControl)
   else  exit;

 // inherited AlignControls(AControl, ARect); это не используется по свойму делается

       // Autosize; если у дочерних контролов Autosize=true
       if true then
       begin
        NewAutoH:=0;
        for I :=  AWinControl.ControlCount-1 downto 0 do
        begin
            (AWinControl.Controls[i] as TWinControl).Realign;
            inc(NewAutoH,AWinControl.Controls[i].Height);
            if AWinControl.Controls[i].AlignWithMargins then
            begin
               inc(NewAutoH,AWinControl.Controls[i].Margins.Top);
               inc(NewAutoH,AWinControl.Controls[i].Margins.Bottom);
            end;


        end;
        AWinControl.Height:= NewAutoH;
       // AWinControl.a
       end;




 X:= Lmid.IndexOf(AWinControl);
 if X>=0 then  // если контрола нет тогда и нечего выравнивать если есть и X>=0  значит index 0 есть и   index ListClient.Count-1 есть
 begin

     // изменение top  что бы контолы были прижаты друг к другу как alTop or albottom
     // больше похоже на albottom
     // нужно для тогда что бы когда Child изменяет свою высоту остальные об этом узнали и выровлянись


    // atop:= ListClient[0].Top;
    // aH:=   ListClient[0].Height;

    // if (atop>0) and   then



     atop:= Lmid[Lmid.Count-1].Top;
     //aH:=   ListClient[ListClient.Count-1].Height;



     for I := Lmid.Count-2 downto 0 do
     begin
        Lmid[i].Top :=  atop - Lmid[i].Height;
        atop:= Lmid[i].Top;
     end;



     CalcAutoRange();
 end;


 // измерение range скрола + коррекция позиции что бы не выбегала за рамки  range






end;
procedure TamChatScrollBoxCustom.CalcAutoRange();
var RangeOld,RangePageOld:integer;
Hbottom,Htop:integer;
EdiScr:boolean;
begin
  RangeOld:=  FVertRangeBar.Range;
  RangePageOld:=  FVertRangeBar.FCalcRange;
  FVertRangeBar.CalcAutoRange;
  if  (Lmid.Count=0)  then exit;


  // позиция нижнени части последнего контола минус ClientHeight дает представление что делать с позицией
  Hbottom:=   Lmid[Lmid.Count-1].Top   + Lmid[Lmid.Count-1].Height - ClientHeight;

  if  (FVertRangeBar.Range>RangeOld)  then // Range стал больше
  begin

    Htop:= Lmid[0].Top;
    if FVertRangeBar.CalcPageRange <=0  then
    begin
        // если условие true значит позиция = 0  т.е в самом низу а в самом верху позиция = FVertRangeBar.CalcPageRange
        // это просто наоборот в сравнении с обычным TscrollBox

        if Hbottom>0 then //если true значит надо подскролить немного что бы прилип к низу последний контрол
        ScrollByChat(0,  Hbottom );
        FVertRangeBar.FPosition:=0;
    end
   // else if Htop>0 and  then
         
    else   FVertRangeBar.FPosition :=   Hbottom;



  end
  else if (FVertRangeBar.Range<RangeOld) then  // Range стал меньще
  begin




   //   logmain.Log('<'+hb.ToString +' R='+FVertRangeBar.CalcPageRange.ToString);

        EdiScr:=false;
        if Hbottom<0 then
        begin
           // нижний контрол должен прилипнуть к низу а позиция = 0;
           ScrollByChat(0,  Hbottom );
            FVertRangeBar.FPosition:=0;
           // logmain.Log('< hb =0');
            EdiScr:=true;
        end;

        Htop:= Lmid[0].Top;

        if not ediscr and (Htop>=0)   then
        begin
           // верхний контрол должен прилипнуть к верху а позиция = FVertRangeBar.CalcPageRange;
           if (Htop>0) then
           ScrollByChat(0,  Htop );
           FVertRangeBar.FPosition:=FVertRangeBar.CalcPageRange;
           EdiScr:=true;
        end;

        if not ediscr then // иначе по нижнему элементу определяем позицию
        FVertRangeBar.FPosition:=Hbottom;


  end
  else
  begin
    if (FVertRangeBar.FCalcRange<=0) or (Hbottom<0) then
    begin
        if Hbottom<>0 then        
        ScrollByChat(0,  Hbottom );
        FVertRangeBar.FPosition:=0;
    end
    else
     FVertRangeBar.FPosition:=Hbottom;

  end;



 // RangePageOld:=  FVertRangeBar.FCalcRange;



end;
procedure TamChatScrollBoxCustom.Resize;
var i:integer;
begin
       if SaveHeight<>Height then
       begin
         //logmain.Log('WMSize '+self.Height.ToString+ ' '+inttostr(SaveHeight));
         CalcAutoRange();
         SaveHeight:= self.Height;
       end;
       if SaveWidth<>Width then
       begin
         for I := 0 to  Lmid.Count-1 do ResizeBlock(Lmid[i]);
         SaveWidth:= self.Width;
       end;
       ControlListCheck2(false);
       inherited Resize;
end;
procedure TamChatScrollBoxCustom.ResizeBlock(ItemClient:TWincontrol);
begin
      if      (Width<MaxWidthBlock) and (Width>MinWidthBlock) then    ItemClient.Width:=  Width
      else if (Width>MaxWidthBlock)                           then    ItemClient.Width:=  MaxWidthBlock
      else if (Width<MinWidthBlock)                           then    ItemClient.Width:=  MinWidthBlock
end;

Procedure TamChatScrollBoxCustom.ReDrawLockUser;
begin
   ReDrawLock;
end;
Procedure TamChatScrollBoxCustom.ReDrawUnLockUser;
begin
   ReDrawUnLock;
   SaveHeight:=0;
   SaveWidth:=0;
   CalcAutoRange;
   FVertRangeBar.Position:=0;
   //postmessage(self.Handle,wm_size,0,0);

end;
Procedure TamChatScrollBoxCustom.ReDrawLock;
begin
//exit;
   if not FReDrawStateLock then  FReDrawStateLock:=true
   else exit;
   Perform( WM_SETREDRAW, 0, 0 );
end;
Procedure TamChatScrollBoxCustom.ReDrawUnLock;
begin
 //exit;
   if FReDrawStateLock then
   begin
     Perform( WM_SETREDRAW, 1, 0 );
     RedrawWindow( Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN );
     FReDrawStateLock:=false;
   end;

end;
Function  TamChatScrollBoxCustom.ReDrawStateLock:boolean;
begin
   Result:=FReDrawStateLock;
end;


               {TamChatScrollRange}

constructor TamChatScrollRange.Create(AControl: TamChatScrollBoxCustom);
begin
  inherited Create;

  FTimerChangePosition:= TTimerEvent.Create(nil);
  FTimerChangePosition.Enabled:=false;
  FTimerChangePosition.Interval:=100;
  FTimerChangePosition.SaveOldPosition:=0;
  FTimerChangePosition.OnTimer:=  TimerPositionEvent;
  FControl := AControl;


  FScrollTo_Timer := TTimer.Create(nil);
  FScrollTo_Timer.Enabled:=false;
  FScrollTo_Timer.Interval:=20;
  FScrollTo_Timer.OnTimer:=  ScrollTo_Timer;
  FScrollTo_Timer_Up:=false;
  FScrollTo_Timer_Lock:=false;
  FScrollTo_OnMin :=nil;
  FScrollTo_OnMax :=nil;
  FScrollTo_OnDivisor:=nil;

  FScrollTo_CorrectMinMax:=0;
  FScrollTo_DivisorMax:= 5;
  FScrollTo_DivisorProcessing:=false;
  FScrollTo_Lock:=false;



  FPos:=0;
  FRange:=0;
  FCalcRange:=0;
  FUpdateNeeded:=false;
  FUpSetPosition:=false;
  FControlListPos:=0;
  FControlListPosOld:=0;
end;
destructor TamChatScrollRange.Destroy;
begin
   FTimerChangePosition.Enabled:=false;
   FScrollTo_Timer.Enabled:=false;
   FreeAndNil(FTimerChangePosition);
   FreeAndNil(FScrollTo_Timer);
   inherited;
end;
procedure TamChatScrollRange.ScrollTo_StartTimer(Up:boolean);
begin
   if FScrollTo_Timer_Up<>Up then
   begin
     FScrollTo_Timer.Enabled:=false;
     FScrollTo_Timer_Lock:=false;
   end;
   if FScrollTo_Timer_Lock then exit;

   FScrollTo_Timer_Up:= Up;
   FScrollTo_Timer_Lock:=true;
   FScrollTo_Timer.Enabled:=true;



end;
procedure   TamChatScrollRange.ScrollTo_Timer(S:Tobject);
var R:boolean;
begin
 R:=false;
 FScrollTo_Timer.Enabled:=false;
 try
   if FScrollTo_Timer_Up then
   begin
      Position:=  Position +   FControl.ClientHeight ;
      R:=ControlListPosition <  ControlListCalcPageRange - FScrollTo_CorrectMinMax;
   end
   else
   begin
     Position:=  Position -  ( FControl.ClientHeight ) ;
     R:= ControlListPosition > FScrollTo_CorrectMinMax;
   end;
 finally
    if  ScrollTo_Lock then  R:=false;
    FScrollTo_Timer.Enabled:=R;
    FScrollTo_Timer_Lock:=R;
 end;
end;

procedure   TamChatScrollRange.DoScrollTo_OnMax;
begin
   //showmessage('DoScrollTo_OnMaxPost');
   if Assigned(FScrollTo_OnMax) then
   PostMessage(self.Handle, SCROLL_ONMAX ,0,0);
end;
procedure   TamChatScrollRange.DoScrollTo_OnMaxPost(Var Msg:TMessage);// message SCROLL_ONMAX;
begin

   if Assigned(FScrollTo_OnMax) then FScrollTo_OnMax(FControl);
end;
procedure   TamChatScrollRange.DoScrollTo_OnMin;
begin
 //  showmessage('DoScrollTo_OnMinPost');
   if Assigned(FScrollTo_OnMin) then
    PostMessage(self.Handle, SCROLL_ONMIN ,0,0);
end;
procedure   TamChatScrollRange.DoScrollTo_OnMinPost(Var Msg:TMessage);// message SCROLL_ONMIN;
begin

   if Assigned(FScrollTo_OnMin) then FScrollTo_OnMin(FControl);
end;
procedure   TamChatScrollRange.DoScrollTo_OnDivisor(old,new:integer);
var RangeVert:integer;
ExportedDivisor:boolean;
EventPos:Integer;
begin
   //что бы получить блок старых сообщений при прокрутке скрола подключимся к событию  FScrollTo_OnDivisor
   // отправляем postMessage самому себе что бы овободить этот поток процедур


    if  FScrollTo_DivisorProcessing   then exit;
    if FControl is TamChatScrollBoxSavePos and (FControl as  TamChatScrollBoxSavePos).StateSavePos then exit;
    
    ExportedDivisor:=false;

    if new>old then
    ExportedDivisor:= (FScrollTo_DivisorMax >0)
    and  ( ControlListPosition >= ControlListCalcPageRange  -  (ControlListCalcPageRange div FScrollTo_DivisorMax));

    FScrollTo_DivisorProcessing:= ExportedDivisor; // что бы не получать тысячи старых блоков а только 1 блок скажем по 40 msg
    if FScrollTo_DivisorProcessing then PostMessage(self.Handle,SCROLL_ONDIVIZOR,0,0);

end;
procedure   TamChatScrollRange.DoScrollTo_OnDivisorPost(Var Msg:TMessage); //message SCROLL_ONDIVIZOR;
begin
  try

   if Assigned(FScrollTo_OnDivisor) then
   begin
      FScrollTo_OnDivisor(FControl);

   end;
  finally  FScrollTo_DivisorProcessing:=false; end;
end;



procedure   TamChatScrollRange.DoChangePosition(Old:integer);
begin
    if Assigned(FChangePosition) then
    begin
       //if FTimerChangePosition.Enabled then  FTimerChangePosition.Enabled:=false
       //else
        FTimerChangePosition.SaveOldPosition:= Old;
       // FTimerChangePosition.Enabled:=true;

        TimerPositionEvent(self);
    end;
end;
procedure  TamChatScrollRange.DoControlListChangePosition(Old:integer;New:Integer);
begin


   if (Old>New) and (New <=   FScrollTo_CorrectMinMax) then DoScrollTo_OnMin()
   else if (Old<New) and ( New >=  ControlListCalcPageRange - FScrollTo_CorrectMinMax) then DoScrollTo_OnMax();
   if Assigned(FControlListChangePosition) then  FControlListChangePosition(self,Old,New);


end;
procedure   TamChatScrollRange.TimerPositionEvent(S:Tobject);
var  OldPos: Integer;
     NewPos: Integer;
begin
    FTimerChangePosition.Enabled:=False;
 //   if  FUpSetPosition then  exit;
    //exit;
   if Assigned(FChangePosition) then
   begin

    // FUpSetPosition:=true;
     try
         OldPos:= FTimerChangePosition.SaveOldPosition;
         NewPos:= Position;
         FChangePosition(self,OldPos,NewPos);
     finally
       //FUpSetPosition:=false;
     end;
   end;
            //FReversPosition OldPos:= CalcPageRange-OldPos;
            //NewPos:= CalcPageRange-NewPos;

end;
procedure  TamChatScrollRange.CalcAutoRange;
var
  I, //NewRange,
  //AlignMargin,
  NewRange2: Integer;
begin
      NewRange2:=0;
      for I := 0 to FControl.Lmid.Count - 1 do
      inc(NewRange2,FControl.Lmid[i].Height);


     DoSetRange(NewRange2 { + AlignMargin + Margin});
end;


procedure   TamChatScrollRange.SetPos(Value: Integer);
begin
    FPos:=  Value;


    if not FUpSetPosition then
    begin
     FUpSetPosition:=true;
      try
          FControlListPosOld:=FControlListPos;
          FControlListPos:=  FControl.Lbot.SaveHeight +FPos ;
        DoControlListChangePosition(FControlListPosOld,FControlListPos);
      finally
         FUpSetPosition:=false;
      end;
    end;



end;

procedure   TamChatScrollRange.SetControlListPosition(Value: Integer);
begin
   SetPosition(  Value-FControl.Lbot.SaveHeight );
end;

procedure TamChatScrollRange.SetPosition(Value: Integer);
var
  Form: TCustomForm;
  OldPos: Integer;
begin
    if  FUpSetPosition then  exit;
    if  ScrollTo_Lock then  exit;

    FUpSetPosition:=true;
    try
      if csReading in FControl.ComponentState then
        FPos := Value
      else
      begin


        if Value > FCalcRange then   Value := FCalcRange
        else if Value < 0 then   Value := 0;
        if Value <> FPosition then
        begin
          OldPos := FPosition;
          FPosition := Value;

          FControl.ScrollByRangeBar(0, OldPos - Value);
          DoChangePosition(OldPos);

          FControlListPosOld:=FControlListPos;
          FControlListPos:=  FControl.Lbot.SaveHeight +FPos ;
          DoControlListChangePosition(FControlListPosOld,FControlListPos);
           DoScrollTo_OnDivisor(FControlListPosOld,FControlListPos);


          if csDesigning in FControl.ComponentState then
          begin
            Form := GetParentForm(FControl, False);
            if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
          end;
        end;
      end;
    finally
      FUpSetPosition:=false;
    end;
end;

procedure TamChatScrollRange.DoSetRange(Value: Integer);
var F,Old,CLOld,CLNew:integer;
begin

       if Value < 0 then Value := 0;
      //if (FRange<>Value) then



      CLOld:= FControlListRange;
      CLNew:=Value;

      inc(CLNew,FControl.Ltop.SaveHeight);
      inc(CLNew,FControl.Lbot.SaveHeight);
      if CLNew < 0 then CLNew := 0;
      FControlListRange:= CLNew;


      Old:=Frange;
      FRange := Value;


      F := FRange - FControl.ClientHeight;
      if F <= 0 then F := 0;
     // else if FCalcRange=0 then   FPosition:=F;
      FCalcRange:= F;

      F := FControlListRange - FControl.ClientHeight;
      if F <= 0 then F := 0;
      FControlListCalcPageRange:= F;


      if     Assigned(FChangeRange) then FChangeRange(self,Old,Value);
      if     Assigned(FControlListChangeRange) then
      FControlListChangeRange(self,CLOld,CLNew);

end;

procedure TamChatScrollRange.SetRange(Value: Integer);
begin
  //FScaled := True;
  DoSetRange(Value);
end;


end.
