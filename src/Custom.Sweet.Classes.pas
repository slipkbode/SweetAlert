unit Custom.Sweet.Classes;

interface

uses Custom.Sweet.Interfaces,
     FMX.Objects,
     FMX.Types,
     System.SysUtils,
     Custom.Sweet.Types,
     System.Rtti,
     System.UITypes,
     System.Threading,
     System.Classes;

type
  TSweetBase = class
  protected
    FBackGround: TRectangle;
    FIcon      : TSweetAlertIconType;

    class var FFontFamily: String;

    procedure CreateObjects; virtual;
    procedure CreateIcon;
    procedure CreateBackGround;
    procedure CreateBody;
    procedure Animate; virtual;
    procedure CloseMessage; virtual; abstract;
    procedure DoFinishClose(Sender: TObject); virtual;
    procedure CallThen; virtual;

    function GetSize: TArray<Single>; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure SetFontFamily(const AFontFamily: String);
  end;

  TSweetMessage = class(TSweetBase)
  private
    FSize   : Single;
    FStyles : TFontStyles;
    FMessage   : String;

    procedure DoClickCancel(Sender: TObject);
  protected
    FConfirmButtonText : String;
    FCancelButtonText  : String;
    FResult            : TResult;
    FShowCancelButtom  : Boolean;

    procedure CreateLayoutButtons;
    procedure CreateConfirmButton;
    procedure CreateCancelButton;
    procedure CreateButtons;
    procedure AdjustFontMessage;
    procedure CreateMessage;
    procedure CreateObjects; override;
    procedure DoClickConfirmed(Sender: TObject); virtual;
    procedure HideComponents; virtual;
    procedure CloseMessage; override;

    function GetSize: TArray<Single>; override;
  public
    constructor Create(const AMessage: String); overload;
  end;

  TSweetTitle = class(TSweetMessage)
  protected
    FTitle: String;

    procedure CreateTitle;
    procedure CreateObjects; override;
    procedure HideComponents; override;

    function GetSize: TArray<Single>; override;
  public
    constructor Create(const ASweetAlert: ISweetAlert); overload;
  end;

  TThen = class(TInterfacedObject, IThen)
  private
    FThen: TProc<TResult, TValue>;

    procedure &then(const AProc: TProc<TResult, TValue>);
  public
    procedure Execute(AResult: TResult; AValue: TValue);
    destructor Destroy; override;
  end;

  TSweetAlert = class(TInterfacedObject, ISweetAlert)
  private
    FIcon             : TSweetAlertIconType;
    FText             : string;
    FTitle            : string;
    FShowCancelButton : Boolean;
    FconfirmButtonText: String;
    FcancelButtonText : String;

    function title(const ATitle: string): ISweetAlert; overload;
    function text(const AText: string): ISweetAlert; overload;
    function icon(const AIcon: TSweetAlertIconType): ISweetAlert; overload;
    function showCancelButton(const AShow: Boolean): ISweetAlert; overload;
    function confirmButtonText(const AText: String): ISweetAlert; overload;
    function cancelButtonText(const AText: String): ISweetAlert; overload;

    constructor Create;
  public
    class function New: ISweetAlert;

    function title: string; overload;
    function text: string; overload;
    function icon: TSweetAlertIconType; overload;
    function showCancelButton: Boolean; overload;
    function confirmButtonText: String; overload;
    function cancelButtonText: String; overload;
  end;

  TSweetIcon = class
  public
    class function GetStream(const ASweetAlertIconType: TSweetAlertIconType): TStream;
  end;

  TWait = class(TInterfacedObject, IWait)
  private
    FProcStop: TProc;
    FProcText: TProc<String>;

    procedure Stop;
    procedure text(const AText: String);
  public
    constructor Create(const AProcStop: TProc; const AProcText: TProc<String>); reintroduce;
  end;

  TSweetInput = class(TInterfacedObject, ISweetInput)
  private
    FTitle: String;

    function title(const ATitle: String): ISweetInput; overload;
  public
    class function New: ISweetInput;

    function title: String; overload;
  end;

  TSweetLookup = class(TInterfacedObject, ISweetLookup)
  strict private
    FAlignIcon: TAlignLayout;
    FAlignText: TAlignLayout;
    Ftitle    : String;
    FItems    : TArray<ISweetLookupItem>;
  private
    function items(const AItems: TArray<ISweetLookupItem>): ISweetLookup; overload;
    function AlignIcon(const AAlign: TAlignLayout): ISweetLookup; overload;
    function AlignText(const AAlign: TAlignLayout): ISweetLookup; overload;
    function title(const ATitle: String): ISweetLookup; overload;
  public
    class function New: ISweetLookup;

    function AlignIcon: TAlignLayout; overload;
    function AlignText: TAlignLayout; overload;
    function title: String; overload;
    function items: TArray<ISweetLookupItem>; overload;
  end;

  TSweetLookupItem = class(TInterfacedObject, ISweetLookupItem)
  strict private
    Ficon     : TBytes;
    Ftext     : String;
    Fid       : Variant;
    FColor    : TAlphaColor;
  private
     function icon(const AData: TBytes): ISweetLookupItem; overload;
     function text(const AText: String): ISweetLookupItem; overload;
     function id(const AId: Variant): ISweetLookupItem; overload;
     function Color(const AColor: TAlphaColor): ISweetLookupItem; overload;

     function icon: TBytes; overload;
     function text: String; overload;
     function id: Variant; overload;
     function Color: TAlphaColor; overload;
  public
     class function New: ISweetLookupItem;
  end;

  TSweetPopup = class(TInterfacedObject, ISweetPopup)
  strict private
    FName  : String;
    FOption: String;
  private
    function Option(const AOption: String): ISweetPopup; overload;
    function Name(const AName: String): ISweetPopup; overload;
  public
    class function New: ISweetPopup;

    function Option: String; overload;
    function Name: String; overload;
  end;

