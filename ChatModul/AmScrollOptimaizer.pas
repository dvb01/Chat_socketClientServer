unit AmScrollOptimaizer;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,AmClientChatSocket,AmUserType,AmLogTo,JsonDataObjects,
  AmHandleObject,IOUtils,mmsystem,AmList,Math,AmControls,ES.BaseControls, ES.Layouts, ES.Images,
  AmChatClientComponets,AmChatCustomSocket,AmVoiceControl,ShellApi,AmMessageFilesControl,
  AmContentNoPaintObject,System.Generics.Collections;



  Type
   TParamOpt = class
      Text:string;

   end;


  Type
   TMessageOpt = class(Tpanel)
   public
      constructor Create(AOwner: TComponent); override;

   end;


  Type
  TamSBOptItem = class
   public
     Control:TWinControl;
     Param: Tobject;
     destructor Destroy; override;
  end;


  Type
  TamSBOptBlock = class(TamHandleObject)
   private
     FOwner: TComponent;
     procedure PanelCreate;
   public
     id:integer;
     Ps_H:integer;
     Panel:Tpanel;
     ListItem:TList<TamSBOptItem>;
     procedure HideContectPost(var Msg:Tmessage) ; message wm_user+1;
     procedure HideContect;
     procedure ShowContect;
     procedure AddItem(Item:TamSBOptItem);
      constructor Create(AOwner: TComponent);
      destructor Destroy; override;
  end;







  Type
   TBoxScrollOptimaizer = class(TamScrollBoxSuper)
    private
      FCounterIDBlock:integer;
      FtimerDeleteBlock:TTimer;
      FChangeHideShow:Boolean;
     protected
           procedure CreateWnd;  override;


         function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;  override;

          Procedure TimerDeleteBlock(S:TObject);
          Procedure DoChangePosition(Old,New:integer);override;
          Procedure DoChangeRange(Old,New:integer);   override;
          Procedure IsNeedShowHideBlock(Old,New:integer); virtual;
          Procedure IsNeedShowHideBlockPost(var Msg:Tmessage);message wm_user+1;
          Procedure IsNeedShowHideBlockExp(Old,New:integer);
     public
     De:boolean;
      PanelBottom:Tpanel;
      PanelTop:Tpanel;
      PanelClient:Tpanel;
      ListBlock:TList<TamSBOptBlock>;

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure  MouseWheelInput( Old,New: Integer);
      procedure AddBlock(Block:TamSBOptBlock);
      procedure HideBlock(Block:TamSBOptBlock);
   end;
implementation


constructor TMessageOpt.Create(AOwner: TComponent);
begin
  inherited create(nil);

   Align:= Albottom;
   //Parent:= PM;
   //Tag:= Cap;
  // Top:=integer.MaxValue;

   AlignWithMargins := True;
   Width := 450;
   self.ParentBackground:=false;
   self.ParentColor:=false;
   Height := 80;
   Margins.Left := 20;
   Margins.Top := 0 ;
   Margins.Right := 20;
   Margins.Bottom := 10 ;
   Align :=alBottom ;
   BevelEdges := [] ;
   BevelOuter := bvNone;
   Color := $0049362E;//  ;
   Constraints.MaxWidth := 400 ;
   Font.Charset := DEFAULT_CHARSET ;
   Font.Color := clWindowText ;
   Font.Height := -27 ;
   Font.Name := 'Tahoma';
   Font.Style := [] ;
   ParentBackground := False ;
   ParentFont := False ;

   Font.Color:=clWhite;


end;


destructor TamSBOptItem.Destroy;
begin


   FreeAndNil(Param);
   inherited;
end;



             {TamSBOptBlock}
constructor TamSBOptBlock.Create(AOwner: TComponent);
begin
    inherited create;
    FOwner:= AOwner;
    ListItem:= TList<TamSBOptItem>.Create;
    PanelCreate;


end;
destructor TamSBOptBlock.Destroy;
var
  I: Integer;
begin
   for I := 0 to ListItem.Count-1 do
   begin
     ListItem[i].Free;
     ListItem[i]:=nil;

   end;
   ListItem.Clear;
   FreeAndNil(ListItem);
   inherited;
end;
procedure TamSBOptBlock.PanelCreate;
var i:integer;
Msg:TMessageOpt;
begin
      Panel:= Tpanel.Create(FOwner);
      Panel.ParentBackground:=false;
      Panel.ParentColor:=false;
      Panel.Align:=albottom;
      Panel.AutoSize:=true;
      Panel.Constraints.MaxWidth:= 400;
      Panel.Top:=integer.MaxValue;
      Panel.Caption:= 'Main';



     // ListHelper:= TList.Create;
     // FVisibleContent:=true;
     // FcounterId:=0;

      //BevelEdges := [] ;
     // BevelOuter := bvNone;

     for I := 0 to ListItem.Count-1 do
     begin
        Msg:= TMessageOpt.Create(FOwner);
        Msg.Caption:= (ListItem[i].Param as TParamOpt).Text;
        ListItem[i].Control:= Msg;
        ListItem[i].Control.Parent:= self.Panel;
        ListItem[i].Control.Top:= integer.MaxValue;
     end;
       
