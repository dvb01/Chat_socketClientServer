unit UnitClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, System.Win.ScktComp,AmUserType,AmLogTo,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmChatCustomSocket, Vcl.ComCtrls,AmChatClientComponets,
  DateUtils, Vcl.Grids,math,AmControls, Vcl.WinXPanels,
  Vcl.OleCtnrs, Vcl.OleCtrls, SHDocVw,ShellAPI, Richedit,ShellAnimations,
  ES.BaseControls, ES.Layouts, ES.Images,AmList, Vcl.DBCtrls,AmChatClientMessageBox,AmChatClientContactBox,
  JsonDataObjects, RxRichEd ,AmVoiceRecord, RxCtrls, registry,ShlObj,
  Vcl.ExtDlgs,FileCtrl,AmMessageFilesControl,
  dxGDIPlusClasses,AmGrafic,System.Diagnostics
  ,AmChatClientFileThread,Jpeg, ES.PaintBox, AmFormPopapNewMessage, Vcl.AppEvnts,
  mmsystem, System.UITypes,AmVoiceControl;






type
  TForm2 = class(TForm)
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Memo3: TMemo;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Button6: TPanel;
    Panel1: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure FormCreate(Sender: TObject);

    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);


    procedure Button6Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);

  private
    { Private declarations }
     procedure WMHotkey( var msg: TWMHotkey ); message WM_HOTKEY;
     procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
     procedure WMEnterSizeMove(var Message: TMessage);message WM_ENTERSIZEMOVE;
     procedure WMExitSizeMove(var Message: TMessage); message WM_EXITSIZEMOVE;
  public
    { Public declarations }
     Procedure FormPopapNewMessageOnOpenDialog(S:Tobject);
     procedure ChatClientFormContNoRead(Val:integer);

    //procedure WndProc2(var Message: TMessage);  message WM_NOTIFY;
   protected

  end;

var
  Form2: TForm2;

implementation
uses AmChatClientForm;
{$R *.dfm}

procedure TForm2.WMHotkey( var msg: TWMHotkey );
begin
  if msg.hotkey = 1 then
  begin
    Panel1Click(self);
  end;
end;
procedure TForm2.WMEnterSizeMove(var Message: TMessage); //message WM_ENTERSIZEMOVE;
begin
     inherited;
     if Assigned(ChatClientForm) then
     begin
       if ChatClientForm.PanelChatClient.Visible then
       begin
         postMessage(ChatClientForm.Handle,WM_ENTERSIZEMOVE,0,0);


       end;
     end;

   //  showmessage('1');
   //  logmain.Log('EnterSize пользователь начал тянуть за края формы что бы изменить ее размер');
     // здесь это не работает на форме повесить эти процедуры и вызвать SavePosBegin
end;
procedure TForm2.WMExitSizeMove(var Message: TMessage); //message WM_EXITSIZEMOVE;
begin
    inherited;
     if Assigned(ChatClientForm) then
     begin
       if ChatClientForm.PanelChatClient.Visible then
       begin
         postMessage(ChatClientForm.Handle,WM_EXITSIZEMOVE,0,0);

       end;
     end;
end;








procedure TForm2.WMDropFiles(var Msg: TWMDropFiles);// message WM_DROPFILES;
begin
   if AmChatClientForm.ChatClientForm.Showing then
   AmChatClientForm.ChatClientForm.WMDropFiles(Msg)
   else DragFinish(Msg.Drop);
end;
{
procedure TMyP.WM_SHOWWINDOW(var N:Tmessage);
begin
  inherited;
     Logmain.log('WM_NCACTIVATE ');
end;  }








procedure TForm2.Button6Click(Sender: TObject);
begin
ChatClientForm.ChatClientLogIn;
end;












