unit Custom.SweetAlert;

interface

uses
  System.Classes, FMX.Controls, FMX.Objects, FMX.StdCtrls, FMX.Layouts, Custom.SweetAlert.Types,
  System.Types, System.SysUtils, Custom.SweetAlert.Interfaces, System.UITypes,
  FMX.Skia;

type
  TResult = (Confirmed);

  Swal = class sealed
  private type
    IThen = interface
      ['{E98426BC-8C2C-413A-8C87-179DE23E7487}']
      procedure &then(const AResult: TProc<TResult>);
    end;

    TThen = class(TInterfacedObject, IThen)
    public
      procedure &then(const AResult: TProc<TResult>);
    end;
  strict private
    class var FBackGround, FBody: TRectangle;
    class var FMessage          : TLabel;
    class var FLayoutButton     : TLayout;
    class var FResult           : TResult;
    class var FTitle            : TLabel;
    class var FIcon             : TSkAnimatedImage;
  private
    class procedure CreateBackground;
    class procedure CreateBody;
    class procedure AnimateBody;
    class procedure CreateTitle(const ATitle: String);
    class procedure CreateIcon(const AIcon: TSweetAlertIconType);
    class procedure CreateMessage(const AMessage: String); overload;
    class procedure CreateMessage(const AMessage: String; ASize: Single; AFontStyles: TFontStyles); overload;
    class procedure CreateLayoutButton;
    class procedure CreateConfirmButton;
    class procedure DoClickConfirmed(Sender: TObject);

    class function CalculeSize: TArray<Single>;
  public
    class function fire(const ASweetAlert: ISweetAlert): IThen; overload;

    class procedure fire(const AMessage: String); overload;
  end;

implementation

uses FMX.Forms, FMX.Types, FMX.Ani, FMX.Graphics, FMX.TextLayout,
  Custom.Button, Custom.SweetAlert.Classes;

{ Swal }

class function Swal.fire(const ASweetAlert: ISweetAlert): IThen;
var
  LSweetAlert: TSweeatAlert;
begin
  LSweetAlert := TSweeatAlert(ASweetAlert);

  CreateBackground;
  CreateBody;

  if LSweetAlert.title.Trim.IsEmpty then
    CreateMessage(LSweetAlert.text)
  else
  begin
    CreateTitle(LSweetAlert.title);
    CreateMessage(LSweetAlert.text, 18, []);
  end;

  if LSweetAlert.icon <> TSweetAlertIconType.null then
    CreateIcon(LSweetAlert.icon);

  CreateLayoutButton;
  CreateConfirmButton;
  AnimateBody;

  Result := TThen.Create;
end;

class procedure Swal.AnimateBody;
var
  LSizeCalculed: TArray<Single>;
begin
  LSizeCalculed := CalculeSize;

  TAnimator.AnimateFloat(FBody, 'height', LSizeCalculed[0], 0.5, TAnimationType.Out, TInterpolationType.Elastic);
  TAnimator.AnimateFloat(FBody, 'width', LSizeCalculed[1], 0.5, TAnimationType.Out, TInterpolationType.Elastic);
end;

class function Swal.CalculeSize: TArray<Single>;
var
  LText, LTitleText: TTextLayout;
  LTitleHeight     : Single;
  LIconHeight      : Single;
begin
  LText        := TTextLayoutManager.DefaultTextLayout.Create;
  LTitleText   := TTextLayoutManager.DefaultTextLayout.Create;
  LTitleHeight := 0;
  LIconHeight  := 0;

  try
    LText.Font     := FMessage.Font;
    LText.TopLeft  := TPointF.Create(Application.MainForm.Width, Application.MainForm.Height);
    LText.text     := FMessage.text;
    LText.WordWrap := FMessage.WordWrap;

    if FTitle <> nil then
    begin
      LTitleText.Font     := FTitle.Font;
      LTitleText.TopLeft  := TPointF.Create(0, 0);
      LTitleText.text     := FTitle.text;
      LTitleText.WordWrap := FTitle.WordWrap;

      LTitleHeight := LTitleText.Height + FTitle.Margins.Bottom;
    end;

    if FIcon <> nil then
      LIconHeight := FIcon.Height;

    Result := [LText.Height + FBody.Padding.Bottom + FBody.Padding.Top + LTitleHeight + FLayoutButton.Height + FLayoutButton.Margins.Top + LIconHeight,
      LText.TextWidth + (FBody.Padding.Right + FBody.Padding.Left)];

    if Result[1] > FBackGround.Width then
    begin
      Result[0] := Result[0] + (LText.Height * Trunc(Result[1] / FBackGround.Width));
      Result[1] := FBackGround.Width - (FBody.Padding.Right + FBody.Padding.Left);
    end;
  finally
    LTitleText.Free;
    LText.Free;
  end;
end;

class procedure Swal.CreateBackground;
begin
  FBackGround             := TRectangle.Create(nil);
  FBackGround.Parent      := Application.MainForm;
  FBackGround.Fill.Color  := TAlphaColorRec.Black;
  FBackGround.Opacity     := 0.55;
  FBackGround.Align       := TAlignLayout.Client;
  FBackGround.Stroke.Kind := TBrushKind.None;
