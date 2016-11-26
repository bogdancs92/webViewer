object WebViewerForm: TWebViewerForm
  Left = 0
  Top = 0
  Caption = 'WebViewerForm'
  ClientHeight = 426
  ClientWidth = 697
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 697
    Height = 33
    Align = alTop
    TabOrder = 0
    DesignSize = (
      697
      33)
    object edAddress: TEdit
      Left = 8
      Top = 6
      Width = 645
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'www.google.fr'
      OnEnter = edAddressEnter
      OnExit = edAddressExit
      OnKeyDown = edAddressKeyDown
    end
    object btLaunch: TBitBtn
      Left = 659
      Top = 3
      Width = 35
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Go'
      TabOrder = 1
      OnClick = btLaunchClick
    end
  end
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 33
    Width = 697
    Height = 393
    Align = alClient
    TabOrder = 1
    OnNavigateComplete2 = WebBrowser1NavigateComplete2
    ExplicitTop = 32
    ControlData = {
      4C000000094800009E2800000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 440
    Top = 208
  end
end
