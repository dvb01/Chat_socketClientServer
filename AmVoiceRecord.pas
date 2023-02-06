unit AmVoiceRecord;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls,Vcl.ExtCtrls, Vcl.Forms, Vcl.Dialogs,Bass, Bassenc_mp3,Bassenc, Vcl.StdCtrls,math,

  AmHandleObject, {нужен что бы объект принимал win message можно написать свой или посмотреть конец модуля}
  AmUserType;     {нужен что бы дождатся выполнения потока прям в процедуре а не в событии конец модуля в помощь}

 const AM_BASS_SPECTR_TH_RESULT = wm_user+1901;
  type
  WAVHDR = packed record
    riff:			array[0..3] of AnsiChar;
    len:			DWord;
    cWavFmt:		array[0..7] of AnsiChar;
    dwHdrLen:		DWord;
    wFormat:		Word;
    wNumChannels:	Word;
    dwSampleRate:	DWord;
    dwBytesPerSec:	DWord;
    wBlockAlign:	Word;
    wBitsPerSample:	Word;
    cData:			array[0..3] of AnsiChar;
    dwDataLen:		DWord;
  end;


 type
   PAmBassSpectrRL =  ^TAmBassSpectrRL;
   TAmBassSpectrRL = record
    bufL:  TamArrayOfReal;
    bufR : TamArrayOfReal;
  end;
   PAmBassSpectrMono =  ^TAmBassSpectrMono;
   TAmBassSpectrMono = TamArrayOfReal;//array of Real;





  type TAmBassSpectrThread = class(TThread)
    private
      Fdecoder : HSTREAM;
      Fbpp: dword;
      FSpectr:PAmBassSpectrRL;
      FSize:integer;
      FHandleResult:Cardinal;
    protected
      procedure Execute; override;
      procedure ScanSpectr;
    public
      constructor Create(decoder:HSTREAM;bpp:dword;Spectr:PAmBassSpectrRL;Size:integer;HandleResult:Cardinal);
  end;

 type  {Повторно объект создавать нельзя есть переменная AmBass}
       {Все объекты которые добавляем в List:TList; удалять не нужно они саси удалятся если они в листе}

                   {нужен что бы объект принимал win message можно написать свой или посмотреть конец модуля}
  TAmBass = class (AmHandleObject.TamHandleObject)
    Type TOnChangePos=procedure (Pos:integer;Max:integer;CaptionTime:string) of object;
    Type TOnChangeMaxRecord=procedure (Max:integer;CaptionTime:string) of object;
    Type TOnChangeNewFile=procedure (NewFile:string;NewControl:TObject) of object;
    Type TOnRecGood=procedure  of object;
    Type TOnRecNot=procedure (StrError:string)  of object;
   strict Private

     FRecord_Chan:    HSTREAM;	// playback channel
     FRecord_RChan:   HRECORD;	// recording channel
     FRecord_WaveHdr: WAVHDR;  // WAV header


     FRecord_ActivDeviceNumber:integer;
     FRecord_ListDevice:TStringList;
     FRecord_DeviceName:string;
     FRecord_LevelVolume:integer;
     FRecord_OnChangePosition: TOnChangeMaxRecord;
     FRecord_OnGoodStart: TOnRecGood;
     FRecord_OnNotStart:  TOnRecNot;
     FRecord_OnEnd: TOnChangeMaxRecord;
     FRecord_TimerMax:TTimer;

     FOnChangePos:TOnChangePos;
     FPlay_Chan:HSTREAM;
     FPlay_TimerPosition:TTimer;
     FPlay_PositionMax:integer;
     FPlay_Position:integer;



     FPlay_PositionChange:Boolean;
     FPlay_Status :integer;
     FPlay_OnEnd: TNotifyEvent;
     FPlay_OnChangeNewFile : TOnChangeNewFile;
     FPlay_FullFileName:string;
     FVoiceControl:TObject;

     Spectr_GetBufferResult:integer;


     procedure SetPlay_Notify(FullFileName:string;OnChangePosition:TOnChangePos;OnEnd:TNotifyEvent;OnChangeNewFile:TOnChangeNewFile);
     procedure
     Record_OnTimerMax(S:Tobject);
     procedure SetPlay_Position(val:integer);
     procedure Play_IsEnd();
     procedure Play_OnTimerPosition(S:Tobject);
     procedure SetRecord_LevelVolume(val:integer);
     procedure Record_DeviceNameUpdate;
     procedure SetRecord_ActivDeviceNumber(val:integer);
     procedure AddDeviceForRecord;
     procedure StartSet;
     Function Play_AddFile(FullFileName:string):boolean;
     Procedure SpectrResultPost(var Msg:Tmessage); message AM_BASS_SPECTR_TH_RESULT;
   private
     LastError:string;
     IsYouCanUsePlay:boolean;
     IsYouCanUseRecord:boolean;
     List:TList;
     FRecord_WaveStream : TMemoryStream;
     FPlay_WaveStream : TMemoryStream;
     constructor Create;
     destructor Destroy ;override;
    Public

     property Record_ListDevice: TStringList read FRecord_ListDevice;
     property Record_ActivDeviceNumber:integer read FRecord_ActivDeviceNumber write SetRecord_ActivDeviceNumber ;
     property Record_DeviceName:string read FRecord_DeviceName;
     property Record_LevelVolume:integer  read FRecord_LevelVolume write SetRecord_LevelVolume ;
     Function Record_Start:boolean;
    // Function Record_Start:boolean;
     Function Record_Stop:boolean;
     Function Record_Clear:boolean;
     Function Record_GetStream:TMemoryStream;
     Function Record_SaveToFile(FullFileNameMp3:string):boolean;
     property Record_OnChangePosition:TOnChangeMaxRecord  read FRecord_OnChangePosition write FRecord_OnChangePosition;
     property Record_OnGoodStart:TOnRecGood  read FRecord_OnGoodStart write FRecord_OnGoodStart;
     property Record_OnNotStart:TOnRecNot  read FRecord_OnNotStart write FRecord_OnNotStart;
     property Record_OnEnd:TOnChangeMaxRecord  read FRecord_OnEnd write FRecord_OnEnd;




     Property Play_VoiceControl:Tobject read FVoiceControl;
     Function Play_IsSameFile(FullFileName:string):Boolean;
     Function Play_Status():integer;
     Function Play_Start(FullFileName:string):boolean; overload;
     Function Play_Start(FullFileName:string;OnChangePosition:TOnChangePos;OnEnd:TNotifyEvent;OnChangeNewFile:TOnChangeNewFile):boolean; overload;
     Function Play_Start(FullFileName:string;aVoiceControl:TObject):boolean; overload;
     Function Play_Start(WaveStream:TMemoryStream;OnChangePosition:TOnChangePos;OnEnd:TNotifyEvent;OnChangeNewFile:TOnChangeNewFile):boolean; overload;
     Function Play_Start(WaveStream:TMemoryStream):boolean; overload;

     Function Play_Free():boolean;
     Function Play_Stop():boolean;
     Function Play_Pause():boolean;
     Function Play_Resume():boolean;

     Function Play_GetCaptionTime(Pos,Max:integer):string;
     property Play_PositionMax:integer  read FPlay_PositionMax;
     property Play_Position:integer  read FPlay_Position write SetPlay_Position;
    // property Play_OnChangePosition:TOnChangePos  read FOnChangePos write FOnChangePos;
    // property Play_OnEnd:TNotifyEvent  read FPlay_OnEnd write FPlay_OnEnd;
     //AmBass один а контролов воспроизведения много подключись что бы узнать когда сменился файл что прошлый контрол выключить
    // property Play_OnChangeNewFile:TNotifyEvent  read FPlay_OnChangeNewFile write FPlay_OnChangeNewFile;

     procedure Spectr_GetBufferLR(FullFileName:string;var Spectr:TAmBassSpectrRL;QualityPixsel:integer);   overload;
     procedure Spectr_GetBufferMono(FullFileName:string;var Spectr:TAmBassSpectrMono;QualityPixsel:integer);  overload;
     procedure Spectr_GetBufferLR(WaveStream:TMemoryStream;var Spectr:TAmBassSpectrRL;QualityPixsel:integer); overload;
     procedure Spectr_GetBufferMono(WaveStream:TMemoryStream;var Spectr:TAmBassSpectrMono;QualityPixsel:integer); overload;
  end;


