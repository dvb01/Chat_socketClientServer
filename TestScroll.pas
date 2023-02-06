unit TestScroll;

interface
uses

  System.Messaging,
  Winapi.Messages, Winapi.Windows, System.SysUtils, System.Classes,
   Vcl.Graphics,  Vcl.Controls,
 Vcl.Themes,Vcl.Dialogs,AmLogTo,
  Vcl.Forms;






{ TamWinControlVertScroll переделанный компонент TScrollingWinControl
  удален сам визуальный  вертикальный скрол
  удален горизонтальный скролу
  удалены лишные методы и функции
  можно крутить мышкой если менять VertScrollBar.Position

}
type
  TamWinControlVertScroll = class(TWinControl)
   type
      {TScrollPosSave это старый TControlScrollBar
       ныняшняя задача класса просто считать Range хранить FPosition и выполнять сам сколл scrollby

      }
       TScrollPosSave = class(TPersistent)
        private
          FControl: TamWinControlVertScroll;
          FPosition: Integer;
          FRange: Integer;
          FCalcRange: Integer;
          FUpdateNeeded: Boolean;
          constructor Create(AControl: TamWinControlVertScroll);
          procedure   CalcAutoRange;
          function    ControlSize(): Integer;
          procedure   DoSetRange(Value: Integer);
          procedure   SetPosition(Value: Integer);
          procedure   SetRange(Value: Integer);
          procedure   Update();
        protected
        public
        published
          property Position: Integer read FPosition write SetPosition default 0;
          property Range: Integer read FRange write SetRange default 0;
        end;
  private
    FAutoRangeCount: Integer;
    FUpdatingScrollBars: Boolean;
    FVertScrollBar: TScrollPosSave;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    function AutoScrollEnabled: Boolean; virtual;
    procedure AutoScrollInView(AControl: TControl); virtual;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CreateWnd; override;
    procedure SendChangeScaleMessage(M, D: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DisableAutoRange;
    procedure EnableAutoRange;
    procedure ScrollInView(AControl: TControl);
     procedure UpdateScrollBars;
     procedure CalcAutoRange;
  published
    property OnAlignInsertBefore;
    property OnAlignPosition;
    property VertScrollBar: TScrollPosSave read FVertScrollBar ;
  end;



{ TamScrollBoxNoVisableScroll  без самого windows скрола скрол только мышкой или VertScrollBar.Position }
  TamScrollBoxNoVisableScroll = class(TamWinControlVertScroll)
  private
    FBorderStyle: TBorderStyle;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
  protected
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;

    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Constraints;
    property DockSite;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Color nodefault;
    property Ctl3D;
    property Font;
    property Padding;
    property ParentBiDiMode;
    property ParentBackground default False;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Touch;
    property Visible;
    property StyleElements;
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

implementation
 uses

  System.Math, Winapi.CommCtrl;


{ TamWinControlVertScroll.TScrollPosSave }

constructor TamWinControlVertScroll.TScrollPosSave.Create(AControl: TamWinControlVertScroll);
begin
  inherited Create;
  FControl := AControl;
  FUpdateNeeded := True;
end;
procedure  TamWinControlVertScroll.TScrollPosSave.CalcAutoRange;
var
  I, NewRange, AlignMargin: Integer;

  procedure ProcessVert(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alTop, alNone:
          if (Control.Align = alTop) or (Control.Anchors * [akTop, akBottom] = [akTop]) then
            NewRange := Max(NewRange, Position + Control.Top + Control.Height);
        alBottom: Inc(AlignMargin, Control.Height);
      end;
  end;

begin


    if FControl.AutoScrollEnabled then
    begin

      NewRange := 0;
      AlignMargin := 0;
      for I := 0 to FControl.ControlCount - 1 do
          ProcessVert(FControl.Controls[I]);


      DoSetRange(NewRange + AlignMargin{ + Margin});
    end
    else DoSetRange(0);

end;
function TamWinControlVertScroll.TScrollPosSave.ControlSize(): Integer;
begin
    Result := FControl.ClientHeight ;//+ Adjustment(SB_HORZ, SM_CXHSCROLL)
end;
procedure TamWinControlVertScroll.TScrollPosSave.SetPosition(Value: Integer);
var
  Form: TCustomForm;
  OldPos: Integer;
begin
   logmain.Log('SetPosition');
  if csReading in FControl.ComponentState then
    FPosition := Value
  else
  begin
    if Value > FCalcRange then Value := FCalcRange
    else if Value < 0 then Value := 0;
    if Value <> FPosition then
    begin
      OldPos := FPosition;
      FPosition := Value;
      FControl.ScrollBy(0, OldPos - Value);


      if csDesigning in FControl.ComponentState then
      begin
        Form := GetParentForm(FControl, False);
        if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
      end;
    end;
  end;
end;
procedure TamWinControlVertScroll.TScrollPosSave.DoSetRange(Value: Integer);
begin
  FRange := Value;
  if FRange < 0 then FRange := 0;
    logmain.Log('DoSetRange'+Value.ToString);
  FControl.UpdateScrollBars;
end;

procedure TamWinControlVertScroll.TScrollPosSave.SetRange(Value: Integer);
begin
  //FScaled := True;
  DoSetRange(Value);
end;
procedure TamWinControlVertScroll.TScrollPosSave.Update();
begin
    FCalcRange := Range - ControlSize();
    if FCalcRange < 0 then FCalcRange := 0;
end;



{ TamWinControlVertScroll }

constructor TamWinControlVertScroll.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNeedsBorderPaint];
  //FHorzScrollBar := TControlScrollBar2.Create(Self, sbHorizontal);
  FVertScrollBar := TScrollPosSave.Create(Self);
  //FAutoScroll := False;
 // Touch.InteractiveGestures := [igPan, igPressAndTap];
 //Touch.InteractiveGestureOptions := [igoPanInertia,
  //  igoPanSingleFingerHorizontal, igoPanSingleFingerVertical,
   // igoParentPassthrough];
end;

destructor TamWinControlVertScroll.Destroy;
begin
 // FreeAndNil(FHorzScrollBar);
  FreeAndNil(FVertScrollBar);
  inherited Destroy;
end;


//[UIPermission(SecurityAction.LinkDemand, Window=UIPermissionWindow.AllWindows)]
procedure TamWinControlVertScroll.CreateWnd;
begin
  inherited CreateWnd;
{$IF NOT DEFINED(CLR)}
  //! Scroll bars don't move to the Left side of a TScrollingWinControl when the
  //! WS_EX_LEFTSCROLLBAR flag is set and InitializeFlatSB is called.
  //! A call to UnInitializeFlatSB does nothing.
  if not SysLocale.MiddleEast and
     not CheckWin32Version(5, 1) then
    InitializeFlatSB(Handle);
{$ENDIF}
  UpdateScrollBars;
end;

procedure TamWinControlVertScroll.AlignControls(AControl: TControl; var ARect: TRect);
begin
logmain.Log('AlignControls');
  CalcAutoRange;
  inherited AlignControls(AControl, ARect);

end;

function TamWinControlVertScroll.AutoScrollEnabled: Boolean;
begin
  Result := not AutoSize and not (DockSite and UseDockManager);
end;


procedure TamWinControlVertScroll.CalcAutoRange;
begin
  if FAutoRangeCount <= 0 then
  begin
    VertScrollBar.CalcAutoRange;
  end;
end;





procedure TamWinControlVertScroll.UpdateScrollBars;
begin
  if not FUpdatingScrollBars and HandleAllocated then
    try

      FUpdatingScrollBars := True;
      FVertScrollBar.Update();
    finally
      FUpdatingScrollBars := False;
     // if sfHandleMessages in StyleServices.Flags then
      //  SendMessage(Handle, WM_NCPAINT, 0, 0);
    end;
end;

procedure TamWinControlVertScroll.AutoScrollInView(AControl: TControl);
begin
  if (AControl <> nil) and not (csLoading in AControl.ComponentState) and
    not (csLoading in ComponentState) and not (csDestroying in ComponentState) then
    ScrollInView(AControl);
end;

procedure TamWinControlVertScroll.DisableAutoRange;
begin
  Inc(FAutoRangeCount);
end;

procedure TamWinControlVertScroll.EnableAutoRange;
begin
  if FAutoRangeCount > 0 then
  begin
    Dec(FAutoRangeCount);
    if (FAutoRangeCount = 0) then CalcAutoRange;
  end;
end;


procedure TamWinControlVertScroll.ScrollInView(AControl: TControl);
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
  if Rect.Left < 0 then
   // with HorzScrollBar do Position := Position + Rect.Left
  else if Rect.Right > ClientWidth then
  begin
    if Rect.Right - Rect.Left > ClientWidth then
      Rect.Right := Rect.Left + ClientWidth;
   // with HorzScrollBar do Position := Position + Rect.Right - ClientWidth;
  end;

  if Rect.Top < 0 then
    with VertScrollBar do Position := Position + Rect.Top
  else if Rect.Bottom > ClientHeight then
  begin
    if Rect.Bottom - Rect.Top > ClientHeight then
      Rect.Bottom := Rect.Top + ClientHeight;
    with VertScrollBar do Position := Position + Rect.Bottom - ClientHeight;
  end;
end;


procedure TamWinControlVertScroll.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
//  ScaleScrollBars(M, D);
  inherited ChangeScale(M, D, isDpiChange);
end;
 {
procedure TScrollingWinControl2.Resizing(State: TWindowState);
begin
  // Overridden by TCustomFrame
end; }

procedure TamWinControlVertScroll.WMSize(var Message: TWMSize);
var
  NewState: TWindowState;
  SaveUpdatingScrollBars: Boolean;
begin
   logmain.Log('WMSize');
  Inc(FAutoRangeCount);
  try
    inherited;
    NewState := wsNormal;
{$IF DEFINED(CLR)}
    case Message.SizeType.ToInt64 of
{$ELSE}
    case Message.SizeType of
{$ENDIF}
      SIZENORMAL: NewState := wsNormal;
      SIZEICONIC: NewState := wsMinimized;
      SIZEFULLSCREEN: NewState := wsMaximized;
    end;
    //Resizing(NewState);
  finally
    Dec(FAutoRangeCount);
  end;
  SaveUpdatingScrollBars := FUpdatingScrollBars;
  FUpdatingScrollBars := True;
  try
    CalcAutoRange;
  finally
    FUpdatingScrollBars := SaveUpdatingScrollBars;
  end;
 // if  FVertScrollBar.Visible then
    UpdateScrollBars;
end;

procedure TamWinControlVertScroll.WMHScroll(var Message: TWMHScroll);
begin
  {if (Message.ScrollBar = 0) and FHorzScrollBar.Visible then
    FHorzScrollBar.ScrollMessage(Message) else
    inherited; }
end;

procedure TamWinControlVertScroll.WMVScroll(var Message: TWMVScroll);
begin

 { if (Message.ScrollBar = 0) and FVertScrollBar.Visible then
    FVertScrollBar.ScrollMessage(Message) else
    inherited;   }
end;

procedure TamWinControlVertScroll.AdjustClientRect(var Rect: TRect);
begin
//  exit;

    Rect := Bounds(0, -VertScrollBar.Position, Max(0, ClientWidth), Max(ClientHeight, VertScrollBar.Range));
  inherited AdjustClientRect(Rect);

end;

procedure TamWinControlVertScroll.CMBiDiModeChanged(var Message: TMessage);
var
  Save: Integer;
begin
      logmain.Log('CMBiDiModeChanged');
  Save := Message.WParam;
  try
    { prevent inherited from calling Invalidate & RecreateWnd }
    if not (Self is TamScrollBoxNoVisableScroll) then Message.wParam := 1;
    inherited;
  finally
    Message.wParam := Save;
  end;
  if HandleAllocated then
  begin
    //HorzScrollBar.ChangeBiDiPosition;
    UpdateScrollBars;
  end;
end;

procedure TamWinControlVertScroll.SendChangeScaleMessage(M, D: Integer);
begin
  if M <> D then
    TMessageManager.DefaultManager.SendMessage(Self,
      TChangeScaleMessage.Create(Self, M, D));
end;







{ TamScrollBoxNoVisableScroll  без самого windows скрола скрол только мышкой или VertScrollBar.Position }

constructor TamScrollBoxNoVisableScroll.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks, csPannable, csGestures];
  //AutoScroll := True;
  Width := 185;
  Height := 41;
  FBorderStyle := bsSingle;
end;

procedure TamScrollBoxNoVisableScroll.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if Visible then
    UpdateScrollBars;
end;

procedure TamScrollBoxNoVisableScroll.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TamScrollBoxNoVisableScroll.WMNCHitTest(var Message: TWMNCHitTest);
begin
  DefaultHandler(Message);
end;

procedure TamScrollBoxNoVisableScroll.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

end.
