unit AmMessageFilesControl;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Dialogs,Vcl.StdCtrls,Vcl.ComCtrls,Vcl.ExtCtrls,
  Math,ES.BaseControls, ES.Layouts, ES.Images ,AmVoiceRecord,AmUserType,Amlist,
   System.Zip,Vcl.Forms,System.Generics.Collections,AmGrafic,JsonDataObjects,
   AmChatClientComponets,AmControls, ShellApi,ES.PaintBox,AmHandleObject,AmLogto;



  {
  алгоритм отправки примема файлов
  1. отправление
     1. на форму перетаскиваются файлы
     2. их имена заносятся в лист бокс
       в лист боксе видно только привью файла
     3.нажимается кнопка отправить
       подготовка файлов
       1. проверить что эти файлы есть на диске
       2. найти фото среди файлов
       3. все фото помесить в одну фотку
       4. получить 10 на 10 для привью
       5. получить 500 на 500 или меньще для норм отображения
       6. добавить в архив 10 и 500
       7. оригиналы фото также добавить в архив
       8. остальные файлы которые не фото тоде добавить в арзив
       9. добавить в архив файл конфиг в котором есть инфа о том что мы слелали

       10. создать 2й архив в который добавить только 500 10 и файл конфиг

       на выходе унас есть 2 стрима с архивами плюс конфиг данные о отпавляемых данных


     4. отправить запрос на сервер что бы получить имя для загрузки
        ответ это File<IDuser>_<IDfile>  и если есть колаж то File<IDuser>_<IDfile>_CollagePhoto
        2 имени приходят в любом случаи

     5. по полученым именам загружаем файлы
        сначало CollagePhoto
        потом отправляем юзеру сообщение
        потом закачиваем сам архив оригиналов

  2. примем
      приходит сообщение
      в нем есть инфа какие файлы были отправлены
      фото 10
      и размер колажа что бы подогнать высоту сообщения
       отображаем
       юзер видит что ему отправили файлы
       фото размытое и список файлов

       компонент знает что фото 10 у него
       отправляет запрос на сервер что бы скачать фото 500
       юзер видит что фото скачивается
       если фото уже  было скачано то оно берется с диска
        юзер хочет посмотреть что за файлы ему прислали и кликает
        если файлов нет придлагается скачать оригиналы
        если есть с зип архира извлекается 1 файл если поштучно




  }


   // имена файлов которые должны быть в архиве если в архиве есть фотки
 CONST
   AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10 =  '__PhotoCollage10__.jpg';
   AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500 = '__PhotoCollage500__.jpg';
   AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_DEF = '__PhotoDef__.jpg';
   AM_CHAT_FILEZIP_NAMEFILE_CONFIG =      '__Config__.json';
   AM_CHAT_FILEZIP_NAMEFILE_PHOTO_EXT   = '.png|.jpeg|.jpg|.bmp';

 type {не использую}
   TAmClientMessageOneFileImg =class(TEsLayout)
   strict private
     FtimerFocus:Ttimer;
     FFn:TpaintBox;
     FImg:Es.Images.TEsImage;
     FIconPhoto:TIcon;
     FFileNamePhoto:string;
     FIsMouseActiv:boolean;
     procedure FnPaint(S:TObject);
     procedure ImgMouseEnter(Sender: TObject);
     procedure ImgMouseLeave(Sender: TObject);
     procedure FnMouseEnter(Sender: TObject);
     procedure FnMouseLeave(Sender: TObject);
     procedure TimerFocusOnTimer(Sender: TObject);
     procedure SetFileNamePhoto(val: string);
    protected
    public
     CorrectIcoX, CorrectIcoY:integer;
     CorrectTextX, CorrectTextY:integer;
     property  FileBox:TpaintBox Read FFn;
     property  Img:TEsImage Read FImg;

     //это не физичиский путь к картике он может быть случайным используется что бы отобразить имя файла и вывести иконку расширения файла
     property  FileNamePhoto:string  read FFileNamePhoto write SetFileNamePhoto;

     // обновляет размер картинки Img что размеа совподал с изображением и пропорциями
     procedure UpdateHeight;
     constructor Create(AOwner: TComponent); override;
     destructor Destroy ; override;
   end;










 type
   TAmClientMessageFilesPaintBox =class;
   TAmClientMessageFilesZipControl= class;
   TAmClientMessageFilesImageCollage=class;

   TAmChatZipFile_Config =Record

     public
       //CollageNeed:boolean;
      // CollageNeed_MaxWidth:integer;
       LinkPB:TAmClientMessageFilesPaintBox;
       LinkImage:TAmClientMessageFilesImageCollage;
       PhotoSqueeze:boolean;
       PhotoSqueeze_MaxWidth:integer;
       Index_Config:integer;

       procedure JsonToConfig(JsonStream:TStream);

       procedure AddListFileOther(Arr:TJsonArray);
       procedure AddListFileOtherTextJson(ArrJsonString:string);

       procedure AddListFilePhoto(Arr:TJsonArray);
       procedure AddListFilePhotoTextJson(ArrJsonString:string);
       procedure Clear;

   End;
  TAmClientMessageFilesZipEvent = procedure (FilesZip:TAmClientMessageFilesZipControl;Sender:TObject; CompLparam,Index:integer;FileName:string) of object;
   {задача класса получает архив(имя файла на диске) распокавать и отобразить файлы на PaintBox или Image}
   //используется в самом сообщении для отображенния файлов и картинок
   // т.е прищло сообщение от когото нужно показать файлы в чате
  TAmClientMessageFilesZipControl =class(TEsLayout)




    strict private
      FZipFile:string;
      FPhoto10FileName:string;
      FPhoto500FileName:string;
      FPhotoDefaultFileName,FPhotoDefaultResource:string;

      FBoxItemHeight:integer;
      FPb:TAmClientMessageFilesPaintBox;
      FImg : TAmClientMessageFilesImageCollage;
      FdivCollage:string;
      FinishPot:integer;

      FOnOpenManagger:TAmClientMessageFilesZipEvent;
      FOnDownloadStart:TAmClientMessageFilesZipEvent;
      FOnDownloadAbort:TAmClientMessageFilesZipEvent;
      FOnDownloadPause:TAmClientMessageFilesZipEvent;


      procedure SetZipFile(val:String);
      procedure SetPhoto10FileName(val:String);
      procedure SetPhoto500FileName(val:String);
      procedure SetPhotoDefaultFileName(val:String);
      procedure SetPhotoDefaultResource(val:String);
      procedure SetPhotoDefault(val:String;IsResource:boolean);
      procedure SetColor(val:TColor);
      function GetColor:TColor;


       procedure FileOnDownloadEvent(S:Tobject;Proc:TAmClientMessageFilesZipEvent);
       procedure FileOnOpenManagger(S:Tobject);
       procedure FileOnDownloadStart(S:Tobject);
       procedure FileOnDownloadAbort(S:Tobject);
       procedure FileOnDownloadPause(S:Tobject);
     private
       IsCreateWindMn:boolean;
      // создает новую картинку и заносит ее в ListControl  Stream получаю когда читаю zip архив ZipFileName в SetZipFile
        procedure LoadNewImg(Fn:String;IsResource:boolean);
    //  procedure CreateNewImgToGroop(Stream:TMemoryStream;Fn:String);
      //procedure AM_FinishPotRender(var msg:Tmessage);message AM_FINISH_POT_RENDER ;
       procedure ResizeSelf(W:integer);
       procedure ResizeImg(NowWidth:integer);
     protected
      procedure CreateWnd; override;
      procedure Paint; override;
      procedure Resize; override;
      procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth,MaxHeight: Integer); override;

     public
       Config:TAmChatZipFile_Config;

       IdPhoto10:string;
       IdPhoto500:string;
       IdFile:string;
       //содержит array файлов с zip архива которые нельзя отобразить как картинку
     //  FListFiles:TamListVar<String>;

       // содержит  array фото (оригиналов) и доп информацию например array trect что бы знать когда кликают по колажу на какиую именно кликнули
    //   FListPhoto:TamListVar<String>;


       // это сама картинка если она есть (это калаж картинок в ахиве есть оригиналы  всех фото плюс калаж с конкретным именем)
       //  колаж есть 2х размеров
       // 10x10 и макс 500x500 или меньще
       // в архиве также есть файл конфиг который содержит настройки и доп инфу о файлах
     // Property СollagePhoto:Es.Images.TEsImage read FImg;
      Property Color: TColor  read GetColor write SetColor;
      // устаналивать файлы когда они  уже есть на компе
      Property ZipFileName :string read FZipFile Write SetZipFile;

      Property Photo10FileName :string read FPhoto10FileName Write SetPhoto10FileName;

      Property Photo500FileName :string read FPhoto500FileName Write SetPhoto500FileName;

      Property PhotoDefaultFileNames :string read FPhotoDefaultFileName Write SetPhotoDefaultFileName;
      Property PhotoDefaultResource :string read FPhotoDefaultResource Write SetPhotoDefaultResource;
      //размер Height элемента со списка FListFiles
      Property  BoxItemHeight :integer read FBoxItemHeight Write FBoxItemHeight;

      //визуальный список с FListFiles который нарисован в TPaintBox
      Property  BoxFiles :TAmClientMessageFilesPaintBox read FPb;
      Property  BoxImage :TAmClientMessageFilesImageCollage read FImg;

       property OnOpenManagger  :  TAmClientMessageFilesZipEvent  read FOnOpenManagger  write FOnOpenManagger ;
       property OnDownloadStart :  TAmClientMessageFilesZipEvent  read FOnDownloadStart write FOnDownloadStart ;
       property OnDownloadAbort :  TAmClientMessageFilesZipEvent  read FOnDownloadAbort write FOnDownloadAbort ;
       property OnDownloadPause :  TAmClientMessageFilesZipEvent  read FOnDownloadPause write FOnDownloadPause ;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy ; override;

      //в паренте при resize запусскается эта процедура что бы за 1раз изменить размер
      // после ее выполнения знаем текуший размер self в параметре передается ширина парента
      procedure ResizeParamIntput(W:integer);
  end;


   TAmClientMenuFilesPaintBox =  class (TAmClientPopapMenu)
    strict private
       Procedure  ClickToItem(S:Tobject;NameItem:String);
    public
      constructor Create(aParent: TWincontrol); reintroduce;
   end;


    TMessageFilesItemState = (mfitNoDownload,mfitProcessing,mfitIsDownload,mfitNone,mfitNoSelect,mfitErrorDownload);


    TAmClientMessageFilesImageCollage = class (TEsImage)
      type
        TItem = class
           FControl:TAmClientMessageFilesImageCollage;
           IsDestroy:boolean;
           aRect:Trect;
           FileName:string;
           FullFileName:string;
           SizeFile:int64;
           constructor Create;
           destructor Destroy; override;
      end;
      private
       FOnOpenManagger:TNotifyEvent;
       FOnDownloadStart:TNotifyEvent;
       procedure ListsClear;
       procedure RunFile(FileName:string);
       procedure RunPapkaSelectFile(FileName:string);
       procedure  OpenPapap(State:TMessageFilesItemState);
       function   ItemAtPos(Pos: TPoint): Integer;
      protected
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
      public
       IndexActiv:integer;
       CollageSizeMax:TSize;
       List: TList<TItem>;
       Popap:TAmClientMenuFilesPaintBox;
       property OnOpenManagger : TNotifyEvent  read FOnOpenManagger  write FOnOpenManagger ;
       property OnDownloadStart : TNotifyEvent  read FOnDownloadStart write FOnDownloadStart ;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
    end;

   TAmClientMessageFilesPaintBox = class(TEsPaintBox)

     Type
       TItem = class

       private
         FControl:TAmClientMessageFilesPaintBox;

         Ico:TGraphic;
         FPositionBar:int64;
         FProcentBar:integer;
         FColorBar:TColor;
         FileNameView:string;
         FFileNameFull:string;
         procedure GradDel;

         procedure SetPositionBar(val:int64);
         procedure SetFileNameFull(val:string);

      public
         IsDestroy:boolean;
         KindDownload:TMessageFilesItemState;
         aRect:TRect;
         aRectTextSize:TRect;


         FileName:string;
         SizeFile:int64;
         ComponentLparam:integer;
         LastJsonError:string;
         property FileNameFull:string Read FFileNameFull write SetFileNameFull;
         property Control:TAmClientMessageFilesPaintBox Read FControl write FControl;
         property PositionBar:int64 Read FPositionBar write SetPositionBar;
         property ColorBar:Tcolor Read FColorBar write FColorBar;
         procedure Clear;
         procedure Repaint;
         constructor Create;
         destructor Destroy; override;
       end;
     private
       FItemIndexMouseMove:integer;
       FItemIndexActiv:integer;
       FColorItemMouseMovi:TColor;
       FColorItemSelect:TColor;
       FBoxItemHeight:integer;
       FList:Tlist<TItem>;

       FOnOpenManagger:TNotifyEvent;
       FOnDownloadStart:TNotifyEvent;
       FOnDownloadAbort:TNotifyEvent;
       FOnDownloadPause:TNotifyEvent;

       procedure  RunFile(FileName:string);
       procedure  RunPapkaSelectFile(FileName:string);

       procedure ListsClear;

       procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

       procedure DoPaintProcentBar(Item:TItem;Index:integer);
       procedure PaintProcentBar(Item:TItem;Index:integer;aRect:TRect);
       procedure PaintIco(Item:TItem;Index:integer);
       procedure PaintText(Item:TItem;Index:integer);
     protected
       procedure Paint ; override;
       function PaintOneFile(Item:TItem;Index:integer):integer;
       procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
      // procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
       function ItemAtPos(Pos: TPoint): Integer;
     public
       Popap:TAmClientMenuFilesPaintBox;

       property ListFiles:Tlist<TItem> REad FList ;

       procedure  OpenPapap(State:TMessageFilesItemState);
       property IndexActiv : integer  read FItemIndexActiv ;
    //   property ListFile: TamListVar<string>  write SetListFile ;

       property OnOpenManagger : TNotifyEvent  read FOnOpenManagger  write FOnOpenManagger ;
       property OnDownloadStart : TNotifyEvent  read FOnDownloadStart write FOnDownloadStart ;
       property OnDownloadAbort : TNotifyEvent  read FOnDownloadAbort write FOnDownloadAbort ;
       property OnDownloadPause : TNotifyEvent  read FOnDownloadPause write FOnDownloadPause ;

       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
   end;



  // лист бокс используется когда на форму перетаскиваются файлы что бы их отобразить (юзер пытается отправить файлы готовит их)
   type
    TAmClientListBoxFilesAtSend = class (TAmListBoxFilesCustom)
      private
       FOnNeedOpenDialog: TNotifyEvent;

       Procedure  PopapClickToItem(S:Tobject;NameItem:String);
      protected
      public
       property OnNeedOpenDialog:TNotifyEvent read FOnNeedOpenDialog write  FOnNeedOpenDialog;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
    end;




    // юзер нажимает на кнопку отправить файлы
    // здесь выполнится подготовка проверка и запоковка в архив
    // выход это Tmemory Stream который нужно отправить
    // внутри арфива будет калаж фото 10 калаж фото 500 или меньше
    // файл конфиг  и все остальные файлы с их именами
   type
    TAmClientAddToArchivFilesAtSend = class(TamHandleObject)
      type
        TResult = record  //cодаюется и удаляется вместе с объектом
           Result:boolean; // есди в zip был добавлен хоть 1 файл
           Photo10StringBase64:string; //картинка 10 на 10  для отправки в сообщении в base64
           Photo500StringBase64:string; //картинка 500 на 500  для отправки в сообщении в base64
           Photo10Result:boolean;
           Photo500Result:boolean;
           Photo10SizeStream:int64;
           Photo500SizeStream:int64;
           ZipSizeStream:int64;

           CollageSizeMax:Tsize; // размер картинки  коллаж
           CountFileCollage:integer;       // кол-во картинок которые в колаже для отправки в сообщении
           //ListFileOther:TamListVar<string>; // список файлов которые не в колаже и не картинки для отправки в сообщении
           ListFileOtherJson:string;
           ListFilePhotoJson:string;
        end;
    private
        Collage:TAmConvecterToСollagePhoto;

        Procedure ConvertDo;
        Procedure ConvertPost(var Msg:Tmessage);message wm_user+1;
        Procedure CollageAddPhoto(ListFullNameFiles:TamListVar<string>;var ResultListOther:TamListVar<string>);

    public
      function  Get(
                        OutStreamZip:TMemoryStream;              //out  //архив для отправки не в сообщении а как загрузка файла

                        ListFullNameFiles:TamListVar<string>; //input
                        CollageNeed:boolean;                  //input
                        CollageNeed_MaxWidth:integer;         //input
                        PhotoSqueeze :boolean;                //input
                        PhotoSqueeze_MaxWidth:integer        //input


                    ):TAmClientAddToArchivFilesAtSend.TResult; overload;

      function  Get(
                        FileNamePhoto10:string;
                        FileNamePhoto500:string;
                        FileNameZipFile:string;
                        ListFullNameFiles:TamListVar<string>; //input
                        CollageNeed:boolean;                  //input
                        CollageNeed_MaxWidth:integer;         //input
                        PhotoSqueeze :boolean;                //input
                        PhotoSqueeze_MaxWidth:integer        //input


                    ):TAmClientAddToArchivFilesAtSend.TResult; overload;
       constructor Create;
       destructor Destroy; override;
    end;


  // запускается поток отправки файлов на сервер
 { type
   TAmClientFileSendPot =  class(TAmClientPot)
       const
          ServerGetFileId_Call = wm_user+6000;
          ServerGetFileId_Back = wm_user+6001;
        private
          Procedure Send;
        public
         //input

         SysHandle:Cardinal;
         ListFiles:TamListVar<string>;
         Comment:string;
         constructor Create;
    end;
         }



   type
    TAmClientListBoxFilesAtView = class (TAmListBoxFilesCustom)
      private
       Procedure  PopapClickToItem(S:Tobject;NameItem:String);
      protected
      public
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
    end;

   type
    TAmClientListBoxFilesAtViewZip = class (TAmListBoxFilesCustom)
     type TOnBeforeSaveFile = procedure (FnZip:string; out NewFn:string; out CanSave:boolean) of object;
      private
       FOnBeforeSaveFile:TOnBeforeSaveFile;
       Procedure  PopapClickToItem(S:Tobject;NameItem:String);
      protected
        Procedure  SaveFile(FileToZipName:String);
      public
       FileNameZip:string;
       Procedure ViewZip;
       property OnBeforeSaveFile:TOnBeforeSaveFile read FOnBeforeSaveFile write FOnBeforeSaveFile;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
    end;