var AmBass: TAmBass;

implementation
 uses AmVoiceControl;
//------------------------------------------------------------------------------

{ TScanThread }

constructor TAmBassSpectrThread.Create(decoder:HSTREAM;bpp:dword;Spectr:PAmBassSpectrRL;Size:integer;HandleResult:Cardinal);
begin

  inherited create(False);
  Priority := tpNormal;
  FreeOnTerminate := true;
  FDecoder := decoder;
  Fbpp:=bpp;
  FSpectr:=Spectr;
  FSize:=Size;
  FHandleResult:=HandleResult;
  //self.Start;
end;

procedure TAmBassSpectrThread.Execute;
begin
  inherited;
  ScanSpectr;
  Terminate;
end;

procedure TAmBassSpectrThread.ScanSpectr;
var
  cpos,level : DWord;
  peak : array[0..1] of DWORD;
  position : DWORD;
  RealPosition : DWORD;
  counter : integer;
begin
  try
    setlength(FSpectr^.bufL,FSize);  //PB.ClientWidth;
    setlength(FSpectr^.bufR,FSize);  //PB.ClientWidth;
    cpos := 0;
    peak[0] := 0;
    peak[1] := 0;
    counter := 0;

    while not self.Terminated do
    begin
      level := BASS_ChannelGetLevel(FDecoder); // scan peaks
      if (peak[0]<LOWORD(level)) then
        peak[0]:=LOWORD(level); // set left peak
      if (peak[1]<HIWORD(level)) then
        peak[1]:=HIWORD(level); // set right peak
      if BASS_ChannelIsActive(FDecoder) <> BASS_ACTIVE_PLAYING then
      begin
        position := cardinal(-1); // reached the end
      end else
      begin
        RealPosition:= BASS_ChannelGetPosition(FDecoder,BASS_POS_BYTE);
        position :=  RealPosition div Fbpp;
      end;



       // showmessage(RealPosition.ToString);
      if position > cpos then
      begin
        inc(counter);
        if counter <= length(FSpectr^.bufL)-1 then
        begin
          FSpectr^.bufL[counter] := math.RoundTo(peak[0]/32768,-2);
          FSpectr^.bufR[counter] := math.RoundTo(peak[1]/32768,-2);
        end;

        if (position >= dword(FSize{PB.ClientWidth})) then
          break;
        cpos := position;
       end;


      peak[0] := 0;
      peak[1] := 0;
    end;

  finally
       BASS_StreamFree(FDecoder); // free the decoder
       PostMessage(FHandleResult,AM_BASS_SPECTR_TH_RESULT,0,1);
  end;

