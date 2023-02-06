unit UnitTestPhotoConvert;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,amGrafic, Vcl.StdCtrls,Jpeg, Vcl.ExtCtrls,
  Vcl.ComCtrls, ES.BaseControls, ES.Images;

type
  TForm3 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Image2: TImage;
    TrackBar1: TTrackBar;
    EsImage1: TEsImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var P:TAmConvecterTo—ollagePhoto;
I:integer;
Out_Bm:TBitMap;
s,s2:TmemoryStream;
jpg:TJpegImage;
begin
 if not  openDialog1.Execute then exit;


   P:=  TAmConvecterTo—ollagePhoto.Create;
   s:=  TmemoryStream.Create;
   s2:= TmemoryStream.Create;
   jpg:= TJpegImage.Create;
   try
  //
    for I := 0 to openDialog1.Files.Count-1 do
     P.AddFileNameImg(openDialog1.Files[i]);

     P.SetNeedMaxWidth:=600;
     P.Convecter;
     P.ResultGetStream(s,TrackBar1.Position,0);
     {Label1.Caption:= formatFloat('0.000',s.Size / 1000000) +'Mb '+' / ';
     Image2.Picture.LoadFromStream(s);
     s.Position:=0;





     jpg.Assign(P.ResultGetBitMap());
    //jpg.LoadFromStream(s);
      s.Clear;
     jpg.DIBNeeded;
     jpg.CompressionQuality := TrackBar1.Position;
     jpg.Grayscale:=false;
     jpg.Compress;
   //  jpg.SaveToFile(Edit1.Text+'\SnapShots(new)\'+numberStr+'(new).bmp');
     jpg.SaveToStream(s);
     s.Position:=0;
     Label2.Caption:= formatFloat('0.000',s.Size / 1000000) +'Mb '+' / ';}
     EsImage1.Picture.LoadFromStream(s);
     Label1.Caption:= formatFloat('0.000',s.Size / 1000000) +'Mb '+' / '
   finally
    P.Free;
    s.Free;
    s2.Free;
    jpg.Free;
   end;


end;

end.