{
procedure TAmClientMessageFilesZipControl.PbPaint(S:TObject);
var
  aTop: Integer;
  aRect:Trect;
  I:integer;
begin
    FPb.Canvas.Brush.Color := FPb.Color;
    FPb.Canvas.FillRect(self.ClientRect);
    aTop:=0;
    for I := 0 to Config.ListFileOther.Count-1 do  aTop:= PbPaintOneFile(Config.ListFileOther[i],aTop);
    if aTop=0 then
    begin
      FPb.Canvas.Brush.Color := FPb.Color;
      FPb.Canvas.Font.Color := clwhite;
      FPb.Canvas.TextOut(6, aTop+6 ,'Посмотреть файлы...');
    end;
   // UpdateSize;
end;
function TAmClientMessageFilesZipControl.PbPaintOneFile(Fn:string;aTop:integer):integer;
var Icon:TIcon;
var ItemHeight:integer;
begin



   Icon := TIcon.Create;
   try

         Icon.Handle :=AmGetFileExtAssociatedIcon(Fn, true,false);
       if Icon.Handle>0 then
       begin
        if  (FBoxItemHeight - Icon.Height >0)
        and (FBoxItemHeight-Icon.Width>0) then
         FPb.Canvas.Draw(((FBoxItemHeight- Icon.Height) div 2),aTop+((FBoxItemHeight- Icon.Height) div 2),Icon)
        else FPb.Canvas.Draw(5,aTop+5,Icon);
       end;

   finally
     Icon.Free;
   end;
   FPb.Canvas.Brush.Color := FPb.Color;
   FPb.Canvas.Font.Color := $00E8B4B3;
   FPb.Canvas.TextOut(FBoxItemHeight, aTop+6 ,Fn);
   REsult:=  aTop+ FBoxItemHeight;
end;
}

implementation

                   {TAmClientMessageFilesImageCollage.TItem}
constructor TAmClientMessageFilesImageCollage.TItem.Create;
begin
    inherited create;
    FControl:=nil;
    IsDestroy:=false;
    aRect:=Rect(0,0,0,0);
    FileName:='';
    FullFileName:='';
    SizeFile:=0;
end;
destructor TAmClientMessageFilesImageCollage.TItem.Destroy;
begin
    if IsDestroy then exit;
    IsDestroy:=true;
    FControl:=nil;
    aRect:=Rect(0,0,0,0);
    FileName:='';
    FullFileName:='';
    SizeFile:=0;
    inherited;
end;
                        {TAmClientMessageFilesImageCollage}
constructor TAmClientMessageFilesImageCollage.Create(AOwner: TComponent);
begin
    inherited create(AOwner);
    List:= TList<TItem>.create;
    CollageSizeMax.cx:=0;
    CollageSizeMax.cy:=0;
    IndexActiv:=-1;

    Popap:=nil;
end;
destructor TAmClientMessageFilesImageCollage.Destroy;
begin
    ListsClear;
    List.Free;
    if  AmCheckControl(Popap) then  Popap.Free;
    Popap:=nil;
    inherited;