end;
//------------------------------------------------------------------------------

procedure TAmBass.Spectr_GetBufferLR(WaveStream:TMemoryStream;var Spectr:TAmBassSpectrRL;QualityPixsel:integer);
var
  chan2: HSTREAM;
  bpp,MaxLength:dword; // stream bytes per pixel
  Rs:boolean;
begin
    if QualityPixsel<10 then QualityPixsel:=10;
    if QualityPixsel>10000 then QualityPixsel:=10000;


    //getting peak levels in seperate thread, stream handle as parameter
		chan2 := BASS_StreamCreateFile(True,WaveStream.Memory,0,WaveStream.Size,BASS_STREAM_DECODE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
	 	if (chan2 = 0) then chan2 := BASS_MusicLoad(True,WaveStream.Memory,0,WaveStream.Size,BASS_MUSIC_DECODE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF},1);

    MaxLength:= BASS_ChannelGetLength(chan2,BASS_POS_BYTE);
    bpp := MaxLength div QualityPixsel;//PB.ClientWidth; // stream bytes per pixel
    if (bpp < BASS_ChannelSeconds2Bytes(chan2,0.02)) then // minimum 20ms per pixel (BASS_ChannelGetLevel scans 20ms)
    begin
       bpp := BASS_ChannelSeconds2Bytes(chan2,0.02);
       QualityPixsel:=  MaxLength div bpp;

    end;



    Spectr_GetBufferResult:=0;
    TAmBassSpectrThread.Create(chan2,bpp,@Spectr,QualityPixsel,Handle); // start scanning peaks in a new thread

    {нужен что бы дождатся выполнения потока прям в процедуре а не в событии конец модуля в помощь}
    Rs:=AmUserType.ToWaitFor.GoDelay(50,
    function:boolean begin Result:= Spectr_GetBufferResult=1  end);

    if Rs then
    begin

    end;

end;
procedure TAmBass.Spectr_GetBufferMono(WaveStream:TMemoryStream;var Spectr:TAmBassSpectrMono;QualityPixsel:integer);
var SpectrRl:TAmBassSpectrRl;
i,M:integer;
begin
    Spectr_GetBufferLR(WaveStream,SpectrRl,QualityPixsel);
    M:= Length(SpectrRl.bufL);
    SetLength(Spectr,M);
    for I := 0 to M-1 do Spectr[i]:= Max(SpectrRl.bufL[i],SpectrRl.bufR[i]);

end;
procedure TAmBass.Spectr_GetBufferLR(FullFileName:string;var Spectr:TAmBassSpectrRL;QualityPixsel:integer);
var

  i : integer;

  chan2: HSTREAM;
  bpp,MaxLength:dword; // stream bytes per pixel
  Rs:boolean;
