object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 1092
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 472
    Top = 92
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Image1: TImage
    Left = 447
    Top = 66
    Width = 195
    Height = 225
  end
  object memoLog: TMemo
    Left = 8
    Top = 8
    Width = 433
    Height = 283
    Color = 12961265
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 447
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '5678'
  end
  object ButtonStart: TButton
    Left = 447
    Top = 35
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = ButtonStartClick
  end
  object Memo1: TMemo
    Left = 880
    Top = 8
    Width = 177
    Height = 283
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
  object Button1: TButton
    Left = 543
    Top = 35
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 711
    Top = 66
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 5
  end
  object Button3: TButton
    Left = 711
    Top = 97
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 6
  end
  object Button4: TButton
    Left = 711
    Top = 128
    Width = 75
    Height = 25
    Caption = 'buff'
    TabOrder = 7
  end
  object Edit2: TEdit
    Left = 711
    Top = 159
    Width = 121
    Height = 21
    TabOrder = 8
    Text = '5678'
  end
end