{

procedure TForm2.Button14Click(Sender: TObject);
var P:TAmConvecterToСollagePhoto;
I:integer;
Out_Bm:TBitMap;
s,s2:TmemoryStream;
jpg:TJpegImage;
begin
 if not  openDialog1.Execute then exit;


   P:=  TAmConvecterToСollagePhoto.Create;
   s:=  TmemoryStream.Create;
   s2:= TmemoryStream.Create;
   jpg:= TJpegImage.Create;
   try
    // EsImage4.Picture.LoadFromFile(openDialog1.FileName);
    for I := 0 to openDialog1.Files.Count-1 do
     P.AddFileNameImg(openDialog1.Files[i]);

     P.SetNeedMaxWidth:=600;

   //  EsImage3.Picture.Bitmap.Assign(Out_Bm);
     P.Convecter;
     //EsImage4.Picture:=  p.ResultGetPicture(0);
     //showmessage(s.Size.ToString);
     P.ResultGetStream(s,80,0);
     PhotoRect:= P.ResultGetRect;
     PhotoSize:= P.ResultGetFullSize;



     Label12.Caption:= formatFloat('0.000',s.Size / 1000000) +'Mb '+' / '+formatFloat('0.000',AmSizeFIle(openDialog1.FileName) / 1000000) +'Mb ';

    // showmessage(s.Size.ToString);
   //  amScaleImage.GetPic();
       //s.Position:=0;
      // s2.LoadFromFile(openDialog1.FileName+'');
      // s2.Position:=0;
    // EsImage3. DoubleBuffered:=true;
     //EsImage3.Picture :=P.ResultGetPicture(10);

     // P.ResultGetStream(s,10);

    // EsImage3.Picture.LoadFromFile(openDialog1.FileName);
       // s.Position:=0;
      // Image33.Picture.LoadFromStream(s);
        //s.Position:=0;
       EsImage3.Picture.LoadFromStream(s);
     //  EsImage3.Stretch
     exit;
     s.Position:=0;
       Image33.Picture.LoadFromStream(s);
     // Image33.Picture.LoadFromStream(s2);
  //  EsImage3.Picture:=P.ResultGetPicture(10);
     //s.SaveToFile(openDialog1.FileName+'New1111.jpg');
   // EsImage3.Picture.LoadFromFile(openDialog1.FileName+'New1111.jpg');
   //  P.ResultGetPicture(190);
    // s.SaveToFile(openDialog1.FileName+'New1111.jpg');
     //showmessage(s.Size.ToString);
     //EsImage3.Picture:=nil;
    // EsImage3.Picture:=P.ResultGetPicture(0);
   // s.Position:=0;;
   //   EsImage3.Picture.LoadFromFile(openDialog1.FileName+'New1111.jpg');
    // EsImage3.Picture.Bitmap:= P.ResultGetBitMap(10);

     PhotoRect:= P.ResultGetRect;
     PhotoSize:= P.ResultGetFullSize;

     s.Clear;
     jpg.Assign(EsImage4.Picture.Bitmap);
     jpg.DIBNeeded;
     jpg.CompressionQuality := 100;
     jpg.Grayscale:=false;
     jpg.Compress;
    // jpg.SaveToFile(Edit1.Text+'\SnapShots(new)\'+numberStr+'(new).bmp');
     jpg.SaveToStream(s);

     s.Position:=0;

     Label13.Caption:= formatFloat('0.000',s.Size / 1000000) +'Mb '+' / '+formatFloat('0.000',AmSizeFIle(openDialog1.FileName) / 1000000) +'Mb ';
    // EsImage3.Picture.LoadFromStream(s);
   //  EsImage3.Picture.SaveToFile(openDialog1.FileName+'New.jpg');

   finally
    P.Free;
    s.Free;
    s2.Free;
    jpg.Free;
   end;
end;
}
 {
procedure TForm2.EsImage3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var d,w:real;
  I: Integer;
  var RectScale:TArray<TRect>;
  s:string;
begin

   d:= PhotoSize.cy / EsImage3.Height;

    Setlength(RectScale,length(PhotoRect));

    for I := 0 to length(PhotoRect)-1 do
    begin
       RectScale[i]:= Rect(
                            round(PhotoRect[i].Rect.Left / d) ,
                            round(PhotoRect[i].Rect.Top / d) ,
                            round(PhotoRect[i].Rect.Right / d) ,
                            round(PhotoRect[i].Rect.Bottom / d)
                          );
       if PtInRect(RectScale[i],Point(X,Y)) then
       begin

           memo4.Lines.Add(PhotoRect[i].IndificatorFileName);
       //
       end;

    end;


end;
  }








