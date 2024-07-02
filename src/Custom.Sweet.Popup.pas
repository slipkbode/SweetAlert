unit Custom.Sweet.Popup;

interface

uses Custom.Sweet.Classes,
     Custom.Sweet.Interfaces,
     Custom.Sweet.Types,
     Custom.Button;

type
  Popup = class(TSweetBase)
  private
    FThen      : IThen;
    FSweetPopup: TArray<ISweetPopup>;
    FResult    : TResult;
    FPopupName : String;

    procedure DoClickPopup(Sender: TObject);
    procedure CreateOptionsPopup;
    procedure CreateButtonPopupCancel;
    procedure CreateButtonPopup(const ASweetPopup: TSweetPopup);

  protected
    procedure CreateObjects; override;
    procedure Animate; override;
    procedure CloseMessage; override;
    procedure CallThen; override;

    function GetSize: TArray<Single>; override;
  public
    class function show(const AArrayPopup: TArray<ISweetPopup>): IThen;

    constructor Create(const AArrayPopup: TArray<ISweetPopup>; const AThen: IThen); overload;
  end;

implementation

uses FMX.Types,
     FMX.Objects,
     System.SysUtils,
     FMX.Controls,
     System.UITypes,
     System.Threading,
     FMX.Ani,
     System.Classes;

{ Popup }

procedure Popup.Animate;
begin
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        var
          LSize: TArray<Single>;
          LBody: TControl;
        begin
          LSize := GetSize;
          LBody := FBackGround.FindComponent('body') as TControl;

          TAnimator.AnimateFloat(LBody, 'height', LSize[0], 0.4, TAnimationType.InOut, TInterpolationType.Elastic);
          TAnimator.AnimateFloat(LBody, 'Position.Y', FBackGround.Height - LSize[0], 0.4, TAnimationType.InOut, TInterpolationType.Elastic);
        end
      )
    end
  )
end;

procedure Popup.CallThen;
begin
  inherited;
  if FThen <> nil then
    TThen(FThen).Execute(FResult, FPopupName);
end;

procedure Popup.CloseMessage;
var
  LBody          : TControl;
  LFloatAnimation: TFloatAnimation;
begin
  LBody   := FBackGround.FindComponent('body') as TControl;

  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          LFloatAnimation                  := TFloatAnimation.Create(nil);
          LFloatAnimation.OnFinish         := DoFinishClose;
          LFloatAnimation.Parent           := LBody;
          LFloatAnimation.AnimationType    := TAnimationType.In;
          LFloatAnimation.Interpolation    := TInterpolationType.Back;
          LFloatAnimation.Duration         := 0.5;
          LFloatAnimation.PropertyName     := 'Position.Y';
          LFloatAnimation.StartFromCurrent := True;
          LFloatAnimation.StopValue        := FBackGround.Height;
          LFloatAnimation.Start;

          TAnimator.AnimateFloat(LBody, 'height', 0, 0.15, TAnimationType.InOut, TInterpolationType.Elastic);
        end
      )
    end
  )
end;

constructor Popup.Create(const AArrayPopup: TArray<ISweetPopup>;
  const AThen: IThen);
begin
  FSweetPopup := AArrayPopup;
  FThen       := AThen;
  inherited Create;
end;

procedure Popup.CreateObjects;
begin
  inherited;
  CreateOptionsPopup;
end;

procedure Popup.CreateOptionsPopup;
var
  LSweetPopup      : ISweetPopup;
  LObjectSweetPopup: TSweetPopup;
  LBody            : TRectangle;
begin
  LBody            := FBackGround.FindComponent('body') as TRectangle;
  LBody.Align      := TAlignLayout.None;
  LBody.Corners    := [TCorner.TopLeft, TCorner.TopRight];
  LBody.Position.X := 0;
  LBody.Position.Y := FBackGround.Height;
  LBody.Width      := FBackGround.Width;

  for LSweetPopup in FSweetPopup do
  begin
    LObjectSweetPopup := TSweetPopup(LSweetPopup);

    if LObjectSweetPopup.Option.Trim.IsEmpty or LObjectSweetPopup.Name.Trim.IsEmpty then
      Continue;

    CreateButtonPopup(LObjectSweetPopup);
  end;

  CreateButtonPopupCancel;
