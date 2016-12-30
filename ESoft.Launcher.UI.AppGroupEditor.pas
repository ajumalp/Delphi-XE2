Unit ESoft.Launcher.UI.AppGroupEditor;

{ ---------------------------------------------------------- }
{ Developed by Muhammad Ajmal p }
{ ajumalp@gmail.com }
{ ---------------------------------------------------------- }

Interface

Uses
   Winapi.Windows,
   Winapi.Messages,
   System.SysUtils,
   System.Variants,
   System.Classes,
   Vcl.Graphics,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.Dialogs,
   Vcl.StdCtrls,
   Vcl.ExtCtrls,
   Vcl.FileCtrl,
   ESoft.Launcher.Application,
   Vcl.Buttons,
   Vcl.Samples.Spin;

Type
   TFormAppGroupEditor = Class(TForm)
      GroupBox2: TGroupBox;
      Label2: TLabel;
      sBtnBrowseAppSource: TSpeedButton;
      Label3: TLabel;
      sBtnBrowseAppDest: TSpeedButton;
      Label4: TLabel;
      Label5: TLabel;
      edtAppSource: TButtonedEdit;
      edtAppDest: TButtonedEdit;
      edtFileMask: TButtonedEdit;
      edtExeName: TButtonedEdit;
      btnCancel: TButton;
      btnOK: TButton;
      Label1: TLabel;
      edtGroupName: TButtonedEdit;
      Label6: TLabel;
      cbFixedParams: TComboBox;
      chkCreateFolder: TCheckBox;
      cbGroupType: TComboBox;
      Label7: TLabel;
      cbDisplayLabel: TComboBox;
      grpBranching: TGroupBox;
      chkMajor: TCheckBox;
      chkMinor: TCheckBox;
      chkRelease: TCheckBox;
      edtPrefix: TLabeledEdit;
      edtSufix: TLabeledEdit;
      sEdtMainBranch: TSpinEdit;
      Label8: TLabel;
      Label9: TLabel;
      sEdtNoOfBuilds: TSpinEdit;
      Label10: TLabel;
      sEdtCurrBranch: TSpinEdit;
      chkCreateBranchFolder: TCheckBox;
      chkSkipRecent: TCheckBox;
      Procedure sBtnBrowseAppSourceClick(Sender: TObject);
      Procedure btnOKClick(Sender: TObject);
      Procedure FormActivate(Sender: TObject);
      Procedure edtAppSourceRightButtonClick(Sender: TObject);
      Procedure edtGroupNameKeyPress(Sender: TObject; Var Key: Char);
      Procedure edtGroupNameEnter(Sender: TObject);
      Procedure edtGroupNameChange(Sender: TObject);
      Procedure FormCreate(Sender: TObject);
      Procedure chkMajorClick(Sender: TObject);
      Procedure chkCreateFolderClick(Sender: TObject);
      procedure cbGroupTypeChange(Sender: TObject);
      procedure edtExeNameChange(Sender: TObject);
      procedure edtAppDestChange(Sender: TObject);
      procedure edtFileMaskChange(Sender: TObject);
   Private
      // Private declarations. Variables/Methods can be access inside this class and other class in the same unit. { Ajmal }
   Strict Private
      // Strict Private declarations. Variables/Methods can be access inside this class only. { Ajmal }
      FTempExecutable, FTempDestFolder, FTempFileMask: String;
      FInitialized: Boolean;
      FUpdateFileMakWithName: Boolean;
      FAppGroup: TEApplicationGroup;
   Public
      { Public declarations }
      Constructor Create(aOwner: TComponent; Const aAppGroup: TEApplicationGroup = Nil); Reintroduce;

      Class Function CreatGroupFromFile(Const aFileName: String = ''): TModalResult;
      Procedure LoadData;

   Published
      Property AppGroup: TEApplicationGroup Read FAppGroup;
   End;

Var
   FormAppGroupEditor: TFormAppGroupEditor;

Implementation

{$R *.dfm}

Uses
   UnitMDIMain, 
   ESoft.Utils;

Type
   hTStringList = Class Helper For TStringList
   Public
      Function AddText(Const aText: String): String;
      Function InCaseSensitiveIndexOf(Const aText: String): Integer;
   End;