end;
procedure TAmClientMessageFilesImageCollage.ListsClear;
var
  I: Integer;
begin
   for I := 0 to List.Count-1 do
   List[i].Free;
   List.Clear;
end;
function   TAmClientMessageFilesImageCollage.ItemAtPos(Pos: TPoint): Integer;
  var d:real;
  I: Integer;
  var RectScale:TArray<TRect>;
  s:string;
begin
   Result:=-1;
   d:= CollageSizeMax.cy / Height;

    Setlength(RectScale,List.Count);

    for I := 0 to List.Count-1 do
    begin
       RectScale[i]:= Rect(
                            round(List[i].aRect.Left / d) ,
                            round(List[i].aRect.Top / d) ,
                            round(List[i].aRect.Right / d) ,
                            round(List[i].aRect.Bottom / d)
                          );
       if PtInRect(RectScale[i],Pos) then
       begin
           REsult:=i;

       //
       end;

    end;

end;
procedure TAmClientMessageFilesImageCollage.RunFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, 'open', PChar(FileName), '', nil,SW_SHOWNORMAL)
end;
procedure TAmClientMessageFilesImageCollage.RunPapkaSelectFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, nil, 'explorer.exe', PChar('/select,' + FileName), nil, SW_SHOWNORMAL);
end;
procedure  TAmClientMessageFilesImageCollage.OpenPapap(State:TMessageFilesItemState);
begin
       if       State in [mfitProcessing]  then Popap.Open(self,1)
       else if  State in [mfitNoDownload] then  Popap.Open(self,0)
       else if  State in [mfitErrorDownload] then Popap.Open(self,0)
       else if  State in [mfitIsDownload] then  Popap.Open(self,2)
       else if  State in [mfitNoSelect] then    Popap.Open(self,4)
       else                                              Popap.Open(self,3)
end;
procedure TAmClientMessageFilesImageCollage.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
   if Button = TMouseButton.mbLeft then
   begin
     IndexActiv:=ItemAtPos(Point(X,Y));
     if IndexActiv>=0 then
     begin
       if  List[IndexActiv].FullFileName<>'' then RunPapkaSelectFile(List[IndexActiv].FullFileName)
       else
     end;
     
   end
   else if Button = TMouseButton.mbRight then
   begin
     IndexActiv:=ItemAtPos(Point(X,Y));
     if IndexActiv>=0 then
     begin
       OpenPapap(mfitNoDownload);
     end;
   end;
        


end;


              {TAmClientMessageFilesPaintBox.TItem}
constructor TAmClientMessageFilesPaintBox.TItem.Create;
begin
   inherited create;
   IsDestroy:=false;
   Ico:=nil;
   Clear;
   FPositionBar:=20;
   FColorBar:=  $0055AAFF;
end;
destructor TAmClientMessageFilesPaintBox.TItem.Destroy;
begin
   if IsDestroy then exit;
   IsDestroy:=true;
   Clear;
   inherited;
end;
procedure TAmClientMessageFilesPaintBox.TItem.Clear;
begin
   KindDownload:=mfitnone;
   LastJsonError:='';
   ComponentLparam:=0;
   FControl:=nil;
   FProcentBar:=0;
   FPositionBar:=1;
   SizeFile:=1;
   KindDownload:=mfitNone;
   FileNameView:='';
   FFileNameFull:='';
   FileName:='';
   GradDel;
   Ico:=nil;
   aRect:=Rect(0,0,0,0);
   aRectTextSize:=Rect(0,0,0,0);
end;
procedure TAmClientMessageFilesPaintBox.TItem.GradDel;
begin
  if  Assigned(Ico) then
  begin
    if ( Ico is TBitmap) then  TBitmap(Ico).Free
    else if Ico is TIcon then  TIcon(Ico).Free
    else
    Ico.Free;

    Ico:=nil;
  end;
end;
procedure TAmClientMessageFilesPaintBox.TItem.Repaint;
begin
   if Assigned(FControl) then FControl.Repaint;
end;
procedure TAmClientMessageFilesPaintBox.TItem.SetPositionBar(val:int64);
begin


  if (val>=0) and ( FPositionBar<>val )  then
  begin
    FPositionBar:=val;
    if SizeFile<=0 then SizeFile:=1;
    FProcentBar :=round(FPositionBar*100/ SizeFile);
    if (FProcentBar<0) then FProcentBar :=0;
    if (FProcentBar>100) then FProcentBar :=100;
    Repaint;
  end;
end;
procedure TAmClientMessageFilesPaintBox.TItem.SetFileNameFull(val:string);
begin
    FFileNameFull:=val;
    if (FFileNameFull<>'') and FileExists(FFileNameFull) then
    begin
      GradDel;
      Ico:= AmGetGraficIcon(FFileNameFull,16);
      Repaint;
    end;

end;


constructor TAmClientMessageFilesPaintBox.Create(AOwner: TComponent);
var Style:TAmClientMenuFilesPaintBox.TStyle;
var Element:TAmClientMenuFilesPaintBox.TElement;
begin

   inherited create(AOwner);
   FList:=Tlist<TItem>.create;
   FItemIndexMouseMove:=-1;
   FItemIndexActiv:=-1;
   FBoxItemHeight:=25;
   ParentColor := FAlse;
   //Color := Color;//$00423129;
   Font.Color:=Clwhite;
   Font.Size:=8;
   FColorItemMouseMovi:= $00513D33;
   FColorItemSelect:= $00BEB545;

   Popap:=TAmClientMenuFilesPaintBox.Create(self);

end;
destructor TAmClientMessageFilesPaintBox.Destroy;
begin
    ListsClear;
    FList.Free;
    if  AmCheckControl(Popap) then  Popap.Free;
    Popap:=nil;
    inherited;
end;
procedure TAmClientMessageFilesPaintBox.ListsClear;
var
  I: Integer;
begin
   for I := 0 to FList.Count-1 do
   FList[i].Free;
   FList.Clear;
end;

function TAmClientMessageFilesPaintBox.ItemAtPos(Pos: TPoint): Integer;
var
  i:integer;
begin
  Result := -1;
  if ClientRect.Contains(Pos) then
  begin
    for I := 0 to FList.Count-1 do
    if FList[i].aRect.Contains(Pos) then
    begin
      Result:=i;
      break;
    end;
  end;

end;
procedure TAmClientMessageFilesPaintBox.CMMouseLeave(var Message: TMessage); //message CM_MOUSELEAVE;
begin
  inherited ;

  FItemIndexMouseMove:= -1;
//  FItemIndexActiv:= -1;
  Repaint;

end;
procedure TAmClientMessageFilesPaintBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var I:integer;
begin
  inherited MouseMove(Shift,X, Y);
  I:= ItemAtPos(Point(X, Y));
  if (i<>FItemIndexMouseMove) then
  begin
     FItemIndexMouseMove:= i;
     Repaint;
  end;

end;
procedure TAmClientMessageFilesPaintBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I:integer;
    NoSel:boolean;
begin
   NoSel:=false;
  inherited MouseMove(Shift,X, Y);
  I:= ItemAtPos(Point(X, Y));
  if (I>=0)then
  begin
   if i<>FItemIndexActiv then   FItemIndexActiv:= i
   else NoSel:=true;

   if     mbRight = Button then  OpenPapap(FList[i].KindDownload)
   else if mbLeft = Button then
   begin
     if FList[i].aRectTextSize.Contains(Point(X,Y)) then
     begin
       if      FList[i].KindDownload = mfitIsDownload then self.RunPapkaSelectFile(FList[i].FileNameFull)
       else if FList[i].KindDownload = mfitErrorDownload then  showmessage(FList[i].LastJsonError)


     end
     else if  NoSel then  FItemIndexActiv:= -1;
            
   end;

   Repaint;
  end
  else
  begin
    if     mbRight = Button then  OpenPapap(mfitNoSelect)
    else if mbLeft = Button then
    if Assigned(self.OnOpenManagger) then OnOpenManagger(self);
    
  end;





end;
procedure TAmClientMessageFilesPaintBox.Paint;
var
  aTop: Integer;
  aRect:Trect;
  I:integer;
  Item:Titem;
begin
    Canvas.Brush.Color := Color;
    aRect:= self.ClientRect;
    Canvas.FillRect(aRect);
    aTop:=0;
    for I := 0 to FList.Count-1 do
    begin
       Item:=FList[i];
       Item.aRect.Left:=  aRect.Left;
       Item.aRect.Top:=Atop;
       Item.aRect.Width:= aRect.Width;
       Item.aRect.Height:= FBoxItemHeight;
       PaintOneFile(Item,i);
       inc(aTop,FBoxItemHeight);
    end;
    if aTop=0 then
    begin
      Canvas.Brush.Color := Color;
      Canvas.Font.Color := clwhite;
      Canvas.TextOut(5, aTop+5 ,'Посмотреть файлы...');
    end;
    inherited Paint;

end;
function TAmClientMessageFilesPaintBox.PaintOneFile(Item:TItem;Index:integer):integer;
begin
   if Index = FItemIndexActiv then
   begin
     Canvas.Brush.Color := FColorItemSelect;
     Canvas.Font.Color := clWhite;
   end
   else
   if Index = FItemIndexMouseMove then
   begin
     Canvas.Font.Color := $00E8B4B3;
     Canvas.Brush.Color := FColorItemMouseMovi;
   end
   else
   begin
   Canvas.Font.Color := $00E8B4B3;
   Canvas.Brush.Color := Color;
   end;
   Canvas.FillRect(Item.aRect);

   DoPaintProcentBar(Item,index);
   PaintIco(Item,index);
   PaintText(Item,index);



   //////////////////////////////////////
 {
   Icon := TIcon.Create;
   try

         Icon.Handle :=AmGetFileExtAssociatedIcon(Fn, true,false);
       if Icon.Handle>0 then
       begin
        if  (FBoxItemHeight - Icon.Height >0)
        and (FBoxItemHeight-Icon.Width>0) then
         Canvas.Draw(((FBoxItemHeight- Icon.Height) div 2),aTop+((FBoxItemHeight- Icon.Height) div 2),Icon)
        else Canvas.Draw(5,aTop+5,Icon);
       end;

   finally
     Icon.Free;
   end;
   Canvas.Brush.Color := Color;
   Canvas.Font.Color := $00E8B4B3;
   Canvas.TextOut(FBoxItemHeight, aTop+6 ,Fn);
   REsult:=  aTop+ FBoxItemHeight; }
end;
procedure TAmClientMessageFilesPaintBox.PaintText(Item:TItem;Index:integer);
var
    SizeText,SizeTextFileSize:TSize;
    W:integer;
    TextFileSize,Pos,Sz:string;
