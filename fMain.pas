unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, IniFiles, MSHTML, registry, hooks;

type
  THTMLEventNotifyEvent = procedure(EventObject: IHTMLEventObj; EventType: string) of object;
  THTMLEvent= class(TInterfacedObject, IDispatch)
    private
     FDocument: IHTMLDocument2;
     FOnEvent: THTMLEventNotifyEvent;
     function GetTypeInfoCount(out Count: Integer): HResult;stdcall;
     function GetTypeInfo(Index, LocaleID: Integer;
       out TypeInfo): HResult;stdcall;
     function GetIDsOfNames(const IID: TGUID; Names: Pointer;
       NameCount, LocaleID: Integer; DispIDs: Pointer):
       HResult;stdcall;
     function Invoke(DispID: Integer; const IID: TGUID; LocaleID:
     Integer; Flags: Word; var Params; VarResult, ExcepInfo,
       ArgErr: Pointer): HResult;stdcall;
     procedure DoEvent;
    public
     constructor Create(Document: IHTMLDocument2);
     property OnEvent: THTMLEventNotifyEvent read FOnEvent write FOnEvent;
  end;

  TWebViewerForm = class(TForm)
    PanelTop: TPanel;
    edAddress: TEdit;
    btLaunch: TBitBtn;
    WebBrowser1: TWebBrowser;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edAddressKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btLaunchClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure WebBrowser1NavigateComplete2(ASender: TObject;
      const pDisp: IDispatch; const URL: OleVariant);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure edAddressEnter(Sender: TObject);
    procedure edAddressExit(Sender: TObject);
  private
    { Déclarations privées }
    IniConfigFile : string;
    EventHandler: THTMLEvent;
    EventHandlerErrorHook : boolean;
    timeclick,time2click : TDateTime;
    fMouseMove : TMouseMoveEvent;
    procedure KeyEvent(EventObject: IHTMLEventObj; EventType: string);
    procedure SwitchFullScreen(_force:boolean=false);
  private
    KeyboardHook: TKeyboardHook;
    MouseHook: TMouseHook;
    procedure KeyboardHookPREExecute(Hook: THook; var Hookmsg: THookMsg);
    procedure MouseHookPREExecute(Hook: THook; var Hookmsg: THookMsg);
  public
    { Déclarations publiques }
    procedure TryHookeEvent;
     property OnMouseMove: TMouseMoveEvent read fMouseMove write fMouseMove;
  end;

var
  WebViewerForm: TWebViewerForm;

implementation

{$R *.dfm}

function THTMLEvent.GetTypeInfoCount(out Count: Integer): HResult;
begin
   Result := E_NOTIMPL
end;
function THTMLEvent.GetTypeInfo(Index, LocaleID: Integer;
   out TypeInfo): HResult;
begin
   Result := E_NOTIMPL
