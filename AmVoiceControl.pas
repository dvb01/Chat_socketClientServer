unit AmVoiceControl;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Dialogs,Vcl.StdCtrls,Vcl.ComCtrls,Vcl.ExtCtrls,
  Math,ES.BaseControls, ES.Layouts, ES.Images ,AmVoiceRecord,AmUserType,AmHandleObject;
  {ES  можно не использовать = удалить}
 type
  TAmClientVisualCompressorProcent=  10..1700;
  TAmClientSpectrQualityPixsel=  10..10000;
 type
  TAmClientVoiceControlScrollBar =class(TPaintBox)
     Type TOnChangePos=procedure (Pos:integer;Max:integer) of object;
     Private
      BMP:TBitmap;
      FPosition:integer;
      FPositionPixel:integer;
      FMax:Integer;
      FSpectr: TAmBassSpectrMono;
      FColorBack:TColor;
      FColorWaveOld:TColor;
      FColorWaveFuture:TColor;
      FChangePosition:Boolean;
      FUserPosChanging:Boolean;
      FVisualCompressor: TAmClientVisualCompressorProcent;
      FAutoVisualCompressor:boolean;
      FOnChangePos: TOnChangePos;
      FChangePositionUserMouseUp:TOnChangePos;
      Procedure SetMaxPixel(val:Integer);
      function  GetMaxPixel:integer;
      Procedure SetPosition(val:Integer);
      Procedure SetPositionPixel(val:Integer);
      Procedure SetMax(val:Integer);
      Procedure AutoVisualCompressorExp(var val:TAmBassSpectrMono);
      Procedure SetSpectr(val:TAmBassSpectrMono);
     protected
      procedure Paint; override;
      procedure Resize;override;
      procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
     public

      property Position : integer read FPosition write SetPosition;
      property Max : integer read FMax write SetMax;

      property PositionPixel : integer read FPositionPixel write SetPositionPixel;
      property MaxPixel      : integer read GetMaxPixel write SetMaxPixel;
      property IsUserPosChanging : boolean read FUserPosChanging;




     // звук имеет разную визуальную амплитуду одини вообще не видны другие за края выспукают
     // VisualCompressor поможет увеличить ампитуду или уменьшить
      property VisualCompressor : TAmClientVisualCompressorProcent read FVisualCompressor write FVisualCompressor;

      // проблема Auto в том что если один елемент спекта из масива спектора будет самым больщим а остальные мальнькие то auto по самому большому будет оринтироватся
      // решение можно комперсивровать или лимитировать сам звук а не визуалку
      property AutoVisualCompressor : Boolean read FAutoVisualCompressor write FAutoVisualCompressor;


      // масиив для визуализации трека по его спектру содержит Real от 0 до 1
      // длинна задается не здесь в  TAmClientVoiceControl.SpectrQualityPixsel
      // см. как обновить спект в TAmClientVoiceControl.RefreshSpectrForFileName
      property Spectr : TAmBassSpectrMono read FSpectr write SetSpectr;
      property ColorBack:TColor  read FColorBack write FColorBack;
      property ColorSpectrFuture:TColor  read FColorWaveFuture write FColorWaveFuture;
      property ColorSpectrOld:TColor  read FColorWaveOld write FColorWaveOld;


      // отписовывает  BMP  и BMP рисуется в Self(TPaintBox)
      //т.е Spectr(Array of real) конвертируется в BMP(TBitmap) а BMP конвертируется  в Self(TPaintBox) = рисунок
      procedure NewBmpDraw;
      property  OnChangePosition :TOnChangePos   read FOnChangePos write FOnChangePos;
      property  OnChangePositionUserMouseUp :TOnChangePos   read FChangePositionUserMouseUp write FChangePositionUserMouseUp;
      //procedure DrawSpectrRL(Spectr:TAmBassSpectrRL);
      constructor Create(AOwner: TComponent); override;
      destructor Destroy ; override;
  end;





  type
   TAmClientVoiceControl =class(TEsLayout) {если нет TEsLayout  из модуля ES.BaseControls, ES.Layouts то Tpanel или TLayout }
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

      FLabelPlay:TLabel;
      FSpectr:TAmClientVoiceControlScrollBar;
      FLabelInfo: TLabel;

      FIsPlay:boolean;
      FFileName:string;
      FSpectrQualityPixsel: TAmClientSpectrQualityPixsel;
      FIsActivBASS,FIsBASS:Boolean;
     // procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;

      procedure ScrollBarChangePos(Pos:integer;Max:integer);
      Procedure StartProc;
      Procedure StopProc;
      Procedure PauseProc;
      Procedure ResumeProc;
      procedure LabelPlayClick(S:Tobject);
      procedure SetLabelPlay();

      function  GetColor:TColor;
      procedure SetColor(val:TColor);
     public
      IdVoice:string;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy ; override;

      // внешне не использовать они используется только с AmBass
      Procedure BASSChangePositionTin(Pos,Max: Integer;C:string);
      Procedure BASSChangePositionEnd(C:TOBject);
      procedure BASSChangeNewFile(NewFile:string;NewControl:TObject);



      //файл какой воспроизводить можно так же раширить и самому сделать для TmemoryStream
      property FileName : string read FFileName write FFileName;

      //обновить спект для файла FileName спект сам не загружается после вызова Start
      // установили FileName и вызвали  RefreshSpectrForFileName; Start;
      Procedure RefreshSpectrForFileName;

      // контрол который содержит русунок спектра
      property Spectr : TAmClientVoiceControlScrollBar read FSpectr write FSpectr;

      // качество спектра если это возможно будет то выполнится если нет установится максимально возможный  TAmBass.Spectr_GetBufferLR ; begin ...SizeWidth:=  MaxLength div bpp; .......
      property SpectrQualityPixsel:TAmClientSpectrQualityPixsel read FSpectrQualityPixsel write FSpectrQualityPixsel;

     // лайбел иконки плей пауза
      property LabelPlay : TLabel read FLabelPlay write FLabelPlay;

     // лайбел таймер время прослушивания
      property LabelInfo : TLabel read FLabelInfo write FLabelInfo;

       // нажата ли кнопка старт прослущивания файла
      property IsPlay : boolean read FIsPlay;



      // условно понятные названия действий
      Procedure Start;
      Procedure Stop;
      Procedure Pause;
      Procedure Resume;
      ///////////////////

      //цвет фона цвета спекта в self.Spectr.Color..
      property Color : TColor read GetColor write SetColor;

      //true значит BASS на этом объекте  и воспроизведение активно
      property IsActivBASS : Boolean read FIsActivBASS;

      //true значит BASS на этом объекте
      property IsBASS : Boolean read FIsBASS;

      // события нет файла или нельзя воспроизвести файл
      property  OnNotPlay : TOnEventPlay read FOnNotPlay write FOnNotPlay ;

      // условно понятные названия
      property  OnGoodPlay : TOnEventPlay read FOnGoodPlay write FOnGoodPlay ;
      property  OnClickPlayBefore : TOnEventPlay read FOnClickPlayBefore write FOnClickPlayBefore ;
      property  OnClickPlayAfter : TOnEventPlay read FOnClickPlayAfter write FOnClickPlayAfter ;
      /////////

     // в AmBass Поменялся  контрол т.е какой то другой файл начинает воспроизводится вызывается с BASSChangeNewFile
     // т.е этот объект управлял только что  AmBass а  New это тот который сейчас будет управлять
      property  OnBassChangeControl : TOnEventBassChangeControl read FOnBassChangeControl write FOnBassChangeControl ;

      //любое изменение позиции
      property  OnChangePosition : TOnEventChangePos read FChangePos write FChangePos ;

     //юзер изменил позицию перемоткой
      property  OnChangePositionUser : TOnEventChangePosUser read FChangePosUser write FChangePosUser ;

     //закончился трек
      property  OnPositionFinish : TOnEventPlay read FOnPlayFinish write FOnPlayFinish ;
   end;





