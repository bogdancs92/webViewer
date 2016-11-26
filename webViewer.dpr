program webViewer;

uses
  Vcl.Forms,
  fMain in 'fMain.pas' {WebViewerForm},
  Hooks in 'Hooks.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TWebViewerForm, WebViewerForm);
  Application.Run;
end.