begin
    if QualityPixsel<10 then QualityPixsel:=1;
    if QualityPixsel>1200 then QualityPixsel:=1200;


    //getting peak levels in seperate thread, stream handle as parameter
		chan2 := BASS_StreamCreateFile(FALSE,pchar(FullFileName),0,0,BASS_STREAM_DECODE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
	 	if (chan2 = 0) then chan2 := BASS_MusicLoad(FALSE,pchar(FullFileName),0,0,BASS_MUSIC_DECODE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF},1);

    MaxLength:= BASS_ChannelGetLength(chan2,BASS_POS_BYTE);
    bpp := MaxLength div QualityPixsel;//PB.ClientWidth; // stream bytes per pixel
    if (bpp < BASS_ChannelSeconds2Bytes(chan2,0.02)) then // minimum 20ms per pixel (BASS_ChannelGetLevel scans 20ms)
    begin
       bpp := BASS_ChannelSeconds2Bytes(chan2,0.02);
       QualityPixsel:=  MaxLength div bpp;

    end;


    Spectr_GetBufferResult:=0;
    TAmBassSpectrThread.Create(chan2,bpp,@Spectr,QualityPixsel,Handle); // start scanning peaks in a new thread

    {нужен что бы дождатся выполнения потока прям в процедуре а не в событии конец модуля в помощь}
    Rs:=AmUserType.ToWaitFor.GoDelay(50,
    function:boolean begin Result:= Spectr_GetBufferResult=1  end);

    if Rs then
    begin

    end;

end;
procedure TAmBass.Spectr_GetBufferMono(FullFileName:string;var Spectr:TAmBassSpectrMono;QualityPixsel:integer);
var SpectrRl:TAmBassSpectrRl;
i,M:integer;
begin
    Spectr_GetBufferLR(FullFileName,SpectrRl,QualityPixsel);
    M:= Length(SpectrRl.bufL);
    SetLength(Spectr,M);
    for I := 0 to M-1 do Spectr[i]:= Max(SpectrRl.bufL[i],SpectrRl.bufR[i]);
end;

Procedure TAmBass.SpectrResultPost(var Msg:Tmessage);// message AM_BASS_SPECTR_TH_RESULT;
begin
    Spectr_GetBufferResult:=Msg.LParam;
end;

Function TAmBass.Play_AddFile(FullFileName:string):boolean;
var
	f: PChar;