Procedure TFormAppGroupEditor.btnOKClick(Sender: TObject);
Begin
   If Not Assigned(FAppGroup) Then
   Begin
      If Trim(edtGroupName.Text) = '' Then
      Begin
         MessageDlg('Name cannot be empty', mtError, [mbOK], 0);
         Abort;
      End;
      Try
         FAppGroup := FormMDIMain.AppGroups.AddItem(edtGroupName.Text);
      Except
         On Ex:Exception Do
         Begin
            edtGroupName.SetFocus;
            Raise;
         End;
      End;
   End;
   AppGroup.DisplayLabel := FormMDIMain.DisplayLabels.AddText(cbDisplayLabel.Text);
   AppGroup.FixedParameter := cbFixedParams.Text;
   AppGroup.ExecutableName := edtExeName.Text;
   AppGroup.Name := edtGroupName.Text;
   AppGroup.SourceFolder := edtAppSource.Text;
   AppGroup.DestFolder := edtAppDest.Text;
   AppGroup.FileMask := edtFileMask.Text;
   AppGroup.CreateFolder := chkCreateFolder.Enabled And chkCreateFolder.Checked;
   AppGroup.SkipFromRecent := chkSkipRecent.Checked;
   AppGroup.GroupType := cbGroupType.ItemIndex;
   AppGroup.IsMajorBranching := chkMajor.Checked;
   AppGroup.IsMinorBranching := chkMinor.Checked;
   AppGroup.IsReleaseBranching := chkRelease.Checked;
   AppGroup.BranchingPrefix := edtPrefix.Text;
   AppGroup.BranchingSufix := edtSufix.Text;
   AppGroup.MainBranch := sEdtMainBranch.Value;
   AppGroup.NoOfBuilds := sEdtNoOfBuilds.Value;
   AppGroup.CurrentBranch := sEdtCurrBranch.Value;
   AppGroup.CreateBranchFolder := chkCreateBranchFolder.Checked;

   AppGroup.SaveData(FormMDIMain.ParentFolder + cGroup_INI);
   ModalResult := mrOk;
End;

procedure TFormAppGroupEditor.cbGroupTypeChange(Sender: TObject);
begin
   chkCreateFolder.Enabled := cbGroupType.ItemIndex = cGroupType_ZipFiles;
   grpBranching.Enabled := cbGroupType.ItemIndex = cGroupType_ZipFiles;

   edtFileMask.Enabled := cbGroupType.ItemIndex <> cGroupType_Application;
   If Not edtFileMask.Enabled Then
      edtFileMask.Clear
   Else
      edtFileMask.Text := FTempFileMask;

   edtAppDest.Enabled := cbGroupType.ItemIndex = cGroupType_ZipFiles;
   If Not edtAppDest.Enabled Then
      edtAppDest.Clear
   Else
      edtAppDest.Text := FTempDestFolder;

   edtExeName.Enabled := cbGroupType.ItemIndex <> cGroupType_Folder;
   If Not edtExeName.Enabled Then
      edtExeName.Clear
   Else
      edtExeName.Text := FTempExecutable;
end;

Procedure TFormAppGroupEditor.chkCreateFolderClick(Sender: TObject);
Begin
   chkCreateBranchFolder.Enabled := chkCreateFolder.Checked And edtPrefix.Enabled;
End;

Procedure TFormAppGroupEditor.chkMajorClick(Sender: TObject);
Begin
   edtPrefix.Enabled := chkMajor.Checked Or chkMinor.Checked Or chkRelease.Checked;
   edtSufix.Enabled := edtPrefix.Enabled;
   sEdtMainBranch.Enabled := edtPrefix.Enabled;
   sEdtCurrBranch.Enabled := edtPrefix.Enabled;
   sEdtNoOfBuilds.Enabled := edtPrefix.Enabled;
   chkCreateFolderClick(Nil);
End;

Constructor TFormAppGroupEditor.Create(aOwner: TComponent; Const aAppGroup: TEApplicationGroup);
Begin
   FInitialized := False;
   Inherited Create(aOwner);

   cbFixedParams.Clear;
   cbFixedParams.Items.Add(cParameterPick);

   FAppGroup := aAppGroup;
   edtGroupName.Enabled := Not Assigned(FAppGroup);
End;

Class Function TFormAppGroupEditor.CreatGroupFromFile(Const aFileName: String): TModalResult;
var
   bIsDirectory: Boolean;
   varAppGroup: TEApplicationGroup;
begin
   Result := mrNone;
   bIsDirectory := False;
   Try
      varAppGroup := FormMDIMain.AppGroups.Items[ExtractFileName(aFileName)];
   Except
      varAppGroup := Nil;
   End;

   FormAppGroupEditor := TFormAppGroupEditor.Create(FormMDIMain, varAppGroup);
   Try
      If (varAppGroup = Nil) And (aFileName <> '') Then
      Begin
         bIsDirectory := DirectoryExists(aFileName);
         With FormAppGroupEditor Do
         Begin
            edtAppDest.Clear;
            cbGroupType.ItemIndex := cGroupType_Folder;
            edtGroupName.Text := ExtractFileName(aFileName);
            If bIsDirectory Then
            Begin
               edtAppSource.Text := aFileName;
               chkCreateFolder.Checked := False;
               chkSkipRecent.Checked := True;
            End
            Else
            Begin
               edtFileMask.Clear;
               cbGroupType.ItemIndex := cGroupType_Application;
               edtExeName.Text := edtGroupName.Text;
               edtAppSource.Text := ExtractFilePath(aFileName);
               cbFixedParams.ItemIndex := -1;
            End;
            cbGroupTypeChange(Nil);
         End;
      End;
      Result := FormAppGroupEditor.ShowModal;
   Finally
     FreeAndNil(FormAppGroupEditor);
   End;
