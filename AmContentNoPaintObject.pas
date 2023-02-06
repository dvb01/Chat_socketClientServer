unit AmContentNoPaintObject;

// ������ ������� ��� ������ ���������� ��� �� ������� ��������� ������������ �� ���� ��� ��� ����������
// ��������� ���������  ������� ������� ��� TAmClientVoiceControl ����� ��� TAmClientVoice_Object
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Dialogs,Vcl.StdCtrls,Vcl.ComCtrls,Vcl.ExtCtrls,
  Math,ES.BaseControls, ES.Layouts, ES.Images ,AmVoiceRecord,AmUserType,AmHandleObject;

  Const AM_CLIENT_VOICE_CHANGE_PLAY = wm_user+13000;
        AM_CLIENT_VOICE_CHANGE_TIME = wm_user+13001;
        AM_CLIENT_VOICE_CHANGE_POSITION = wm_user+13002;
        AM_CLIENT_VOICE_CHANGE_SPECTR = wm_user+13003;

 // ���� ����� ��� �    TAmClientVoiceControlScrollBar ������ ��� ������ ����������
 // ���� �������� Paint Resize �.� ��������� �������� ����� ��� ����������� �������� ����� ���������
 // �.� ��� ������ ������ � ������� ������� ��� ���������� ��������� ����������
 type
  TAmClientVoiceSpect_Object =class(AmHandleObject.TamHandleObject)
     Type TOnChangePos=procedure (Pos:integer;Max:integer) of object;
     Private


      FPosition:integer;
      FPositionPixel:integer;
      FMax:Integer;
      FSpectr: TAmBassSpectrMono;

      FColorWaveOld:TColor;
      FColorWaveFuture:TColor;
      FChangePosition:Boolean;
      FUserPosChanging:Boolean;
      FVisualCompressor: integer;
      FAutoVisualCompressor:boolean;
      FOnChangePos: TOnChangePos;
      FChangePositionUserMouseUp:TOnChangePos;

      Procedure SetPosition(val:Integer);
      Procedure SetPositionPixel(val:Integer);
      Procedure SetMax(val:Integer);
      Procedure AutoVisualCompressorExp(var val:TAmBassSpectrMono);
      Procedure SetSpectr(val:TAmBassSpectrMono);

      // ������������  BMP  � BMP �������� � Self(TPaintBox)
      //�.� Spectr(Array of real) �������������� � BMP(TBitmap) � BMP ��������������  � Self(TPaintBox) = �������
      // ����������� ����� ����� ����� ���  � �������� ���������� resize
      procedure NewBmpDraw;
     protected

     public
      HandleControl:Cardinal;
      R:Trect;
      BMP:TBitmap;
      ColorBack:TColor;
      ColorWaveOld:TColor;
      ColorWaveFuture:TColor;


      property Position : integer read FPosition write SetPosition;
      property Max : integer read FMax write SetMax;

      property PositionPixel : integer read FPositionPixel write SetPositionPixel;

      property IsUserPosChanging : boolean read FUserPosChanging;




     // ���� ����� ������ ���������� ��������� ����� ������ �� ����� ������ �� ���� ���������
     // VisualCompressor ������� ��������� �������� ��� ���������
      property VisualCompressor : integer read FVisualCompressor write FVisualCompressor;

      // �������� Auto � ��� ��� ���� ���� ������� ������ �� ������ �������� ����� ����� ������� � ��������� ��������� �� auto �� ������ �������� ����� �������������
      // ������� ����� ��������������� ��� ������������ ��� ���� � �� ��������
      property AutoVisualCompressor : Boolean read FAutoVisualCompressor write FAutoVisualCompressor;


      // ������ ��� ������������ ����� �� ��� ������� �������� Real �� 0 �� 1
      // ������ �������� �� ����� �  TAmClientVoiceControl.SpectrQualityPixsel
      // ��. ��� �������� ����� � TAmClientVoiceControl.RefreshSpectrForFileName
      property Spectr : TAmBassSpectrMono read FSpectr write SetSpectr;



      property  OnChangePosition :TOnChangePos   read FOnChangePos write FOnChangePos;
      property  OnChangePositionUserMouseUp :TOnChangePos   read FChangePositionUserMouseUp write FChangePositionUserMouseUp;
      //procedure DrawSpectrRL(Spectr:TAmBassSpectrRL);


      //��������� ����� �� repaint ���������
      Procedure   Resize;
      function   MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer):boolean;
      function   MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer):boolean;
      function   MouseMove(Shift: TShiftState; X, Y: Integer):boolean;
      constructor Create;
      destructor Destroy ; override;


  end;


  type
   TAmClientVoice_Object =class(AmHandleObject.TamHandleObject)
     Type TOnEventPlay = procedure (S:TObject; FileName:String;IsPlay:boolean) of Object;
     Type TOnEventBassChangeControl = procedure (NowControl:TObject; NewControl:TObject) of Object;
     Type TOnEventChangePos=procedure (S:TObject; Pos:integer;Max:integer) of object;
     Type TOnEventChangePosUser=procedure (S:TObject; Pos:integer;Max:integer;IsActivBASS,IsBASS:boolean) of object;
     Private
      FOnNotPlay :TOnEventPlay;
      FOnGoodPlay:TOnEventPlay;
      FOnClickPlayBefore:TOnEventPlay;
      FOnClickPlayAfter:TOnEventPlay;
      FOnBassChangeControl: TOnEventBassChangeControl;
      FChangePos:TOnEventChangePos;
      FChangePosUser:TOnEventChangePosUser;
      FOnPlayFinish:TOnEventPlay;


      FSpectr:TAmClientVoiceSpect_Object;
      FIsPlay:boolean;
      FFileName:string;
      FSpectrQualityPixsel: integer;
      FIsActivBASS,FIsBASS:Boolean;
     // procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;

      procedure ScrollBarChangePos(Pos:integer;Max:integer);
      Procedure StartProc;
      Procedure StopProc;
      Procedure PauseProc;
      Procedure ResumeProc;
      procedure LabelPlayClick;
      procedure SetLabelPlay();


     public
      IdVoice:string;
      R:Trect;
      RPlay:Trect;
      RTime:Trect;
      CaptionTime :String;
      CaptionPlay:string;

      constructor Create;
      destructor Destroy ; override;

      // ������ �� ������������ ��� ������������ ������ � AmBass
      Procedure BASSChangePositionTin(Pos,Max: Integer;C:string);
      Procedure BASSChangePositionEnd(C:TOBject);
      procedure BASSChangeNewFile(NewFile:string;NewControl:TObject);



      //���� ����� �������������� ����� ��� �� �������� � ������ ������� ��� TmemoryStream
      property FileName : string read FFileName write FFileName;

      //�������� ����� ��� ����� FileName
      Procedure RefreshSpectrForFileName;

      //�������� ������� �������
      property Spectr : TAmClientVoiceSpect_Object read FSpectr;

      // �������� ������� ���� ��� �������� ����� �� ���������� ���� ��� ����������� ����������� ���������  TAmBass.Spectr_GetBufferLR ; begin ...SizeWidth:=  MaxLength div bpp; .......
      property SpectrQualityPixsel:integer read FSpectrQualityPixsel write FSpectrQualityPixsel;


       // ������ �� ������ ����� ������������� �����
      property IsPlay : boolean read FIsPlay;



      // ������� �������� �������� ��������
      Procedure Start;
      Procedure Stop;
      Procedure Pause;
      Procedure Resume;
      ///////////////////

      //true ������ BASS �� ���� �������  � ��������������� �������
      property IsActivBASS : Boolean read FIsActivBASS;

      //true ������ BASS �� ���� �������
      property IsBASS : Boolean read FIsBASS;

      // ������� ��� ����� ��� ������ ������������� ����
      property  OnNotPlay : TOnEventPlay read FOnNotPlay write FOnNotPlay ;

      // ������� �������� ��������
      property  OnGoodPlay : TOnEventPlay read FOnGoodPlay write FOnGoodPlay ;
      property  OnClickPlayBefore : TOnEventPlay read FOnClickPlayBefore write FOnClickPlayBefore ;
      property  OnClickPlayAfter : TOnEventPlay read FOnClickPlayAfter write FOnClickPlayAfter ;
      /////////

     // � AmBass ���������  ������� �.� ����� �� ������ ���� �������� ��������������� ���������� � BASSChangeNewFile
     // �.� ���� ������ �������� ������ ���  AmBass �  New ��� ��� ������� ������ ����� ���������
      property  OnBassChangeControl : TOnEventBassChangeControl read FOnBassChangeControl write FOnBassChangeControl ;

      //����� ��������� �������
      property  OnChangePosition : TOnEventChangePos read FChangePos write FChangePos ;

     //���� ������� ������� ����������
      property  OnChangePositionUser : TOnEventChangePosUser read FChangePosUser write FChangePosUser ;

     //���������� ����
      property  OnPositionFinish : TOnEventPlay read FOnPlayFinish write FOnPlayFinish ;
   end;