implementation


           {TAmClientVoiceControl PaintBox}
Procedure TAmClientVoiceControlScrollBar.SetMaxPixel(val:Integer);
begin
   Width:= val;
end;

function  TAmClientVoiceControlScrollBar.GetMaxPixel:integer;
begin
   Result:=Width;
end;

Procedure TAmClientVoiceControlScrollBar.SetPositionPixel(val:Integer);
var Procent:real;
begin
   FPositionPixel:= val;

   if FChangePosition then exit;
   FChangePosition:=true;
   try

     Procent:=  FPositionPixel / GetMaxPixel  ;
     Position:=  Round(Procent*Max);
     NewBmpDraw;

   finally
    FChangePosition:=false;
   end;
end;

Procedure TAmClientVoiceControlScrollBar.SetPosition(val:Integer);
var Procent:real;
begin
   FPosition:= val;
   if Assigned(FOnChangePos) then FOnChangePos(FPosition,FMax);


   if FChangePosition then exit;
   FChangePosition:=true;
   try

     Procent:= FPosition  /Max  ;
     PositionPixel:=  Round(Procent*GetMaxPixel);
     NewBmpDraw;


   finally
    FChangePosition:=false;
   end;

end;

Procedure TAmClientVoiceControlScrollBar.SetMax(val:Integer);
begin
    FMax:= val;