end;
procedure TamSBOptBlock.AddItem(Item:TamSBOptItem);
var aTop:integer;
Up:boolean;
begin

    Up:=false;
    Item.Control.Parent:= self.Panel;
    // HelpPanel.InsertControl(P);

       aTop:= integer.MinValue;
       ListItem.Insert(0,Item);


    Item.Control.Top:= aTop;



end;
procedure TamSBOptBlock.HideContect;
var i:integer;
begin
   Ps_H:=Panel.Height;
  // postmessage(self.Handle,wm_user+1,0,0);
     FreeAndNil( self.Panel );
     //for I := 0 to ListItem.Count-1 do ListItem[i].Control:=nil;
end;

procedure  TamSBOptBlock.HideContectPost(var Msg:Tmessage);
begin



end;
procedure TamSBOptBlock.ShowContect;
begin
    PanelCreate;

end;





         {TBoxScrollOptimaizer}
Procedure TBoxScrollOptimaizer.DoChangePosition(Old,New:integer);
begin

   inherited DoChangePosition(Old,New);






 //  if Old<>New then
 //  DoGetOldBlockMessages(Old,New);
end;
procedure  TBoxScrollOptimaizer.MouseWheelInput( Old,New: Integer);
begin


     if (Old<>New) and (New <= self.Box.VertScrollBar.Range)and (Old <= self.Box.VertScrollBar.Range) then
      IsNeedShowHideBlock(Old,New);
end;
Procedure TBoxScrollOptimaizer.DoChangeRange(Old,New:integer);
begin
 //if Old<>New then
  // SetCorrectSequenceBlock;

  // if Old<>New then
   //IsNeedShowHideBlock(Old,New);

   inherited DoChangeRange(Old,New);
end;
procedure TBoxScrollOptimaizer.AddBlock(Block:TamSBOptBlock);
begin
    if Block=nil then exit;

    inc(FCounterIDBlock);
      Block.Panel.Color:=clred;
    Block.id:=FCounterIDBlock;
    Block.Panel.Align:=alBottom;
    Block.Panel.Top:=integer.MinValue;
    Block.Panel.Parent:= PanelClient;




  //  if PanelClient.Height +Item.Block.Height> Box.ClientHeight then
    //PanelClient.Height:= PanelClient.Height + Item.Block.Height;

    ListBlock.Insert(0,Block);

    PanelBottom.Top:=integer.MaxValue;
end;
Procedure TBoxScrollOptimaizer.IsNeedShowHideBlockExp(Old,New:integer);


  Function ShowedIsNeed(ScrollUping:boolean):boolean;
  var i:integer;
  minId:integer;
  B: TamSBOptBlock;
  begin
      minId:=integer.MaxValue;

     if ScrollUping then
     begin
      for I := 0 to ListBlock.Count-1 do
      begin
         if Assigned( ListBlock[i].Panel) then
         begin
            if i>0 then
            begin
             minId:= i-1;
             B:= ListBlock[minId];
             B.ShowContect;
             B.Panel.Color:=clBlack;
             B.Panel.Align:=alBottom;
             B.Panel.Top:=integer.MinValue;
             B.Panel.Parent:= PanelClient;
             PanelTop.Height:= PanelTop.Height - B.Ps_H;
             PanelBottom.Top:=integer.MaxValue;
            end;
            break;

         end;


      end;

     end
     else
     begin
      for I := ListBlock.Count-1 downto 0 do
      begin
         if Assigned( ListBlock[i].Panel) then
         begin
            if  (i+1<=ListBlock.Count-1) then
            begin
             minId:= i+1;
             B:= ListBlock[minId];
             B.ShowContect;
             B.Panel.Color:=clBlack;
             B.Panel.Align:=alBottom;
             B.Panel.Top:=integer.MaxValue;
             B.Panel.Parent:= PanelClient;
             PanelBottom.Height:= PanelBottom.Height - B.Ps_H;
             PanelBottom.Top:=integer.MaxValue;
             break;
            end;


         end;


      end;
     end;




  end ;





  Function HiderIsNeed(B:TamSBOptBlock;ScrollUping:boolean):boolean;
  var Sh:boolean;
  Tester:integer;
  begin
         REsult:=false;
        Tester:=220;
        if Assigned(B.Panel) then
        begin
            if ScrollUping then
            Sh:= (  PanelTop.Height + B.Panel.Top < Box.ClientHeight+Box.VertScrollBar.Position + Tester)
            else
            Sh:= ( PanelTop.Height + B.Panel.Top+B.Panel.Height > Box.VertScrollBar.Position - Tester);


            if not sh and (B.Panel<>nil)  then
            begin

             B.HideContect;
             De:=true;
             REsult:=true;
             FtimerDeleteBlock.Enabled:=true;
            end;
        end;
  end;