implementation

uses
  FMX.Forms,
  FMX.Graphics,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.TextLayout,
  System.Types,
  FMX.Ani,
  FMX.Layouts,
  FMX.Skia,
  Custom.Button,
  Custom.SweetAlert.Consts;

{ TSweet }

procedure TSweetBase.Animate;
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
          TAnimator.AnimateFloat(LBody, 'width', LSize[1], 0.4, TAnimationType.InOut, TInterpolationType.Elastic);

        end
      )
    end
  )
end;

procedure TSweetBase.CallThen;
begin

end;

constructor TSweetBase.Create;
begin
  inherited;
  FFontFamily := 'Quicksand';
  CreateObjects;
  Animate;
end;

procedure TSweetBase.CreateBackGround;
begin
  FBackGround             := TRectangle.Create(nil);
  FBackGround.Parent      := Application.MainForm;
  FBackGround.Fill.Color  := TAlphaColorRec.Black;
  FBackGround.Opacity     := 0.55;
  FBackGround.Align       := TAlignLayout.Client;
  FBackGround.Stroke.Kind := TBrushKind.None;
end;

procedure TSweetBase.CreateBody;
var
  LBody: TRectangle;
begin
  LBody                := TRectangle.Create(FBackGround);
  LBody.Height         := 0;
  LBody.Width          := 0;
  LBody.Parent         := Application.MainForm;
  LBody.Fill.Color     := TAlphaColorRec.White;
  LBody.Align          := TAlignLayout.Center;
  LBody.Stroke.Kind    := TBrushKind.None;
  LBody.XRadius        := 5.72;
  LBody.YRadius        := 5.72;
  LBody.Margins.Bottom := 8;
  LBody.Margins.Top    := 8;
  LBody.Margins.Left   := 8;
  LBody.Margins.Right  := 8;
  LBody.Padding.Left   := FBackGround.Width * 0.02;
  LBody.Padding.Right  := FBackGround.Width * 0.02;
  LBody.Padding.Top    := FBackGround.Height * 0.01;
  LBody.Padding.Bottom := FBackGround.Height * 0.01;
  LBody.Name           := 'body';
end;

procedure TSweetBase.CreateObjects;
begin
  CreateBackGround;
  CreateBody;
end;

destructor TSweetBase.Destroy;
begin
  FreeAndNil(FBackGround);
  inherited;
end;

procedure TSweetBase.DoFinishClose(Sender: TObject);
begin
  FBackGround.Visible := False;
  CallThen;
  Self.Free;
end;

class procedure TSweetBase.SetFontFamily(const AFontFamily: String);
begin
  FFontFamily := AFontFamily;
end;

{ TThen }