begin
//BASS_Encode_MP3_StartFile
  Result:=false;
	f := PChar(FullFileName);
	FPlay_Chan := BASS_StreamCreateFile(False, f, 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
	if FPlay_Chan <> 0 then Result:=true
	else
	LastError:='Error creating stream!';

end;

Function TAmBass.Play_Status():integer;
begin
    Result:=FPlay_Status;
end;
Function TAmBass.Play_IsSameFile(FullFileName:string):Boolean;
begin
  Result:=FPlay_FullFileName= FullFileName;
end;

procedure TAmBass.SetPlay_Notify(FullFileName:string;OnChangePosition:TOnChangePos;OnEnd:TNotifyEvent;OnChangeNewFile:TOnChangeNewFile);
begin

   FPlay_FullFileName:= FullFileName;
   FOnChangePos:= OnChangePosition;
   FPlay_OnEnd:=  OnEnd;
   if Assigned(FPlay_OnChangeNewFile) then FPlay_OnChangeNewFile(FullFileName,FVoiceControl);
   FPlay_OnChangeNewFile:= OnChangeNewFile;
end;

Function TAmBass.Play_Start(FullFileName:string;aVoiceControl:TObject):boolean;
var Control:TAmClientVoiceControl;
begin
   FVoiceControl:=nil;
   if Assigned(aVoiceControl) and  (aVoiceControl is TAmClientVoiceControl) then
   begin
      FVoiceControl:= aVoiceControl;
      Control:= FVoiceControl as TAmClientVoiceControl;
       Result:=Play_Start(FullFileName,Control.BASSChangePositionTin,Control.BASSChangePositionEnd,Control.BASSChangeNewFile);
   end
   else Result:=Play_Start(FullFileName);

end;
Function TAmBass.Play_Start(FullFileName:string):boolean;
begin
 Result:=Play_Start(FullFileName,nil,nil,nil);
end;
Function TAmBass.Play_Start(
                                    FullFileName:string;
                                    OnChangePosition:TOnChangePos;
                                    OnEnd:TNotifyEvent;
                                    OnChangeNewFile:TOnChangeNewFile):boolean;
//var   Info: Bass_ChannelInfo;
begin
   FPlay_FullFileName:= FullFileName;
   FPlay_TimerPosition.Enabled := false;
   Bass_StreamFree(FPlay_Chan);
   FPlay_WaveStream.Clear;
   if fileexists (FullFileName) then
   begin
    try
     FPlay_WaveStream.LoadFromFile(FullFileName);
    except end;
   end;
   Result:=Play_Start(FPlay_WaveStream,OnChangePosition,OnEnd,OnChangeNewFile);

end;
Function TAmBass.Play_Start(WaveStream:TMemoryStream):boolean;
begin
    FPlay_FullFileName:='';
    Result:=Play_Start(WaveStream,nil,nil,nil);
end;
Function TAmBass.Play_Start(WaveStream:TMemoryStream;OnChangePosition:TOnChangePos;OnEnd:TNotifyEvent;OnChangeNewFile:TOnChangeNewFile):boolean;
begin
    Result:=False;
    FPlay_TimerPosition.Enabled := false;
    Bass_StreamFree(FPlay_Chan);
    SetPlay_Notify(FPlay_FullFileName,OnChangePosition,OnEnd,OnChangeNewFile);

    FPlay_Chan := Bass_StreamCreateFile(True, WaveStream.Memory, 0, WaveStream.Size ,BASS_STREAM_AUTOFREE or BASS_MUSIC_STOPBACK {BASS_SAMPLE_LOOP} {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});//
    if FPlay_Chan <> 0 then
    begin
      FPlay_Position:=0;
      FPlay_PositionMax := round(BASS_ChannelBytes2Seconds(FPlay_Chan, BASS_ChannelGetLength(FPlay_Chan, BASS_POS_BYTE)));
      Result:=Bass_ChannelPlay(FPlay_Chan, FAlse);
      if Result then
      begin
        FPlay_Status:=1;
        FPlay_TimerPosition.Enabled := true
      end
      else LastError:='Can''t play ChannelPlay';

    end
    else LastError:='Can''t play the file';

end;




Function TAmBass.Play_Pause():boolean;
begin
   Result:=false;
  if FPlay_Chan<>0 then
  begin
  Result:= BASS_ChannelPause(FPlay_Chan);
  FPlay_Status:=2;
  end;
  FPlay_TimerPosition.Enabled := False;
end;

Function TAmBass.Play_Resume():boolean;
begin
  if FPlay_Chan<>0 then
  begin

    Result:=Bass_ChannelPlay(FPlay_Chan, false);
    FPlay_TimerPosition.Enabled := Result;
    FPlay_Status:=1;
  end;
end;

Function TAmBass.Play_Stop():boolean;
begin

   FPlay_TimerPosition.Enabled := False;
   Result:= BASS_ChannelStop(FPlay_Chan);
   Bass_StreamFree(FPlay_Chan);
   FPlay_Chan:=0;
   FPlay_Status:=3;
end;
Function TAmBass.Play_Free():boolean;
begin

   Play_Stop;
   FPlay_FullFileName:= '';
   FPlay_OnChangeNewFile:=nil;
   FOnChangePos:= nil;
   FPlay_OnEnd:=  nil;
   FVoiceControl:=nil;
   FPlay_Chan:=0;
   FPlay_Status:=-1;
end;



Function TAmBass.Play_GetCaptionTime(Pos,Max:integer):string;
    function Tostr (Val:integer):string;
    begin
      Result:=  Val.ToString;
      if Length(Result)=1 then Result:='0'+Result;
    end;
var
     min,sek:string;
     minM,sekM:string;
begin

   minM:= Tostr(Floor(Max div 60));
   sekM:= Tostr(Max mod 60);
 if Pos>=0 then
 begin
   min:= Tostr(Floor(Pos div 60));
   sek:= Tostr(Pos mod 60);
   Result:= min+':'+sek+' / '+minM+':'+sekM;
 end
 else
 begin
   Result:=minM+':'+sekM;
 end;
 

end;
procedure TAmBass.Play_OnTimerPosition(S:Tobject);

var V:integer;
CaptionTime:string;
begin
 FPlay_TimerPosition.Enabled := False;
 try
     V := round(BASS_ChannelBytes2Seconds(FPlay_Chan, BASS_ChannelGetPosition(FPlay_Chan, BASS_POS_BYTE)));
    if V<>FPlay_Position then
    begin
      FPlay_Position:= V;



      if Assigned(FOnChangePos) then
      begin
        FPlay_PositionChange:=true;
        try
           FOnChangePos(FPlay_Position,FPlay_PositionMax,Play_GetCaptionTime(FPlay_Position,FPlay_PositionMax));
        finally
          FPlay_PositionChange:=false;
        end;

      end;
    end;
 finally
    Play_IsEnd;
 end;


end;
procedure TAmBass.Play_IsEnd();
begin


   if (FPlay_Position >= FPlay_PositionMax)
   //or (FPlay_PositionSave >= FPlay_PositionMax)
   then
   begin


        Play_Stop ;
       if Assigned(FPlay_OnEnd) then FPlay_OnEnd(FVoiceControl);

   end
   else FPlay_TimerPosition.Enabled := True;



   // if not FPlay_PositionEnd then FPlay_PositionEnd:= FPlay_Position+FPlay_PositionInc >  FPlay_PositionMax;

end;
procedure TAmBass.SetPlay_Position(val:integer);
begin
  if not FPlay_PositionChange then
  begin
    if val<0 then val:=0;
    if val>FPlay_PositionMax then val:=FPlay_PositionMax;
    FPlay_Position:=  val;
    BASS_ChannelSetPosition(FPlay_Chan, BASS_ChannelSeconds2Bytes(FPlay_Chan, FPlay_Position), BASS_POS_BYTE);

  end;
end;


constructor TAmBass.Create;
begin
     inherited Create;
     FPlay_Status:=0;
     IsYouCanUsePlay:=true;
     IsYouCanUseRecord:=true;
     List:= TList.Create;
     FRecord_ListDevice:= TStringList.Create;
     FRecord_ActivDeviceNumber:=-1;
     FRecord_WaveStream:= TMemoryStream.Create;
     FPlay_WaveStream := TMemoryStream.Create;
     FPlay_TimerPosition:=TTimer.Create(nil);
     FPlay_TimerPosition.Interval:=1000;
     FPlay_TimerPosition.Enabled:=false;
     FPlay_TimerPosition.OnTimer:= Play_OnTimerPosition;

     FRecord_TimerMax:=TTimer.Create(nil);
     FRecord_TimerMax.Interval:=1000;
     FRecord_TimerMax.Enabled:=false;
     FRecord_TimerMax.OnTimer:= Record_OnTimerMax;

     StartSet;
end;
destructor TAmBass.Destroy ;
begin
  List.Clear;
  List.Free;
  FRecord_TimerMax.Enabled:=false;
  FPlay_TimerPosition.Enabled:=false;
  FPlay_TimerPosition.Free;
  FRecord_TimerMax.Free;
  FRecord_ListDevice.Free;
  FRecord_WaveStream.Free;
  FPlay_WaveStream.Free;
	BASS_RecordFree;
	BASS_Free;
	BASS_Stop;

   inherited ;
end;
procedure TAmBass.StartSet;
begin

	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
	 //	MessageBox(0,'An incorrect version of BASS.DLL was loaded', nil,MB_ICONERROR);
	 //	Halt;
     LastError:=  'An incorrect version of BASS.DLL was loaded';
     IsYouCanUsePlay:=false;
     IsYouCanUseRecord:=false;
     exit;
	end;
	// Initialize audio - default device, 44100hz, stereo, 16 bits
	if not BASS_Init(-1, 44100, 0, Handle, nil) then
  begin
     LastError:= 'Error initializing audio!';
     IsYouCanUsePlay:=false;

  end;
  if not BASS_RecordInit(-1) then
  begin
     LastError:= 'Cannot start default recording device!';
     IsYouCanUseRecord:=false;

  end;
  if IsYouCanUseRecord then AddDeviceForRecord;

end;
procedure  TAmBass.AddDeviceForRecord;
var
  r: Boolean;
  i: Integer;
  dName: PAnsiChar;
  level: Single;
begin
	i := 0;
	dName := BASS_RecordGetInputName(i);
	while dName <> nil do
	begin
		FRecord_ListDevice.Add(StrPas(dName));
		// is this one currently "on"?
		if (BASS_RecordGetInput(i, level) and BASS_INPUT_OFF) = 0 then
    FRecord_ActivDeviceNumber := i;
		Inc(i);
		dName := BASS_RecordGetInputName(i);
	end;
  SetRecord_ActivDeviceNumber(FRecord_ActivDeviceNumber);
end;
procedure TAmBass.SetRecord_ActivDeviceNumber(val:integer);
var
	i: Integer;
    r: Boolean;
begin
  if (val >=0) and (val < FRecord_ListDevice.Count) then
  begin
        FRecord_ActivDeviceNumber:=  val;
        // enable the selected input
          r := True;
          i := 0;
          // first disable all inputs, then...
        while r do
          begin
          r := BASS_RecordSetInput(i, BASS_INPUT_OFF, -1);
              Inc(i);
        end;
          // ...enable the selected.
        BASS_RecordSetInput(FRecord_ActivDeviceNumber, BASS_INPUT_ON, -1);
        Record_DeviceNameUpdate; 	// update info

  end;

end;
procedure TAmBass.Record_DeviceNameUpdate;
var
	i: DWord;
	level: Single;
begin
	I := BASS_RecordGetInput(FRecord_ActivDeviceNumber, level);
	FRecord_LevelVolume := Round(level * 100);	// set the level slider


	case (i and BASS_INPUT_TYPE_MASK) of
		BASS_INPUT_TYPE_DIGITAL: FRecord_DeviceName := 'digital';
		BASS_INPUT_TYPE_LINE:    FRecord_DeviceName := 'line-in';
		BASS_INPUT_TYPE_MIC:     FRecord_DeviceName := 'microphone';
		BASS_INPUT_TYPE_SYNTH:   FRecord_DeviceName := 'midi synth';
		BASS_INPUT_TYPE_CD:      FRecord_DeviceName := 'analog cd';
		BASS_INPUT_TYPE_PHONE:   FRecord_DeviceName := 'telephone';
		BASS_INPUT_TYPE_SPEAKER: FRecord_DeviceName := 'pc speaker';
		BASS_INPUT_TYPE_WAVE:    FRecord_DeviceName := 'wave/pcm';
		BASS_INPUT_TYPE_AUX:     FRecord_DeviceName := 'aux';
		BASS_INPUT_TYPE_ANALOG:  FRecord_DeviceName := 'analog';
	else
		FRecord_DeviceName := 'undefined';
	end;
end;
procedure TAmBass.SetRecord_LevelVolume(val:integer);
begin
  if val<0 then val:=0;
  if val>100 then val:=100;
  FRecord_LevelVolume:=  val;
	BASS_RecordSetInput(FRecord_ActivDeviceNumber, 0, FRecord_LevelVolume / 100);
end;


(* This is called while recording audio *)
function AmBassRecordingCallback(channel: HRECORD; buffer: Pointer; length: DWORD; user: Pointer): boolean; stdcall;
begin
    // Copy new buffer contents to the memory buffer
	//AmBass.FRecord_WaveStream.Write(buffer^, length);
    // Allow recording to continue
	//Result := True;
  Result := Bool(BASS_Encode_IsActive(channel));
end;
procedure SaveProc(handle:HENCODE; channel:DWORD; buffer:Pointer; length:DWORD; user:Pointer);stdcall;
begin
//showmessage('1');
  AmBass.FRecord_WaveStream.Write(buffer^, length);
end;
procedure TAmBass.Record_OnTimerMax(S:Tobject);
var PositionMax:integer;
Cap:string;
begin
   if Assigned(FRecord_OnChangePosition) then
   begin
     PositionMax:= (round(BASS_ChannelBytes2Seconds(FRecord_rchan,BASS_ChannelGetPosition(FRecord_rchan, BASS_POS_BYTE))));
     FRecord_OnChangePosition(PositionMax,Play_GetCaptionTime(-1,PositionMax));
   end;
end;
Function TAmBass.Record_Start:boolean;
begin
   Result:=false;
   Record_Clear;
 LastError:='';
  FRecord_rchan := BASS_RecordStart(44100, 2, BASS_RECORD_PAUSE, @AmBassRecordingCallback, 0);
  if FRecord_rchan = 0 then  LastError:='Couldn''t start recording';

 if LastError='' then
 begin
  if (BASS_Encode_Start(FRecord_rchan, 'lib\lame.exe --alt-preset standard - ', BASS_ENCODE_AUTOFREE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF}, SaveProc, 0) = 0) then
  begin
    LastError:='Couldn''t start encoding...' + #10
      + 'Make sure OGGENC.EXE (if encoding to OGG) is in the same' + #10
      + 'direcory as this RECTEST, or LAME.EXE (if encoding to MP3).';
    BASS_ChannelStop(FRecord_rchan);
    FRecord_rchan := 0;

  end;
 end;

 if LastError='' then
  Result:=BASS_ChannelPlay(FRecord_rchan, FALSE); // resume recoding

  if Result then
  begin
   if Assigned(FRecord_OnGoodStart) then FRecord_OnGoodStart;
   FRecord_TimerMax.Enabled:=true;
  end
  else
  begin
    if Assigned(FRecord_OnNotStart) then FRecord_OnNotStart(LastError);
  end;