end;

Procedure TAmClientVoiceControlScrollBar.SetSpectr(val:TAmBassSpectrMono);
begin
  if FAutoVisualCompressor then AutoVisualCompressorExp(val);
  FSpectr:=val;
  PositionPixel:=0;
  NewBmpDraw;
end;
Procedure TAmClientVoiceControlScrollBar.AutoVisualCompressorExp(var val:TAmBassSpectrMono);
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
procedure TAmClientVoiceControlScrollBar.NewBmpDraw;
var
  x,ht : integer;
  ott:Real;
  Ri:real;
  I:integer;
  FCol:TColor;
begin
   //clear background
   BMP.Width:= MaxPixel;
   BMP.Height:= Height;
   Parent.DoubleBuffered := true;


   BMP.Canvas.Brush.Color := FColorBack;
   BMP.Canvas.FillRect(Rect(0,0,BMP.Width,BMP.Height));

   //draw peaks
   ht :=  (ClientHeight div 2)-2;
   ott:=    length(FSpectr) /BMP.Width ;


   i:=0;
   Ri:=0;


   for x:=0 to BMP.Width-1 do
   begin
    //for i:=0 to length(wavebufL)-1 do
     i:= Round( Ri );//эта строка +  (Ri:= Ri+ ott) помогает при изменении размера растянуть или сжать рисунок;
     //т.е один и тотже пиксиль нужно нарисовать в 2 писеля рисунка если длинна в 2 раза больше
     if (i>=0) and (i < length(FSpectr)-1 ) then
     begin

      //именяется цвет если уже прослущано
      if x < FPositionPixel  then FCol:= FColorWaveOld
      else                        FCol:= FColorWaveFuture;

    //  Memo1.Lines.Add(trunc((wavebufL[i]/32768)*ht * 2).ToString);
      BMP.Canvas.MoveTo(x,ht);


      // рисуется вверх волна
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.LineTo(x,(ht+2)-1);
      BMP.Canvas.LineTo(x,(ht) - trunc((FSpectr[i])*(ht * (FVisualCompressor/100))));

      // рисуется низ волна
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.MoveTo(x,ht+2);
      BMP.Canvas.LineTo(x,ht+2+trunc((FSpectr[i])*ht * (FVisualCompressor/100)));
      //ну одинако рисует если получать не TAmBassSpectrMono а TAmBassSpectrRL то будет разное

      Ri:= Ri+ ott;
     end;


   end;

   {for x:=0 to BMP.Width-1 do
   begin
    //for i:=0 to length(wavebufL)-1 do
     i:= Round( Ri );//эта строка +  (Ri:= Ri+ ott) помогает при изменении размера растянуть или сжать рисунок;
     //т.е один и тотже пиксиль нужно нарисовать в 2 писеля рисунка если длинна в 2 раза больше
     if (i>=0) and (i < length(FSpectr)-1 ) then
     begin

      //именяется цвет если уже прослущано
      if x < FPositionPixel  then FCol:= FColorWaveOld
      else                        FCol:= FColorWaveFuture;

    //  Memo1.Lines.Add(trunc((wavebufL[i]/32768)*ht * 2).ToString);
      BMP.Canvas.MoveTo(x,ht);


      // рисуется вверх волна
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.LineTo(x,(ht+2)-1);
      BMP.Canvas.LineTo(x,(ht) - trunc((FSpectr[i])*(ht * (FVisualCompressor/100))));

      // рисуется низ волна
      BMP.Canvas.Pen.Color := FCol;
      BMP.Canvas.MoveTo(x,ht+2);
      BMP.Canvas.LineTo(x,ht+2+trunc((FSpectr[i])*ht * (FVisualCompressor/100)));
      //ну одинако рисует если получать не TAmBassSpectrMono а TAmBassSpectrRL то будет разное

      Ri:= Ri+ ott;
     end;


   end; }
   Refresh;