end;

procedure TFormAppGroupEditor.edtAppDestChange(Sender: TObject);
begin
   If Trim(edtAppDest.Text) <> '' Then
      FTempDestFolder := edtAppDest.Text;
end;

Procedure TFormAppGroupEditor.edtAppSourceRightButtonClick(Sender: TObject);
Begin
   TButtonedEdit(Sender).Text := '';
End;

procedure TFormAppGroupEditor.edtExeNameChange(Sender: TObject);
begin
   If Trim(edtExeName.Text) <> '' Then
      FTempExecutable := edtExeName.Text;
end;

procedure TFormAppGroupEditor.edtFileMaskChange(Sender: TObject);
begin
   If Trim(edtFileMask.Text) <> '' Then
      FTempFileMask := edtFileMask.Text;
end;

Procedure TFormAppGroupEditor.edtGroupNameChange(Sender: TObject);
Begin
   If FUpdateFileMakWithName Then
      edtFileMask.Text := edtGroupName.Text;
End;

Procedure TFormAppGroupEditor.edtGroupNameEnter(Sender: TObject);
Begin
   FUpdateFileMakWithName := (edtFileMask.Text = '') Or (edtFileMask.Text = edtGroupName.Text);
End;

Procedure TFormAppGroupEditor.edtGroupNameKeyPress(Sender: TObject; Var Key: Char);
Begin
   If Not(key In ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', ' ', #46, #8]) Then
      Abort;
End;

Procedure TFormAppGroupEditor.FormActivate(Sender: TObject);
Begin
   If Not FInitialized Then
   Begin
      FInitialized := True;
      If Assigned(FAppGroup) Then
         LoadData;
   End;
End;

Procedure TFormAppGroupEditor.FormCreate(Sender: TObject);
Begin
   cbDisplayLabel.Items := FormMDIMain.DisplayLabels;
   FTempExecutable := edtExeName.Text;
   FTempDestFolder := edtAppDest.Text;
   FTempFileMask := edtFileMask.Text;
End;

Procedure TFormAppGroupEditor.LoadData;
Begin
   cbDisplayLabel.ItemIndex := cbDisplayLabel.Items.IndexOf(AppGroup.DisplayLabel);
   cbFixedParams.Text := AppGroup.FixedParameter;
   edtExeName.Text := AppGroup.ExecutableName;
   edtGroupName.Text := AppGroup.Name;
   edtAppSource.Text := AppGroup.SourceFolder;
   edtAppDest.Text := AppGroup.DestFolder;
   edtFileMask.Text := AppGroup.FileMask;
   chkCreateFolder.Checked := AppGroup.CreateFolder;
   chkSkipRecent.Checked := AppGroup.SkipFromRecent;
   cbGroupType.ItemIndex := AppGroup.GroupType;
   chkMajor.Checked := AppGroup.IsMajorBranching;
   chkMinor.Checked := AppGroup.IsMinorBranching;
   chkRelease.Checked := AppGroup.IsReleaseBranching;
   edtPrefix.Text := AppGroup.BranchingPrefix;
   edtSufix.Text := AppGroup.BranchingSufix;
   sEdtMainBranch.Value := AppGroup.MainBranch;
   sEdtNoOfBuilds.Value := AppGroup.NoOfBuilds;
   sEdtCurrBranch.Value := AppGroup.CurrentBranch;
   chkCreateBranchFolder.Checked := AppGroup.CreateBranchFolder;

   cbGroupTypeChange(Nil);
End;

Procedure TFormAppGroupEditor.sBtnBrowseAppSourceClick(Sender: TObject);
Var
   sPath: String;
Begin
   If SelectDirectory('Select a folder', '', sPath, [sdNewFolder, sdShowEdit], Self) Then
   Begin
      If Sender = sBtnBrowseAppSource Then
      Begin
         edtAppSource.Text := sPath;
         If edtAppDest.Text = '' Then
            edtAppDest.Text := sPath;
      End
      Else If Sender = sBtnBrowseAppDest Then
         edtAppDest.Text := sPath;
   End;
End;

{ hTStringList }

Function hTStringList.AddText(Const aText: String): String;
Var
   iIndex: Integer;
Begin
   iIndex := InCaseSensitiveIndexOf(aText);
   If iIndex = -1 Then
      iIndex := Add(aText);
   Result := Self[iIndex];
End;

Function hTStringList.InCaseSensitiveIndexOf(Const aText: String): Integer;
Var
   iCntr: Integer;
Begin
   For iCntr := 0 To Pred(Count) Do
   Begin
      If SameText(aText, Self[iCntr]) Then
         Exit(iCntr)
   End;
   Result := -1;
End;

End.
