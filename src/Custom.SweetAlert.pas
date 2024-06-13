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
    class var FFinally          : Boolean;
    class var FFontName         : String;
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
    class procedure CloseMessage;
    class procedure DoFinishClose(Sender: TObject);

    class function CalculeSize: TArray<Single>;
  public
    class function fire(const ASweetAlert: ISweetAlert): IThen; overload;

    class procedure fire(const AMessage: String); overload;
    class procedure SetFontFamily(const AFontName: String);

    class constructor Create;
  end;

implementation

uses FMX.Forms, FMX.Types, FMX.Ani, FMX.Graphics, FMX.TextLayout, System.Threading, System.Math,
  Custom.Button, Custom.SweetAlert.Classes;

{ Swal }

class function Swal.fire(const ASweetAlert: ISweetAlert): IThen;
var
  LSweetAlert: TSweeatAlert;
begin
  LSweetAlert := TSweeatAlert(ASweetAlert);

  CreateBackground;
  CreateBody;

  if LSweetAlert.icon <> TSweetAlertIconType.null then
    CreateIcon(LSweetAlert.icon);

  if LSweetAlert.title.Trim.IsEmpty then
    CreateMessage(LSweetAlert.text)
  else
  begin
    CreateTitle(LSweetAlert.title);
    CreateMessage(LSweetAlert.text, 18, []);
  end;

  CreateLayoutButton;
  CreateConfirmButton;
  AnimateBody;

  Result := TThen.Create;
end;

class procedure Swal.AnimateBody;
var
  LSizeCalculed: TArray<Single>;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      LSizeCalculed := CalculeSize;

      TAnimator.AnimateFloat(FBody, 'height', LSizeCalculed[0], 0.7, TAnimationType.Out, TInterpolationType.Elastic);
      TAnimator.AnimateFloat(FBody, 'width', LSizeCalculed[1], 0.7, TAnimationType.Out, TInterpolationType.Elastic);
    end);
end;

class function Swal.CalculeSize: TArray<Single>;
var
  LText, LTitleText: TTextLayout;
  LTitleHeight     : Single;
  LIconHeight      : Single;
  LNewHeight       : Single;
begin
  LText        := TTextLayoutManager.DefaultTextLayout.Create;
  LTitleText   := TTextLayoutManager.DefaultTextLayout.Create;
  LTitleHeight := 0;
  LIconHeight  := 0;

  try
    LText.Font     := FMessage.Font;
    LText.TopLeft  := TPointF.Create(0, 0);
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
      LIconHeight := FIcon.Height + FIcon.Margins.Bottom;

    Result := [LText.Height + FBody.Padding.Bottom + FBody.Padding.Top + LTitleHeight + FLayoutButton.Height + FLayoutButton.Margins.Bottom +
      FBody.Margins.Bottom + FBody.Margins.Top + LIconHeight, LText.TextWidth + (FBody.Padding.Right + FBody.Padding.Left + +FBody.Margins.Left +
      FBody.Margins.Right)];

    if Result[1] > FBackGround.Width then
    begin
      LNewHeight := LText.Height * RoundTo(LText.TextWidth / FBackGround.Width, 0);

      Result[0] := Result[0] + LNewHeight + FLayoutButton.Margins.Bottom + FMessage.Margins.Bottom;
      Result[1] := FBackGround.Width - (FBody.Padding.Right + FBody.Padding.Left + FBody.Margins.Left + FBody.Margins.Right);
    end;

  finally
    LTitleText.Free;
    LText.Free;
  end;
end;

class procedure Swal.CloseMessage;
var
  LFloatAnimation: TFloatAnimation;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FMessage.Visible := False;

      if FTitle <> nil then
        FTitle.Visible := False;

      FLayoutButton.Visible := False;

      if FIcon <> nil then
        FIcon.Visible := False;

      LFloatAnimation := TFloatAnimation.Create(nil);
      LFloatAnimation.OnFinish := DoFinishClose;
      LFloatAnimation.Parent := FBody;
      LFloatAnimation.AnimationType := TAnimationType.In;
      LFloatAnimation.Interpolation := TInterpolationType.Elastic;
      LFloatAnimation.Duration := 0.3;
      LFloatAnimation.PropertyName := 'width';
      LFloatAnimation.StartFromCurrent := True;
      LFloatAnimation.StopValue := 0;

      TAnimator.AnimateFloat(FBody, 'height', 0, 0.3, TAnimationType.In, TInterpolationType.Back);
      LFloatAnimation.Start;
    end);
end;

class constructor Swal.Create;
begin
  FFontName := 'Quicksand';
end;

class procedure Swal.CreateBackground;
begin
  FBackGround             := TRectangle.Create(nil);
  FBackGround.Parent      := Application.MainForm;
  FBackGround.Fill.Color  := TAlphaColorRec.Black;
  FBackGround.Opacity     := 0.55;
  FBackGround.Align       := TAlignLayout.Client;
  FBackGround.Stroke.Kind := TBrushKind.None;

  FFinally := False;
end;

class procedure Swal.CreateBody;
begin
  FBody                := TRectangle.Create(FBackGround);
  FBody.Height         := 0;
  FBody.Width          := 0;
  FBody.Parent         := Application.MainForm;
  FBody.Fill.Color     := TAlphaColorRec.White;
  FBody.Align          := TAlignLayout.Center;
  FBody.Stroke.Kind    := TBrushKind.None;
  FBody.XRadius        := 5.72;
  FBody.YRadius        := 5.72;
  FBody.Margins.Left   := 8;
  FBody.Margins.Right  := 8;
  FBody.Margins.Top    := 8;
  FBody.Margins.Bottom := 8;
  FBody.Padding.Left   := FBackGround.Width * 0.02;
  FBody.Padding.Right  := FBackGround.Width * 0.02;
  FBody.Padding.Top    := FBackGround.Height * 0.01;
  FBody.Padding.Bottom := FBackGround.Height * 0.01;
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
  FIcon := TSkAnimatedImage.Create(FBody);
  if AIcon in [TSweetAlertIconType.info, TSweetAlertIconType.warning, TSweetAlertIconType.success] then
    FIcon.Height := 68
  else
    FIcon.Height := 58;

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
  FLayoutButton                := TLayout.Create(FBody);
  FLayoutButton.Align          := TAlignLayout.Top;
  FLayoutButton.Margins.Bottom := 6;
  FLayoutButton.Height         := 45;
  FLayoutButton.Parent         := FBody;
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
  FMessage.Font.Family    := FFontName;
  FMessage.Margins.Bottom := 8;
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
  FTitle.Font.Family    := FFontName;
end;

class procedure Swal.CreateMessage(const AMessage: String);
begin
  CreateMessage(AMessage, 28, [TFontStyle.fsBold])
end;

class procedure Swal.DoClickConfirmed(Sender: TObject);
begin
  FResult := TResult.Confirmed;
  CloseMessage;
end;

class procedure Swal.DoFinishClose(Sender: TObject);
begin
  FBackGround.Visible := False;
  FreeAndNil(FIcon);
  FreeAndNil(FTitle);
  FreeAndNil(FMessage);
  FreeAndNil(FLayoutButton);
  FreeAndNil(FBody);
  FreeAndNil(FBackGround);

  FFinally := True;
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

class procedure Swal.SetFontFamily(const AFontName: String);
begin
  FFontName := AFontName;
end;

{ Swal.TThen }

procedure Swal.TThen.&then(const AResult: TProc<TResult>);
begin
  if Assigned(AResult) then
    AResult(FResult);
end;

end.
