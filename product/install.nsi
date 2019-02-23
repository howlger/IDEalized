# Windows installer definition for an Eclipse based application

# required (if not uncomment below) input parameters:
# !define APPNAME "My Application"
# !define APPEXE "eclipse.exe"
# !define APPINI "eclipse.ini"
# !define FOLDER_NAME "my-application"
# !define CONTEXT_MENU "Open in My Application"
# !define DATE "2018-03-30"
# !define INPUT_DIR "c:\my-application"
# !define INSTALLSIZE 123000 # size (in kB)
# !define PUBLISHER "Unknown"


Outfile "${FOLDER_NAME}-${DATE}_install.exe"
Name "${APPNAME} ${DATE}"

BrandingText " "
AddBrandingImage left 12
AddBrandingImage right 12
AddBrandingImage top 60
AddBrandingImage bottom 4

ChangeUI all "${NSISDIR}\Contrib\UIs\sdbarker_tiny.exe"

Icon "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
ShowInstDetails nevershow
InstProgressFlags smooth

#RequestExecutionLevel user ;no elevation needed here

# install directory: %USERPROFILE%\${FOLDER_NAME}
InstallDir "$PROFILE\${FOLDER_NAME}"

#Page directory
Page instfiles

Section

  Var /GLOBAL APPNAMEFULL
  StrCpy $APPNAMEFULL "${APPNAME}"

  # if beta (= file name contains substring "-beta"):
  # - "${INSTDIR}" -> "${APPNAME}-beta"
  # - "${APPNAME}" -> "${APPNAME} BETA"
  Push "$EXEFILE"
  Push "-beta"
  Call StrContains
  Pop $0
  StrCmp $0 "" set_install_dir_end
    StrCpy $INSTDIR "$PROFILE\${FOLDER_NAME}-beta"
    StrCpy $APPNAMEFULL "${APPNAME} BETA"
  set_install_dir_end:

  # output
  SetOutPath $INSTDIR

  # uninstall previous version
  IfFileExists "$INSTDIR\uninstall.exe" 0 noprevious
  ExecWait '"$INSTDIR\uninstall.exe" /S _?=$INSTDIR'
  noprevious:

  # all files
  #SetOverWrite try
  File /r "${INPUT_DIR}\*"

  # uninstall.exe
  WriteUninstaller "$INSTDIR\uninstall.exe"

  # shortcuts
  CreateShortcut "$SMPROGRAMS\$APPNAMEFULL.lnk" "$INSTDIR\${APPEXE}"
  #CreateShortcut "$DESKTOP\$APPNAMEFULL.lnk" "$INSTDIR\${APPEXE}"

  # register uninstaller
  # see http://nsis.sourceforge.net/A_simple_installer_with_start_menu_shortcut_and_uninstaller
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "DisplayName" "$APPNAMEFULL"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "InstallLocation" "$\"$INSTDIR$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "DisplayIcon" "$\"$INSTDIR\${APPEXE}$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "Publisher" "${PUBLISHER}"
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "HelpLink" "$\"${HELPURL}$\""
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "URLUpdateInfo" "$\"${UPDATEURL}$\""
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "URLInfoAbout" "$\"${ABOUTURL}$\""
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "DisplayVersion" "$\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\""
  #WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "VersionMajor" ${VERSIONMAJOR}
  #WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "VersionMinor" ${VERSIONMINOR}
  # there is no option for modifying or repairing the install
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "NoRepair" 1
  # set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$APPNAMEFULL" "EstimatedSize" ${INSTALLSIZE}

  # add "Open with Eclipse" to Windows context menu (HKEY_CLASSES_ROOT\*\shell\Open with Eclipse\command)
  WriteRegStr HKCR "*\shell\${CONTEXT_MENU}\command" "" "$\"$INSTDIR\${APPEXE}$\" --launcher.openFile $\"%1$\""

  #
  Push "-Xshareclasses"             # text to be replaced
  Push "-Xshareclasses:cacheDir=$INSTDIR\_shareclasses_cache" # replace with
  Push "0"                          # replace first occurrences
  Push "1"                          # replace first occurrences
  Push "$INSTDIR\${APPINI}"         # file to replace in
  Call AdvReplaceInFile

SectionEnd