destructor TThen.Destroy;
begin
  FThen := nil;
  inherited;
end;

procedure TThen.Execute(AResult: TResult; AValue: TValue);
begin
  if Assigned(FThen) then
    FThen(AResult, AValue);
end;

procedure TThen.&then(const AProc: TProc<TResult, TValue>);
begin
  FThen := AProc;
end;

{ TSweetMessage }

procedure TSweetMessage.CloseMessage;
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
          HideComponents;

          LFloatAnimation                  := TFloatAnimation.Create(nil);
          LFloatAnimation.OnFinish         := DoFinishClose;
          LFloatAnimation.Parent           := LBody;
          LFloatAnimation.AnimationType    := TAnimationType.In;
          LFloatAnimation.Interpolation    := TInterpolationType.Back;
          LFloatAnimation.Duration         := 0.15;
          LFloatAnimation.PropertyName     := 'height';
          LFloatAnimation.StartFromCurrent := True;
          LFloatAnimation.StopValue        := 0;
          LFloatAnimation.Start;
        end
      )
    end
  )
end;

constructor TSweetMessage.Create(const AMessage: String);
begin
  FMessage           := AMessage;
  FSize              := 28;
  FStyles            := [TFontStyle.fsBold];
  FConfirmButtonText := 'OK';
  inherited Create;
end;

procedure TSweetMessage.CreateButtons;
var
  LControl: TControl;
begin
  CreateLayoutButtons;
  LControl := FBackGround.FindComponent('layoutbutton') as TControl;
  LControl.BeginUpdate;

  try
    CreateConfirmButton;

    if FShowCancelButtom then
      CreateCancelButton;
  finally
    LControl.EndUpdate;
  end;
end;


procedure TSweetMessage.CreateCancelButton;
var
  LButton: TButtonEffect;
  LLayout: TFlowLayout;
begin
  LLayout := FBackGround.FindComponent('layoutbutton') as TFlowLayout;

  LButton                          := TButtonEffect.Create(FBackGround);
  LButton.Parent                   := LLayout;
  LButton.Fill.Color               := $FF707880;
  LButton.EffectButtonColor        := $FF545454;
  LButton.Height                   := LLayout.Height;
  LButton.Name                     := 'btnCancel';
  LButton.text                     := FCancelButtonText;
  LButton.OnClick                  := DoClickCancel;
  LButton.TypeEffect               := TTypeEffect.ColorButton;
  LButton.TextSettings.Font.Family := FFontFamily;
  LButton.Stroke.Kind              := TBrushKind.None;
  LButton.TextSettings.Font.Size   := 15;
  LButton.AutoSize                 := True;
end;

procedure TSweetMessage.DoClickCancel(Sender: TObject);
begin
  FResult := TResult.Canceled;
  CloseMessage;
end;

procedure TSweetMessage.CreateConfirmButton;
var
  LButton: TButtonEffect;
  LLayout: TFlowLayout;
begin
  LLayout := FBackGround.FindComponent('layoutbutton') as TFlowLayout;

  LButton                          := TButtonEffect.Create(FBackGround);
  LButton.Parent                   :=  LLayout;
  LButton.Fill.Color               := $FF6E66D9;
  LButton.EffectButtonColor        := $FF635CC3;
  LButton.Stroke.Kind              := TBrushKind.None;
  LButton.Height                   := LLayout.Height;
  LButton.Name                     := 'btnConfirmed';
  LButton.text                     := FConfirmButtonText;
  LButton.OnClick                  := DoClickConfirmed;
  LButton.TypeEffect               := TTypeEffect.ColorButton;
  LButton.TextSettings.Font.Family := FFontFamily;
  LButton.TextSettings.Font.Size   := 15;
  LButton.AutoSize                 := True;
end;

procedure TSweetMessage.CreateLayoutButtons;
var
  LLayoutButton: TFlowLayout;
begin
  LLayoutButton                 := TFlowLayout.Create(FBackGround);
  LLayoutButton.Align           := TAlignLayout.Bottom;
  LLayoutButton.Height          := 45;
  LLayoutButton.Parent          := FBackGround.FindComponent('body') as TControl;
  LLayoutButton.Justify         := TFlowJustify.Center;
  LLayoutButton.JustifyLastLine := TFlowJustify.Center;
  LLayoutButton.VerticalGap     := 5;
  LLayoutButton.HorizontalGap   := 8;
  LLayoutButton.Name            := 'layoutbutton';