implementation

constructor TAmClientVoice_Object.Create;
begin
   inherited Create();
   FIsPlay:=false;
   FSpectrQualityPixsel:=200;
   FIsActivBASS:=False;
   FIsBASS :=False;

   FSpectr:= TAmClientVoiceSpect_Object.Create;
   FSpectr.ColorBack:= clBlack;
   FSpectr.OnChangePositionUserMouseUp:= ScrollBarChangePos;
   FSpectr.Position:=0;
   FSpectr.PositionPixel:=0;
end;
destructor TAmClientVoice_Object.Destroy ;
begin
  if FIsActivBASS or FIsBASS then AmBass.Play_Free;
  FIsBASS:=false;
  FIsActivBASS:=false;
  FSpectr.Free;
  inherited Destroy;
end;

procedure TAmClientVoice_Object.LabelPlayClick;
begin
   if Assigned(FOnClickPlayBefore) then FOnClickPlayBefore(self,FFileName,IsPlay);

   SetLabelPlay;
   if Assigned(FOnClickPlayAfter) then FOnClickPlayAfter(self,FFileName,IsPlay);

end;
procedure TAmClientVoice_Object.SetLabelPlay();
begin

    if FIsPlay then
    begin
        FIsPlay:=false;
        CaptionPlay := '4';
        PauseProc;
    end
    else
    begin
        FIsPlay:=true;
        CaptionPlay := ';';
        ResumeProc;
    end;


