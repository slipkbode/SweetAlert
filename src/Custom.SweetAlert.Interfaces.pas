unit Custom.SweetAlert.Interfaces;

interface

uses
  Custom.SweetAlert.Types;

type
  ISweetAlert = interface
    ['{AD5B1CDF-7B76-428D-8B86-0B8BBF08C535}']
    function title(const ATitle: String): ISweetAlert;
    function text(const AText: String): ISweetAlert;
    function icon(const AIcon: TSweetAlertIconType): ISweetAlert;
  end;


implementation

end.