end;

procedure TSweetMessage.CreateMessage;
var
  LMessage: TLabel;
begin
  LMessage                := TLabel.Create(FBackGround);
  LMessage.Parent         := FBackGround.FindComponent('body') as TControl;
  LMessage.text           := FMessage;
  LMessage.StyledSettings := [];
  LMessage.Font.Size      := FSize;
  LMessage.Align          := TAlignLayout.Client;
  LMessage.WordWrap       := True;
  LMessage.AutoSize       := True;
  LMessage.Font.Style     := FStyles;
  LMessage.TextAlign      := TTextAlign.Center;
  LMessage.FontColor      := $FF545454;
  LMessage.Font.Family    := FFontFamily;
  LMessage.Margins.Bottom := 8;
  LMessage.Name           := 'message';
end;

procedure TSweetMessage.CreateObjects;
begin
  inherited;
  CreateMessage;
  CreateButtons;
end;

procedure TSweetMessage.DoClickConfirmed(Sender: TObject);
begin
  FResult := TResult.Confirmed;
  CloseMessage;
end;

function TSweetMessage.GetSize: TArray<Single>;
var
  LText : TTextLayout;
  LLabel: TLabel;
begin
  LText := TTextLayoutManager.DefaultTextLayout.Create;
  try
    if FBackGround.FindComponent('message') = nil then
    begin
      Result := [0, 0];
      Exit;
    end;

    LLabel         := FBackGround.FindComponent('message') as TLabel;

    LText.Font     := LLabel.Font;
    LText.TopLeft  := TPointF.Create(FBackGround.Width, FBackGround.Height);
    LText.text     := LLabel.text;
    LText.WordWrap := LLabel.WordWrap;

    Result := [LText.Height + 24 + 45, LText.TextWidth + 34];

    if FIcon = TSweetAlertIconType.wait then
      Result[0] := Result[0] + 65;

    if LText.TextWidth > FBackGround.Width then
    begin
      Result[0] := Result[0] + (LText.Height * (Round(Result[1] / FBackGround.Width)));
      Result[1] := FBackGround.Width - 16;
    end;

    if Result[1] < 200 then
      Result[1] := 200;

  finally
    LText.Free;
  end;
end;

procedure TSweetMessage.HideComponents;
var
  LControl: TComponent;
begin
  LControl := FBackGround.FindComponent('layoutbutton');

  if LControl <> nil then
    TControl(LControl).Visible := False;

  LControl := FBackGround.FindComponent('message');

  if LControl <> nil then
    TControl(LControl).Visible := False;
end;

{ TSweetTitle }

procedure TSweetMessage.AdjustFontMessage;
var
  LText: TLabel;
begin
  LText := FBackGround.FindComponent('message') as TLabel;

  LText.Font.Size  := 18;
  LText.Font.Style := [];
end;

constructor TSweetTitle.Create(const ASweetAlert: ISweetAlert);
var
  LSweetAlert: TSweetAlert;
begin
  LSweetAlert        := TSweetAlert(ASweetAlert);
  FTitle             := LSweetAlert.title;
  FIcon              := LSweetAlert.icon;
  FShowCancelButtom  := LSweetAlert.FShowCancelButton;
  FConfirmButtonText := LSweetAlert.FconfirmButtonText;
  FCancelButtonText  := LSweetAlert.FcancelButtonText;
  inherited Create(TSweetAlert(ASweetAlert).text);
end;

procedure TSweetBase.CreateIcon;
var
  LStream: TStream;
  LIcon  : TSkAnimatedImage;
begin
  LIcon := TSkAnimatedImage.Create(FBackGround);

  if FIcon in [TSweetAlertIconType.info, TSweetAlertIconType.warning, TSweetAlertIconType.success] then
    LIcon.Height := 68
  else
    LIcon.Height := 58;

  LIcon.Align          := TAlignLayout.MostTop;
  LIcon.Index          := 0;
  LIcon.Parent         := FBackGround.FindComponent('body') as TControl;

  if FIcon <> TSweetAlertIconType.wait then
    LIcon.Animation.Loop := False
  else
    LIcon.Height := 100;

  LIcon.Name := 'icon';

  LStream := TSweetIcon.GetStream(FIcon);
  try
    LIcon.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

