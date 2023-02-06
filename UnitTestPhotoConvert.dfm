object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 465
  ClientWidth = 681
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 568
    Top = 72
    Width = 77
    Height = 33
    Caption = 'Label1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 566
    Top = 111
    Width = 77
    Height = 33
    Caption = 'Label2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Image1: TImage
    Left = 0
    Top = 8
    Width = 225
    Height = 209
    Stretch = True
  end
  object Image2: TImage
    Left = 0
    Top = 223
    Width = 225
    Height = 209
    Stretch = True
  end
  object EsImage1: TEsImage
    Left = 296
    Top = 200
    Width = 273
    Height = 232
    Stretch = Fit
  end
  object Button1: TButton
    Left = 568
    Top = 25
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object TrackBar1: TTrackBar
    Left = 323
    Top = 40
    Width = 102
    Height = 25
    Max = 100
    Min = 1
    Frequency = 5
    Position = 100
    TabOrder = 1
    ThumbLength = 14
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 304
    Top = 256
  end
end