end;

(*
Function TAmBass.Record_Start:boolean;
begin
  Result:=false;
  if  FRecord_ActivDeviceNumber < 0 then Exit;
  Record_Clear;

	// generate header for WAV file
	with FRecord_WaveHdr do
    begin
		riff := 'RIFF';
		len := 36;
		cWavFmt := 'WAVEfmt ';
		dwHdrLen := 16;
		wFormat := 1;
		wNumChannels := 2;
		dwSampleRate := 44100;
		wBlockAlign := 4;
		dwBytesPerSec := 176400;
		wBitsPerSample := 16;
		cData := 'data';
		dwDataLen := 0;
    end;
	FRecord_WaveStream.Write(FRecord_WaveHdr, SizeOf(WAVHDR));
	// start recording @ 44100hz 16-bit stereo
	FRecord_rchan := BASS_RecordStart(44100, 2, 0, @AmBassRecordingCallback, nil);
	if FRecord_rchan = 0 then
	begin
		LastError:='Couldn''t start recording!';
		FRecord_WaveStream.Clear;
	end
  else  Result:=true;

end; *)
Function TAmBass.Record_Stop:boolean;
var
	i: integer;
  PositionMax:integer;
  CaptionTime:string;
begin
  PositionMax:= (round(BASS_ChannelBytes2Seconds(FRecord_rchan,BASS_ChannelGetPosition(FRecord_rchan, BASS_POS_BYTE))));
  CaptionTime:=Play_GetCaptionTime(0,PositionMax);

  FRecord_TimerMax.Enabled:=False;
  Result:=false;
  BASS_ChannelStop(FRecord_rchan);
  FRecord_rchan := 0;
 {	BASS_ChannelStop(FRecord_rchan);
	//bRecord.Caption := 'Record';
	// complete the WAV header
	FRecord_WaveStream.Position := 4;
	i := FRecord_WaveStream.Size - 8;
	FRecord_WaveStream.Write(i, 4);
	i := i - $24;
	FRecord_WaveStream.Position := 40;
	FRecord_WaveStream.Write(i, 4);
	FRecord_WaveStream.Position := 0;  }
	// create a stream from the recorded data
 //	FRecord_chan := BASS_StreamCreateFile(True, FRecord_WaveStream.Memory, 0, FRecord_WaveStream.Size, 0);
	if FRecord_chan <> 0 then Result:=true
  else
  begin
    LastError:='Error creating stream from recorded data!';
  end;

 if  Assigned(FRecord_OnEnd) then FRecord_OnEnd(PositionMax,CaptionTime);