begin
   SizeText:=Canvas.TextExtent(FList[Index].FileName);

   if Item.KindDownload in [mfitProcessing]  then
   begin
       Pos:=FormatFloat('0.00',FList[Index].PositionBar/1000000);
       Sz:=FormatFloat('0.00',FList[Index].SizeFile/1000000);
       TextFileSize:= Pos+' / '+Sz+'Mb';
   end
   else
   if  Item.KindDownload in [mfitNoDownload] then
   begin
       Sz:=FormatFloat('0.00',FList[Index].SizeFile/1000000);
       TextFileSize:= Sz+'Mb';
   end
   else
   if  Item.KindDownload in [mfitIsDownload] then
   begin
       TextFileSize:= 'Показать в папке';
   end
   else
   if  Item.KindDownload in [mfitErrorDownload] then
   begin
       TextFileSize:= 'Ошибка';
   end

   else  TextFileSize:='';

   Item.aRectTextSize.Top:= Item.aRect.Top;
   Item.aRectTextSize.Left:= Item.aRect.Left;
   Item.aRectTextSize.Bottom:= Item.aRect.Bottom;
   Item.aRectTextSize.Right:= Item.aRect.Right;



   SizeTextFileSize:= Canvas.TextExtent(TextFileSize);
   W:= Item.aRect.Width - SizeTextFileSize.cx-30;

   Item.FileNameView:= AmWrapText.SetText_WidthTrim(Item.FileName,SizeText.cx,W);
   Canvas.TextOut(FBoxItemHeight, Item.aRect.Top+5 ,Item.FileNameView);

   Canvas.TextOut(W+20, Item.aRect.Top+5 ,TextFileSize);

   Item.aRectTextSize.Left:=W+20;

end;
procedure TAmClientMessageFilesPaintBox.PaintIco(Item:TItem;Index:integer);
var Graf:TGraphic;
begin
   Graf:= Item.Ico;
   if Assigned(Graf) then
   begin
    if  (FBoxItemHeight - Graf.Height >0)
    and (FBoxItemHeight-Graf.Width>0) then
     Canvas.Draw(((FBoxItemHeight- Graf.Height) div 2),Item.aRect.Top+((FBoxItemHeight- Graf.Height) div 2),Graf)
    else Canvas.Draw(5,Item.aRect.Top+5,Graf);
   end;
end;
procedure TAmClientMessageFilesPaintBox.DoPaintProcentBar(Item:TItem;Index:integer);
var
    arect:TRect;
    Col:TColor;
begin
  if Item.KindDownload in [mfitProcessing]  then
  begin
  //if not Item.IsDownloadProcessing then exit;
   Col:= Canvas.Brush.Color;
   Canvas.Brush.Color := Item.ColorBar;
   arect.Left:=   Item.aRect.Left;
   arect.Top:=    Item.aRect.Left;
   arect.Bottom:= Item.aRect.Bottom;
   arect.Right:=  Item.aRect.Right;
   PaintProcentBar(Item,Index,aRect);
   Canvas.Brush.Color := Col;
  end;
end;
procedure TAmClientMessageFilesPaintBox.PaintProcentBar(Item:TItem;Index:integer;aRect:TRect);
begin
   arect.Top:= arect.Height-2;
   arect.Right:=  round(arect.Right*Item.FProcentBar/100);
   Canvas.FillRect(arect);
end;
procedure TAmClientMessageFilesPaintBox.RunFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, 'open', PChar(FileName), '', nil,SW_SHOWNORMAL)
end;
procedure TAmClientMessageFilesPaintBox.RunPapkaSelectFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, nil, 'explorer.exe', PChar('/select,' + FileName), nil, SW_SHOWNORMAL);
end;
procedure  TAmClientMessageFilesPaintBox.OpenPapap(State:TMessageFilesItemState);
begin
       if       State in [mfitProcessing]  then Popap.Open(self,1)
       else if  State in [mfitNoDownload] then  Popap.Open(self,0)
       else if  State in [mfitErrorDownload] then Popap.Open(self,0)
       else if  State in [mfitIsDownload] then  Popap.Open(self,2)
       else if  State in [mfitNoSelect] then    Popap.Open(self,4)
       else                                              Popap.Open(self,3)
end;

constructor TAmClientMenuFilesPaintBox.Create(aParent: TWincontrol);
var Style:TAmClientMenuFilesPaintBox.TStyle;
var Element:TAmClientMenuFilesPaintBox.TElement;
begin
   inherited create(aParent);
   ControlSave:=nil;
   Color:=$00453830;

   self.Constraints.MinHeight:=20;
   self.Constraints.MaxHeight:=300;

   try
    // стиль когда не скачано
    Style.Clear;
     Element.ItemName:='Download';
     Element.Caption:='Скачать файл';
     Element.W:=150;
     Style.Add(Element);

     {Element.ItemName:='OpenMenagger';
     Element.Caption:='Скачать все файлы';
     Element.W:=200;
     Style.Add(Element); }


    { Element.ItemName:='OpenMenagger';
     Element.Caption:='Показать все файлы';
     Element.W:=200;
     Style.Add(Element);}

   finally
     ListStyle.Add(Style);
   end;

   try
    // стиль когда скачивается
    Style.Clear;
     Element.ItemName:='Abort';
     Element.Caption:='Отмена';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Pause';
     Element.Caption:='В конец очереди';
     Element.W:=150;
     Style.Add(Element);

     {Element.ItemName:='OpenMenagger';
     Element.Caption:='Скачать все файлы';
     Element.W:=200;
     Style.Add(Element); }


    { Element.ItemName:='OpenMenagger';
     Element.Caption:='Показать все файлы';
     Element.W:=200;
     Style.Add(Element);}

   finally
     ListStyle.Add(Style);
   end;


   try
    // стиль когда скачалось

    Style.Clear;

     Element.ItemName:='Open';
     Element.Caption:='Открыть файл';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='OpenPapka';
     Element.Caption:='Показать в папке';
     Element.W:=150;
     Style.Add(Element);

     {Element.ItemName:='OpenMenagger';
     Element.Caption:='Скачать все файлы';
     Element.W:=200;
     Style.Add(Element); }


    { Element.ItemName:='OpenMenagger';
     Element.Caption:='Показать все файлы';
     Element.W:=200;
     Style.Add(Element);}

     Element.ItemName:='Download';
     Element.Caption:='Скачать заново';
     Element.W:=150;
     Style.Add(Element);
   finally
     ListStyle.Add(Style);
   end;


   try
    // стиль когда неизвестно что
    Style.Clear;

     {Element.ItemName:='OpenMenagger';
     Element.Caption:='Скачать все файлы';
     Element.W:=200;
     Style.Add(Element); }



     Element.ItemName:='Download';
     Element.Caption:='Скачать';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Open';
     Element.Caption:='Открыть файл';
     Element.W:=150;
     Style.Add(Element);

    { Element.ItemName:='OpenMenagger';
     Element.Caption:='Показать все файлы';
     Element.W:=200;
     Style.Add(Element);}

     Element.ItemName:='Abort';
     Element.Caption:='Отмена';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Pause';
     Element.Caption:='В конец очереди';
     Element.W:=150;
     Style.Add(Element);

   finally
     ListStyle.Add(Style);
   end;

   try
    // стиль когда не выбран файл
    Style.Clear;

    { Element.ItemName:='OpenMenagger';
     Element.Caption:='Показать все файлы';
     Element.W:=200;
     Style.Add(Element);}


   finally
     ListStyle.Add(Style);
   end;

   Self.OnClickItem:=  ClickToItem;



end;
Procedure  TAmClientMenuFilesPaintBox.ClickToItem(S:Tobject;NameItem:String);
var FilesPaintBox: TAmClientMessageFilesPaintBox;
    FilesImg:TAmClientMessageFilesImageCollage;
begin
     FilesImg:=nil;
     FilesPaintBox:=nil;
    //showmessage('ClickToItem');
     if AmCheckObject(ControlSave) then
     begin
       if  (ControlSave is TAmClientMessageFilesPaintBox)then
       begin
           FilesPaintBox:= ControlSave as TAmClientMessageFilesPaintBox;
           if  not AmControlCheckWork(FilesPaintBox) then exit;


           if       NameItem = 'Abort' then
           begin
             if Assigned( FilesPaintBox.OnDownloadAbort) then
             FilesPaintBox.OnDownloadAbort(FilesPaintBox);
           end
           else
           if       NameItem = 'Pause' then
           begin
             if Assigned( FilesPaintBox.OnDownloadPause) then
             FilesPaintBox.OnDownloadPause(FilesPaintBox);
           end
           else
           if       NameItem = 'Download' then
           begin
             if Assigned( FilesPaintBox.OnDownloadStart) then
             FilesPaintBox.OnDownloadStart(FilesPaintBox);
           end
           else
           if       NameItem = 'OpenMenagger' then
           begin
             if Assigned( FilesPaintBox.OnOpenManagger) then
             FilesPaintBox.OnOpenManagger(FilesPaintBox);
           end
           else
           if       NameItem = 'Open' then
           begin
            if  (FilesPaintBox.IndexActiv>=0)
            and (FilesPaintBox.FList[FilesPaintBox.IndexActiv].FileNameFull<>'') then
            begin
                FilesPaintBox.runFile(FilesPaintBox.FList[FilesPaintBox.IndexActiv].FileNameFull);
            end;
           end
           else
           if       NameItem = 'OpenPapka' then
           begin
            if  (FilesPaintBox.IndexActiv>=0)
            and (FilesPaintBox.FList[FilesPaintBox.IndexActiv].FileNameFull<>'') then
            begin
                FilesPaintBox.RunPapkaSelectFile(FilesPaintBox.FList[FilesPaintBox.IndexActiv].FileNameFull);
            end;

           end



       end
       else if  (ControlSave is TAmClientMessageFilesImageCollage)then
       begin
           FilesImg:= ControlSave as TAmClientMessageFilesImageCollage;
           if  not AmControlCheckWork(FilesImg) then exit;


           if       NameItem = 'Abort' then
           begin

           end
           else
           if       NameItem = 'Pause' then
           begin

           end
           else
           if       NameItem = 'Download' then
           begin
             if Assigned( FilesImg.OnDownloadStart) then
             FilesImg.OnDownloadStart(FilesImg);
           end
           else
           if       NameItem = 'OpenMenagger' then
           begin
             if Assigned( FilesImg.OnOpenManagger) then
             FilesImg.OnOpenManagger(FilesImg);
           end
           else
           if       NameItem = 'Open' then
           begin
            if  (FilesImg.IndexActiv>=0)
            and (FilesImg.List[FilesImg.IndexActiv].FullFileName<>'') then
            begin
                FilesImg.runFile(FilesImg.List[FilesImg.IndexActiv].FullFileName);
            end;
           end
           else
           if       NameItem = 'OpenPapka' then
           begin
            if  (FilesImg.IndexActiv>=0)
            and (FilesImg.List[FilesImg.IndexActiv].FullFileName<>'') then
            begin
                FilesImg.RunPapkaSelectFile(FilesImg.List[FilesImg.IndexActiv].FullFileName);
            end;

           end
       end;
     end;

