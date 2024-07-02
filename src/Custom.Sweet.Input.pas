unit Custom.Sweet.Input;

interface

uses Custom.Sweet.Classes,
     Custom.Sweet.Interfaces,
     System.TypInfo;

type
  Input = class(TSweetTitle)
  private
    FThen              : IThen;
    class var FTypeInfo: PTypeInfo;

    procedure CreateEdit;
    procedure AdjustSizeTitle;
  protected
    procedure CreateObjects; override;
    procedure HideComponents; override;
    procedure CallThen; override;

    function GetSize: TArray<Single>; override;
  public
    class function fire<T>(const ASweetInput: ISweetInput): IThen;

    constructor Create(const ASweetInput: ISweetInput; const AThen: IThen); reintroduce;
  end;

implementation

uses FMX.Edit,
     FMX.Types,
     FMX.StdCtrls,
     FMX.Controls,
     System.Rtti,
     System.SysUtils;

{ Input }

procedure Input.AdjustSizeTitle;
var
  LLabel: TLabel;
begin
  LLabel := FBackGround.FindComponent('title') as TLabel;
  LLabel.Font.Size := 24;
end;

procedure Input.CallThen;
var
  LEdit : TEdit;
  LValue: TValue;
begin
  inherited;
  LEdit  := FBackGround.FindComponent('edtValue') as TEdit;
  LValue := TValue.Empty;

  if LEdit <> nil then
  begin
    if not LEdit.Text.Trim.IsEmpty then
      TValue.Make<Variant>(LEdit.Text, LValue);
  end;

  if Assigned(FThen) then
    TThen(FThen).Execute(FResult, LValue);
end;

constructor Input.Create(const ASweetInput: ISweetInput; const AThen: IThen);
begin
  FThen       := AThen;
  inherited Create(TSweetAlert
                            .New
                            .title(TSweetInput(ASweetInput).title)
                            .showCancelButton(True)
                            .confirmButtonText('OK')
                            .cancelButtonText('Cancelar')
  );
end;

procedure Input.CreateEdit;
var
  LEdit: TEdit;
begin
  LEdit                        := TEdit.Create(FBackGround);
  LEdit.Align                  := TAlignLayout.Client;
  LEdit.Font.Family            := FFontFamily;
  LEdit.Font.Size              := 16;
  LEdit.Margins.Top            := 10;
  LEdit.Margins.Bottom         := 10;
  LEdit.Margins.Left           := 15;
  LEdit.Margins.Right          := 15;
  LEdit.KillFocusByReturn      := True;
  LEdit.ReturnKeyType          := TReturnKeyType.Go;
  LEdit.Parent                 := FBackGround.FindComponent('body') as TControl;
  LEdit.Name                   := 'edtValue';
  LEdit.StyledSettings         := [TStyledSetting.FontColor];
  LEdit.TextSettings.HorzAlign := TTextAlign.Center;
  {$IFDEF WINDOWS}
  LEdit.SetFocus;
  {$ENDIF}

  case FTypeInfo.Kind of
    tkFloat:
      begin
        LEdit.FilterChar   := '0123456789,.';
        LEdit.KeyboardType := TVirtualKeyboardType.DecimalNumberPad;
      end;
    tkInteger, tkInt64:
      begin
        LEdit.FilterChar   := '0123456789';
        LEdit.KeyboardType := TVirtualKeyboardType.NumberPad;
      end;
  end;
end;

procedure Input.CreateObjects;
begin
  CreateBackGround;
  CreateBody;
  CreateTitle;
  CreateEdit;
  CreateButtons;
  AdjustSizeTitle;
end;

class function Input.fire<T>(const ASweetInput: ISweetInput): IThen;
begin
  Result    := TThen.Create;
  FTypeInfo := TypeInfo(T);

  Self.Create(ASweetInput, Result);
end;

function Input.GetSize: TArray<Single>;
begin
  Result := inherited;

  Result[0] := Result[0] + 98;
  Result[1] := Result[1] + 55;
end;

procedure Input.HideComponents;
begin
  inherited;
  TControl(FBackGround.FindComponent('edtValue')).Visible := False;
end;

end.