procedure TSweetTitle.CreateObjects;
begin
  inherited;
  if FIcon <> TSweetAlertIconType.null then
    CreateIcon;

  if not FTitle.Trim.IsEmpty then
    CreateTitle;

  AdjustFontMessage;
end;

procedure TSweetTitle.CreateTitle;
var
  LTitle: TLabel;
begin
  LTitle                := TLabel.Create(FBackGround);
  LTitle.Parent         := FBackGround.FindComponent('body') as TControl;
  LTitle.text           := FTitle;
  LTitle.StyledSettings := [];
  LTitle.Font.Size      := 30;
  LTitle.Align          := TAlignLayout.MostTop;
  LTitle.WordWrap       := True;
  LTitle.AutoSize       := True;
  LTitle.Font.Style     := [TFontStyle.fsBold];
  LTitle.TextAlign      := TTextAlign.Center;
  LTitle.FontColor      := $FF545454;
  LTitle.Font.Family    := FFontFamily;
  LTitle.Name           := 'title';
end;

function TSweetTitle.GetSize: TArray<Single>;
var
  LText : TTextLayout;
  LLabel: TLabel;
  LIcon : TControl;
begin
  Result := inherited;

  LText := TTextLayoutManager.DefaultTextLayout.Create;
  try
    LLabel := FBackGround.FindComponent('title') as TLabel;
    LIcon  := FBackGround.FindComponent('icon') as TControl;

    if LLabel = nil then
      Exit;

    LText.Font     := LLabel.Font;
    LText.TopLeft  := TPointF.Create(FBackGround.Width, FBackGround.Height);
    LText.text     := LLabel.text;
    LText.WordWrap := LLabel.WordWrap;

    Result[0] := LText.Height + 8 + Result[0];

    if LIcon <> nil then
      Result[0] := Result[0] + LIcon.Height + 6;

    if LText.TextWidth > Result[1] then
      Result[1] := LText.TextWidth + 28;

    if LText.TextWidth > FBackGround.Width then
    begin
      Result[0] := Result[0] + (LText.Height * (Round(Result[1] / FBackGround.Width)));
      Result[1] := FBackGround.Width - 16;
    end;

  finally
    LText.Free;
  end;
end;

procedure TSweetTitle.HideComponents;
var
  LControl: TComponent;
begin
  inherited;
  LControl := FBackGround.FindComponent('title');

  if LControl <> nil then
    TControl(LControl).Visible := False;

  LControl := FBackGround.FindComponent('icon');

  if LControl <> nil then
    TControl(LControl).Visible := False;
end;

{ TSweetAlert }

function TSweetAlert.cancelButtonText(const AText: String): ISweetAlert;
begin
  Result            := Self;
  FcancelButtonText := AText;
end;

function TSweetAlert.cancelButtonText: String;
begin
  Result := FcancelButtonText;
end;

function TSweetAlert.confirmButtonText: String;
begin
  Result := FconfirmButtonText;
end;

function TSweetAlert.confirmButtonText(const AText: String): ISweetAlert;
begin
  Result             := Self;
  FconfirmButtonText := AText;
end;

constructor TSweetAlert.Create;
begin
  FconfirmButtonText := 'OK';
  FcancelButtonText  := 'Cancel';
end;

function TSweetAlert.icon(const AIcon: TSweetAlertIconType): ISweetAlert;
begin
  Result := Self;
  FIcon  := AIcon;
end;

function TSweetAlert.icon: TSweetAlertIconType;
begin
  Result := FIcon;
end;

class function TSweetAlert.New: ISweetAlert;
begin
  Result := Self.Create;
end;

function TSweetAlert.showCancelButton: Boolean;
begin
  Result := FShowCancelButton;
end;

function TSweetAlert.showCancelButton(const AShow: Boolean): ISweetAlert;
begin
  Result            := Self;
  FShowCancelButton := AShow;
end;

function TSweetAlert.text(const AText: string): ISweetAlert;
begin
  Result := Self;
  FText  := AText;
end;

function TSweetAlert.text: string;
begin
  Result := FText;
end;

function TSweetAlert.title(const ATitle: string): ISweetAlert;
begin
  Result := Self;
  FTitle := ATitle;
end;

function TSweetAlert.title: string;
begin
  Result := FTitle;