end;
procedure  TAmClientVoice_Object.BASSChangePositionTin(Pos,Max: Integer;C:string);
begin
  CaptionTime:= C;
  if not FSpectr.IsUserPosChanging then
  begin
   FSpectr.Max:= Max;
   FSpectr.Position:= Pos;
   if Assigned(FChangePos) then FChangePos(Self,Pos,Max);

  end;
end;
procedure TAmClientVoice_Object.ScrollBarChangePos(Pos:integer;Max:integer);
begin
  if FIsActivBASS and FIsBASS then
    AmBass.Play_Position:= Pos;
  if Assigned(FChangePosUser) then  FChangePosUser(Self,Pos,Max,IsActivBASS,IsBASS);

end;
Procedure TAmClientVoice_Object.BASSChangePositionEnd(C:TOBject);
begin

  FIsPlay:=true;
  SetLabelPlay;
  if Assigned(FOnPlayFinish) then FOnPlayFinish(Self,FFileName,IsPlay);

end;
procedure TAmClientVoice_Object.BASSChangeNewFile(NewFile:string;NewControl:TObject);
var  NewControlVoice: TAmClientVoice_Object;
begin
   if Assigned(NewControl) and  (NewControl is TAmClientVoice_Object) then
   begin
     NewControlVoice:= NewControl as TAmClientVoice_Object;
     if NewControlVoice<>self then
     begin
       Stop;
       FSpectr.Position:= 0;
       FIsActivBASS:=false;
       FIsBASS :=False;
       if Assigned(FOnBassChangeControl) then FOnBassChangeControl(self,NewControl);

     end;
   end;

end;
Procedure TAmClientVoice_Object.Start;
begin
  FIsPlay:=False;
  SetLabelPlay;