end;

procedure Popup.DoClickPopup(Sender: TObject);
begin
  FPopupName := TButtonEffect(Sender).Name;
  FResult    := TResult.Confirmed;

  if TButtonEffect(Sender).Name = 'btnCanceled' then
    FResult := TResult.Canceled;

  CloseMessage;
end;

function Popup.GetSize: TArray<Single>;
var
  LControl: TControl;
  LBody: TControl;
begin
  LBody  := FBackGround.FindComponent('body') as TControl;
  Result := [0, 0];

  for LControl in LBody.Controls do
  begin
    Result[0] := LControl.Height + Result[0] + 8;
  end;

  if Result[0] > FBackGround.Height then
    Result[0] := FBackGround.Height;
end;

class function Popup.show(const AArrayPopup: TArray<ISweetPopup>): IThen;
begin
  Result := TThen.Create;
  Self.Create(AArrayPopup, Result);
end;

procedure Popup.CreateButtonPopupCancel;
var
  LButton : TButtonEffect;
  LLine   : TLine;
  LControl: TControl;
begin
  LControl := FBackGround.FindComponent('body') as TControl;

  LLine                := TLine.Create(FBackGround);
  LLine.Height         := 2;
  LLine.Margins.Bottom := 3;
  LLine.Margins.Top    := 3;
  LLine.Parent         := LControl;
  LLine.Align          := TAlignLayout.Bottom;
  LLine.Fill.Color     := $FFced4da;

  LButton                          := TButtonEffect.Create(FBackGround);
  LButton.Parent                   := LControl;
  LButton.Fill.Color               := TAlphaColorRec.Null;
  LButton.Stroke.Color             := TAlphaColorRec.Null;
  LButton.EffectButtonColor        := TAlphaColorRec.Null;
  LButton.Align                    := TAlignLayout.MostBottom;
  LButton.Name                     := 'btnCanceled';
  LButton.text                     := 'Cancelar';
  LButton.OnClick                  := DoClickPopup;
  LButton.TypeEffect               := TTypeEffect.ColorButton;
  LButton.TextSettings.HorzAlign   := TTextAlign.Trailing;
  LButton.TextSettings.FontColor   := $FFc1121f;
  LButton.TextSettings.Font.Family := 'Quicksand';
  LButton.TextSettings.Font.Size   := 18;
  LButton.Height                   := 45;
end;

procedure Popup.CreateButtonPopup(const ASweetPopup: TSweetPopup);
var
  LButton : TButtonEffect;
  LControl: TControl;
begin
  LControl := FBackGround.FindComponent('body') as TControl;

  LButton                          := TButtonEffect.Create(FBackGround);
  LButton.Parent                   := LControl;
  LButton.Fill.Color               := TAlphaColorRec.Null;
  LButton.Stroke.Color             := TAlphaColorRec.Null;
  LButton.EffectButtonColor        := TAlphaColorRec.Null;
  LButton.Align                    := TAlignLayout.MostTop;
  LButton.Name                     := ASweetPopup.Name;
  LButton.text                     := ASweetPopup.Option;
  LButton.OnClick                  := DoClickPopup;
  LButton.TypeEffect               := TTypeEffect.ColorButton;
  LButton.TextSettings.HorzAlign   := TTextAlign.Trailing;
  LButton.TextSettings.FontColor   := TAlphaColorRec.Black;
  LButton.TextSettings.Font.Family := 'Quicksand';
  LButton.TextSettings.Font.Size   := 18;
  LButton.Height                   := 45;
  LButton.Margins.Bottom           := 2;
end;

end.
