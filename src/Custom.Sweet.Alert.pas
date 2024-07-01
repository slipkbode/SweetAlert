unit Custom.Sweet.Alert;

interface

uses Custom.Sweet.Classes, Custom.Sweet.Interfaces;

type
  Swal = class(TSweetTitle)
  private
    FThen: IThen;
  protected
    procedure CallThen; override;
  public
    class procedure fire(const AText: String); overload;
    class function fire(const ASweetAlert: ISweetAlert): IThen; overload;

    constructor Create(const ASweetAlert: ISweetAlert; const AThen: IThen); reintroduce; overload;
  end;

implementation

uses System.Rtti;

procedure Swal.CallThen;
begin
  if Assigned(FThen) then
    TThen(FThen).Execute(FResult, TValue.Empty);

  inherited;
end;

constructor Swal.Create(const ASweetAlert: ISweetAlert; const AThen: IThen);
begin
  inherited Create(ASweetAlert);
  FThen := AThen;
end;

{ TSweetAlert }

class function Swal.fire(const ASweetAlert: ISweetAlert): IThen;
begin
  Result := TThen.Create;

  Self.Create(ASweetAlert, Result);
end;

class procedure Swal.fire(const AText: String);
begin
  TSweetMessage.Create(AText);
end;

end.