end;
Procedure TAmClientVoice_Object.Stop;
begin
  FIsPlay:=true;
  SetLabelPlay;
end;
Procedure TAmClientVoice_Object.Pause;
begin
  FIsPlay:=true;
  SetLabelPlay;
end;
Procedure TAmClientVoice_Object.Resume;
begin
  FIsPlay:=False;
  SetLabelPlay;
end;
Procedure TAmClientVoice_Object.RefreshSpectrForFileName;
var Spectr:TAmBassSpectrMono;
begin
  if FFileName<>'' then
  begin
    AmBass.Spectr_GetBufferMono(FFileName,Spectr,FSpectrQualityPixsel);
    FSpectr.Spectr:= Spectr;
  end;

end;
Procedure TAmClientVoice_Object.StartProc;
begin
 FIsActivBASS:=False;
 FIsBASS :=True;
 if FFileName<>'' then
 begin
  FIsActivBASS:=AmBass.Play_Start(FFileName,Self);
  //RefreshSpectrForFileName;
 end ;
 if not FIsActivBASS then
 begin
   if Assigned(FOnNotPlay) then
   begin
     FOnNotPlay(self,FFileName,IsPlay);
   end
   else
   begin
     CaptionTime:='�� ������� ������������.';
     delay(300);
     SetLabelPlay();
   end;


 end
 else if Assigned(FOnGoodPlay) then  FOnGoodPlay(self,FFileName,IsPlay);



end;
Procedure TAmClientVoice_Object.StopProc;
begin
   AmBass.Play_Stop;
end;
Procedure TAmClientVoice_Object.PauseProc;
begin
 AmBass.Play_Pause;
end;
Procedure TAmClientVoice_Object.ResumeProc;
var R:boolean;
//var
  //oc1, oc2: TAmBass.TOnChangePos;
begin
   R:=false;
   //oc1:= AmBass.Play_OnChangePosition;
 //  oc2:= ChangePositionTin;

 //if (TMethod(oc1).Data = TMethod(oc2).Data) and
 //    (TMethod(oc1).Code = TMethod(oc2).Code) then
  if Assigned(AmBass.Play_VoiceControl) and (AmBass.Play_VoiceControl is TAmClientVoice_Object )
  and ((AmBass.Play_VoiceControl as TAmClientVoice_Object ) = self) then
  begin
    if AmBass.Play_IsSameFile(FFileName) then R:=AmBass.Play_Resume;
  end;
  if not R then StartProc;
end;





                {TAmClientVoiceSpect_Object}

constructor TAmClientVoiceSpect_Object.Create ;
begin
   inherited Create();
   HandleControl:=0;
   ColorBack:=  $00795535;
   ColorWaveOld:= $00FFEC70;//$00CFAF30;
   ColorWaveFuture:= $00E1CDBB;
   FChangePosition:=false;
   FUserPosChanging:=false;
   BMP:=TBitmap.Create;
   SetLength(FSpectr,0);
   FPosition:=0;
   FPositionPixel:=0;
   FMax:=1;
   FVisualCompressor:=150;
   FAutoVisualCompressor:=True;

end;
destructor TAmClientVoiceSpect_Object.Destroy ;
begin
    FreeAndNil(BMP);
    inherited;
end;

Procedure TAmClientVoiceSpect_Object.SetPositionPixel(val:Integer);
var Procent:real;
begin
   FPositionPixel:= val;

   if FChangePosition then exit;
   FChangePosition:=true;
   try

     Procent:=  FPositionPixel / R.Width  ;
     Position:=  Round(Procent*Max);
     NewBmpDraw;

   finally
    FChangePosition:=false;
   end;
end;

Procedure TAmClientVoiceSpect_Object.SetPosition(val:Integer);
var Procent:real;
begin
   FPosition:= val;
   if Assigned(FOnChangePos) then FOnChangePos(FPosition,FMax);


   if FChangePosition then exit;
   FChangePosition:=true;
   try

     Procent:= FPosition  /Max  ;
     PositionPixel:=  Round(Procent*R.Width);
     NewBmpDraw;


   finally
    FChangePosition:=false;
   end;

end;

