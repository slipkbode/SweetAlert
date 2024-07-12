unit Custom.Sweet.Interfaces;

interface

uses System.Rtti, Custom.Sweet.Types, System.SysUtils, System.UITypes,
  FMX.Types;

type
  ISweetBase = interface
    ['{B15FA005-1487-4BD2-83C5-71060268CDFB}']
  end;

  IThen = interface(ISweetBase)
    ['{8D7A46A3-F27E-4869-A300-6F4C9F751487}']
    procedure &then(const AProc: TProc<TResult, TValue>);
  end;

  ISweetAlert = interface
    ['{F4346B64-43DD-4206-B0E3-2CA9452186E5}']
    function title(const ATitle: String): ISweetAlert;
    function text(const AText: String): ISweetAlert;
    function icon(const AIcon: TSweetAlertIconType): ISweetAlert;
    function showCancelButton(const AShow: Boolean): ISweetAlert;
    function confirmButtonText(const AText: String): ISweetAlert;
    function cancelButtonText(const AText: String): ISweetAlert;
  end;

  ISweetPopup = interface
    ['{C4249720-2120-4EA4-A370-C5E390FFC665}']
    function Option(const AOption: String): ISweetPopup;
    function Name(const AName: String): ISweetPopup;
  end;

  ISweetLookupItem = interface
    ['{98BA9C12-D85F-4B30-8BF1-FCF744613EFD}']
    function icon(const AData: TBytes): ISweetLookupItem; overload;
    function icon: TBytes; overload;
    function text(const AText: String): ISweetLookupItem; overload;
    function text: String; overload;
    function id(const AId: Variant): ISweetLookupItem; overload;
    function id: Variant; overload;
    function Color(const AColor: TAlphaColor): ISweetLookupItem; overload;
    function Color: TAlphaColor; overload;
  end;

  ISweetLookup = interface
    ['{045C18C6-A64C-49AA-AEB9-48E4BF023502}']
    function items(const AItems: TArray<ISweetLookupItem>): ISweetLookup;
    function AlignIcon(const AAlign: TAlignLayout): ISweetLookup;
    function AlignText(const AAlign: TAlignLayout): ISweetLookup;
    function title(const ATitle: String): ISweetLookup;
  end;

  ISweetAwait = interface
    ['{EB436F2E-CA91-487B-9CA3-F75990E75085}']
    procedure Stop;
    procedure text(const AText: String);
  end;

  ISweetInput = interface
    ['{19948C49-C81F-4EFF-BA30-48657FDF70F0}']
    function title(const ATitle: String): ISweetInput;
  end;

  IWait = interface(ISweetBase)
    ['{CAB82FB8-1EED-46F5-A174-9A2DA25E7E4C}']
    procedure Stop;
    procedure text(const AText: String);
  end;

implementation

end.
