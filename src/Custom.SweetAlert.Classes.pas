unit Custom.SweetAlert.Classes;

interface

uses
  Custom.SweetAlert.Interfaces, Custom.SweetAlert.Types, System.Classes;

type
  TSweeatAlert = class(TInterfacedObject, ISweetAlert)
  private
    FIcon : TSweetAlertIconType;
    FText : string;
    FTitle: string;

    function title(const ATitle: string): ISweetAlert; overload;
    function text(const AText: string): ISweetAlert; overload;
    function icon(const AIcon: TSweetAlertIconType): ISweetAlert; overload;

    constructor Create;
  public
    class function New: ISweetAlert;

    function title: string; overload;
    function text: string; overload;
    function icon: TSweetAlertIconType; overload;
  end;

  TSweetAlertIcon = class
  public
    class function GetStream(const ASweetAlertIconType: TSweetAlertIconType): TStream;
  end;

implementation

uses Custom.SweetAlert.Consts;

{ TSweeatAlert }

constructor TSweeatAlert.Create;
begin

end;

function TSweeatAlert.icon(const AIcon: TSweetAlertIconType): ISweetAlert;
begin
  Result := Self;
  FIcon  := AIcon;
end;

function TSweeatAlert.icon: TSweetAlertIconType;
begin
  Result := FIcon;
end;

class function TSweeatAlert.New: ISweetAlert;
begin
  Result := Self.Create;
end;

function TSweeatAlert.text(const AText: string): ISweetAlert;
begin
  Result := Self;
  FText  := AText;
end;

function TSweeatAlert.title(const ATitle: string): ISweetAlert;
begin
  Result := Self;
  FTitle := ATitle;
end;

function TSweeatAlert.text: string;
begin
  Result := FText;
end;

function TSweeatAlert.title: string;
begin
  Result := FTitle;
end;

{ TSweeatAlertIcon }

class function TSweetAlertIcon.GetStream(const ASweetAlertIconType: TSweetAlertIconType): TStream;
begin
  case ASweetAlertIconType of
    success:
      Result := TStringStream.Create(cSucess);
    error:
      Result := TStringStream.Create(cError);
    warning:
      Result := TStringStream.Create(cWarning);
    info:
      Result := TStringStream.Create(cInfo);
    question:
      Result := TStringStream.Create(cQuestion);
    else
      Result := nil;
  end;
end;

end.