end;


procedure TAmClientVoiceControlScrollBar.Paint;
begin
   inherited Paint;
   if Assigned(BMP) then
   Canvas.Draw(0,0,BMP);
end;
procedure TAmClientVoiceControlScrollBar.Resize;
begin
    inherited Resize;
    if Assigned(BMP) then
    NewBmpDraw;
end;
procedure TAmClientVoiceControlScrollBar.ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
begin
     inherited ConstrainedResize(MinWidth, MinHeight, MaxWidth, MaxHeight);
     MinWidth:=50;
     MinHeight:=10;
end;
procedure TAmClientVoiceControlScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
begin
    inherited MouseDown(Button,Shift,X, Y);
    if Assigned(BMP) then
    begin
      FUserPosChanging:=true;
      PositionPixel:= X;
    end;
end;
procedure TAmClientVoiceControlScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseUp(Button,Shift,X, Y);
    if Assigned(BMP) then
    begin

     if FUserPosChanging then
     begin
      PositionPixel:= X;
      if Assigned(FChangePositionUserMouseUp) then FChangePositionUserMouseUp(Position,Max);
     end;

    end;
    FUserPosChanging:=False;
end;
procedure TAmClientVoiceControlScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseMove(Shift,X, Y);
    if Assigned(BMP) and FUserPosChanging then  PositionPixel:= X;
end;
constructor TAmClientVoiceControlScrollBar.Create(AOwner: TComponent);
begin

   FChangePosition:=false;
   FUserPosChanging:=false;
   inherited Create(AOwner);
   BMP:=TBitmap.Create;
   SetLength(FSpectr,0);
   FPosition:=0;
   FPositionPixel:=0;
   FMax:=1;
   FColorBack:=  $00795535;
   FColorWaveOld:= $00FFEC70;//$00CFAF30;
   FColorWaveFuture:= $00E1CDBB;
   FVisualCompressor:=150;
   FAutoVisualCompressor:=True;
  // Width:=100;
  // Height:=10;

end;
destructor TAmClientVoiceControlScrollBar.Destroy ;
begin
   BMP.Free;
   BMP:=nil;
   inherited Destroy;
end;



              {TAmClientVoiceControl}
procedure TAmClientVoiceControl.LabelPlayClick(S:Tobject);
begin
   if Assigned(FOnClickPlayBefore) then FOnClickPlayBefore(self,FFileName,IsPlay);

   SetLabelPlay;
   if Assigned(FOnClickPlayAfter) then FOnClickPlayAfter(self,FFileName,IsPlay);

end;
procedure TAmClientVoiceControl.SetLabelPlay();
begin

    if FIsPlay then
    begin
        FIsPlay:=false;
        FLabelPlay.Caption := '4';
        PauseProc;
    end
    else
    begin
        FIsPlay:=true;
        FLabelPlay.Caption := ';';
        ResumeProc;
    end;