end;

{ TSweetIcon }

class function TSweetIcon.GetStream(const ASweetAlertIconType: TSweetAlertIconType): TStream;
begin
  case ASweetAlertIconType of
    TSweetAlertIconType.success:
      Result := TStringStream.Create(cSucess);
    TSweetAlertIconType.error:
      Result := TStringStream.Create(cError);
    TSweetAlertIconType.warning:
      Result := TStringStream.Create(cWarning);
    TSweetAlertIconType.info:
      Result := TStringStream.Create(cInfo);
    TSweetAlertIconType.question:
      Result := TStringStream.Create(cQuestion);
    TSweetAlertIconType.wait:
      Result := TStringStream.Create(cWait);
    else
      Result := nil;
  end;

end;

{ TWait }

constructor TWait.Create(const AProcStop: TProc;const AProcText: TProc<String>);
begin
  inherited Create;
  FProcStop := AProcStop;
  FProcText := AProcText;
end;

procedure TWait.Stop;
begin
  FProcStop;
end;

procedure TWait.text(const AText: String);
begin
  FProcText(AText);
end;

{ TSweetInput }

class function TSweetInput.New: ISweetInput;
begin
  Result := Self.Create;
end;

function TSweetInput.title(const ATitle: String): ISweetInput;
begin
  Result := Self;
  FTitle := ATitle;
end;

function TSweetInput.title: String;
begin
  Result := FTitle
end;

{ TSweetLookup }

function TSweetLookup.AlignIcon(const AAlign: TAlignLayout): ISweetLookup;
begin
  Result     := Self;
  FAlignIcon := AAlign;
end;

function TSweetLookup.AlignIcon: TAlignLayout;
begin
  Result := FAlignIcon;
end;

function TSweetLookup.AlignText: TAlignLayout;
begin
  Result := FAlignText;
end;

function TSweetLookup.AlignText(const AAlign: TAlignLayout): ISweetLookup;
begin
  Result     := Self;
  FAlignText := AAlign;
end;

{ TSweetLookupItem }

function TSweetLookupItem.Color(const AColor: TAlphaColor): ISweetLookupItem;
begin
  Result := Self;
  FColor := AColor;
end;

function TSweetLookupItem.Color: TAlphaColor;
begin
  Result := FColor;
end;

function TSweetLookupItem.icon: TBytes;
begin
  Result := Ficon;
end;

function TSweetLookupItem.icon(const AData: TBytes): ISweetLookupItem;
begin
  Result := Self;
  Ficon  := AData;
end;

function TSweetLookupItem.id: Variant;
begin
  Result := Fid;
end;

class function TSweetLookupItem.New: ISweetLookupItem;
begin
  Result := Self.Create;
end;

function TSweetLookup.items: TArray<ISweetLookupItem>;
begin
  Result := FItems;
end;

function TSweetLookup.items(const AItems: TArray<ISweetLookupItem>): ISweetLookup;
begin
  Result := Self;
  FItems := AItems;
end;

function TSweetLookupItem.id(const AId: Variant): ISweetLookupItem;
begin
  Result := Self;
  Fid    := AId;
end;

class function TSweetLookup.New: ISweetLookup;
begin
  Result := Self.Create;
  Result.AlignIcon(TAlignLayout.MostLeft);
  Result.AlignText(TAlignLayout.Client);
end;

function TSweetLookupItem.text(const AText: String): ISweetLookupItem;
begin
  Result := Self;
  Ftext  := AText;
end;

function TSweetLookupItem.text: String;
begin
  Result := Ftext;
end;

function TSweetLookup.title(const ATitle: String): ISweetLookup;
begin
  Result := Self;
  Ftitle := ATitle;
end;

function TSweetLookup.title: String;
begin
  Result := Ftitle;
end;

{ TSweetPopup }

function TSweetPopup.Name(const AName: String): ISweetPopup;
begin
  Result := Self;
  FName  := AName;
end;

function TSweetPopup.Option(const AOption: String): ISweetPopup;
begin
  Result  := Self;
  FOption := AOption;
end;

function TSweetPopup.Name: String;
begin
  Result := FName;
end;

class function TSweetPopup.New: ISweetPopup;
begin
  Result := Self.Create;
end;

function TSweetPopup.Option: String;
begin
  Result := FOption;
end;

end.
