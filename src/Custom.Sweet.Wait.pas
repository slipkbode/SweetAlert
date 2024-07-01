unit Custom.Sweet.Wait;

interface

uses Custom.Sweet.Classes,
     Custom.Sweet.Interfaces,
     System.SysUtils;

type
  Wait = class(TSweetMessage)
  protected
    procedure CreateObjects; override;
    procedure HideComponents; override;

    function GetSize: TArray<Single>; override;
  public
    class procedure async(const AProcedure: TProc<IWait>);

    constructor Create(const AProcedure: TProc<IWait>); reintroduce;
  end;

implementation

uses FMX.StdCtrls,
     FMX.Controls,
     Custom.SweetAlert.Consts,
     Custom.Sweet.Types,
     FMX.Skia;

{ Wait }

class procedure Wait.async(const AProcedure: TProc<IWait>);
begin
  Self.Create(AProcedure);
end;

constructor Wait.Create(const AProcedure: TProc<IWait>);
begin
  FIcon := TSweetAlertIconType.wait;

  inherited Create('');

  if Assigned(AProcedure) then
    AProcedure(TWait.Create(
      procedure
      begin
        CloseMessage;
      end,
      procedure(AText: String)
      var
        LLabel: TLabel;
      begin
        LLabel      := FBackGround.FindComponent('message') as TLabel;
        LLabel.Text := AText;
      end
    ));
end;

procedure Wait.CreateObjects;
begin
   CreateBackGround;
   CreateBody;
   CreateMessage;
   CreateIcon;
   AdjustFontMessage
end;

function Wait.GetSize: TArray<Single>;
begin
  Result    := inherited;

  if Result[1] < 200 then
    Result[1] := 200;
end;

procedure Wait.HideComponents;
var
  LIcon: TSkAnimatedImage;
begin
  inherited;
  LIcon := TSkAnimatedImage(FBackGround.FindComponent('icon'));
  LIcon.Animation.Stop;
  LIcon.Visible := False;
end;

end.