end;
procedure  TAmClientVoiceControl.BASSChangePositionTin(Pos,Max: Integer;C:string);
begin
  FLabelInfo.Caption:= C;
  if not FSpectr.IsUserPosChanging then
  begin
   FSpectr.Max:= Max;
   FSpectr.Position:= Pos;
   if Assigned(FChangePos) then FChangePos(Self,Pos,Max);
   
  end;
end;
procedure TAmClientVoiceControl.ScrollBarChangePos(Pos:integer;Max:integer);
begin
  if FIsActivBASS and FIsBASS then
    AmBass.Play_Position:= Pos;
  if Assigned(FChangePosUser) then  FChangePosUser(Self,Pos,Max,IsActivBASS,IsBASS);
    
end;
Procedure TAmClientVoiceControl.BASSChangePositionEnd(C:TOBject);
begin

  FIsPlay:=true;
  SetLabelPlay;
  if Assigned(FOnPlayFinish) then FOnPlayFinish(Self,FFileName,IsPlay);

end;
procedure TAmClientVoiceControl.BASSChangeNewFile(NewFile:string;NewControl:TObject);
var  NewControlVoice: TAmClientVoiceControl;
begin
   if Assigned(NewControl) and  (NewControl is TAmClientVoiceControl) then
   begin
     NewControlVoice:= NewControl as TAmClientVoiceControl;
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
Procedure TAmClientVoiceControl.Start;
begin
  FIsPlay:=False;
  SetLabelPlay;
end;
Procedure TAmClientVoiceControl.Stop;
begin
  FIsPlay:=true;
  SetLabelPlay;
end;
Procedure TAmClientVoiceControl.Pause;
begin
  FIsPlay:=true;
  SetLabelPlay;
end;
Procedure TAmClientVoiceControl.Resume;
begin
  FIsPlay:=False;
  SetLabelPlay;
end;
Procedure TAmClientVoiceControl.RefreshSpectrForFileName;
var Spectr:TAmBassSpectrMono;
begin
  if FFileName<>'' then
  begin
    AmBass.Spectr_GetBufferMono(FFileName,Spectr,FSpectrQualityPixsel);
    FSpectr.Spectr:= Spectr;
  end;

end;
Procedure TAmClientVoiceControl.StartProc;
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
     FLabelInfo.Caption:='Не удается воспроизвети.';
     delay(300);
     SetLabelPlay();
   end;


 end
 else if Assigned(FOnGoodPlay) then  FOnGoodPlay(self,FFileName,IsPlay);

 

end;
Procedure TAmClientVoiceControl.StopProc;
begin
   AmBass.Play_Stop;
end;
Procedure TAmClientVoiceControl.PauseProc;
begin
 AmBass.Play_Pause;
end;
Procedure TAmClientVoiceControl.ResumeProc;
var R:boolean;
//var
  //oc1, oc2: TAmBass.TOnChangePos;
begin
   R:=false;
   //oc1:= AmBass.Play_OnChangePosition;
 //  oc2:= ChangePositionTin;

 //if (TMethod(oc1).Data = TMethod(oc2).Data) and
 //    (TMethod(oc1).Code = TMethod(oc2).Code) then
  if Assigned(AmBass.Play_VoiceControl) and (AmBass.Play_VoiceControl is TAmClientVoiceControl )
  and ((AmBass.Play_VoiceControl as TAmClientVoiceControl ) = self) then
  begin
    if AmBass.Play_IsSameFile(FFileName) then R:=AmBass.Play_Resume;
  end;
  if not R then StartProc;
end;