end;















                 {TAmClientListBoxFilesAtSend}
constructor TAmClientListBoxFilesAtViewZip.Create(AOwner: TComponent);
var Style:TAmClientPopapMenu.TStyle;
var Element:TAmClientPopapMenu.TElement;
begin
   inherited create(AOwner);
   try
     Element.ItemName:='Save';
     Element.Caption:='Cохранить как...';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Open';
     Element.Caption:='Открыть';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Place';
     Element.Caption:='Расположение файла';
     Element.W:=190;
     Style.Add(Element);
     //....

   finally
     Popap.ListStyle.Add(Style);
   end;

   Popap.OnClickItem:= PopapClickToItem;

end;
destructor TAmClientListBoxFilesAtViewZip.Destroy;
begin
   inherited ;
end;
Procedure TAmClientListBoxFilesAtViewZip.ViewZip;
var Zip: TZipFile;
    ArchiveFile: String;
begin
  self.Clear;
  if FileExists(FileNameZip) then
  begin
      Zip:=TZipFile.Create;
      try
        Zip.Open(FileNameZip,zmRead);
        for ArchiveFile in Zip.FileNames do  AddFile(ArchiveFile);
          // Zip.Extract;
        Zip.Close;
      finally
        Zip.Free;
      end;
  end;



end;
Procedure  TAmClientListBoxFilesAtViewZip.PopapClickToItem(S:Tobject;NameItem:String);
begin

   if       NameItem = 'Save' then
   begin
      //
      SaveFile(ItemsMy[ItemIndex]);
   end
   else if  NameItem = 'Open'  then
   begin
     if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunFile(FileNameZip);
   end
   else if  NameItem = 'Place'  then
   begin
      if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunPapkaSelectFile(FileNameZip);
   end;
   Popap.Close;
end;
Procedure  TAmClientListBoxFilesAtViewZip.SaveFile(FileToZipName:String);
var Zip: TZipFile;
var NewFullFileName:string;
var CanSave:boolean;
begin
     CanSave:=false;
     NewFullFileName:='';
     if Assigned(FOnBeforeSaveFile) then FOnBeforeSaveFile(FileToZipName,NewFullFileName,CanSave );

     if not CanSave then exit;
     if NewFullFileName='' then exit;


      Zip:=TZipFile.Create;
      try
        Zip.Open(FileNameZip,zmRead);
        Zip.Extract(FileToZipName,NewFullFileName);

        Zip.Close;
      finally
        Zip.Free;
      end;
end;

                 {TAmClientListBoxFilesAtSend}
constructor TAmClientListBoxFilesAtView.Create(AOwner: TComponent);
var Style:TAmClientPopapMenu.TStyle;
var Element:TAmClientPopapMenu.TElement;
begin
   inherited create(AOwner);
   try
     Element.ItemName:='Save';
     Element.Caption:='Cохранить как...';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Open';
     Element.Caption:='Открыть';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Place';
     Element.Caption:='Расположение файла';
     Element.W:=190;
     Style.Add(Element);
     //....

   finally
     Popap.ListStyle.Add(Style);
   end;

   Popap.OnClickItem:= PopapClickToItem;

end;
destructor TAmClientListBoxFilesAtView.Destroy;
begin
   inherited ;
end;
Procedure  TAmClientListBoxFilesAtView.PopapClickToItem(S:Tobject;NameItem:String);
begin

   if       NameItem = 'Save' then
   begin
      //if Assigned(FOnSaveFile) then FOnSaveFile(ItemsMy[ItemIndex]);
   end
   else if  NameItem = 'Open'  then
   begin
     if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunFile(ItemsMy[ItemIndex]);
   end
   else if  NameItem = 'Place'  then
   begin
      if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunPapkaSelectFile(ItemsMy[ItemIndex]);
   end;
   Popap.Close;
end;


                 {TAmClientListBoxFilesAtSend}
constructor TAmClientListBoxFilesAtSend.Create(AOwner: TComponent);
var Style:TAmClientPopapMenu.TStyle;
var Element:TAmClientPopapMenu.TElement;
begin
   inherited create(AOwner);
   try
     Element.ItemName:='Add';
     Element.Caption:='Добавить еще';
     Element.W:=190;
     Style.Add(Element);

     Element.ItemName:='Clear';
     Element.Caption:='Очистить';
     Element.W:=190;
     Style.Add(Element);

     Element.ItemName:='Delete';
     Element.Caption:='Удалить';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Open';
     Element.Caption:='Открыть';
     Element.W:=150;
     Style.Add(Element);

     Element.ItemName:='Place';
     Element.Caption:='Показать в папке';
     Element.W:=190;
     Style.Add(Element);
     //....

   finally
     Popap.ListStyle.Add(Style);
   end;

   Popap.OnClickItem:= PopapClickToItem;

end;
destructor TAmClientListBoxFilesAtSend.Destroy;
begin
   inherited ;
end;
Procedure  TAmClientListBoxFilesAtSend.PopapClickToItem(S:Tobject;NameItem:String);
begin

   if       NameItem = 'Delete' then
   begin
      DeleteFile(ItemIndex);
   end
   else if  NameItem = 'Add'  then
   begin
     if AmCheckControl( Popap.ControlSave ) and Assigned(FOnNeedOpenDialog) then
     begin
       if Popap.ControlSave is  TAmClientListBoxFilesAtSend then
       FOnNeedOpenDialog(self);

     end;
   end
   else if  NameItem = 'Clear'  then
   begin
     Clear;
   end
   else if  NameItem = 'Open'  then
   begin
     if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunFile(ItemsMy[ItemIndex]);
   end
   else if  NameItem = 'Place'  then
   begin
      if (ItemIndex>=0) and (ItemIndex<ItemsMy.Count) then RunPapkaSelectFile(ItemsMy[ItemIndex]);
   end;
   Popap.Close;
end;










{
function TAmZipFile.SerchName(NameFile:string):integer;
var i:integer;
    Arr:TArray<string>;
    M:integer;
begin
  Result:=-1;
  Arr:= FileNames;
  M:=Length(Arr);
  for i:=0 to M-1 do
  if NameFile=Arr[i] then
  begin
     Result:=i;
     break;
  end;
end;}




constructor TAmClientAddToArchivFilesAtSend.Create;
begin
    inherited create;
    Collage:=  TAmConvecterToСollagePhoto.Create;
end;
destructor TAmClientAddToArchivFilesAtSend.Destroy;
begin
    Collage.Free;
    inherited;
end;



Procedure TAmClientAddToArchivFilesAtSend.CollageAddPhoto(ListFullNameFiles:TamListVar<string>;var ResultListOther:TamListVar<string>);
var I: Integer;
    FileExt,F: string;
begin

    ResultListOther.Clear;

    for I := 0 to ListFullNameFiles.Count-1 do
    begin
       F:=ListFullNameFiles[i];
       FileExt:=LowerCase(ExtractFileExt(F));

       if (pos(FileExt,AM_CHAT_FILEZIP_NAMEFILE_PHOTO_EXT)<>0) then
       begin
           if  Collage.AddFileNameImg(F) then
           else ResultListOther.Add(F);
       end
       else ResultListOther.Add(F);
    end;
end;
Procedure TAmClientAddToArchivFilesAtSend.ConvertDo;
begin
   //что бы конвертация была всегда успешной текущий объект нужно создать в главном потоке приложения
   // а вызывать get можно в другом потоке
   SendMessage(self.Handle,wm_user+1,0,0);
end;
Procedure TAmClientAddToArchivFilesAtSend.ConvertPost(var Msg:Tmessage);//message wm_user+1;
begin
// showmessage(MainThreadId.ToString()+' : '+ GetCurrentThreadId.ToString());
   Collage.Convecter;
end;
function  TAmClientAddToArchivFilesAtSend.Get(
                        FileNamePhoto10:string;
                        FileNamePhoto500:string;
                        FileNameZipFile:string;
                        ListFullNameFiles:TamListVar<string>; //input
                        CollageNeed:boolean;                  //input
                        CollageNeed_MaxWidth:integer;         //input
                        PhotoSqueeze :boolean;                //input
                        PhotoSqueeze_MaxWidth:integer        //input


                    ):TAmClientAddToArchivFilesAtSend.TResult;
var Zip  : TZipFile;
    I    : integer;
    Json : TJsonObject;
    Hob  : TJsonObject;
    Fs_500  : TFileStream;
    Fs_10   : TFileStream;
    CollageRect:TArray<TAmConvecterToСollagePhoto.TResultRect>;
    Ms      : TMemoryStream;
    ListFileOther:TamListVar<string>;