procedure TForm2.FormCreate(Sender: TObject);


//var
//  Banner: String;
  //buf: array [0..$ff] of Char;
 //const EM_SETCUEBANNER = $1501;
//var
//Style: LongInt;

begin


                         {
if SetWindowLong(self.Handle, GWL_EXSTYLE, GetWindowLong(self.Handle, GWL_EXSTYLE) or WS_EX_LAYERED) = 0 then
ShowMessage('Error !');

if not SetLayeredWindowAttributes(self.Handle, 0, Transp, LWA_ALPHA) then
ShowMessage('Error !'); }
DragAcceptFiles(Handle, true);

//ListBox2.Params.Style := Params.Style xor WS_VSCROLL;

  {
Style := GetWindowLong(ListBox2.Handle, GWL_STYLE);
Style := Style xor WS_VSCROLL;
SetWindowLong(ListBox2.Handle, GWL_STYLE, Style);
 }
//  RichEdit4.Perform( EM_SETCUEBANNER , 0 , PWideChar('test'));
  //Banner:=UTF8Encode('Введите логин');

  //Utf8ToUnicode(PWideChar(@buf), PAnsiChar(Banner), Length(Banner));
  //SendMessage(RichEdit4.Handle, EM_SETCUEBANNER, 0, Integer(@buf));

//mask := SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
//SendMessage(RichEdit2.Handle, EM_SETEVENTMASK, 0, mask or ENM_LINK);
//SendMessage(RichEdit2.Handle, EM_AUTOURLDETECT, Integer(True), 0);
//RichEdit2.Text :='The best site - '+ 'www.sql.ru';

     ReportMemoryLeaksOnShutdown := true;
    LogMain:= TamLogString.create(self);



    LogMain.SetErrorLog.fmemo                :=  Memo3;
    LogMain.SetErrorLog.FileName             :=  ExtractFilePath(Application.ExeName)+'set\log\log.txt';
    LogMain.SetErrorLog.TimeNeed                  :=true;
    LogMain.SetErrorLog.Format                    := 1;
    LogMain.SetErrorLog.CanCreatePopPap      := 3;

    LogMain.SetLog.fmemo                     :=Memo3;
    LogMain.SetLog.FileName                  :=  ExtractFilePath(Application.ExeName)+'set\log\log.txt';
    LogMain.SetLog.TimeNeed                  :=true;
    LogMain.SetLog.Format                    := 2;
    LogMain.SetLog.CanCreatePopPap           := 3;

   // LogMain.SetErrorApplication.fmemo        :=nil;
   // LogMain.SetErrorApplication.FileName     :=  ExtractFilePath(Application.ExeName)+'set\log\logErrorApplication.log';
   // LogMain.SetErrorApplication.TimeNeed                  :=true;
   // LogMain.SetErrorApplication.Format                    := 1;
    LogMain.SetErrorApplication.CanCreatePopPap      := 0;

    LogMain.Global_CanCreatePopap:=false;
    LogMain.Global_CanCreateNewRecordToMemo:=true;
    LogMain.Global_CanCreateNewRecordToFile :=true;
    LogMain.CanCreateNewFileIfFileBig    :=false;

    LogMain.UpdateSettingExeAfterCreate;

 //   Application.CreateForm(TFormChatClient, FormChatClient);



 // СontrolToScreen:=TamIsСontrolToScreenHook.create;


//PotSockFile:=TAmClientSockFile.Create(logmain);

      // CreateChatClick(SELF);
      ChatClientFormCreate(self,Edit1.Text,AmInt(Edit2.Text,0),LogMain);
      ChatClientForm.OnFormPopapNewMessageOnOpenDialog := FormPopapNewMessageOnOpenDialog;
      ChatClientForm.ChatClient.OnChangeCountNoReadMessage:= ChatClientFormContNoRead;
      ChatClientForm.ChatClientLogIn;

if not RegisterHotkey(Handle, 1,  MOD_SHIFT, vkX) then
  ShowMessage('Unable to assign Alt-Shift-F9 as hotkey.');

//В событии OnClose удаляем горячую клавишу:

end;
procedure TForm2.ChatClientFormContNoRead(Val:integer);
begin
    Button6.Caption:= 'Зайти в чат ('+ AmStr(Val)+')';
end;
Procedure TForm2.FormPopapNewMessageOnOpenDialog(S:Tobject);
begin
   if Form2.WindowState = wsMinimized then    Form2.WindowState  :=wsNormal;
   

   if PageControl1.activePage <> TabSheet1 then PageControl1.activePage:= TabSheet1;
   if not ChatClientForm.ChatClient.UserActivSeans then ChatClientForm.ChatClientLogIn;

end;
procedure TForm2.Panel1Click(Sender: TObject);
var r:string;

begin



 if not Panel2.Visible then
 begin
  r:=InputBox('',#1,'');
  if r='w12345' then
  begin
    Panel2.Visible:=true;
    Panel2.BringToFront;
  end;
 end
 else Panel2.Visible:=false;

end;

procedure TForm2.Panel4Click(Sender: TObject);
var V:TAmClientVoiceControl;
begin

 V:= TAmClientVoiceControl.Create(self);
 V.Parent:=   Form2;
 V.Align:=alBottom;
 v.FileName:= 'D:\untitled1.mp3';
 v.SpectrQualityPixsel:=1400;
// v.Color:=clred;
 v.RefreshSpectrForFileName;
// delay(2000);
 v.Height:=100;
   exit;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
   UnRegisterHotkey( Handle, 1 );
   ChatClientFormDestroy;
   LogMain.Free;
end;
procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   LogMain.Global_CanCreatePopap:=false;
   LogMain.Global_CanCreateNewRecordToMemo:=false;


   //СontrolToScreen.free;

  // PotSockFile.Free;
  // showmessage('TForm2 FormDestroy');
  // ChatClientForm.Free;
   //ChatClientForm:=nil;
   //LogMain.Free;
end;



procedure TForm2.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

begin
//logmain.Log(WheelDelta.ToString);
//scr.ScrollingAtWheel(-WheelDelta);

  WheelDelta:= round(WheelDelta * 0.65);



  {   else if (BoxOptimaizer<>nil)and MouseInControl(BoxOptimaizer) then
  begin
      Od:= BoxOptimaizer.Scroll.Position;
      Nw:= BoxOptimaizer.Scroll.Position - WheelDelta;
     //BoxTest.Box.VertScrollBar.Position:=BoxTest.Box.VertScrollBar.Position- WheelDelta
     BoxOptimaizer.Scroll.Position:=  Nw;


    BoxOptimaizer.MouseWheelInput(Od,Nw);
  end }

 if Assigned(ChatClientForm) and ChatClientForm.CanFocus and ChatClientForm.Showing and MouseInControl(ChatClientForm) then
  begin
   ChatClientForm.FormMouseWheel(Sender,Shift,WheelDelta,MousePos, Handled);
  end;

  ;
Handled:=true;
end;



end.




      { Memo:=    TRichEdit.Create(P);
       Memo.Parent:= P;
       Memo.Top := 21;
       Memo.Align:=alcLient;
       Memo.AlignWithMargins:=true;
       Memo.Margins.Bottom:=10;
       Memo.Margins.Top:=21;
       Memo.Margins.Left:=50;
     //  Memo.a
       Memo.Left := 46;
       Memo.Font.Color := clred;
       Memo.Font.Size:=10;
       Memo.Font.Name := 'Arial';

      Memo.BevelInner := bvNone;
      Memo.BevelOuter := bvNone;
      Memo.BorderStyle := bsNone;
      Memo.Text:= 'sssssssssssssss' +Cap.ToString;}

 //
 // Memo.Color:=   $0049362E  ;



{procedure MakeRounded(Control: TWinControl);
var R: TRect;
    Rgn: HRGN;
begin
 with Control do begin
  R := ClientRect;
  rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, width, width); // для окружности поиграйтесь p5,p6
  Perform(EM_GETRECT, 0, lParam(@r));
  InflateRect(r, 0, 0);
  Perform(EM_SETRECTNP, 0, lParam(@r));
  SetWindowRgn(Handle, rgn, True);
  Invalidate
 end
end;}