Section "Uninstall"

  # all files but not workspace
  RMDir /r $INSTDIR\configuration
  RMDir /r $INSTDIR\dropins
  RMDir /r $INSTDIR\features
  RMDir /r $INSTDIR\jre
  RMDir /r $INSTDIR\p2
  RMDir /r $INSTDIR\plugins
  RMDir /r $INSTDIR\readme
  RMDir /r $INSTDIR\_shareclasses_cache
  Delete $INSTDIR\.eclipseproduct
  Delete $INSTDIR\artifacts.xml
  Delete $INSTDIR\${APPEXE}
  Delete $INSTDIR\${APPINI}
  Delete $INSTDIR\eclipsec.exe

  # if beta (= install directory ends with "-beta"), remove beta related things
  StrCpy $0 $INSTDIR "" -5
  StrCmp $0 "-beta" uninstall_beta
  # uninstall_non_beta:

    # remove uninstaller from the registry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

    # remove shortcuts
    Delete "$SMPROGRAMS\${APPNAME}.lnk"
    Delete "$DESKTOP\${APPNAME}.lnk"

    Goto uninstall_beta_end
  uninstall_beta:

    # remove uninstaller from the registry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} BETA"

    # remove shortcuts
    Delete "$SMPROGRAMS\${APPNAME} BETA.lnk"
    Delete "$DESKTOP\${APPNAME} BETA.lnk"
  uninstall_beta_end:

  # remove context menu
  DeleteRegKey HKCR "*\shell\${CONTEXT_MENU}"

  # remove uninstaller
  Delete $INSTDIR\uninstall.exe

  # remove install directory if empty
  # see http://nsis.sourceforge.net/Delete_dir_only_if_empty
  StrCpy $0 "$INSTDIR"
  Call un.DeleteDirIfEmpty

SectionEnd

Function un.DeleteDirIfEmpty
  FindFirst $R0 $R1 "$0\*.*"
  strcmp $R1 "." 0 NoDelete
   FindNext $R0 $R1
   strcmp $R1 ".." 0 NoDelete
    ClearErrors
    FindNext $R0 $R1
    IfErrors 0 NoDelete
     FindClose $R0
     Sleep 1000
     RMDir "$0"
  NoDelete:
   FindClose $R0
FunctionEnd

# http://nsis.sourceforge.net/More_advanced_replace_text_in_file
Function AdvReplaceInFile
    Exch $0 ;file to replace in
    Exch
    Exch $1 ;number to replace after
    Exch
    Exch 2
    Exch $2 ;replace and onwards
    Exch 2
    Exch 3
    Exch $3 ;replace with
    Exch 3
    Exch 4
    Exch $4 ;to replace
    Exch 4
    Push $5 ;minus count
    Push $6 ;universal
    Push $7 ;end string
    Push $8 ;left string
    Push $9 ;right string
    Push $R0 ;file1
    Push $R1 ;file2
    Push $R2 ;read
    Push $R3 ;universal
    Push $R4 ;count (onwards)
    Push $R5 ;count (after)
    Push $R6 ;temp file name

      GetTempFileName $R6
      FileOpen $R1 $0 r ;file to search in
      FileOpen $R0 $R6 w ;temp file
       StrLen $R3 $4
       StrCpy $R4 -1
       StrCpy $R5 -1

    loop_read:
     ClearErrors
     FileRead $R1 $R2 ;read line
     IfErrors exit

       StrCpy $5 0
       StrCpy $7 $R2

    loop_filter:
       IntOp $5 $5 - 1
       StrCpy $6 $7 $R3 $5 ;search
       StrCmp $6 "" file_write1
       StrCmp $6 $4 0 loop_filter

    StrCpy $8 $7 $5 ;left part
    IntOp $6 $5 + $R3
    IntCmp $6 0 is0 not0
    is0:
    StrCpy $9 ""
    Goto done
    not0:
    StrCpy $9 $7 "" $6 ;right part
    done:
    StrCpy $7 $8$3$9 ;re-join

    IntOp $R4 $R4 + 1
    StrCmp $2 all loop_filter
    StrCmp $R4 $2 0 file_write2
    IntOp $R4 $R4 - 1

    IntOp $R5 $R5 + 1
    StrCmp $1 all loop_filter
    StrCmp $R5 $1 0 file_write1
    IntOp $R5 $R5 - 1
    Goto file_write2

    file_write1:
     FileWrite $R0 $7 ;write modified line
    Goto loop_read

    file_write2:
     FileWrite $R0 $R2 ;write unmodified line
    Goto loop_read

    exit:
      FileClose $R0
      FileClose $R1

       SetDetailsPrint none
      Delete $0
      Rename $R6 $0
      Delete $R6
       SetDetailsPrint lastused

    Pop $R6
    Pop $R5
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
    Pop $9
    Pop $8
    Pop $7
    Pop $6
    Pop $5
    ;These values are stored in the stack in the reverse order they were pushed
    Pop $0
    Pop $1
    Pop $2
    Pop $3
    Pop $4
FunctionEnd

# https://nsis.sourceforge.io/StrContains
Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR

Function StrContains
  Exch $STR_NEEDLE
  Exch 1
  Exch $STR_HAYSTACK
  ; Uncomment to debug
  ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
    StrCpy $STR_RETURN_VAR ""
    StrCpy $STR_CONTAINS_VAR_1 -1
    StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
    StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
    loop:
      IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
      StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
      StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
      StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
      Goto loop
    found:
      StrCpy $STR_RETURN_VAR $STR_NEEDLE
      Goto done
    done:
   Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
   Exch $STR_RETURN_VAR
FunctionEnd