begin
 Result.Result:=false;
 Result.Photo10StringBase64:='';
 Result.Photo500StringBase64:='';
 Result.Photo10Result:=false;
 Result.Photo500Result:=false;
 Result.CollageSizeMax.cx:=0;
 Result.CollageSizeMax.cy:=0;
 Result.CountFileCollage:=0;
 Result.Photo10SizeStream:=0;
 Result.Photo500SizeStream:=0;
 Result.ZipSizeStream:=0;
 Result.ListFileOtherJson:='';
 ListFileOther.Clear;
 Result.ListFilePhotoJson:='';

 if FileNameZipFile='' then exit;


 //проверка что файлы есть на диске
 for I := ListFullNameFiles.Count-1 downto 0 do
 if not FileExists(ListFullNameFiles[i]) then ListFullNameFiles.Delete(i);
 if ListFullNameFiles.Count=0 then exit;

 Zip:= TZipFile.Create;
 Json:= TJsonObject.Create;
 Ms:=  TMemoryStream.Create;
 try
  try
    Zip.Open(FileNameZipFile,zmWrite);

    if CollageNeed and (FileNamePhoto10<>'') and (FileNamePhoto500<>'') then
    begin

      Fs_500:= TFileStream.Create(FileNamePhoto500,fmCreate);
      Fs_10:= TFileStream.Create(FileNamePhoto10,fmCreate);
      try
          Collage.Clear;
          Collage.SetNeedMaxWidth:= CollageNeed_MaxWidth;
          CollageAddPhoto(ListFullNameFiles,ListFileOther);
          Result.CountFileCollage:= Collage.ListPic.Count;
          if Result.CountFileCollage>0 then
          begin
            ConvertDo;
            Collage.ResultGetStream(Fs_500,90,0);
            Collage.ResultGetStream(Fs_10,90,10);
            CollageRect:= Collage.ResultGetRect;
            Result.CollageSizeMax:= Collage.ResultGetFullSize;

            Result.Photo10SizeStream:=Fs_10.Size;
            Result.Photo500SizeStream:=Fs_500.Size;
            Result.Photo500Result:=  Fs_500.Size>0;
            Result.Photo10Result:=  Fs_10.Size>0;
           // showmessage(Ms_10.Size.ToString+' '+Inttostr(length(Result.Photo10StringBase64))+#13+
           // Ms_500.Size.ToString+' '+Inttostr(length(Result.Photo500StringBase64)));
          end;
      finally
        Fs_500.Free;
        Fs_10.Free;
      end;
    end;


    if not  CollageNeed or not Result.Photo500Result then
    begin
       ListFileOther.Clear;
       for I := 0 to ListFullNameFiles.Count-1 do
       ListFileOther.Add(ListFullNameFiles[i]);

    end;
   // Result.ListFileOther.Arr:= ListFullNameFiles.Arr;





    for I := 0 to ListFullNameFiles.Count-1 do
    begin
          if  ( ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10)
          and (ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500)
          and (ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_CONFIG) then
          continue;

          Ms.Clear;



          if PhotoSqueeze and (pos(LowerCase(ExtractFileExt(ListFullNameFiles[i])),AM_CHAT_FILEZIP_NAMEFILE_PHOTO_EXT)<>0) then
          begin
             try   Ms.LoadFromFile(ListFullNameFiles[i]); except showmessage('Error Ms.LoadFromFile');end;


             try  amScaleImage.GetPic(Ms,PhotoSqueeze_MaxWidth,true); except showmessage('Error amScaleImage.GetPic');end;


            if Ms.Size>0  then
            begin
               Ms.Position:=0;
               try
                Zip.Add(Ms,ExtractFileName(ListFullNameFiles[i]));
                Result.Result:=true;
               except
                 showmessage('Ms Zip.Add Error Add')
               end;
            end;
          end
          else
          begin
             Zip.Add(ListFullNameFiles[i],ExtractFileName(ListFullNameFiles[i]));
             Result.Result:=true;
          end;

    end;






     if (Zip.FileCount>0) or (Result.CountFileCollage>0) then
     begin
          // FConfig.MaxWidthPhoto:= AmInt(JsonConfig['Data']['MaxWidthPhoto'],0);
          // FConfig.CountFile:= AmInt(JsonConfig['Data']['CountFile'],0);
          // FConfig.CountPhotoFile:= AmInt(JsonConfig['Data']['CountPhotoFile'],0);
        if Result.Photo500Result then
        begin

          for I := 0 to length(CollageRect)-1 do
          begin
              Hob:= Json['Data'].A['CollageRect'].AddObject;
              Hob['Rect'].Value:=       AmRectSize.RectToStr( CollageRect[i].Rect );
              Hob['FileName'].Value:=   ExtractFileName( CollageRect[i].IndificatorFullFileName );
              Hob['Size'].Value:=       AmStr(AmSizeFile( CollageRect[i].IndificatorFullFileName ));
          end;
          Result.ListFilePhotoJson:=Json['Data'].A['CollageRect'].ToJSON();

          Json['Data']['CollageSizeMax'].Value:=  AmRectSize.SizeToStr(Result.CollageSizeMax);
        end;



        for I :=0  to ListFileOther.Count-1 do
        begin
         Hob:=  Json['Data'].A['ListFileOther'].AddObject;
         Hob['Size'].Value:=  AmStr(AmSizeFile(ListFileOther[i]));
         Hob['FileName'].Value:=ExtractFileName(ListFileOther[i]);
        end;

       // Json['Data']['CollageNeed'].Value:=  AmStr(CollageNeed);
       // Json['Data']['CollageNeed_MaxWidth'].Value:=  AmStr(CollageNeed_MaxWidth);
        Json['Data']['PhotoSqueeze'].Value:=  AmStr(PhotoSqueeze);
        Json['Data']['PhotoSqueeze_MaxWidth'].Value:=  AmStr(PhotoSqueeze_MaxWidth);
        Ms.Clear;
        Ms.Position:=0;
        Json.SaveToStream(Ms,false);
        Result.ListFileOtherJson:= Json['Data'].A['ListFileOther'].ToJSON();

        try
          Ms.Position:=0;
          Zip.Add(Ms,AM_CHAT_FILEZIP_NAMEFILE_CONFIG);
        except
               showmessage('AM_CHAT_FILEZIP_NAMEFILE_CONFIG Zip.Add Error Add')
        end;
     end;
  except
     on e:exception do
     if Assigned(LogMain) then LogMain.LogError('Error.TAmClientAddToArchivFilesAtSend.Get',self,e);

  end;

 finally
   Zip.Free;
   Json.Free;
   Ms.Free;
   Result.ZipSizeStream:= amSizeFile(FileNameZipFile);
 end;


end;


function TAmClientAddToArchivFilesAtSend.Get(
                                                  OutStreamZip:TMemoryStream;
                                                  ListFullNameFiles:TamListVar<string>;
                                                  CollageNeed:boolean;
                                                  CollageNeed_MaxWidth:integer;
                                                  PhotoSqueeze :boolean;
                                                  PhotoSqueeze_MaxWidth:integer

                                              ):TAmClientAddToArchivFilesAtSend.TResult;
{var Ms_500:TMemoryStream;
    Ms_10:TMemoryStream;
    Ms:TMemoryStream;
    CollageRect:TArray<TAmConvecterToСollagePhoto.TResultRect>;

    Json:TJsonObject;
    Hob: TJsonObject;
    i:integer;
    Zip:TZipFile;
    HpStr:String;  }
begin
{
            exit;
 OutStreamZip.Clear;
 Result.Photo10StringBase64:='';
 Result.Photo500StringBase64:='';
 Result.Photo10Result:=false;
 Result.Photo500Result:=false;
 Result.CollageSizeMax.cx:=0;
 Result.CollageSizeMax.cy:=0;
 Result.CountFileCollage:=0;
// Result.ListFileOther.Clear;

 //проверка что файлы есть на диске
 for I := ListFullNameFiles.Count-1 downto 0 do
 if not FileExists(ListFullNameFiles[i]) then ListFullNameFiles.Delete(i);
 if ListFullNameFiles.Count=0 then exit;



 Zip:= TZipFile.Create;
 Json:= TJsonObject.Create;
 Ms:= TMemoryStream.Create;
 try
    Zip.Open(OutStreamZip,zmWrite);

    if CollageNeed then
    begin
      Ms_500:= TMemoryStream.Create;
      Ms_10:= TMemoryStream.Create;
      try

          Collage.SetNeedMaxWidth:= CollageNeed_MaxWidth;
         // CollageAddPhoto(ListFullNameFiles,Result.ListFileOther);
          Result.CountFileCollage:= Collage.ListPic.Count;
          if Result.CountFileCollage>0 then
          begin
            Collage.Convecter;
            Collage.ResultGetStream(Ms_500,0);
            Collage.ResultGetStream(Ms_10,10);
            CollageRect:= Collage.ResultGetRect;
            Result.CollageSizeMax:= Collage.ResultGetFullSize;
            Result.Photo10Result:= AmBase64.StreamToBase64(Ms_10, HpStr);
            Result.Photo10StringBase64:=HpStr;
            HpStr:='';
            Result.Photo500Result:=AmBase64.StreamToBase64(Ms_500,HpStr);
            Result.Photo500StringBase64:=HpStr;

            HpStr:='';
           // showmessage(Ms_10.Size.ToString+' '+Inttostr(length(Result.Photo10StringBase64))+#13+
           // Ms_500.Size.ToString+' '+Inttostr(length(Result.Photo500StringBase64)));
          end;
      finally
        Ms_500.Free;
        Ms_10.Free;
      end;
    end;


    if not  CollageNeed or not Result.Photo500Result then
  //  Result.ListFileOther.Arr:= ListFullNameFiles.Arr;





    for I := 0 to ListFullNameFiles.Count-1 do
    begin
          if  ( ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10)
          and (ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500)
          and (ListFullNameFiles[i]= AM_CHAT_FILEZIP_NAMEFILE_CONFIG) then
          continue;

          Ms.Clear;
          try   Ms.LoadFromFile(ListFullNameFiles[i]); except showmessage('Error Ms.LoadFromFile');end;



          if PhotoSqueeze and (pos(LowerCase(ExtractFileExt(ListFullNameFiles[i])),AM_CHAT_FILEZIP_NAMEFILE_PHOTO_EXT)<>0) then
          begin
             try  amScaleImage.GetPic(Ms,PhotoSqueeze_MaxWidth,true); except showmessage('Error amScaleImage.GetPic');end;
          end;
          if Ms.Size>0  then
          begin
             Ms.Position:=0;
             try
              Zip.Add(Ms,ExtractFileName(ListFullNameFiles[i]));
             except
               showmessage('Ms Zip.Add Error Add')
             end;
          end;


    end;






     if (Zip.FileCount>0) or (Result.CountFileCollage>0) then
     begin
          // FConfig.MaxWidthPhoto:= AmInt(JsonConfig['Data']['MaxWidthPhoto'],0);
          // FConfig.CountFile:= AmInt(JsonConfig['Data']['CountFile'],0);
          // FConfig.CountPhotoFile:= AmInt(JsonConfig['Data']['CountPhotoFile'],0);
        if Result.Photo500Result then
        begin

          for I := 0 to length(CollageRect)-1 do
          begin
              Hob:= Json['Data'].A['CollageRect'].AddObject;
              Hob['Rect'].Value:= AmRectSize.RectToStr( CollageRect[i].Rect );
              Hob['FileName'].Value:= ExtractFileName(CollageRect[i].IndificatorFileName);
          end;
          Json['Data']['CollageSizeMax'].Value:=  AmRectSize.SizeToStr(Result.CollageSizeMax);
        end;



       // for I :=0  to Result.ListFileOther.Count-1 do
       // Json['Data'].A['ListFileOther'].Add(ExtractFileName(Result.ListFileOther[i]));

       // Json['Data']['CollageNeed'].Value:=  AmStr(CollageNeed);
       // Json['Data']['CollageNeed_MaxWidth'].Value:=  AmStr(CollageNeed_MaxWidth);
        Json['Data']['PhotoSqueeze'].Value:=  AmStr(PhotoSqueeze);
        Json['Data']['PhotoSqueeze_MaxWidth'].Value:=  AmStr(PhotoSqueeze_MaxWidth);
        Ms.Clear;
        Ms.Position:=0;
        Json.SaveToStream(Ms,false);


        try
          Ms.Position:=0;
          Zip.Add(Ms,AM_CHAT_FILEZIP_NAMEFILE_CONFIG);
        except
               showmessage('AM_CHAT_FILEZIP_NAMEFILE_CONFIG Zip.Add Error Add')
        end;
     end;

 finally
   Zip.Free;
   Json.Free;
   Ms.Free;
 end;
 if OutStreamZip.Size>0 then  OutStreamZip.Position:=0;
  }
end;
procedure TAmChatZipFile_Config.JsonToConfig(JsonStream:TStream);
var Json:TjsonObject;
i:integer;