Procedure TAmClientVoiceSpect_Object.SetMax(val:Integer);
begin
    FMax:= val;
end;
function   TAmClientVoiceSpect_Object.MouseMove(Shift: TShiftState; X, Y: Integer) : boolean;
begin
    Result:=False;
    if Assigned(BMP) and FUserPosChanging then
    begin
        PositionPixel:= X;
        Result:=True;
    end;
end;
function TAmClientVoiceSpect_Object.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer) : boolean;
begin
    Result:=False;
    if not  Assigned(BMP) then exit;
    FUserPosChanging:=true;
    PositionPixel:= X;
    Result:=True;
end;
function TAmClientVoiceSpect_Object.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer):boolean;
begin
    Result:=False;
    if not  Assigned(BMP) then exit;

    if FUserPosChanging then
    begin
      PositionPixel:= X;
      Result:=True;
      if Assigned(FChangePositionUserMouseUp) then FChangePositionUserMouseUp(Position,Max);
    end;
    FUserPosChanging:=False;
end;
procedure TAmClientVoiceSpect_Object.Resize;
begin
    if Assigned(BMP) then NewBmpDraw;
end;
Procedure TAmClientVoiceSpect_Object.AutoVisualCompressorExp(var val:TAmBassSpectrMono);
var M:Integer;
    Maximum:Single;
    I:integer;

    function Maxval(const Data:TAmBassSpectrMono):Real;
    var
      I: Integer;
    begin

      Result := Data[Low(Data)];
      for I := Low(Data) + 1 to High(Data) do
        if Result < Data[I] then
          Result := Data[I];
    end;
begin
 if Length(val)>0 then
 begin

   Maximum:= Maxval(val);
   I:=  Round(1/Maximum*100);
   if I<10 then  I:=10;
   if I>700 then  I:=1700;
   FVisualCompressor:= I;
 end;

end;
Procedure TAmClientVoiceSpect_Object.SetSpectr(val:TAmBassSpectrMono);
begin
  if FAutoVisualCompressor then AutoVisualCompressorExp(val);
  FSpectr:=val;
  PositionPixel:=0;
  NewBmpDraw;
end;

procedure TAmClientVoiceSpect_Object.NewBmpDraw;
var
  x,ht : integer;
  ott:Real;
  Ri:real;
  I:integer;
  FCol:TColor;
begin
   //clear background
   BMP.Width:= R.Width;
   BMP.Height:= R.Height;



   BMP.Canvas.Brush.Color := ColorBack;
   BMP.Canvas.FillRect(Rect(0,0,BMP.Width,BMP.Height));

   //draw peaks
   ht :=  (BMP.Height div 2)-2;
   ott:=    length(FSpectr) /BMP.Width ;


   i:=0;
   Ri:=0;


   for x:=0 to BMP.Width-1 do
   begin
    //for i:=0 to length(wavebufL)-1 do
     i:= Round( Ri );//��� ������ +  (Ri:= Ri+ ott) �������� ��� ��������� ������� ��������� ��� ����� �������;
     //�.� ���� � ����� ������� ����� ���������� � 2 ������ ������� ���� ������ � 2 ���� ������
     if (i>=0) and (i < length(FSpectr)-1 ) then
     begin

      //��������� ���� ���� ��� ����������
      if x < FPositionPixel  then FCol:= FColorWaveOld
      else                        FCol:= FColorWaveFuture;

    //  Memo1.Lines.Add(trunc((wavebufL[i]/32768)*ht * 2).ToString);
      BMP.Canvas.MoveTo(x,ht);


      // �������� ����� �����
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.LineTo(x,(ht+2)-1);
      BMP.Canvas.LineTo(x,(ht) - trunc((FSpectr[i])*(ht * (FVisualCompressor/100))));

      // �������� ��� �����
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.MoveTo(x,ht+2);
      BMP.Canvas.LineTo(x,ht+2+trunc((FSpectr[i])*ht * (FVisualCompressor/100)));
      //�� ������� ������ ���� �������� �� TAmBassSpectrMono � TAmBassSpectrRL �� ����� ������

      Ri:= Ri+ ott;
     end;


   end;


end;

end.