end;
function THTMLEvent.GetIDsOfNames(const IID: TGUID; Names: Pointer;
   NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
   Result := E_NOTIMPL
end;
function THTMLEvent.Invoke(DispID: Integer; const IID: TGUID;
   LocaleID: Integer; Flags: Word; var Params; VarResult,
   ExcepInfo, ArgErr: Pointer): HResult;
begin
   DoEvent;
   Result := S_OK;
end;
constructor THTMLEvent.Create(Document: IHTMLDocument2);
begin
   inherited Create;
   FDocument:= Document;
   FOnEvent:= nil;
end;
procedure THTMLEvent.DoEvent;
var
   EventObj: IHTMLEventObj;
   EventType: string;
begin
   if Assigned(FOnEvent) then
   begin
     EventObj:= nil;
     EventType:= '';
     if Assigned(FDocument) and Assigned(FDocument.parentWindow) then
     begin
       EventObj:= FDocument.parentWindow.event;
       if Assigned(EventObj) then
         EventType:= EventObj.type_;
     end;
     FOnEvent(EventObj, EventType);
   end;
end;

procedure TWebViewerForm.BitBtn1Click(Sender: TObject);
begin
  SwitchFullScreen;
end;

procedure TWebViewerForm.btLaunchClick(Sender: TObject);
begin
  WebBrowser1.Navigate(edAddress.Text);
end;

procedure TWebViewerForm.edAddressEnter(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TWebViewerForm.edAddressExit(Sender: TObject);
begin
  Timer1.Enabled := true;
end;

procedure TWebViewerForm.edAddressKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) then
    WebBrowser1.Navigate2(edAddress.Text);
end;

procedure TWebViewerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    with TIniFile.Create(IniConfigFile) do try
      WriteInteger('Position','left',Left);
      WriteInteger('Position','width',Width);
      WriteInteger('Position','top',Top);
      WriteInteger('Position','height',Height);
      WriteString('History','url',edAddress.Text);
    finally
      Free;
    end;
  except

  end;
end;

procedure TWebViewerForm.FormCreate(Sender: TObject);
begin
  IniConfigFile := GetCurrentDir+'\config.ini';

  KeyboardHook := TKeyboardHook.Create;
  KeyboardHook.OnPreExecute := KeyboardHookPREExecute;
  KeyboardHook.Active := True;

  {
  MouseHook := TMouseHook.Create;
  MouseHook.OnPreExecute := MouseHookPREExecute;
  MouseHook.Active := True;
  }
end;

procedure TWebViewerForm.FormShow(Sender: TObject);
begin
  if FileExists(IniConfigFile) then begin
    with TIniFile.Create(IniConfigFile) do try
      Left := ReadInteger('Position','left',0);
      Width := ReadInteger('Position','width',800);
      Top := ReadInteger('Position','top',0);
      Height := ReadInteger('Position','height',600);
      edAddress.Text := ReadString('History','url','www.netflix.com');
      btLaunchClick(Sender);
    finally
      Free;
    end;
  end;
end;

procedure TWebViewerForm.KeyEvent(EventObject: IHTMLEventObj;
   EventType: string);
begin
  // Handle Event, show type of event and keycode
  try
    {
    if (EventObject.keyCode=17) then begin
      SwitchFullScreen;
    end
   else
   }if (EventObject.keyCode=0) then begin
     // mmouse click
     if (now-time2click<1/24/60/60/5) then begin
       // double click
       if (Application.MainForm.WindowState = wsMaximized) then
         Application.MainForm.WindowState := wsNormal
       else begin
         Application.MainForm.WindowState := wsMaximized;
       end;
     end;
     time2click := now;
   end;
 except

 end;
 timeclick := now;
 Timer1Timer(nil);
end;

procedure TWebViewerForm.SwitchFullScreen(_force:boolean=false);
begin
  if PanelTop.Visible or _force then begin
    Application.MainForm.BorderStyle := bsNone;
    PanelTop.Visible := false;
  end
  else begin
    Application.MainForm.BorderStyle := bsSizeable;
    PanelTop.Visible := true;
  end;
end;

procedure TWebViewerForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  try
    if (now-timeclick>1/24/60/30) then begin
      Application.MainForm.BorderStyle := bsNone;
      PanelTop.Visible := false;
    end
    else begin
      Application.MainForm.BorderStyle := bsSizeable;
      PanelTop.Visible := true;
    end;
  finally
    Timer1.Enabled := true;
  end;
end;

procedure TWebViewerForm.TryHookeEvent;
var
  HtmlDocument: IHTMLDocument2;
begin
  HtmlDocument := WebBrowser1.Document as IHTMLDocument2;
  Application.MainForm.Caption := HtmlDocument.Title;
  edAddress.Text := HtmlDocument.url;
  EventHandlerErrorHook := false;
  try
    EventHandler:= THTMLEvent.Create(HtmlDocument);
    EventHandler.OnEvent:= KeyEvent;
    // Assign Events
    //HtmlDocument.onkeydown  := EventHandler as IDispatch;
    //HtmlDocument.onkeypress := EventHandler as IDispatch;
    //HtmlDocument.onkeyup    := EventHandler as IDispatch;
    HtmlDocument.onclick    := EventHandler as IDispatch;
    //HtmlDocument.onmousemove:= EventHandler as IDispatch;
  except
    EventHandlerErrorHook := true;
  end;
end;

procedure TWebViewerForm.WebBrowser1NavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
  Timer1.Enabled := false;
  try
    timeclick := now;
    TryHookeEvent;
  except
  end;
  Timer1.Enabled := true;
end;

function BrowserEmulateON : Boolean;
const
  IE_ROOT_KEY = 'SOFTWARE\Microsoft\Internet Explorer\';
var
  ieValueStr : string;
  ieValueInt : integer;
begin
  Result := False;
  try
    with TRegistry.Create(KEY_READ) do try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(IE_ROOT_KEY, false) then
        ieValueStr := ReadString('svcVersion');
      if (ieValueStr = '') then
        ieValueStr := ReadString('Version');
      if (ieValueStr<>'') then
        ieValueStr := Copy(ieValueStr,0,Pos('.',ieValueStr)-1);
    finally
      Free;
    end;

    if (ieValueStr<>'') then with TRegistry.Create(KEY_WRITE) do
      try
        {
                public enum BrowserEmulationVersion
                {
                  Default = 0,
                  Version7 = 7000,
                  Version8 = 8000,
                  Version8Standards = 8888,
                  Version9 = 9000,
                  Version9Standards = 9999,
                  Version10 = 10000,
                  Version10Standards = 10001,
                  Version11 = 11000,
                  Version11Edge = 11001
                }
        ieValueInt := StrToInt(ieValueStr);
        case ieValueInt of
          8,9,10,11  : ieValueInt := ieValueInt * 1000;
          else ieValueInt := 7000;
        end;
        RootKey := HKEY_CURRENT_USER;
        if OpenKey(IE_ROOT_KEY + 'MAIN\FeatureControl\FEATURE_BROWSER_EMULATION', True) then
          WriteInteger(ExtractFileName(ParamStr(0)), ieValueInt);
      finally
        Free;
      end;
    Result := True;
  except
    on E:Exception do
  end;
end;

procedure TWebViewerForm.KeyboardHookPREExecute(Hook: THook; var Hookmsg: THookMsg);
var
  Key: Word;
begin
  //Here you can choose if you want to return the key stroke to the application or not
  {Hookmsg.Result := IfThen(cbEatKeyStrokes.Checked, 1, 0);
  Key := Hookmsg.WPARAM;
  Label2.Caption := Char(key);
  }
  timeclick := now;
end;

procedure TWebViewerForm.MouseHookPREExecute(Hook: THook; var Hookmsg: THookMsg);
begin
  //Here you can choose if you want to return the key stroke to the application or not
  timeclick := now;
end;

initialization
  BrowserEmulateON;

end.