s:string;
begin
    Json:= AmJson.LoadObjectStream(JsonStream);
    try
     s:= Json.ToJSON();
     // CollageNeed:=           AmBool(Json['Data']['CollageNeed'].Value,false);
    //   CollageNeed_MaxWidth:=  AmInt(Json['Data']['CollageNeed_MaxWidth'].Value);
     //  CollageSizeMax:=        AmRectSize.StrToSize(Json['Data']['CollageSizeMax'].Value);
       PhotoSqueeze:=          AmBool(Json['Data']['PhotoSqueeze'].Value,false);
       PhotoSqueeze_MaxWidth:= AmInt(Json['Data']['PhotoSqueeze_MaxWidth'].Value);
       AddListFileOther(Json['Data'].A['ListFileOther']);
       AddListFilePhoto(Json['Data'].A['CollageRect']);

    finally
       Json.Free;
    end;

end;
procedure TAmChatZipFile_Config.AddListFilePhotoTextJson(ArrJsonString:string);
var JsonArray: TJsonArray;
begin
    JsonArray:= AmJson.LoadArrayText(ArrJsonString);
    try
       AddListFilePhoto(JsonArray);
    finally
      JsonArray.Free;
    end;

end;
procedure TAmChatZipFile_Config.AddListFilePhoto(Arr:TJsonArray);
var i:integer;
It:TAmClientMessageFilesImageCollage.TItem;
ObjFile:TJsonObject;
begin
       if not Assigned(LinkImage) then exit;
       LinkImage.ListsClear;

       for I :=0  to Arr.Count-1 do
       begin
         It:=  TAmClientMessageFilesImageCollage.TItem.Create;
         if Arr.Items[i].Typ = jdtString then
         begin
           It.FileName:=     Arr.Items[i].Value;
         end
         else if Arr.Items[i].Typ = jdtObject then
         begin
           ObjFile:= Arr.Items[i].ObjectValue;
           It.aRect:=         AmRectSize.StrToRect(ObjFile['Rect'].Value);
           It.FileName:=      ObjFile['FileName'].Value;
           It.SizeFile:=      AmInt64(ObjFile['Size'].Value,1);
         end;
         
         LinkImage.List.Add(It)

       end;
{
              Hob:= Json['Data'].A['CollageRect'].AddObject;
              Hob['Rect'].Value:=       AmRectSize.RectToStr( CollageRect[i].Rect );
              Hob['FileName'].Value:=   ExtractFileName( CollageRect[i].IndificatorFullFileName );
              Hob['Size'].Value:=       AmStr(AmSizeFile( CollageRect[i].IndificatorFullFileName ));
}
end;
procedure TAmChatZipFile_Config.AddListFileOtherTextJson(ArrJsonString:string);
var JsonArray: TJsonArray;
begin
    JsonArray:= AmJson.LoadArrayText(ArrJsonString);
    try
       AddListFileOther(JsonArray);
    finally
      JsonArray.Free;
    end;
end;
procedure TAmChatZipFile_Config.AddListFileOther(Arr:TJsonArray);
var
  I: Integer;
  Item:TAmClientMessageFilesPaintBox.TItem;
  ObjFile:TJsonObject;
begin

       if not Assigned(LinkPB) then exit;
       LinkPB.ListsClear;

       for I :=0  to Arr.Count-1 do
       begin

           Item:= TAmClientMessageFilesPaintBox.TItem.Create;
           Item.FControl:=LinkPB;
           Item.FileNameFull:= '';
           Item.KindDownload:=mfitNoDownload;


           if Arr.Items[i].Typ = jdtString then
           begin
              Item.FileName:= Arr.Items[i].Value;
              Item.SizeFile:= 1;
              Item.Ico:= AmGetGraficIcon(Item.FileName,16);

           end
           else if Arr.Items[i].Typ = jdtObject then
           begin
              ObjFile:= Arr.Items[i].ObjectValue;
              Item.FileName:= ObjFile['FileName'].Value;
              Item.SizeFile:= AmInt64(ObjFile['Size'].Value,1);
              Item.Ico:= AmGetGraficIcon(Item.FileName,16);

           end;
           LinkPB.FList.Add(Item);

           //Item.SizeFile:= 5000000;
          // Item.PositionBar:=2000000;

       end;
       LinkPB.Repaint;

end;


procedure TAmChatZipFile_Config.Clear;
begin
       //CollageNeed:=false;
      // CollageNeed_MaxWidth:=0;
      // CollageSizeMax.cx:=0;
      // CollageSizeMax.cy:=0;
       PhotoSqueeze:=false;
       PhotoSqueeze_MaxWidth:=0;
       Index_Config:=-1;
end;


                     {TAmClientMessageFilesZipControl}

procedure TAmClientMessageFilesZipControl.SetColor(val:TColor);
begin
    inherited Color:= val;
    FPb.Color:= val;
end;
function TAmClientMessageFilesZipControl.GetColor:TColor;
begin
  Result:= inherited Color;
end;
procedure TAmClientMessageFilesZipControl.SetPhotoDefaultResource(val:String);
begin
  SetPhotoDefault(val,true);
end;
procedure TAmClientMessageFilesZipControl.SetPhotoDefaultFileName(val:String);
begin
   SetPhotoDefault(val,false);
end;

procedure TAmClientMessageFilesZipControl.SetPhotoDefault(val:String;IsResource:boolean);
var CanF:boolean;
begin
  if (FdivCollage=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500)
  or (FdivCollage=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10) then
  begin
     exit;
  end;

   if not FileExists(val) then exit;

 CanF:= CanFocus;
 if CanF then Perform( WM_SETREDRAW, 0, 0 );
 FImg.Visible:=false;
 try
   if IsResource then FPhotoDefaultResource:=val
   else  FPhotoDefaultFileName:=val;

   FdivCollage:=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_DEF;
   FImg.Stretch :=  TImageStretch.Uniform;
   LoadNewImg(FPhotoDefaultFileName,IsResource);
 finally
    FImg.Visible:=true;
    if  CanF then
    begin
     POstMessage(Self.Parent.Handle,wm_size,0,0);
     Perform( WM_SETREDRAW, 1, 0 );
     RedrawWindow( Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN );
    end;
 end;

end;

procedure TAmClientMessageFilesZipControl.SetPhoto10FileName(val:String);
var CanF:boolean;
begin
  if FdivCollage=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500 then
  begin
     //owmessage('photo 10 заблок');
     exit;
  end;
  
   if not FileExists(val) then exit;


 CanF:= CanFocus;
 if CanF then
 begin
   SendMessage(self.Handle, WM_SETREDRAW, 0, 0 );

 end;
 FImg.Visible:=false;
 try
   FPhoto10FileName:=val;
   FdivCollage:=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10;
   FImg.Stretch := TImageStretch.Fit;
   LoadNewImg(FPhoto10FileName,false);

 finally
     FImg.Visible:=true;
    if  CanF then
    begin
     POstMessage(Self.Parent.Handle,wm_size,0,0);
     Perform( WM_SETREDRAW, 1, 0 );
     RedrawWindow( Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN );
    end;
 end;
end;
procedure TAmClientMessageFilesZipControl.SetPhoto500FileName(val:String);
var CanF:boolean;
begin
   if not FileExists(val) then exit;

 CanF:= CanFocus;
 if CanF then Perform( WM_SETREDRAW, 0, 0 );
 FImg.Visible:=false;
 try
   FPhoto500FileName:=val;
   FdivCollage:=AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500;
   FImg.Stretch :=  TImageStretch.Uniform;
   LoadNewImg(FPhoto500FileName,false);
 finally
    FImg.Visible:=true;
    if  CanF then
    begin
     POstMessage(Self.Parent.Handle,wm_size,0,0);
     Perform( WM_SETREDRAW, 1, 0 );
     RedrawWindow( Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN );
    end;
 end;
end;
procedure TAmClientMessageFilesZipControl.LoadNewImg(Fn:String;IsResource:boolean);
var ms:TmemoryStream;
begin
  ms:= TmemoryStream.Create;
  try
   try
    if IsResource then
    begin
      AmUSerType.TamResource.LoadToPicture(FImg.Picture,Fn);
    end
    else
    begin
    ms.LoadFromFile(Fn);
    FImg.Picture.LoadFromStream(ms);
    //AmUSerType.TamResource.LoadToPicture(FImg.Picture,'photo_def_png');
    end;
   except
     showmessage('Error FilesZipControl.LoadNewImg');
   end;
  finally
     ms.Free;
  end;
  ResizeImg(Width);

  
end;

procedure TAmClientMessageFilesZipControl.SetZipFile(val:String);
var Zip: TZipFile;
    Stream:TStream;
    LocalHeader: TZipHeader;
   // i:integer;
begin

  if not FileExists(val) then exit;

  FZipFile:=val;
  Zip:=TZipFile.Create;
  try
    Zip.Open(FZipFile,zmRead);
    Config.Index_Config:= Zip.IndexOf(AM_CHAT_FILEZIP_NAMEFILE_CONFIG);;
    if Config.Index_Config>=0 then
    begin
       Zip.Read(Config.Index_Config, Stream, LocalHeader);
       try Config.JsonToConfig(Stream); finally   Stream.Free; end;
    end;
    Zip.Close;
  finally
    Zip.Free;
  end;


      {  if FConfig.CollageNeed and (FConfig.Index_10>=0) then
        begin
              Zip.Read(FConfig.Index_10, Stream, LocalHeader);
              try
                 MsStream.Clear;
                 MsStream.LoadFromStream(Stream);
                 CreateNewImg(MsStream,AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10);
              finally
                  Stream.Free;
              end;
        end
        else if FConfig.CollageNeed and (FConfig.Index_500>=0) then
        begin
              Zip.Read(FConfig.Index_500, Stream, LocalHeader);
              try
                 MsStream.Clear;
                 MsStream.LoadFromStream(Stream);
                 CreateNewImg(MsStream,AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_500);
              finally
                  Stream.Free;
              end;
        end;
         }






       { for i:=0 to FConfig.ListFileOther.Count-1 do
        begin
        // break;
         //LocalHeader:=Zip.FileInfo[i]; ArrFiles:= Zip.FileNames;

         //ArchiveFile:= AmStr(LocalHeader.FileName);
           // if not GetUTF8PathFromExtraField(LHeader, LFileName) then
             // LFileName := GetTextEncode(FFiles[Index]).GetString(FFiles[Index].FileName);

            // ArchiveFile:=TEncoding.UTF8.GetString(ArchiveFile);

           // if Zip.IndexOf(FConfig.ListFileNeedVisibleIco[i])<0 then  continue;
            FileExt:=ExtractFileExt(ArchiveFile);
            if  pos(LowerCase(FileExt),AM_CHAT_FILEZIP_NAMEFILE_PHOTO_EXT)<>0 then continue
            else FListFiles.Add(FConfig.ListFileNeedVisibleIco[i]);
        end; }
       // UpdateSize;
end;