end;

class procedure Swal.CreateBody;
begin
  FBody                := TRectangle.Create(FBackGround);
  FBody.Height         := 0;
  FBody.Width          := 0;
  FBody.Parent         := Application.MainForm;
  FBody.Fill.Color     := TAlphaColorRec.White;
  FBody.Align          := TAlignLayout.Center;
  FBody.Height         := FBackGround.Height - 8;
  FBody.Width          := FBackGround.Width - 8;
  FBody.Stroke.Kind    := TBrushKind.None;
  FBody.XRadius        := 5.72;
  FBody.YRadius        := 5.72;
  FBody.Margins.Left   := 8;
  FBody.Margins.Right  := 8;
  FBody.Margins.Top    := 8;
  FBody.Margins.Right  := 8;
  FBody.Padding.Left   := 60;
  FBody.Padding.Right  := 60;
  FBody.Padding.Top    := 15;
  FBody.Padding.Bottom := 15;
end;

class procedure Swal.CreateConfirmButton;
var
  LButton: TButtonEffect;
begin
  LButton                   := TButtonEffect.Create(FLayoutButton);
  LButton.Parent            := FLayoutButton;
  LButton.Fill.Color        := $FF6E66D9;
  LButton.Stroke.Color      := $FFB6B2EC;
  LButton.EffectButtonColor := $FF635CC3;
  LButton.Align             := TAlignLayout.HorzCenter;
  LButton.Height            := FLayoutButton.Height;
  LButton.Name              := 'btnConfirmed';
  LButton.text              := 'OK';
  LButton.OnClick           := DoClickConfirmed;
  LButton.TypeEffect        := TTypeEffect.ColorButton;
  LButton.SetFocus;
end;

class procedure Swal.CreateIcon(const AIcon: TSweetAlertIconType);
var
  LStream: TStream;
begin
  FIcon                := TSkAnimatedImage.Create(FBody);
  if AIcon in [TSweetAlertIconType.info, TSweetAlertIconType.warning, TSweetAlertIconType.success] then
    FIcon.Height         := 68
  else
    FIcon.Height         := 58;

  FIcon.Align          := TAlignLayout.MostTop;
  FIcon.Index          := 0;
  FIcon.Parent         := FBody;
  FIcon.Animation.Loop := False;

  LStream := TSweetAlertIcon.GetStream(AIcon);
  try
    FIcon.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

class procedure Swal.CreateLayoutButton;
begin
  FLayoutButton               := TLayout.Create(FBody);
  FLayoutButton.Align         := TAlignLayout.Bottom;
  FLayoutButton.Margins.Top   := 6;
  FLayoutButton.Height        := 45;
  FLayoutButton.Parent        := FBody;
  FLayoutButton.Padding.Left  := 8;
  FLayoutButton.Padding.Right := 8;
  FLayoutButton.Padding.Top   := 8;
  FLayoutButton.Padding.Right := 8;
end;

class procedure Swal.CreateMessage(const AMessage: String; ASize: Single; AFontStyles: TFontStyles);
begin
  FMessage                := TLabel.Create(FBody);
  FMessage.Parent         := FBody;
  FMessage.text           := AMessage;
  FMessage.StyledSettings := [];
  FMessage.Font.Size      := ASize;
  FMessage.Align          := TAlignLayout.Top;
  FMessage.WordWrap       := True;
  FMessage.AutoSize       := True;
  FMessage.Font.Style     := AFontStyles;
  FMessage.TextAlign      := TTextAlign.Center;
  FMessage.FontColor      := $FF545454;
end;

class procedure Swal.CreateTitle(const ATitle: String);
begin
  FTitle                := TLabel.Create(FBody);
  FTitle.Parent         := FBody;
  FTitle.text           := ATitle;
  FTitle.StyledSettings := [];
  FTitle.Font.Size      := 30;
  FTitle.Align          := TAlignLayout.MostTop;
  FTitle.WordWrap       := True;
  FTitle.AutoSize       := True;
  FTitle.Font.Style     := [TFontStyle.fsBold];
  FTitle.TextAlign      := TTextAlign.Center;
  FTitle.FontColor      := $FF545454;
  FTitle.Margins.Bottom := 8;
end;

class procedure Swal.CreateMessage(const AMessage: String);
begin
  CreateMessage(AMessage, 28, [TFontStyle.fsBold])
end;

class procedure Swal.DoClickConfirmed(Sender: TObject);
begin
  FBackGround.Free;
  FResult := TResult.Confirmed;
end;

class procedure Swal.fire(const AMessage: String);
begin
  CreateBackground;
  CreateBody;
  TThread.Synchronize(nil,
    procedure
    begin
      CreateMessage(AMessage);
    end);
  CreateLayoutButton;
  CreateConfirmButton;
  FMessage.Font.Style := [TFontStyle.fsBold];
  AnimateBody;
end;

{ Swal.TThen }

procedure Swal.TThen.&then(const AResult: TProc<TResult>);
begin
  if Assigned(AResult) then
    AResult(FResult);
end;

end.