constructor TAmClientVoiceControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FIsPlay:=false;
   FSpectrQualityPixsel:=200;
   FIsActivBASS:=False;
   FIsBASS :=False;
   self.Width:=400;
   self.Height:=40;
   self.ParentColor:=false;
   self.ParentBackground:=false ;
   inherited Color:=clBlack;

   FLabelPlay:= Tlabel.Create(self);
   FLabelPlay.Parent:=self;
   FLabelPlay.Left := 1;
   FLabelPlay.Top := -4;
   FLabelPlay.Caption := '4';
   FLabelPlay.Font.Charset := SYMBOL_CHARSET;
   FLabelPlay.Font.Color := clWhite;
   FLabelPlay.Font.Size := 20;
   FLabelPlay.Font.Name := 'Webdings';
   FLabelPlay.Font.Style := [];
   FLabelPlay.ParentColor := False;
   FLabelPlay.ParentFont := False;
   FLabelPlay.OnClick:= LabelPlayClick;


   FSpectr:= TAmClientVoiceControlScrollBar.Create(self);
   FSpectr.Parent:=self;
   FSpectr.AlignWithMargins := True;
   FSpectr.Margins.Left := 30;
   FSpectr.Margins.Top := 2;
   FSpectr.Margins.Right := 10;
   FSpectr.Margins.Bottom := 20 ;
   FSpectr.Align := alClient;
   FSpectr.ParentColor := False;
   FSpectr.ColorBack:= clBlack;
   FSpectr.OnChangePositionUserMouseUp:= ScrollBarChangePos;
  // FSpectrum.OnPaint := PBPaint;


   FLabelInfo:= Tlabel.Create(self);
   FLabelInfo.Parent:=self;
   FLabelInfo.Left := 9;
   FLabelInfo.Top := 23;
   FLabelInfo.Anchors:=[akLeft,akBottom];
   FLabelInfo.Caption := '00.00 / 00:00';
   FLabelInfo.Font.Charset := DEFAULT_CHARSET;
   FLabelInfo.Font.Color := ClWhite;
   FLabelInfo.Font.Size := 8;
   FLabelInfo.Font.Name := 'Tahoma';
   FLabelInfo.Font.Style := [];
   FLabelInfo.ParentColor := False;
   FLabelInfo.ParentFont := False;
   FSpectr.Position:=0;
   FSpectr.PositionPixel:=0;
end;
destructor TAmClientVoiceControl.Destroy ;
begin
  if FIsActivBASS or FIsBASS then
  begin
     AmBass.Play_Free;
  end;
  FIsBASS:=false;
  FIsActivBASS:=false;

  inherited Destroy;
end;
function  TAmClientVoiceControl.GetColor:TColor;
begin
  Result:=  inherited Color;
end;
procedure TAmClientVoiceControl.SetColor(val:TColor);
begin
  inherited Color:=val;
  self.FSpectr.ColorBack:= val;
  self.FSpectr.NewBmpDraw;
end;

end.



{

procedure TAmClientVoiceControlScrollBar.DrawSpectrRL(Spectr:TAmBassSpectrRL);
var
  x,ht : integer;
  ott:Real;
  Ri:real;
  I:integer;
begin
  BMP.Width:= Width;
  BMP.Height:= Height;
  Parent.DoubleBuffered := true;

  BMP.Canvas.Brush.Color := $00795535;
  BMP.Canvas.FillRect(Rect(0,0,BMP.Width,BMP.Height));

  //draw peaks
  ht :=  ClientHeight div 2;

  ott:=    length(Spectr.bufL) /BMP.Width ;

 i:=0;
 Ri:=0;
 for x:=0 to BMP.Width-1 do
 begin
  //for i:=0 to length(wavebufL)-1 do
   i:= Round( Ri );
   if (i>=0) and (i < length(Spectr.bufL)-1 ) then
   begin


  //  Memo1.Lines.Add(trunc((wavebufL[i]/32768)*ht * 2).ToString);
    BMP.Canvas.MoveTo(x,ht);
	  BMP.Canvas.Pen.Color := $00E1CDBB;
    BMP.Canvas.LineTo(x,(ht+2)-1);

    BMP.Canvas.LineTo(x,(ht) - trunc((Spectr.bufL[i]/32768)*(ht * 2)));
    BMP.Canvas.Pen.Color := $00E1CDBB;
    BMP.Canvas.MoveTo(x,ht+2);
	  BMP.Canvas.LineTo(x,ht+2+trunc((Spectr.bufR[i]/32768)*ht * 2));
    Ri:= Ri+ ott;
   end;


 end;
 Refresh;
end;
}