var
  i:integer;
begin




    if New < Old then  //идет скролинг вверх
    begin



       for I := ListBlock.Count-1 downto 0 do
       if  HiderIsNeed(ListBlock[i],True) then
       begin
         PanelBottom.Height:= PanelBottom.Height+  ListBlock[i].Ps_H;

         break;
       end;
        if PanelTop.Top + PanelTop.Height > 0 then ShowedIsNeed(true);
    end
    else if New > Old then  //идет скролинг вниз
    begin


       for I := 0 to ListBlock.Count-1 do
       if  HiderIsNeed(ListBlock[i],False) then
        begin
         PanelTop.Height:= PanelTop.Height+  ListBlock[i].Ps_H;
         break;
       end;

       if PanelBottom.Top < Box.ClientHeight then ShowedIsNeed(False);
    end;


end;
Procedure TBoxScrollOptimaizer.IsNeedShowHideBlockPost(var msg:tmessage);
var Old,New:integer;

begin
    Old:=  msg.WParam;
    New:=msg.LParam;
    IsNeedShowHideBlockExp(Old,New);
    FChangeHideShow:=false;


end;
Procedure TBoxScrollOptimaizer.IsNeedShowHideBlock(Old,New:integer);
begin
   //if not FChangeHideShow then
   begin
     FChangeHideShow:=true;
     PostMessage(self.Handle,wm_user+1,Old,New);
   end;
 //IsNeedShowHideBlockExp(Old,New);
end;



procedure TBoxScrollOptimaizer.HideBlock(Block:TamSBOptBlock);
begin


end;
Procedure TBoxScrollOptimaizer.TimerDeleteBlock(S:TObject);
begin
  de:=false;
  FTimerDeleteBlock.Enabled:=false;

end;
constructor TBoxScrollOptimaizer.Create(AOwner: TComponent);
begin
    inherited create(AOwner);
    De:=false;
    FCounterIDBlock:=-1;
    FtimerDeleteBlock:= Ttimer.Create(self);
    FtimerDeleteBlock.Interval:=50;
    FtimerDeleteBlock.Enabled:=false;
    FtimerDeleteBlock.OnTimer:= TimerDeleteBlock;

    ListBlock:= TList<TamSBOptBlock>.create;
    PanelTop:= Tpanel.Create(self);
    PanelTop.ParentBackground:=false;
    PanelTop.ParentColor:=false;
    PanelTop.Align:=alTop;
    PanelTop.Color:=$00FBBDD1;
    PanelTop.Height:=10;
    PanelTop.Caption:='PanelTop';
    PanelTop.Parent:= Box;

    PanelClient := Tpanel.Create(self);
    PanelClient.ParentBackground:=false;
    PanelClient.ParentColor:=false;
    PanelClient.Align:=alBottom;
    PanelClient.Color:=$00CEFFE7;
    PanelClient.Height:=Box.Height;
    PanelClient.Caption:='PanelClient';
    PanelClient.Parent:= Box;
    PanelClient.AutoSize:=true;


    PanelBottom:= Tpanel.Create(self);
    PanelBottom.ParentBackground:=false;
    PanelBottom.ParentColor:=false;
    PanelBottom.Align:=alBottom;
    PanelBottom.Color:=clSilver;
    PanelBottom.Height:=10;
    PanelBottom.Caption:='PanelBottom';
    PanelBottom.Parent:= Box;




end;
destructor TBoxScrollOptimaizer.Destroy;
var
  I: Integer;
begin
   for I := 0 to ListBlock.Count-1 do
   begin
     ListBlock[i].Free;
     ListBlock[i]:=nil;

   end;
   ListBlock.Clear;
   FreeAndNil(ListBlock);
   inherited;
end;
procedure TBoxScrollOptimaizer.CreateWnd;
begin
   inherited CreateWnd;
   PanelClient.Height:=Box.Height;
end;
function TBoxScrollOptimaizer.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;
begin
   REsult:=  inherited  DoMouseWheel(Shift,WheelDelta,MousePos);
   showmessage('DoMouseWheel');
end;
end.
