object ChatClientForm: TChatClientForm
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  Caption = 'ChatClientForm'
  ClientHeight = 664
  ClientWidth = 1015
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTools: TPanel
    Left = 0
    Top = 0
    Width = 1015
    Height = 24
    Align = alTop
    BevelOuter = bvNone
    Color = 2891803
    ParentBackground = False
    TabOrder = 1
    object LogOut: TLabel
      AlignWithMargins = True
      Left = 969
      Top = 3
      Width = 36
      Height = 16
      Margins.Right = 10
      Align = alRight
      Caption = #1042#1099#1081#1090#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421631
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = LogOutClick
    end
  end
  object PanelLogin: TPanel
    Left = 0
    Top = 24
    Width = 1015
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 4337961
    ParentBackground = False
    TabOrder = 3
    object PanelLogin_Main: TPanel
      Left = 136
      Top = 78
      Width = 612
      Height = 451
      Align = alCustom
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 201
        Top = 26
        Width = 206
        Height = 18
        Caption = #1044#1086#1073#1088#1086' '#1087#1086#1078#1072#1083#1086#1074#1072#1090#1100' '#1074' '#1095#1072#1090
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object PanelReg_PReg: TPanel
        Left = 317
        Top = 65
        Width = 277
        Height = 356
        TabOrder = 0
        object Label9: TLabel
          Left = 81
          Top = 17
          Width = 114
          Height = 16
          Caption = #1057#1086#1079#1076#1072#1090#1100' '#1072#1082#1082#1072#1091#1085#1090
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label10: TLabel
          Left = 60
          Top = 140
          Width = 43
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label33: TLabel
          Left = 60
          Top = 46
          Width = 38
          Height = 13
          Caption = #1051#1086#1075#1080#1085' '
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label36: TLabel
          Left = 59
          Top = 188
          Width = 95
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100' '#1077#1097#1077' '#1088#1072#1079
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label37: TLabel
          Left = 59
          Top = 92
          Width = 31
          Height = 13
          Caption = 'Email'
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label38: TLabel
          Left = 60
          Top = 235
          Width = 77
          Height = 13
          Caption = #1048#1084#1103' '#1060#1072#1084#1080#1083#1080#1103
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object PanelReg_Pass: TEdit
          Left = 60
          Top = 158
          Width = 161
          Height = 21
          TabOrder = 0
        end
        object PanelReg_Go: TPanel
          Left = 59
          Top = 284
          Width = 161
          Height = 33
          Caption = #1057#1086#1079#1076#1072#1090#1100
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = PanelReg_GoClick
        end
        object PanelReg_Login: TEdit
          Left = 60
          Top = 64
          Width = 161
          Height = 21
          TabOrder = 2
        end
        object PanelReg_Pass2: TEdit
          Left = 59
          Top = 206
          Width = 161
          Height = 21
          TabOrder = 3
        end
        object PanelReg_Email: TEdit
          Left = 59
          Top = 110
          Width = 161
          Height = 21
          TabOrder = 4
        end
        object PanelReg_UserName: TEdit
          Left = 59
          Top = 254
          Width = 161
          Height = 21
          TabOrder = 5
        end
      end
      object PanelLogin_PLogin: TPanel
        Left = 18
        Top = 65
        Width = 278
        Height = 356
        TabOrder = 1
        object Label35: TLabel
          Left = 86
          Top = 17
          Width = 112
          Height = 16
          Caption = #1042#1086#1081#1090#1080' '#1074' '#1072#1082#1082#1072#1091#1085#1090
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label32: TLabel
          Left = 60
          Top = 94
          Width = 43
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label31: TLabel
          Left = 60
          Top = 46
          Width = 94
          Height = 13
          Caption = #1051#1086#1075#1080#1085' '#1080#1083#1080' Email'
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label34: TLabel
          Left = 82
          Top = 182
          Width = 61
          Height = 13
          Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object PanelLogin_Pass: TEdit
          Left = 60
          Top = 112
          Width = 162
          Height = 21
          TabOrder = 0
        end
        object PanelLogin_Go: TPanel
          Left = 60
          Top = 142
          Width = 162
          Height = 33
          Caption = #1042#1086#1081#1090#1080
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = PanelLogin_GoClick
        end
        object PanelLogin_Remember: TCheckBox
          Left = 61
          Top = 180
          Width = 18
          Height = 17
          Color = 4337961
          ParentColor = False
          TabOrder = 2
        end
        object PanelLogin_Login: TEdit
          Left = 60
          Top = 64
          Width = 162
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  object PanelManagerFile: TPanel
    Left = 0
    Top = 24
    Width = 1015
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 4337961
    ParentBackground = False
    TabOrder = 4
    Visible = False
    object PanelManagerFile_bottom: TPanel
      Left = 0
      Top = 517
      Width = 1015
      Height = 123
      Align = alBottom
      BevelOuter = bvNone
      Color = 4337961
      ParentBackground = False
      TabOrder = 0
      object Label2: TLabel
        Left = 34
        Top = 86
        Width = 69
        Height = 18
        Caption = #1054#1090#1084#1077#1085#1080#1090#1100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16051878
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = PanelSendFile_backClick
      end
      object Label8: TLabel
        Left = 277
        Top = 86
        Width = 101
        Height = 18
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074#1089#1077
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16051878
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = PanelSendFile_sendClick
      end
      object Label11: TLabel
        Left = 34
        Top = 29
        Width = 89
        Height = 16
        Caption = #1055#1072#1087#1082#1072' '#1079#1072#1075#1088#1091#1079#1086#1082
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15250611
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 603
        Top = 61
        Width = 252
        Height = 22
        Caption = 
          #1042#1099' '#1084#1086#1078#1077#1090#1077' '#1074#1099#1087#1086#1083#1085#1080#1090#1100' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1099#1077' '#1086#1087#1077#1088#1072#1094#1080#1080' '#1089' '#1092#1072#1081#1083#1072#1084#1080#13#10#1074#1099#1076#1077#1083#1080#1074' '#1080#1093' '#1080 +
          ' '#1085#1072#1078#1072#1074' '#1087#1088#1072#1074#1091#1102' '#1082#1085#1086#1087#1082#1091' '#1084#1099#1096#1080
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11768708
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = PanelSendFile_AdderFileClick
      end
      object Edit2: TEdit
        Left = 34
        Top = 51
        Width = 272
        Height = 24
        BorderStyle = bsNone
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object Panel7: TPanel
        Left = 34
        Top = 74
        Width = 271
        Height = 1
        BevelOuter = bvNone
        Color = 14531413
        ParentBackground = False
        TabOrder = 1
      end
      object Panel8: TPanel
        Left = 312
        Top = 49
        Width = 30
        Height = 26
        BevelOuter = bvNone
        Caption = '...'
        Color = 7295556
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
      end
      object Panel9: TPanel
        Left = 348
        Top = 49
        Width = 30
        Height = 26
        BevelOuter = bvNone
        Caption = '.'
        Color = 7361091
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 3
      end
    end
    object PanelManagerFile_top: TPanel
      Left = 0
      Top = 0
      Width = 1015
      Height = 37
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object PanelManagerFile_back: TLabel
        Left = 8
        Top = 5
        Width = 24
        Height = 30
        Caption = #1087
        Font.Charset = SYMBOL_CHARSET
        Font.Color = 15250611
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = PanelManagerFile_backClick
      end
    end
    object PanelManagerFile_client: TPanel
      Left = 0
      Top = 37
      Width = 1015
      Height = 480
      Align = alClient
      BevelOuter = bvNone
      Color = 4337961
      ParentBackground = False
      TabOrder = 2
      object PanelManagerFile_menu: TPanel
        Left = 0
        Top = 0
        Width = 40
        Height = 480
        Align = alLeft
        BevelOuter = bvNone
        Color = 4337961
        ParentBackground = False
        TabOrder = 0
        object PanelManagerFile_send_menu: TPanel
          Left = 0
          Top = 0
          Width = 40
          Height = 37
          Align = alTop
          BevelOuter = bvNone
          Color = 9672510
          ParentBackground = False
          TabOrder = 0
          OnClick = PanelManagerFile_send_menuClick
          object PanelManagerFile_send_menu_label: TLabel
            Left = 9
            Top = -1
            Width = 21
            Height = 33
            Caption = #8649
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 15918210
            Font.Height = -27
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = PanelManagerFile_send_menuClick
          end
        end
        object PanelManagerFile_setting_menu: TPanel
          Left = 0
          Top = 111
          Width = 40
          Height = 37
          Align = alTop
          BevelOuter = bvNone
          Color = 4337961
          ParentBackground = False
          TabOrder = 1
          OnClick = PanelManagerFile_setting_menuClick
          object PanelManagerFile_setting_menu_label: TLabel
            Left = 8
            Top = 0
            Width = 20
            Height = 33
            Caption = #10044
            Color = clBlue
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 15380106
            Font.Height = -27
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            OnClick = PanelManagerFile_setting_menuClick
          end
        end
        object PanelManagerFile_download_menu: TPanel
          Left = 0
          Top = 37
          Width = 40
          Height = 37
          Align = alTop
          BevelOuter = bvNone
          Color = 4337961
          ParentBackground = False
          TabOrder = 2
          OnClick = PanelManagerFile_download_menuClick
          object PanelManagerFile_download_menu_label: TLabel
            Left = 8
            Top = -1
            Width = 21
            Height = 33
            Caption = #8647
            Color = clBlue
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 8558834
            Font.Height = -27
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            OnClick = PanelManagerFile_download_menuClick
          end
        end
        object PanelManagerFile_msg_menu: TPanel
          Left = 0
          Top = 74
          Width = 40
          Height = 37
          Align = alTop
          BevelOuter = bvNone
          Color = 4337961
          ParentBackground = False
          TabOrder = 3
          OnClick = PanelManagerFile_msg_menuClick
          object PanelManagerFile_msg_menu_label: TLabel
            Left = 9
            Top = 0
            Width = 21
            Height = 33
            Caption = #9779
            Color = clBlue
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 15380106
            Font.Height = -27
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            OnClick = PanelManagerFile_msg_menuClick
          end
        end
      end
      object PanelManagerFile_send_view: TPanel
        Left = 40
        Top = 0
        Width = 268
        Height = 480
        Align = alLeft
        BevelOuter = bvNone
        Color = 9672510
        ParentBackground = False
        TabOrder = 1
        object Label13: TLabel
          Left = 13
          Top = 9
          Width = 225
          Height = 16
          Caption = #1060#1072#1081#1083#1099' '#1082#1086#1090#1086#1088#1099#1077' '#1089#1077#1081#1095#1072#1089' '#1086#1090#1087#1088#1072#1074#1083#1103#1102#1090#1089#1103
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16245473
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object PanelManagerFile_download_view: TPanel
        Left = 314
        Top = -6
        Width = 214
        Height = 480
        BevelOuter = bvNone
        Color = 4742806
        ParentBackground = False
        TabOrder = 2
        object Label12: TLabel
          Left = 13
          Top = 9
          Width = 217
          Height = 16
          Caption = #1060#1072#1081#1083#1099' '#1082#1086#1090#1086#1088#1099#1077' '#1089#1077#1081#1095#1072#1089' '#1089#1082#1072#1095#1080#1074#1072#1102#1090#1089#1103
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16245473
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object PanelManagerFile_msg_view: TPanel
        Left = 534
        Top = -6
        Width = 217
        Height = 480
        BevelOuter = bvNone
        Color = 9787725
        ParentBackground = False
        TabOrder = 3
        object Label18: TLabel
          Left = 13
          Top = 9
          Width = 194
          Height = 16
          Caption = #1060#1072#1081#1083#1099' '#1089' '#1074#1099#1073#1088#1072#1085#1085#1086#1075#1086' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16245473
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object PanelManagerFile_setting_view: TPanel
        Left = 757
        Top = 1
        Width = 217
        Height = 480
        BevelOuter = bvNone
        Color = 6451501
        ParentBackground = False
        TabOrder = 4
        object Label14: TLabel
          Left = 13
          Top = 9
          Width = 61
          Height = 16
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16245473
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
  object PanelObjectCreate: TPanel
    Left = 0
    Top = 24
    Width = 1015
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 4337961
    ParentBackground = False
    TabOrder = 5
    Visible = False
    object PanelObjectCreate_back: TLabel
      Left = 13
      Top = 6
      Width = 24
      Height = 30
      Caption = #1087
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clSilver
      Font.Height = -27
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = PanelObjectCreate_backClick
    end
    object GroupBox1: TGroupBox
      Left = 36
      Top = 49
      Width = 399
      Height = 294
      TabOrder = 0
      object Label3: TLabel
        Left = 43
        Top = 29
        Width = 153
        Height = 16
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1091#1102' '#1075#1088#1091#1087#1087#1091
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object Label19: TLabel
        Left = 43
        Top = 52
        Width = 167
        Height = 13
        Caption = #1050#1086#1088#1086#1090#1082#1086#1077' '#1080#1084#1103' ('#1085#1072' '#1083#1072#1090#1080#1085#1080#1094#1077')'
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object Label20: TLabel
        Left = 40
        Top = 101
        Width = 147
        Height = 13
        Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099' ('#1085#1072' '#1088#1091#1089#1089#1082#1086#1084')'
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object Label16: TLabel
        Left = 44
        Top = 150
        Width = 67
        Height = 13
        Caption = #1058#1080#1087' '#1075#1088#1091#1087#1087#1099
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object PanelObjectCreate_Groop_Error: TLabel
        Left = 44
        Top = 260
        Width = 4
        Height = 13
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 8421631
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object PanelObjectCreate_Groop_ScreenName: TEdit
        Left = 43
        Top = 70
        Width = 166
        Height = 21
        TabOrder = 0
      end
      object PanelObjectCreate_Groop_UserName: TEdit
        Left = 43
        Top = 119
        Width = 309
        Height = 21
        TabOrder = 1
      end
      object PanelObjectCreate_Groop_Type: TComboBox
        Left = 43
        Top = 169
        Width = 309
        Height = 21
        Style = csDropDownList
        TabOrder = 2
        Items.Strings = (
          #1054#1090#1082#1088#1099#1090#1099#1081' '#1095#1072#1090' '
          #1047#1072#1082#1088#1099#1090#1099#1081' '#1095#1072#1090'('#1090#1086#1083#1100#1082#1086' '#1087#1086' '#1087#1088#1080#1075#1083#1072#1096#1077#1085#1080#1102')'
          #1054#1090#1082#1088#1099#1090#1099#1081' '#1082#1072#1085#1072#1083' ('#1076#1088#1091#1075#1080#1077' '#1085#1077' '#1089#1084#1086#1075#1091#1090' '#1087#1080#1089#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1072#1076#1084#1080#1085#1099') '
          #1047#1072#1082#1088#1099#1090#1085#1099#1081' '#1082#1072#1085#1072#1083' ('#1090#1086#1083#1100#1082#1086' '#1087#1086' '#1087#1088#1080#1075#1083#1072#1096#1077#1085#1080#1102')')
      end
      object PanelObjectCreate_Groop_Create: TPanel
        Left = 44
        Top = 205
        Width = 308
        Height = 38
        Caption = #1057#1086#1079#1076#1072#1090#1100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = PanelObjectCreate_Groop_CreateClick
      end
    end
  end
  object Panel1: TPanel
    Left = 291
    Top = 93
    Width = 374
    Height = 506
    Caption = 'Panel1'
    TabOrder = 6
    Visible = False
    object Panel_Groop_Edit: TEsLayout
      Left = 14
      Top = 11
      Width = 347
      Height = 486
      Color = 4337961
      ParentBackground = False
      ParentColor = False
      TabOrder = 0
      object Label15: TLabel
        Left = 13
        Top = 9
        Width = 141
        Height = 16
        Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15250611
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label21: TLabel
        Left = 97
        Top = 33
        Width = 48
        Height = 16
        Caption = 'localike'
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object Panel_Groop_Edit_Save: TLabel
        Left = 258
        Top = 52
        Width = 62
        Height = 16
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16051878
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Visible = False
        OnClick = Panel_Groop_Edit_SaveClick
      end
      object Label26: TLabel
        Left = 97
        Top = 52
        Width = 68
        Height = 16
        Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15250611
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Panel10: TPanel
        Left = 12
        Top = 34
        Width = 77
        Height = 72
        TabOrder = 0
        object Panel_Groop_Edit_Photo: TEsImage
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 69
          Height = 64
          Align = alClient
          Stretch = Fill
          OnClick = Panel_Groop_Edit_PhotoClick
          ExplicitLeft = 31
          ExplicitTop = 13
          ExplicitWidth = 94
          ExplicitHeight = 90
        end
      end
      object Panel_Groop_Edit_UserName: TEdit
        Left = 97
        Top = 74
        Width = 220
        Height = 24
        BorderStyle = bsNone
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnChange = Panel_Groop_Edit_UserNameChange
      end
      object Panel11: TPanel
        Left = 97
        Top = 101
        Width = 225
        Height = 1
        BevelOuter = bvNone
        Color = 14531413
        ParentBackground = False
        TabOrder = 2
      end
    end
  end
  object PanelProfile: TPanel
    Left = 0
    Top = 24
    Width = 1015
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 4337961
    ParentBackground = False
    TabOrder = 2
    object PanelProfile_UserName: TLabel
      Left = 157
      Top = 43
      Width = 135
      Height = 16
      Caption = #1050#1080#1088#1080#1083#1083' '#1056#1077#1096#1077#1090#1085#1080#1082#1086#1074
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object PanelProfile_back: TLabel
      Left = 13
      Top = 6
      Width = 24
      Height = 30
      Caption = #1087
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clSilver
      Font.Height = -27
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = PanelProfile_backClick
    end
    object PanelProfile_ScreenName: TLabel
      Left = 157
      Top = 59
      Width = 48
      Height = 16
      Caption = 'localike'
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object PanelProfile_EditPass: TLabel
      Left = 46
      Top = 309
      Width = 116
      Height = 16
      Caption = #1055#1086#1084#1077#1085#1103#1090#1100' '#1087#1072#1088#1086#1083#1100
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label27: TLabel
      Left = 46
      Top = 168
      Width = 90
      Height = 13
      Caption = #1057#1090#1072#1088#1099#1081' '#1087#1072#1088#1086#1083#1100
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label28: TLabel
      Left = 46
      Top = 216
      Width = 84
      Height = 13
      Caption = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label29: TLabel
      Left = 46
      Top = 264
      Width = 84
      Height = 13
      Caption = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label30: TLabel
      Left = 69
      Top = 343
      Width = 280
      Height = 13
      Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1091#1074#1077#1076#1086#1084#1083#1077#1085#1080#1103' '#1086' '#1085#1086#1074#1099#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1103#1093
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object PanelProfile_NewPhoto: TLabel
      Left = 46
      Top = 139
      Width = 80
      Height = 16
      Caption = #1053#1086#1074#1086#1077' '#1092#1086#1090#1086
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnClick = PanelProfile_NewPhotoClick
    end
    object LogOutAcc: TLabel
      AlignWithMargins = True
      Left = 50
      Top = 376
      Width = 102
      Height = 16
      Margins.Right = 10
      Caption = #1042#1099#1081#1090#1080' c '#1072#1082#1082#1072#1091#1085#1090#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421631
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = LogOutAccClick
    end
    object PanelProfile_OldPass: TEdit
      Left = 46
      Top = 186
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object PanelProfile_NewPass: TEdit
      Left = 46
      Top = 234
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object PanelProfile_NewPass2: TEdit
      Left = 46
      Top = 282
      Width = 121
      Height = 21
      TabOrder = 2
    end
    object PanelProfile_NotiNewMessage: TCheckBox
      Left = 45
      Top = 342
      Width = 18
      Height = 17
      Color = 4337961
      ParentColor = False
      TabOrder = 3
    end
    object PanelProfile_PanelPhoto: TPanel
      Left = 46
      Top = 39
      Width = 102
      Height = 98
      TabOrder = 4
      object PanelProfile_Photo: TEsImage
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 94
        Height = 90
        Align = alClient
        Stretch = Fill
        OnClick = PanelProfile_NewPhotoClick
        ExplicitLeft = 16
        ExplicitTop = 16
        ExplicitWidth = 100
        ExplicitHeight = 100
      end
    end
  end
  object PanelChatClient: TPanel
    Left = 0
    Top = 24
    Width = 1015
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 3217949
    ParentBackground = False
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 206
      Top = 0
      Width = 2
      Height = 640
      Color = 4337961
      MinSize = 1
      ParentColor = False
    end
    object Splitter2: TSplitter
      Left = 809
      Top = 0
      Width = 2
      Height = 640
      Align = alRight
      Color = 4337961
      ParentColor = False
      ExplicitLeft = 793
    end
    object PanelLeft: TPanel
      Left = 0
      Top = 0
      Width = 206
      Height = 640
      Align = alLeft
      BevelOuter = bvNone
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      object PanelTopContacts: TPanel
        Left = 0
        Top = 0
        Width = 206
        Height = 43
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15250611
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object OpenProFile: TLabel
          Left = 13
          Top = 6
          Width = 17
          Height = 29
          Caption = #8801
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = OpenProFileClick
        end
        object OpenManagerFile: TLabel
          Left = 59
          Top = 5
          Width = 17
          Height = 29
          Caption = #8693
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
          OnClick = OpenManagerFileClick
        end
        object OpenObjectCreate: TLabel
          Left = 36
          Top = 6
          Width = 17
          Height = 29
          Caption = '+'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = OpenObjectCreateClick
        end
        object Panel3: TPanel
          Left = 201
          Top = 0
          Width = 5
          Height = 43
          Align = alRight
          BevelOuter = bvNone
          Color = 6309692
          ParentBackground = False
          TabOrder = 0
        end
      end
    end
    object PanelRigth: TPanel
      Left = 811
      Top = 0
      Width = 204
      Height = 640
      Align = alRight
      BevelOuter = bvNone
      Color = 4337961
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      object PanelSerchTop: TPanel
        Left = 0
        Top = 0
        Width = 204
        Height = 43
        Align = alTop
        BevelOuter = bvNone
        Color = 4337961
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object PanelSerchTop_SerchGo: TLabel
          Left = 176
          Top = 7
          Width = 17
          Height = 33
          Caption = #8981
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -27
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = PanelSerchTop_SerchGoClick
        end
        object Label17: TLabel
          Left = 4
          Top = 8
          Width = 24
          Height = 30
          Caption = #1087
          Font.Charset = SYMBOL_CHARSET
          Font.Color = 15250611
          Font.Height = -27
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
          OnClick = PanelProfile_backClick
        end
        object PanelSerchTop_Serch: TEdit
          Left = 33
          Top = 13
          Width = 135
          Height = 19
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Text = #1055#1086#1080#1089#1082
          OnEnter = PanelSerchTop_SerchEnter
          OnExit = PanelSerchTop_SerchExit
        end
        object Panel6: TPanel
          Left = 32
          Top = 34
          Width = 138
          Height = 1
          BevelOuter = bvNone
          Color = 15250611
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          TabOrder = 1
        end
      end
    end
    object PanelChat: TPanel
      Left = 208
      Top = 0
      Width = 601
      Height = 640
      Align = alClient
      BevelOuter = bvNone
      Color = 10452337
      ParentBackground = False
      TabOrder = 0
      object PanelChatTop: TPanel
        Left = 0
        Top = 0
        Width = 601
        Height = 43
        Align = alTop
        BevelOuter = bvNone
        Color = 4337963
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        DesignSize = (
          601
          43)
        object PanelChatTop_UserName: TLabel
          Left = 41
          Top = 5
          Width = 137
          Height = 18
          Caption = #1050#1080#1088#1080#1083#1083' '#1056#1077#1096#1077#1090#1085#1080#1082#1086#1074
          Color = 4337961
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object PanelChatTop_Status: TLabel
          Left = 42
          Top = 22
          Width = 32
          Height = 13
          Caption = #1074' '#1089#1077#1090#1080
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16051878
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object PanelChatTop_ChatShare: TLabel
          Left = 565
          Top = 5
          Width = 19
          Height = 29
          Anchors = [akTop, akRight]
          Caption = #9783
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
          OnClick = PanelChatTop_ChatShareClick
        end
        object LabelBackChat: TLabel
          Left = 9
          Top = 6
          Width = 24
          Height = 30
          Caption = #1087
          Font.Charset = SYMBOL_CHARSET
          Font.Color = 15250611
          Font.Height = -27
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
          OnClick = LabelBackChatClick
        end
        object LabelOpenSerch: TLabel
          Left = 542
          Top = 4
          Width = 17
          Height = 33
          Anchors = [akTop, akRight]
          Caption = #8981
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15250611
          Font.Height = -27
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
          OnClick = PanelSerchTop_SerchGoClick
        end
        object Panel2: TPanel
          Left = 596
          Top = 0
          Width = 5
          Height = 43
          Align = alRight
          BevelOuter = bvNone
          Color = 6309692
          ParentBackground = False
          TabOrder = 0
        end
      end
      object PanelChatBottomB: TPanel
        Left = 0
        Top = 597
        Width = 601
        Height = 43
        Align = alBottom
        Anchors = [akLeft, akBottom]
        BevelOuter = bvNone
        Color = 4337963
        ParentBackground = False
        TabOrder = 2
        object PanelChatBottomClient: TPanel
          Left = 0
          Top = 0
          Width = 601
          Height = 43
          Align = alClient
          BevelOuter = bvNone
          Color = 4337963
          ParentBackground = False
          TabOrder = 0
          Visible = False
          ExplicitLeft = 4
          ExplicitTop = 30
          DesignSize = (
            601
            43)
          object Panel76: TPanel
            Left = 597
            Top = 0
            Width = 4
            Height = 43
            Align = alRight
            BevelOuter = bvNone
            Color = 6309692
            ParentBackground = False
            TabOrder = 0
          end
          object Panel77: TPanel
            Left = 0
            Top = 0
            Width = 44
            Height = 43
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 1
            DesignSize = (
              44
              43)
            object PanelChatBottom_Att: TEsImage
              Left = 6
              Top = 9
              Width = 31
              Height = 24
              Anchors = [akRight, akBottom]
              ParentShowHint = False
              Picture.Data = {
                0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
                00200806000000737A7AF4000000097048597300000EC400000EC401952B0E1B
                0000026C4944415478DAEDD75B884D511CC7F1FFB8BF280D4EEE424962CA3C90
                520829B91651444C664C698A9228B9454A8871E7819452E49217895142424AB9
                34522E6F340FA6A8091DDF7FEBBF6A5BED3997BDF7C9CBACFABCECD5DEFFDF5A
                7BAD75F6A9CAE7F3F23F5B55578014017A426FFE1DD3D70D238DB6CFF8843F59
                051886BDB88D6B41DF406CC2320B2216B40587F1366D80A138831158855791BE
                C13881713884875A0393B11EFDD080274903F8E2C3B10E2F227D83700AA35187
                E7C1BDDADF6CC197E24BB901D214F74DFB6FE0A2CD50C9019216CFD9B59B7863
                D70EA2060BD1514A002D7EDAA6AE9CE203700CE3B102EFECFA46346226BE160B
                5068E4BAE04E76525C77C2514C10B7F89E46FAB66311E6A0BD5080A4D3EE471E
                575C5FC9557B966ED54ED740DA698F2BAE5B50CF81495829B626E20254AAB8AE
                FA29E2CE8147BE230CD01FE7AD40C58B8701F4D8D4E37509560705922E385F5C
                4FC20D61F1308026BC821DB854E991C7053880A9588076BB96B3F53026EB9187
                017AE1161E634FA47FBFB8136B2D9E9539F2A2C5A301F481F77116C72323BC87
                0BE2B64F66D31E17408BB5D874FB00390BA587517396D31E17A0B7B88F8B07D8
                E7FB7004B3B11B6D68C228D467513C1A406C9A2762317ED8B521D88579E88ED7
                D826FFAE87C4C5C300D370199BC59DD7BEE9EC8C451FB4E27B56C5C3003D6C16
                66600D5E16B9B75ADC6F7BE2E261006D7AE29D13F735BB1577F12BBC47DC6FBC
                6E515D0F8D498BC705D0A6EF7D27E68B3B17EEE083B82F5BDD19D331171FB1A5
                84992A3B80367DDFB3B01CB5E82B6E11FEC47B5C376D698A170AE09BAE8B6A1B
                B9FE11F9663AD2162E3540C55B5780BFE11211D08AD514090000000049454E44
                AE426082}
              Stretch = Uniform
              ShowHint = False
              OnClick = PanelChatBottom_AttClick
              OnMouseEnter = PanelChatBottom_AttMouseEnter
              OnMouseLeave = PanelChatBottom_AttMouseLeave
            end
          end
          object Panel78: TPanel
            AlignWithMargins = True
            Left = 54
            Top = 4
            Width = 489
            Height = 31
            Margins.Left = 10
            Margins.Top = 4
            Margins.Right = 10
            Margins.Bottom = 8
            Align = alClient
            AutoSize = True
            BevelOuter = bvNone
            TabOrder = 2
            object PanelChatBottom_RichSend: TRichEdit
              AlignWithMargins = True
              Left = 0
              Top = 10
              Width = 489
              Height = 16
              Margins.Left = 0
              Margins.Top = 10
              Margins.Right = 0
              Margins.Bottom = 5
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              BorderStyle = bsNone
              Color = 4337963
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = 15395562
              Font.Height = -12
              Font.Name = 'Arial'
              Font.Style = []
              Constraints.MaxHeight = 363
              Constraints.MaxWidth = 971
              ParentFont = False
              TabOrder = 0
              Zoom = 100
              OnChange = PanelChatBottom_RichSendChange
              OnKeyDown = PanelChatBottom_RichSendKeyDown
              OnResizeRequest = PanelChatBottom_RichSendResizeRequest
            end
          end
          object PanelChatBottom_Ridth: TPanel
            Left = 553
            Top = 0
            Width = 44
            Height = 43
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 3
            DesignSize = (
              44
              43)
            object PanelChatBottom_Send: TEsImage
              Left = 14
              Top = 9
              Width = 30
              Height = 24
              Anchors = [akRight, akBottom]
              ParentShowHint = False
              Picture.Data = {
                0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
                00200806000000737A7AF4000000097048597300000EC400000EC401952B0E1B
                000002564944415478DABD964D48554114C7E7196556BA10845A58B828D48568
                F01E6F612D6C112D4AB4DD13C42C0811240421113762A415B810DB94D642A295
                8A4AED0A13C116F6AA55AB68292EC40F4CD052FF877B2E777CDE3B33F7C37BE0
                C73BF76BDEEFCECC9D3989FD745A04880C6807357C9C0523E09DDF861292C019
                7012AC6B9E790DEE7B5C1B050F8208D09FCF80B3E0A642A205BCD1B4790FBCF5
                23700ABF1F411D9FFBAA90F8269C6EF78AEF06F71CE981A7E0B174DE4D828667
                1B9CD0B4F91F14805D3F02261224F013941BB45B0436FD0A98489C079F0D2402
                0B4425114A200A89D002612522110823119940508948058248442EE057E25804
                0AC146CE392F89541881717095F356B0C8F969F0979E319058053B7C5C02E638
                A77D22A3139802F59C3789C37BFC6F50E6F222AA0D2CC5D72966C16D9D403FE8
                E17C187448D77A419F476F7A493C02439C0F8AC3F3C855E01AF8C2F932B82475
                270D038DB1D7C471937809DA38BF013EE904688C7F812B7CDC29BD0105152D4F
                8455159D3390A0AD791A94820AB0AF13A0A0B11FE77C8B7B259B734F3EB8CC79
                12BC124EADE0265109968EBCADE233FC006E71BE02EE086732B94533185348B8
                864AA0182C086775A379F00CBC10EA9A9124EC4F552BA15B882E704F544BE768
                81A1CF691EFC01FFF8BE24F7D2C59C369412262B2155CCCFC143A1AF07EDD803
                7926127E96E22AD005EE0A6B52B90515ADEFC180B0CA735DA1EB4B40EE915A61
                2D2AF6D0FC10D6E245EB87BC0768ABED2002764C8006CE2741A3C77D4A893804
                9412710978495C8F534096A0E5B81B0CC62D604BAC096B128B0388F9DF07E08D
                B01A0000000049454E44AE426082}
              Stretch = Uniform
              ShowHint = False
              OnMouseDown = PanelChatBottom_SendMouseDown
              OnMouseEnter = PanelChatBottom_SendMouseEnter
              OnMouseLeave = PanelChatBottom_SendMouseLeave
              OnMouseUp = PanelChatBottom_SendMouseUp
            end
          end
          object Panel5: TPanel
            Left = 54
            Top = 35
            Width = 489
            Height = 1
            Anchors = [akLeft, akRight, akBottom]
            BevelOuter = bvNone
            Color = 14531413
            ParentBackground = False
            TabOrder = 4
            Visible = False
          end
        end
      end
      object PanelChatBox: TPanel
        Left = 0
        Top = 43
        Width = 601
        Height = 554
        Align = alClient
        BevelOuter = bvNone
        Color = 2957854
        ParentBackground = False
        TabOrder = 1
        OnResize = PanelChatBoxResize
        object PanelSendFile: TPanel
          Left = 106
          Top = 122
          Width = 406
          Height = 334
          BevelOuter = bvNone
          Color = 4337961
          ParentBackground = False
          TabOrder = 0
          Visible = False
          object Label7: TLabel
            Left = 127
            Top = 12
            Width = 141
            Height = 18
            Caption = #1060#1072#1081#1083#1099' '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 15250611
            Font.Height = -15
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            OnClick = PanelSendFile_AdderFileClick
          end
          object PanelSendFile_button: TPanel
            Left = 0
            Top = 211
            Width = 406
            Height = 123
            Align = alBottom
            BevelOuter = bvNone
            Color = 4337961
            ParentBackground = False
            TabOrder = 0
            object PanelSendFile_back: TLabel
              Left = 34
              Top = 86
              Width = 69
              Height = 18
              Caption = #1054#1090#1084#1077#1085#1080#1090#1100
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 16051878
              Font.Height = -15
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              OnClick = PanelSendFile_backClick
            end
            object PanelSendFile_send: TLabel
              Left = 302
              Top = 86
              Width = 75
              Height = 18
              Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 16051878
              Font.Height = -15
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              OnClick = PanelSendFile_sendClick
            end
            object Label6: TLabel
              Left = 34
              Top = 26
              Width = 57
              Height = 16
              Caption = #1054#1087#1080#1089#1072#1085#1080#1077
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 15250611
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
            end
            object PanelSendFile_Comment: TEdit
              Left = 34
              Top = 48
              Width = 343
              Height = 24
              BorderStyle = bsNone
              Color = 4337961
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
            end
            object Panel4: TPanel
              Left = 34
              Top = 76
              Width = 340
              Height = 1
              BevelOuter = bvNone
              Color = 14531413
              ParentBackground = False
              TabOrder = 1
            end
          end
          object PanelSendFile_variant: TPanel
            Left = 34
            Top = 47
            Width = 340
            Height = 138
            BevelOuter = bvNone
            TabOrder = 1
            object PanelSendFile_AdderFile: TEsLayout
              Left = 0
              Top = 0
              Width = 340
              Height = 138
              Align = alClient
              Color = 4337961
              ParentBackground = False
              ParentColor = False
              TabOrder = 0
              OnClick = PanelSendFile_AdderFileClick
              OnPaint = PanelSendFile_AdderFilePaint
              object Label5: TLabel
                Left = 80
                Top = 55
                Width = 177
                Height = 36
                Alignment = taCenter
                Caption = #1055#1077#1088#1077#1090#1072#1097#1080#1090#1077' '#1089#1102#1076#1072' '#1092#1072#1081#1083#1099#13#10#1080#1083#1080' '#1082#1083#1080#1082#1085#1080#1090#1077
                Font.Charset = DEFAULT_CHARSET
                Font.Color = 15250611
                Font.Height = -15
                Font.Name = 'Tahoma'
                Font.Style = []
                ParentFont = False
                OnClick = PanelSendFile_AdderFileClick
              end
            end
          end
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 936
    Top = 120
  end
  object SaveDialog1: TSaveDialog
    Left = 960
    Top = 232
  end
end
