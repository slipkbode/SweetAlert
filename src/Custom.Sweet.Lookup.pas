unit Custom.Sweet.Lookup;

interface

uses Custom.Sweet.Classes,
     Custom.Sweet.Interfaces,
     FMX.ListBox,
     FMX.Types,
     FMX.Controls,
     Custom.Sweet.Types,
     System.UITypes,
     System.SysUtils,
     FMX.Objects;

type
  Lookup = class(TSweetMessage)
  private
    FThen          : IThen;
    FSelectedLookup: ISweetLookupItem;
    FList          : TArray<ISweetLookupItem>;
    FSweetLookup   : TSweetLookup;

    procedure CreateListLookup;
    procedure DoClickSelectedLookup(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure AdjustComponents;
    procedure AddItemsLookup;
    procedure CreateIconLookup(const AControl: TControl; const AIcon: TBytes; const AAlign: TAlignLayout);
    procedure CreateTextLookup(const AControl: TControl; const AText: String; const AAlign: TAlignLayout);

    function CreateContainerLookupItem(const AControl: TControl; const AColor: TAlphaColor): TRectangle;
  protected
    procedure CallThen; override;
    procedure CreateObjects; override;
    function GetSize: TArray<Single>; override;
  public
    class function show(const ASweetLookup: ISweetLookup): IThen;

    constructor Create(const ASweetLookup: ISweetLookup; const AThen: IThen); reintroduce;
  end;

implementation

uses System.Rtti,
     FMX.StdCtrls,
     Custom.Button,
     FMX.Graphics,
     FMX.Skia;

{ Lookup }

procedure Lookup.AddItemsLookup;
var
  LListBox    : TListBox;
  LSweetItem  : TSweetLookupItem;
  LRectangle  : TRectangle;
begin
  LListBox            := FBackGround.FindComponent('ltbLookup') as TListBox;
  LListBox.ItemHeight := 60;
  LListBox.BeginUpdate;
  try
    for var LItem in FSweetLookup.Items do
    begin
      LSweetItem := TSweetLookupItem(LItem);

      LRectangle := CreateContainerLookupItem(
        LListBox.ListItems[LListBox.Items.Add('')],
        LSweetItem.Color
      );

      CreateIconLookup(LRectangle, LSweetItem.icon, FSweetLookup.AlignIcon);
      CreateTextLookup(LRectangle, LSweetItem.text, FSweetLookup.AlignText);
    end;
  finally
    LListBox.EndUpdate;
  end;
end;

procedure Lookup.CreateTextLookup(const AControl: TControl; const AText: String;
  const AAlign: TAlignLayout);
var
  LTextItem: TLabel;
begin
  LTextItem                := TLabel.Create(FBackGround);
  LTextItem.Parent         := AControl;
  LTextItem.text           := AText;
  LTextItem.StyledSettings := [];
  LTextItem.Font.Size      := 18;
  LTextItem.Align          := TAlignLayout.Client;
  LTextItem.WordWrap       := True;
  LTextItem.AutoSize       := True;
  LTextItem.Font.Style     := [TFontStyle.fsBold];
  LTextItem.TextAlign      := TTextAlign.Leading;
  LTextItem.FontColor      := $FF545454;
  LTextItem.Font.Family    := FFontFamily;
  LTextItem.Margins.Bottom := 8;

  if AAlign <> TAlignLayout.None then
    LTextItem.Align := AAlign;
end;

procedure Lookup.CreateIconLookup(const AControl: TControl; const AIcon: TBytes; const AAlign: TAlignLayout);
begin
  var LIcon         := TSkAnimatedImage.Create(AControl);
  LIcon.Parent      := AControl;
  LIcon.Source.Data := AIcon;
  LIcon.Align       := TAlignLayout.MostLeft;

  if AAlign <> TAlignLayout.None then
    LIcon.Align := AAlign;

  LIcon.Width    := 70;
  LIcon.WrapMode := TSkAnimatedImageWrapMode.Stretch;
  LIcon.HitTest  := False;
end;

function Lookup.CreateContainerLookupItem(const AControl: TControl; const AColor: TAlphaColor): TRectangle;
begin
  Result                := TRectangle.Create(AControl);
  Result.Align          := TAlignLayout.Client;
  Result.Stroke.Kind    := TBrushKind.None;
  Result.Fill.Color     := AColor;
  Result.Parent         := AControl;
  Result.Margins.Bottom := 5;
  Result.HitTest        := False;
end;

procedure Lookup.AdjustComponents;
var
  LMessage     : TLabel;
  LButtonEffect: TButtonEffect;
begin
  LMessage := FBackGround.FindComponent('message') as TLabel;
  LMessage.Align     := TAlignLayout.MostTop;
  LMessage.Font.Size := 20;

  LButtonEffect                        := FBackGround.FindComponent('btnCancel') as TButtonEffect;
  LButtonEffect.AutoSize               := True;
  LButtonEffect.Align                  := TAlignLayout.Client;
  LButtonEffect.Fill.Color             := $FFef233c;
  LButtonEffect.Stroke.Color           := TAlphaColorRec.Null;
  LButtonEffect.EffectButtonColor      := $FFd90429;
  LButtonEffect.TextSettings.FontColor := TAlphaColorRec.White;
  LButtonEffect.TextSettings.Font.Size := 18;
  LButtonEffect.ForceColor;
end;

procedure Lookup.CallThen;
begin
  inherited;
  if Assigned(FThen) then
    TThen(FThen).Execute(FResult, TValue.From<ISweetLookupItem>(FSelectedLookup));
end;

constructor Lookup.Create(const ASweetLookup: ISweetLookup; const AThen: IThen);
begin
  FSweetLookup      := TSweetLookup(ASweetLookup);
  FList             := FSweetLookup.items;
  FThen             := AThen;
  FCancelButtonText := 'Cancelar';
  inherited Create(FSweetLookup.title);
  AdjustComponents;
  FSelectedLookup := nil;
end;

procedure Lookup.CreateListLookup;
var
  LListBox: TListBox;
begin
  LListBox                             := TListBox.Create(FBackGround);
  LListBox.Parent                      := FBackGround.FindComponent('body') as TControl;
  LListBox.Align                       := TAlignLayout.Client;
  LListBox.ShowScrollBars              := False;
  LListBox.Name                        := 'ltbLookup';
  LListBox.Margins.Bottom              := 8;
  LListBox.Margins.Top                 := 8;
  LListBox.OnItemClick                 := DoClickSelectedLookup;
  LListBox.DefaultItemStyles.ItemStyle := 'listboxitemnodetail';
  LListBox.ShowScrollBars              := False;
end;

procedure Lookup.CreateObjects;
begin
  CreateBackGround;
  CreateBody;
  CreateMessage;
  CreateListLookup;
  CreateLayoutButtons;
  CreateCancelButton;
  AddItemsLookup;
end;

procedure Lookup.DoClickSelectedLookup(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  FSelectedLookup := FList[Item.Index];
  FResult         := TResult.Confirmed;

  CloseMessage;
end;

function Lookup.GetSize: TArray<Single>;
begin
  Result := [FBackGround.Height * 0.8,
             FBackGround.Width * 0.85];
end;

class function Lookup.show(const ASweetLookup: ISweetLookup): IThen;
begin
  Result := TThen.Create;
  Self.Create(ASweetLookup, Result);
end;

end.
