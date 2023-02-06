object Form2: TForm2
  Left = 0
  Top = 0
  AlphaBlendValue = 200
  Caption = 'Form2'
  ClientHeight = 643
  ClientWidth = 966
  Color = 4337961
  TransparentColorValue = clOlive
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 194
    Width = 966
    Height = 449
    Align = alBottom
    Caption = 'Panel2'
    TabOrder = 0
    Visible = False
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 964
      Height = 447
      ActivePage = TabSheet2
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNone
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'TabSheet1'
        object Memo3: TMemo
          Left = 0
          Top = 0
          Width = 956
          Height = 419
          Align = alClient
          Lines.Strings = (
            'Memo1')
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'TabSheet2'
        ImageIndex = 1
        object Label1: TLabel
          Left = 194
          Top = 11
          Width = 31
          Height = 13
          Alignment = taRightJustify
          Caption = 'Label1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14342874
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Edit1: TEdit
          Left = 8
          Top = 8
          Width = 121
          Height = 21
          TabOrder = 0
          Text = '127.0.0.1'
        end
        object Edit2: TEdit
          Left = 135
          Top = 8
          Width = 121
          Height = 21
          TabOrder = 1
          Text = '5678'
        end
        object Edit3: TEdit
          Left = 262
          Top = 8
          Width = 178
          Height = 21
          TabOrder = 2
          Text = '77.220.213.53 127.0.0.1'
        end
        object Panel3: TPanel
          Left = 440
          Top = 8
          Width = 25
          Height = 21
          Caption = 'V'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = Panel1Click
        end
      end
    end
  end
  object Button6: TPanel
    Left = 0
    Top = 1
    Width = 418
    Height = 41
    Caption = #1047#1072#1081#1090#1080' '#1074' '#1095#1072#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button6Click
  end
  object Panel1: TPanel
    Left = 416
    Top = 1
    Width = 25
    Height = 41
    Caption = 'V'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = Panel1Click
  end
  object Panel4: TPanel
    Left = 441
    Top = 1
    Width = 25
    Height = 41
    Caption = 'M'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = Panel4Click
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 664
    Top = 48
  end
  object SaveDialog1: TSaveDialog
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 592
    Top = 40
  end
end