end;
Function TAmBass.Record_Clear:boolean;
begin
  FRecord_TimerMax.Enabled:=False;
	if FRecord_WaveStream.Size > 0 then
   begin	// free old recording
		BASS_StreamFree(FRecord_chan);
		FRecord_WaveStream.Clear;
  	end;
   Result:=true;
end;
Function TAmBass.Record_GetStream:TMemoryStream;
begin
  Result:=FRecord_WaveStream;
end;
Function TAmBass.Record_SaveToFile(FullFileNameMp3:string):boolean;
var R:HENCODE;
begin
 //BASS_Encode_MP3_Start                                 //BASS_ENCODE_FP_AUTO
 // R:= BASS_Encode_MP3_StartFile (FRecord_RChan, 0,BASS_ENCODE_LIMIT   or BASS_UNICODE, PChar (FullFileNameMp3));
  //showmessage(BASS_ErrorGetCode.ToString);
   //BASS_ERROR_CREATE
   FRecord_WaveStream.SaveToFile(FullFileNameMp3);
end;


















initialization
begin
  AmBass :=  TAmBass.Create;
end;

finalization
begin
 FreeAndNil(AmBass);
end;


{

type
  TamHandleObject = class (Tobject)
  private
    FHandle: HWND;
    procedure WndProc(var Msg: TMessage);
  public
    property Handle: HWND read FHandle;
    constructor Create;
    destructor Destroy; override;
  end;

........

constructor TamHandleObject.Create;
begin
  inherited create;
  FHandle := AllocateHWnd(WndProc);//AllocateHWnd(WndProc);Dispatch
end;

destructor TamHandleObject.Destroy;
begin
  if FHandle <> 0 then
  begin
    DeallocateHWnd(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TamHandleObject.WndProc(var Msg: TMessage);
begin
  try
    Dispatch(Msg);
  except
    Application.HandleException(Self);
  end;
end;





type ToWaitFor = record
     Type Tfun = reference to function : boolean;
Class function  GoDelay(SecondMax:integer;Fun:Tfun):boolean; inline; static;
Class function  ..........
end;

Class function  ToWaitFor.GoDelay(SecondMax:integer;Fun:Tfun):boolean;
var i:integer;
begin
    i:=0;
    Result:=Fun;
    while  not Result and (i<=SecondMax*10) do
    begin
      Result:= Fun;
      if Result then break;
      delay(100);
      inc(i);
    end;

end;


procedure Delay(ms: Cardinal);
var
  TheTime: Cardinal;
begin
  TheTime := GetTickCount + ms;
  while GetTickCount < TheTime do
  begin
     Application.ProcessMessages;
    sleep(1);//на некоторых системах не нужна эта строка
  end;


end;
}

end.
