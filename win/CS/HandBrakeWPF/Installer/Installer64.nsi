/*  Resources.Designer.cs $

 	   This file is part of the HandBrake source code.
 	   Homepage: <http://handbrake.fr/>.
 	   It may be used under the terms of the GNU General Public License. */

; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "HandBrake"
!define PRODUCT_VERSION "0.10.5"
!define PRODUCT_VERSION_NUMBER "0.10.5"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Handbrake.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

;Required .NET framework
!define MIN_FRA_MAJOR "4"
!define MIN_FRA_MINOR "0"
!define MIN_FRA_BUILD "*"

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "handbrakepineapple.ico"
!define MUI_UNICON "handbrakepineapple.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "doc\COPYING"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
;!define MUI_FINISHPAGE_RUN "$INSTDIR\Handbrake.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "HandBrake-${PRODUCT_VERSION_NUMBER}-Win_GUI.exe"

!include WordFunc.nsh
!insertmacro VersionCompare
!include LogicLib.nsh

InstallDir "$PROGRAMFILES64\Handbrake"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Var InstallDotNET

Function .onInit

  ; Begin Only allow one version
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
  Pop $R0

  StrCmp $R0 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running." /SD IDOK
  Abort

  ;Remove previous version
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}\" \
  "UninstallString"
  StrCmp $R0 "" done

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${PRODUCT_NAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to continue." /SD IDOK \
  IDOK uninst
  goto done

 ;Run the uninstaller
  uninst:
   IfSilent +3
   Exec $INSTDIR\uninst.exe
   goto done
   Exec '"$INSTDIR\uninst.exe" /S'
  done:
FunctionEnd

Section "Handbrake" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer

  ; Begin Check .NET version
  StrCpy $InstallDotNET "No"
  Call CheckFramework
     StrCmp $0 "1" +3
        StrCpy $InstallDotNET "Yes"
      MessageBox MB_OK|MB_ICONINFORMATION "${PRODUCT_NAME} requires that the .NET Framework 4.0 Client Profile is installed. The latest .NET Framework will be downloaded and installed automatically during installation of ${PRODUCT_NAME}." /SD IDOK
     Pop $0

  ; Get .NET if required
  ${If} $InstallDotNET == "Yes"
     SetDetailsView hide
     inetc::get /caption "Downloading .NET Framework 4.0" /canceltext "Cancel" "http://www.microsoft.com/downloads/info.aspx?na=41&srcfamilyid=e5ad0459-cbcc-4b4f-97b6-fb17111cf544&srcdisplaylang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2f5%2f6%2f2%2f562A10F9-C9F4-4313-A044-9C94E0A8FAC8%2fdotNetFx40_Client_x86_x64.exe" "$INSTDIR\dotnetfx.exe" /end
     Pop $1

     ${If} $1 != "OK"
           Delete "$INSTDIR\dotnetfx.exe"
           Abort "Installation cancelled, ${PRODUCT_NAME} requires the .NET 4.0 Framework"
     ${EndIf}

     ExecWait "$INSTDIR\dotnetfx.exe"
     Delete "$INSTDIR\dotnetfx.exe"

     SetDetailsView show
  ${EndIf}
  
  ; Install Files
  File "Handbrake.exe"
  File "HandBrakeCLI.exe"
  CreateDirectory "$SMPROGRAMS\Handbrake"
  CreateShortCut "$SMPROGRAMS\Handbrake\Handbrake.lnk" "$INSTDIR\Handbrake.exe"
  CreateShortCut "$DESKTOP\Handbrake.lnk" "$INSTDIR\Handbrake.exe"
  File "*.dll"
  File "*.config"
  File "*.xml"
  File "*.pdb"

  ; Copy the standard doc set into the doc folder
  SetOutPath "$INSTDIR\doc"
  SetOverwrite ifnewer
  File "doc\*.*"

  ; Copy the standard fonts config set into the fonts folder
  SetOutPath "$INSTDIR\fonts"
  SetOverwrite ifnewer
  File /r "fonts\*.*"

  
SectionEnd

Section -AdditionalIcons
  CreateShortCut "$SMPROGRAMS\Handbrake\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Handbrake.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Handbrake.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer." /SD IDOK
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" /SD IDYES IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\uninst.exe"
  
  Delete "$INSTDIR\*.*"
  Delete "$INSTDIR\doc\*.*"
  Delete "$INSTDIR\fonts\*.*"
  Delete "$INSTDIR\fonts\conf.d\*.*"
  Delete "$INSTDIR\fonts\conf.avail\*.*"
  RMDir  "$INSTDIR\doc"
  RMDIR  "$INSTDIR\fonts\conf.d"
  RMDIR  "$INSTDIR\fonts\conf.avail"
  RMDIR  "$INSTDIR\fonts"
  Delete "$SMPROGRAMS\Handbrake\Uninstall.lnk"
  Delete "$DESKTOP\Handbrake.lnk"
  Delete "$SMPROGRAMS\Handbrake\Handbrake.lnk"
  RMDir  "$SMPROGRAMS\Handbrake"
  RMDir  "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

;Check for .NET framework
Function CheckFrameWork

   ;Save the variables in case something else is using them
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $R1
  Push $R2
  Push $R3
  Push $R4
  Push $R5
  Push $R6
  Push $R7
  Push $R8

  StrCpy $R5 "0"
  StrCpy $R6 "0"
  StrCpy $R7 "0"
  StrCpy $R8 "0.0.0"
  StrCpy $0 0

  loop:

  ;Get each sub key under "SOFTWARE\Microsoft\NET Framework Setup\NDP"
  EnumRegKey $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP" $0
  StrCmp $1 "" done ;jump to end if no more registry keys
  IntOp $0 $0 + 1
  StrCpy $2 $1 1 ;Cut off the first character
  StrCpy $3 $1 "" 1 ;Remainder of string

  ;Loop if first character is not a 'v'
  StrCmpS $2 "v" start_parse loop

  ;Parse the string
  start_parse:
  StrCpy $R1 ""
  StrCpy $R2 ""
  StrCpy $R3 ""
  StrCpy $R4 $3

  StrCpy $4 1

  parse:
  StrCmp $3 "" parse_done ;If string is empty, we are finished
  StrCpy $2 $3 1 ;Cut off the first character
  StrCpy $3 $3 "" 1 ;Remainder of string
  StrCmp $2 "." is_dot not_dot ;Move to next part if it's a dot

  is_dot:
  IntOp $4 $4 + 1 ; Move to the next section
  goto parse ;Carry on parsing

  not_dot:
  IntCmp $4 1 major_ver
  IntCmp $4 2 minor_ver
  IntCmp $4 3 build_ver
  IntCmp $4 4 parse_done

  major_ver:
  StrCpy $R1 $R1$2
  goto parse ;Carry on parsing

  minor_ver:
  StrCpy $R2 $R2$2
  goto parse ;Carry on parsing

  build_ver:
  StrCpy $R3 $R3$2
  goto parse ;Carry on parsing

  parse_done:

  IntCmp $R1 $R5 this_major_same loop this_major_more
  this_major_more:
  StrCpy $R5 $R1
  StrCpy $R6 $R2
  StrCpy $R7 $R3
  StrCpy $R8 $R4

  goto loop

  this_major_same:
  IntCmp $R2 $R6 this_minor_same loop this_minor_more
  this_minor_more:
  StrCpy $R6 $R2
  StrCpy $R7 R3
  StrCpy $R8 $R4
  goto loop

  this_minor_same:
  IntCmp $R3 $R7 loop loop this_build_more
  this_build_more:
  StrCpy $R7 $R3
  StrCpy $R8 $R4
  goto loop

  done:

  ;Have we got the framework we need?
  IntCmp $R5 ${MIN_FRA_MAJOR} max_major_same fail OK
  max_major_same:
  IntCmp $R6 ${MIN_FRA_MINOR} max_minor_same fail OK
  max_minor_same:
  IntCmp $R7 ${MIN_FRA_BUILD} OK fail OK

  ;Version on machine is greater than what we need
  OK:
  StrCpy $0 "1"
  goto end

  fail:
  StrCmp $R8 "0.0.0" end


  end:

  ;Pop the variables we pushed earlier
  Pop $R8
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $4
  Pop $3
  Pop $2
  Pop $1
FunctionEnd