constructor TAmClientMessageFilesZipControl.Create(AOwner: TComponent);
begin
   IsCreateWindMn:=false;
   inherited Create(AOwner);
  // AutoSize:=true;
   //ListControl:= Tlist.Create;

   FBoxItemHeight:=25;
   inherited Color:=$0051442D;


   FPb:= TAmClientMessageFilesPaintBox.Create(self);
   FPb.Parent:=self;
   FPb.Align:=alTop;
   FPb.ParentColor := FAlse;
   FPb.Color := Color;//$00423129;
   FPb.Font.Color:=Clwhite;
   FPb.Font.Size:=8;
   FPb.OnOpenManagger:= FileOnOpenManagger;
   FPb.OnDownloadStart:= FileOnDownloadStart;
   FPb.OnDownloadAbort:= FileOnDownloadAbort;
   FPb.OnDownloadPause:= FileOnDownloadPause;
   FPb.FBoxItemHeight:= FBoxItemHeight;


   FImg := TAmClientMessageFilesImageCollage.Create(self);
   FImg.Parent:= self;
   FImg.Align:=alnone;
   FImg.Anchors:=[akLeft,AkTop] ;
   FImg.Height:=0;
   FImg.Width:=0;
   FImg.Stretch := TImageStretch.Mixed;
   FImg.Transparent:=true;
   FImg.Smoth:=true;
   FImg.Popap:=TAmClientMenuFilesPaintBox.Create(self);
   FImg.OnOpenManagger:= FileOnOpenManagger;
   FImg.OnDownloadStart:= FileOnDownloadStart;
  // Fimg.OnMouseEnter:=ImgMouseEnter;
  // Fimg.OnMouseLeave:=ImgMouseLeave;
   Config.Clear;
   Config.LinkPB:= FPb;
   Config.LinkImage:= FImg;
end;
destructor TAmClientMessageFilesZipControl.Destroy ;
begin
 // ListControl.Clear;
 // ListControl.Free;
  inherited;
end;

procedure TAmClientMessageFilesZipControl.FileOnOpenManagger(S:Tobject);
begin
 if  Assigned(FOnOpenManagger)  then
 FOnOpenManagger(self,S,0,-1,'');
end;
procedure TAmClientMessageFilesZipControl.FileOnDownloadStart(S:Tobject);
begin
 if s is TAmClientMessageFilesPaintBox then
 if FPb.ListFiles[ FPb.IndexActiv ].KindDownload = mfitProcessing then exit;

 FileOnDownloadEvent(S, FOnDownloadStart );
end;
procedure TAmClientMessageFilesZipControl.FileOnDownloadAbort(S:Tobject);
begin
 if FPb.ListFiles[ FPb.IndexActiv ].KindDownload <>  mfitProcessing then exit;
 FileOnDownloadEvent(S, FOnDownloadAbort );
end;
procedure TAmClientMessageFilesZipControl.FileOnDownloadPause(S:Tobject);
begin
 if FPb.ListFiles[ FPb.IndexActiv ].KindDownload <>  mfitProcessing then exit;
 FileOnDownloadEvent(S, FOnDownloadPause );
end;
procedure TAmClientMessageFilesZipControl.FileOnDownloadEvent(S:Tobject;Proc:TAmClientMessageFilesZipEvent);
var Item:Tobject;
FileName:string;
Index:integer;
ComponentLparam:Integer;
begin
   Index:=-1;
   FileName:='';
   ComponentLparam:=0;

   if AmCheckObject(S) then
   begin
   
       if (S is TAmClientMessageFilesPaintBox) and  (FPb = TAmClientMessageFilesPaintBox(S)) then
       begin

          Index:=  FPb.IndexActiv;
          if (Index>=0)and (Index<FPb.ListFiles.count) then
          begin
            FileName:=  FPb.ListFiles[ FPb.IndexActiv ].FileName;
            ComponentLparam:= Lparam(FPb.ListFiles[ FPb.IndexActiv ]);
          end;

       end
       else if (S is TAmClientMessageFilesImageCollage) and  (FImg = TAmClientMessageFilesImageCollage(S)) then
       begin
          Index:=  FImg.IndexActiv;
          if (Index>=0)and (Index<FImg.List.count) then
          begin
            FileName:=  FImg.List[ FImg.IndexActiv ].FileName;
            ComponentLparam:= Lparam(FImg.List[ FImg.IndexActiv ]);
          end;
       end;


      if (Index>=0) and (FileName<>'') and(ComponentLparam>0) and Assigned(Proc)  then
      Proc(self,S,ComponentLparam,Index,FileName);
   end;


end;


procedure TAmClientMessageFilesZipControl.Paint;
begin
  inherited Paint;
 // showmessage('TAmClientMessageFilesZipControl');
    Canvas.Brush.Color := Color;
    Canvas.FillRect(self.ClientRect);

end;
procedure TAmClientMessageFilesZipControl.CreateWnd;
begin
   inherited CreateWnd;
   IsCreateWindMn:=true;
end;
procedure  TAmClientMessageFilesZipControl.Resize;
var I:integer;
begin
 //showmessage('TAmClientMessageFilesZipControl');
    inherited Resize;


end;
procedure TAmClientMessageFilesZipControl.ResizeParamIntput(W:integer);
begin
   if self.CanFocus then   ResizeSelf(w) ;
end;
procedure TAmClientMessageFilesZipControl.ResizeImg(NowWidth:integer);
var W,H:integer;
begin
    if not Assigned(FImg.Picture) then
    begin
      FImg.Width:=0;
      FImg.Height:= 0;
      exit;
    end;
    if (FdivCollage<>AM_CHAT_FILEZIP_NAMEFILE_COLLAGE_10) and (FImg.Picture.Width <  Width) then
    begin
        W:= FImg.Picture.Width;
        if W<10 then W:=10;
        
    end
    else W:= Width;
    H:=  round(w/ (FImg.Picture.Width / FImg.Picture.Height));
    FImg.Width:=w;
    FImg.Height:= H;
end;
procedure TAmClientMessageFilesZipControl.ResizeSelf(W:integer);
var I:integer;
NewH:integer;
begin



   if (FPb.FList.Count>0) or (FImg.Height>0)  then
   begin
      NewH:=  (FPb.FList.Count* FBoxItemHeight);
      FPb.Height:= NewH;
      ResizeImg(W);
      FImg.Top:= FPb.Top+FPb.Height+5;
      NewH:=NewH+ FImg.Height ;
      Height:= NewH;
   end
   else Height:= FBoxItemHeight;

end;

procedure TAmClientMessageFilesZipControl.ConstrainedResize(var MinWidth, MinHeight, MaxWidth,MaxHeight: Integer);
begin
   MinWidth:=60;
  inherited ConstrainedResize(MinWidth, MinHeight, MaxWidth,MaxHeight);

end;
















              {TAmClientMessageOneFileImg}

constructor TAmClientMessageOneFileImg.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     CorrectIcoX:=0;
     CorrectIcoY:=0;
    CorrectTextX:=0;
    CorrectTextY:=0;
       FIconPhoto:= Ticon.Create;
       FtimerFocus:= Ttimer.Create(self);
       FtimerFocus.Enabled:=false;
       FtimerFocus.Interval:=500;
       FtimerFocus.OnTimer:= TimerFocusOnTimer;

       FImg := TEsImage.Create(self);
       FImg.Parent:= self;
       FImg.Align:=alclient;
       FImg.Stretch := TImageStretch.Mixed;
       FImg.Transparent:=true;
       FImg.Smoth:=true;
       Fimg.OnMouseEnter:=ImgMouseEnter;
       Fimg.OnMouseLeave:=ImgMouseLeave;

       FFn:= TPaintBox.Create(self);
       FFn.Parent:=self;
       FFn.Top:=0;
       FFn.Left:=0;
       FFn.Width:=200;
       FFn.ParentColor := FAlse;
       FFn.Font.Color:=$00E8B4B3;
       FFn.Font.Size:=10;
       FFn.Height:=30;
       FFn.OnPaint:= FnPaint;
       FFn.Visible:=false;


      // FImg.Picture.LoadFromFile('E:\Red 10.3\Projects\socketClientServer\Win32\Debug\set\chat\client\photos\Photo1_7.jpg');



end;
destructor TAmClientMessageOneFileImg.Destroy ;
begin
   FIconPhoto.Free;
   inherited;
end;
procedure TAmClientMessageOneFileImg.UpdateHeight;
var
PicH,PicW:integer;
Delta:real;
begin
     if (FImg=nil) or  (FImg.Picture=nil) then
     begin
      Height:=0;
      exit;
     end;
    PicH:= FImg.Picture.Height;
    PicW:= FImg.Picture.Width;
    Delta:=  PicH / PicW;
    if Width>1000 then Width:=1000;
    Height:=Round(Width* Delta);
end;
procedure TAmClientMessageOneFileImg.ImgMouseEnter(Sender: TObject);
begin
   FFn.Visible:=true;
   FIsMouseActiv:=true;
   FtimerFocus.Enabled:=true;
end;

procedure TAmClientMessageOneFileImg.ImgMouseLeave(Sender: TObject);
begin
   FIsMouseActiv:=False;
end;
procedure TAmClientMessageOneFileImg.FnMouseEnter(Sender: TObject);
begin
    FFn.Visible:=true;
    FIsMouseActiv:=true;
    FtimerFocus.Enabled:=true;
end;
procedure TAmClientMessageOneFileImg.FnMouseLeave(Sender: TObject);
begin
     FIsMouseActiv:=False;
end;
procedure TAmClientMessageOneFileImg.TimerFocusOnTimer(Sender: TObject);
begin
    if not FIsMouseActiv then
    begin
       FFn.Visible:=false;
       FtimerFocus.Enabled:=false;
    end;
end;
procedure TAmClientMessageOneFileImg.SetFileNamePhoto(val: string);
begin
     FFileNamePhoto:=val;
     FIconPhoto.Handle :=AmGetFileExtAssociatedIcon(FFileNamePhoto, true,false);
end;
procedure  TAmClientMessageOneFileImg.FnPaint(S:TObject);
begin
   FFn.Canvas.Brush.Color := Color;
   FFn.Canvas.FillRect(self.ClientRect);
   FFn.Canvas.Font := FFn.Font;

   if FIconPhoto.Handle>0 then
   begin
    if  (FFn.Height - FIconPhoto.Height > 0)
    and (FFn.Height - FIconPhoto.Width  > 0) then
     FFn.Canvas.Draw(
                      CorrectIcoX+((FFn.Height- FIconPhoto.Height) div 2),
                      CorrectIcoY+((FFn.Height- FIconPhoto.Height) div 2),
                      FIconPhoto
                    )
    else FFn.Canvas.Draw(CorrectIcoX+5,CorrectIcoY+5,FIconPhoto);
   end;
   FFn.Canvas.TextOut(CorrectTextX+FFn.Height, CorrectTextY+6 ,FileNamePhoto);
end;

end.







