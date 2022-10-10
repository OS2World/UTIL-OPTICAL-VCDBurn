/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         __VXREXX____APPENDS__
*/
__VXREXX____APPENDS__:
/*
*/
return
/*:VRX         CB_2PassEncode_Click
*/
CB_2PassEncode_Click: 
  set = VRGet( "CB_2PassEncode", "Set" )
  if set=1 then do
    ok = VRSet( "EF_ffmpegPar2", "Visible", 1 )
    ok = VRSet( "DT_14", "Visible", 1 )
  end
  else
  do
    ok = VRSet( "EF_ffmpegPar2", "Visible", 0 )
    ok = VRSet( "DT_14", "Visible", 0 )
  end
return

/*:VRX         CB_BurnIMG_Click
*/
CB_BurnIMG_Click: 
  call CheckChecked
return

/*:VRX         CB_CreateVCD_Click
*/
CB_CreateVCD_Click: 
  call CheckChecked
return

/*:VRX         CB_Transcode_Click
*/
CB_Transcode_Click: 
  call CheckChecked
return

/*:VRX         CheckChecked
*/
CheckChecked: 
  setTrans = VRGet( "CB_Transcode", "Set" )
  setCrVCD = VRGet( "CB_CreateVCD", "Set" )
  setBrIMG = VRGet( "CB_BurnIMG", "Set" )
  if (setTrans=0) & (setCrVCD=0) & (setBrIMG=0) then
    ok = VRSet( "PB_Start", "Enabled", 0 )
  else do
    if (setTrans=1) | (setCrVCD=1) then do
      if (VRGet( "LB_MPGFiles", "Count" )>0) then
        ok = VRSet( "PB_Start", "Enabled", 1 )
      else
        ok = VRSet( "PB_Start", "Enabled", 0 )
    end
    else
      ok = VRSet( "PB_Start", "Enabled", 1 )
  end
  if (setCrVCD=1) | (setBrIMG=1) then
    if (VRGet( "Combo_Name", "Value" )='') then
      ok = VRSet( "PB_Start", "Enabled", 0 )
return

/*:VRX         Combo_Name_Change
*/
Combo_Name_Change: 
  call CheckChecked
  VCDName = VRGet( "Combo_Name", Value )
  logfile=structpath||VCDName||'_log.txt'
  ok = VRSet( "PB_logshow", "Enabled", VRFileExists(logfile) )
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         GetFileSize
*/
GetFileSize: 
  nF=1
  checkfile = ''
  CheckSize = 0
  do ARG()
    checkfile = checkfile||ARG(nF)
    nF = nF+1
  end
  if pos('"',checkfile) <> 0 then
    checkname = substr(checkfile,2,length(checkfile)-2)
  else
    checkname = checkfile
  checkname = Translate(VRParseFileName( checkname, "NE" ))

  'dir '||checkfile||' > '||tmppath'\dirout.lst'
  do while lines(tmppath'\dirout.lst') <> 0
    RLine = Translate(LINEIN(tmppath'\dirout.lst'))
    if (pos(':\',RLine) = 0) & (pos(checkname,RLine) <> 0) THEN do
      CheckSize = SPACE(TRANSLATE(WORD(RLine,3),'','.'),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'','.'),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'',','),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'',','),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'',"'"),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'',"'"),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'','ï'),0)
      CheckSize = SPACE(TRANSLATE(CheckSize,'','ï'),0)
      if WORD(RLine,4) = 'K' then
        CheckSize = CheckSize / 1024
      else      
        CheckSize = CheckSize / 1048576
    end
  end
  ok=stream(tmppath'\dirout.lst','c','close')
  'del '||tmppath'\dirout.lst'
return CheckSize
/*:VRX         GetFreeDiskSize
*/
GetFreeDiskSize: 
ARG LW
if LW = '' then LW = left(directory(),2)
driveinfo = SysDriveInfo(LW)
freesize = word(driveinfo,2) / 1048576
return freesize

/*:VRX         GetProcess
*/
GetProcess: 
  program = Arg(1)
  progid = 0
  pslist. = ''
  if PRProcessList(pslist) <> "ERROR" then do
    nP = 0
    do pslist.0
      nP = nP +1
      if pos(program,pslist.nP.name) <> 0 then do
        progid = pslist.nP.pid
        leave
      end
    end
  end
return progid
/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         InErrIgnoreList
*/
InErrIgnoreList: 
  retvalue = 1
  sText = ARG(1)
  sListe = errorignore
  counter = 0
  posend = pos('0d0a'x,sListe)      /* crlf */
  do while (posend > 0)             /* parse the ignore list */
    counter = counter + 1
    stemText.counter = substr(sListe,1,posend-1)
    sliste = delstr(sListe,1,posend+1)
    posend = pos('0d0a'x,sListe)
  end
  if length(sListe) > 0 then do     /* last line has no crlf at the end */
    counter = counter + 1
    stemText.counter = sListe
  end
  stemText.0 = counter
  counter = 0
  do stemText.0                     /* check occurence in output line of dvddao */
    counter = counter + 1
    if pos(stemText.counter,sText) <> 0 then do
      retValue = 0
      leave
    end
  end 
return retValue
/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         Logshow_Close
*/
Logshow_Close: 
  font = VRGet( "LB_logshow", "Font" )  
  if font <> fontlogwin then do
    ok = VRSetIni( "VCDVIDEO", "fontlogwin", font, ActDir"\VCDBURN.INI" )
    fontwin = font
  end
  call Logshow_Fini
return

/*:VRX         Logshow_Create
*/
Logshow_Create: 
  call Logshow_Init
  fontlogwin = VRGetIni( "VCDVIDEO", "fontlogwin", ActDir"\VCDBURN.INI", "NoClose" )
  if fontlogwin <> '' then
    ok = VRSet( "LB_logshow", "Font", fontlogwin )
  LLine = linein(logfile,1,0)
  do until lines(logfile) = 0
    LLine = linein(logfile)
    position = VRMethod( "LB_logshow", "AddString", LLine,  )
  end
  ok = lineout(logfile)
  call stream logfile "c" "Close"
return

/*:VRX         Logshow_Fini
*/
Logshow_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         Logshow_Init
*/
Logshow_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         MainWin_Close
*/
MainWin_Close:
  font = VRGet( "LB_Output", "Font" )
  if font <> fontshortlog then 
    ok = VRSetIni( "VCDVIDEO", "fontshortlog", font, ActDir"\VCDBURN.INI", "NoClose" )
  font = VRGet( "LB_MPGFiles", "Font" )  
  if font <> fontfilelist then 
    ok  = VRSetIni( "VCDVIDEO", "fontfilelist", font, ActDir"\VCDBURN.INI", "NoClose" )
  ok= VRSetIni("VCDVIDEO", "initialpath", initialpath, ActDir"\VCDBURN.INI" )
  call Quit
return

/*:VRX         MainWin_Create
*/
MainWin_Create: 
  call rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
  call RxFuncAdd 'PRLoadFuncs', 'PR1UTIL', 'PRLoadFuncs'
  call PRLoadFuncs
  ok = VRRedirectStdIO( "On" )
  tmppath = value( 'TMP', , 'OS2ENVIRONMENT')
  ActDir= VRCurrDrive()||VRCurrDir(VRCurrDrive())
/* read ini settings */
  ffmpegpath= VRGetIni("VCDVIDEO", "ffmpegpath", ActDir"\VCDBURN.INI", "NoClose" )
  encodepath= VRGetIni("VCDVIDEO", "encodepath", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegpar1= VRGetIni("VCDVIDEO", "ffmpegpar1", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegpar2= VRGetIni("VCDVIDEO", "ffmpegpar2", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegrate= VRGetIni("VCDVIDEO", "ffmpegrate", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegaurate= VRGetIni("VCDVIDEO", "ffmpegaurate", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegxvrate= VRGetIni("VCDVIDEO", "ffmpegxvrate", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegxaurate= VRGetIni("VCDVIDEO", "ffmpegxaurate", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpeginterlace= VRGetIni("VCDVIDEO", "ffmpeginterlace", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegdeinterlace= VRGetIni("VCDVIDEO", "ffmpegdeinterlace", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpeg2pass= VRGetIni("VCDVIDEO", "ffmpeg2pass", ActDir"\VCDBURN.INI", "NoClose" )
  ffmpegsys= VRGetIni("VCDVIDEO", "ffmpegsys", ActDir"\VCDBURN.INI", "NoClose" )
  if (ffmpegsys <> "auto") & (ffmpegsys <> "pal") & (ffmpegsys <> "ntsc") & (ffmpegsys <> "film") then ffmpegsys = "auto"
  vcdimagerpath= VRGetIni("VCDVIDEO", "vcdimagerpath", ActDir"\VCDBURN.INI", "NoClose" )
  vcdimagerpar= VRGetIni("VCDVIDEO", "vcdimagerpar", ActDir"\VCDBURN.INI", "NoClose" )
  cdrdaopath= VRGetIni("VCDVIDEO", "cdrdaopath", ActDir"\VCDBURN.INI", "NoClose" )
  cdrdaopar= VRGetIni("VCDVIDEO", "cdrdaopar", ActDir"\VCDBURN.INI", "NoClose" )
  cdrdevice= VRGetIni("VCDVIDEO", "cdrdevice", ActDir"\VCDBURN.INI", "NoClose" )
  cdrdriver= VRGetIni("VCDVIDEO", "cdrdriver", ActDir"\VCDBURN.INI", "NoClose" )
  if length(cdrdriver) = 0 then
    cdrdriver = "generic-mmc"
  errorignore= VRGetIni("VCDVIDEO", "errorignore", ActDir"\VCDBURN.INI", "NoClose" )
  if pos("Buffer underrun",errorignore) = 0 then
    if length(errorignore) = 0 then
      errorignore="Buffer underrun"
    else  
      errorignore=errorignore||"0d0a"x||"Buffer underrun"
  cdrspeed= VRGetIni("VCDVIDEO", "cdrspeed", ActDir"\VCDBURN.INI", "NoClose" )
  structpath= VRGetIni("VCDVIDEO", "structpath", ActDir"\VCDBURN.INI", "NoClose" )
  delmpgfiles=VRGetIni("VCDVIDEO", "delmpgfiles", ActDir"\VCDBURN.INI", "NoClose" )
  delimage=VRGetIni("VCDVIDEO", "delimage", ActDir"\VCDBURN.INI", "NoClose" )
  dellogfile=VRGetIni("VCDVIDEO", "dellogfile", ActDir"\VCDBURN.INI", "NoClose" )
  initialpath=VRGetIni("VCDVIDEO", "initialpath", ActDir"\VCDBURN.INI", "NoClose" )
  fontshortlog = VRGetIni( "VCDVIDEO", "fontshortlog", ActDir"\VCDBURN.INI", "NoClose" )
  if fontshortlog <> '' then
    ok = VRSet( "LB_Output", "Font", fontshortlog )
  fontfilelist = VRGetIni( "VCDVIDEO", "fontfilelist", ActDir"\VCDBURN.INI" )
  if fontfilelist <> '' then
    ok = VRSet( "LB_MPGFiles", "Font", fontfilelist )  
  mainTitle = 'Burn (S)VCD video for eCs and OS/2'
  call ReadFolders
  call SetLanguage
  call CheckChecked
return
/*:VRX         ParseOutcdrdao
*/
ParseOutcdrdao: 
  parse arg aOutType 
  call SysSleep 1
  DO forever
    call SysSleep 0.2
    RLine=''
    IF QUEUED()\=0 THEN Do
      RLine = LINEIN("QUEUE:")      
      IF RLine='' THEN RLine=' '
    END
    if (pos("Info : Unlocking media...",RLine) \= 0) then do
      leave
    end
    if (pos("DONEACTION",RLine) \= 0) then do
      leave
    end

    if (aOutType = 'Blank') then do
      if (pos("ERROR:",RLine) <> 0) & (InErrIgnoreList(RLine) <> 0) then do
        error = 1
        leave        
      end
    end

  end

return

/*:VRX         ParseOutput
*/
ParseOutput:
  parse arg aOutType, aMBComplete 
  ok = VRSet( "MainWin", "HintText", "Working, to cancel close the VIO program and wait a moment." )
  ok = VRSet( "DT_MBReady", "Caption", "" )
  ok = VRSet( "DT_MBAll", "Caption", "" )

  breaked=0
  /* Initialize variables */
  forcount=0
  Factor = 1

  call SysSleep 1
  DO forever
    call SysSleep 0.1
    RLine=''
    IF QUEUED()\=0 THEN Do
      RLine = LINEIN("QUEUE:")      
      IF RLine='' THEN RLine=' '
      else forcount = 0
    END

    if (pos("DONEACTION",RLine) \= 0) then do
      leave
    end

    if Rline <> ' ' then call LINEOUT logfile, RLine

    if (aOutType = 'Bitrate') then do
      if (pos("bitrate:",RLine) \= 0) then do
        posstart = pos("bitrate:",RLine)+9
        posend = pos("bitrate:",RLine)+13
        bitrate = strip(substr(RLine,posstart,posend-posstart),'L')
        if bitrate <> "N/A" then
          Factor = ffmpegrate / bitrate * 1.1
      end
      if (bitrate = "N/A") & (pos("Stream #0.0",RLine) \= 0) then do
        allreadyencodet = 1
        posbitrate = pos("kb/s",RLine)
        bitrate = strip(substr(RLine,posbitrate-5,4))
        Factor = ffmpegrate / bitrate * 1.1
      end
      if (pos("Stream #0.0",RLine) \= 0) & (pos("25.00 fps",RLine) \= 0) then
        SourceSystem = 'PAL'
      if (pos("Stream #0.0",RLine) \= 0) & (pos("29.97 fps",RLine) \= 0) then
        SourceSystem = 'NTSC'
      if (allreadyencodet = 1) & (pos("Stream #0.1",RLine) \= 0) then
        allreadyencodet = 2        
    end

    if (aOutType = 'Trans') then do
      if (pos("[mpeg1video",RLine) \= 0) & (pos("bitrate above max bitrate",RLine) \= 0) then do
        ok  = Beep( "200", "250" )
        position = VRMethod( "LB_Output", "AddString", RLine  )
        error = 1
        leave        
      end
      if (pos("[mpeg1video",RLine) \= 0) & (pos("bitrate below min bitrate",RLine) \= 0) then do
        ok  = Beep( "200", "250" )
        position = VRMethod( "LB_Output", "AddString", RLine  )
        error = 1
        leave        
      end
      if (pos("MV errors",RLine) <> 0) then do
        ok  = Beep( "200", "250" )
	position = VRMethod( "LB_Output", "AddString", RLine  )
        error = 1
      end

      if (pos("frame=",RLine) \= 0) then do
        posstart = pos('size=',RLine)+6
        posend = posstart+7
        kBready = strip(substr(RLine,posstart,posend-posstart),'L')
        if ffmpeg2pass = 1 then
          kBready = kBReady / 2
        kBDisplay = kBCum + kBready
        MBDisplay = Format((kBDisplay / 1024),,2)
        if (MBDisplay > 0) & (MBComplete > 0) then do
          Percent = Format(((MBDisplay / aMBComplete) * 100),,0)
        end
        ok = VRSet( "DT_MBReady", "Caption", MBDisplay )
        ok = VRSet( "SL_Progress", "Percentile", Percent )
        ok = VRSet( "DT_Percent", "Caption", Percent||'%' )
        ok = VRSet( "MainWin", "Caption", Percent||'% - '||mainTitle )
        ok = VRSet( "DT_MBAll", "Caption", Format(aMBComplete,,2) )
      end
    end
  
    if (aOutType = 'MakeImg') then do
      if (pos("ERROR:",RLine) <> 0) | (pos("Error while opening",RLine) <> 0) then do
        ok  = Beep( "200", "250" )
        error = 1
        leave        
      end
      if (pos("INFO: scanning mpeg sequence item",RLine) <> 0) |,     
         (pos("INFO: writing track ",RLine) <> 0) then
        position = VRMethod( "LB_Output", "AddString", RLine  )
    end

    if (aOutType = 'Burn') then do
      if (pos("ERROR:",RLine) <> 0) & (InErrIgnoreList(RLine) <> 0) then do
        ok  = Beep( "200", "250" )
        error = 1
        leave        
      end

      if (pos("Wrote ",RLine) <> 0) & (pos("blocks.",RLine) = 0) then do
        posstart = pos("Wrote ",RLine)+6
        posend = pos(" of ",RLine)
        MBready = substr(RLine,posstart,posend-posstart)
        posstart = pos(' of',RLine)+4
        posend = pos("MB",RLine)
        MBAll = substr(RLine,posstart,posend-posstart-1)
        Percent = Format((MBReady * 100 / MBAll),,0)
        ok = VRSet( "DT_MBReady", "Caption", MBReady )
        ok = VRSet( "DT_MBAll", "Caption", MBAll )
        ok = VRSet( "SL_Progress", "Percentile", Percent )
        ok = VRSet( "DT_Percent", "Caption", Percent||'%' )
        ok = VRSet( "MainWin", "Caption", Percent||'% - '||mainTitle )
      end
    end

    if (queued() = 0) then do
       forcount=forcount+1
       call SysSleep(1)
    end
    if (forcount > 5) then do
      if GetProcess( progstarted ) = 0 then do
        breaked=1
        leave
      end
      else
        forcount = 0
    end
    if (aOutType = 'Trans') & ( length(encodepath) > 0 ) then
      checkdrive = substr(encodepath,1,2)
    else
      checkdrive = substr(structpath,1,2)
    MBFree = GetFreeDiskSize(checkdrive)
    if \(MBFree > 0) then MBFree = 0
    MBFree = Format(MBFree,,2)
    ok = VRSet( "DT_FREE_1", "Caption", "Free space on "||checkdrive )
    ok = VRSet( "DT_FREE_1MB", "Caption", MBFree )

  end
  if error = 1 then
    call LINEOUT logfile, RLine
  call stream logfile, 'c', 'close'

return
/*:VRX         PB_1_Click
*/
PB_1_Click: 
  call Logshow_Close
return

/*:VRX         PB_Add_Click
*/
PB_Add_Click: 
  ok = VRFileDialog( VRWindow(), "Choose MPEG file", "Open", initialpath, "", , , "files." )
  i=0
  do files.0 
    i=i+1
    bExists = VRFileExists( files.i )
    if bExists==1 then
      position = VRMethod( "LB_MPGFiles", "AddString", files.i,  )
  end
  call CheckChecked
  if i > 0 then initialpath = VRParseFileName(files.1, "D") || ":" || VRParseFileName(files.1, "P") || "\"
return

/*:VRX         PB_cdrdaopathsel_Click
*/
PB_cdrdaopathsel_Click: 
  sFile = VRGet( "EF_cdrdaopath", "Value" )
  sInitialPath = VRParseFilePath( sFile, "DP" )||"\"
  sFile = VRFileDialog( VRWindow(), "Choose dvddao executable", "Open", sInitialPath, "", ,  )
  bExists = VRFileExists( sFile )
  if bExists==1 then
    ok = VRSet( "EF_cdrdaopath", "Value", sFile )
return

/*:VRX         PB_encodepathsel_Click
*/
PB_encodepathsel_Click: 
  sFile = VRGet( "EF_encodepath", "Value" )
  sInitialPath = VRParseFilePath( sFile, "DP" )||"\"
  sFile = DirDialg( VRWindow(), "Choose path for encoded files", sInitialPath )
  if length( sFile ) > 0 then ok = VRSet( "EF_encodepath", "Value", sFile )
return

/*:VRX         PB_ffmpegpathsel_Click
*/
PB_ffmpegpathsel_Click: 
  sFile = VRGet( "EF_ffmpegpath", "Value" )
  sInitialPath = VRParseFilePath( sFile, "DP" )||"\"
  sFile = VRFileDialog( VRWindow(), "Choose ffmpeg executable", "Open", sInitialPath, "", ,  )
  bExists = VRFileExists( sFile )
  if bExists==1 then
    ok = VRSet( "EF_ffmpegpath", "Value", sFile )
return

/*:VRX         PB_logclear_Click
*/
PB_logclear_Click: 
  ok = VRMethod( "LB_Output", "Clear" )
return

/*:VRX         PB_logshow_Click
*/
PB_logshow_Click: 
  ok= VRLoadSecondary( "LOGSHOW" )
  ok= VRMethod( "LOGSHOW", "Activate" ) 
return

/*:VRX         PB_MClose_Click
*/
PB_MClose_Click: 
   call SW_Media_Close
return

/*:VRX         PB_Media_Click
*/
PB_Media_Click: 
    ok= VRLoadSecondary( "SW_Media" )
    ok= VRMethod( "SW_Media", "Activate" )
return

/*:VRX         PB_MStart_Click
*/
PB_MStart_Click: 
  ok = VRSet( "PB_MStart", "Enabled", 0 )
  ok = VRSet( "PB_MClose", "Enabled", 0 )
  error=0
  qname="VCDDAOQ"
  call RXQueue 'Create',qname
  oldq=RXQUEUE('Set',qname)
  /* Clean queue */
  DO WHILE QUEUED()\=0
    PULL str
  END
  'RXQUEUE 'qname' /CLEAR'

  ok = VRSet( "SW_Media", "HintText", "Blanking CD-RW..." )
  launch=cdrdaopath 'blank -v 2 --device '||cdrdevice||' --speed '||cdrspeed||' --driver '||cdrdriver' --blank-mode minimal 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
  launch='"'launch'"'
  echo launch '>> '|| logfile
  '@start "Blank CD-RW with cdrdao" /C /B /MIN 'launch
  call ParseOutCdrdao 'Blank'

  /* Clean queue */
  DO WHILE QUEUED()\=0
    PULL str
  END
  'RXQUEUE 'qname' /CLEAR'
  oldq=RXQUEUE('Set',oldq) 

  if error = 1 then do
    ok = VRSet( "SW_Media", "HintText", "Error(s) occured, CD-RW in drive ?" )
  end  
  else
    ok = VRSet( "SW_Media", "HintText", "Ready." )
  ok = VRSet( "PB_MStart", "Enabled", 1 )
  ok = VRSet( "PB_MClose", "Enabled", 1 )
  
return

/*:VRX         PB_Remove_Click
*/
PB_Remove_Click: 
  selected = VRGet( "LB_MPGFiles", "Selected" )
  ok = VRMethod( "LB_MPGFiles", "Delete", selected )
  call CheckChecked
return

/*:VRX         PB_Settings_Click
*/
PB_Settings_Click: 
    ok= VRLoadSecondary( "SETTINGS" )
    ok= VRMethod( "SETTINGS", "Activate" ) 
return

/*:VRX         PB_SettingsCancel_Click
*/
PB_SettingsCancel_Click: 
  call SETTINGS_Fini
return

/*:VRX         PB_SettingsOK_Click
*/
PB_SettingsOK_Click: 
    ffmpegpath= VRGet( "EF_ffmpegpath", "Value" )
    encodepath= VRGet( "EF_encodepath", "Value" )
    ffmpegpar1= VRGet( "EF_ffmpegPar1", "Value" )
    ffmpegpar2= VRGet( "EF_ffmpegPar2", "Value" )
    ffmpegrate= VRGet( "EF_SVCDvidrate", "Value" )
    ffmpegaurate= VRGet( "EF_SVCDaurate", "Value" )
    ffmpegxvrate= VRGet( "EF_XVCDvidrate", "Value" )
    ffmpegxaurate= VRGet( "EF_XVCDaurate", "Value" )
    ffmpeginterlace= VRGet( "CB_Interlace", "Set" ) 
    ffmpegdeinterlace= VRGet( "CB_Deinterlace", "Set" )
    ffmpeg2pass= VRGet( "CB_2PassEncode", "Set" )
    ffmpegsys= VRGet( "DDCB_SYS", "Value" )
    vcdimagerpath= VRGet( "EF_vcdimagerpath", "Value" )
    vcdimagerpar= VRGet( "EF_vcdimagerpar", "Value" )
    cdrdaopath= VRGet( "EF_cdrdaopath", "Value" )    
    cdrdaopar= VRGet( "EF_cdrdaoPar", "Value" )
    cdrdevice= VRGet( "EF_cdrdevice", "Value" )
    cdrdriver= VRGet( "DDCB_driver", "Value" )
    cdrspeed= VRGet( "EF_speed", "Value" )
    errorignore = VRGet( "MLE_ignoreErr", "Value" )
    structpath= VRGet( "EF_structurepath", "Value" )
    delmpgfiles = VRGet( "CB_delmpgfiles", "Set" )
    delimage = VRGet( "CB_delimage", "Set" )
    dellogfile = VRGet( "CB_dellogfile", "Set" )
    ok= VRSetIni("VCDVIDEO", "ffmpegpath", ffmpegpath, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "encodepath", encodepath, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegpar1", ffmpegpar1, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegpar2", ffmpegpar2, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegrate", ffmpegrate, ActDir"\VCDBURN.INI", "NoClose" )    
    ok= VRSetIni("VCDVIDEO", "ffmpegaurate", ffmpegaurate, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegxvrate", ffmpegxvrate, ActDir"\VCDBURN.INI", "NoClose" )    
    ok= VRSetIni("VCDVIDEO", "ffmpegxaurate", ffmpegxaurate, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpeginterlace", ffmpeginterlace, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegdeinterlace", ffmpegdeinterlace, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpeg2pass", ffmpeg2pass, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "ffmpegsys", ffmpegsys, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "vcdimagerpath", vcdimagerpath, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "vcdimagerpar", vcdimagerpar, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "cdrdaopath", cdrdaopath, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "cdrdaopar", cdrdaopar, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "cdrdevice", cdrdevice, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "cdrdriver", cdrdriver, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "cdrspeed", cdrspeed, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "structpath", structpath, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "errorignore", errorignore, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "delmpgfiles", delmpgfiles, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "delimage", delimage, ActDir"\VCDBURN.INI", "NoClose" )
    ok= VRSetIni("VCDVIDEO", "dellogfile", dellogfile, ActDir"\VCDBURN.INI" )
    call ReadFolders
    call SETTINGS_Fini
return

/*:VRX         PB_Start_Click
*/
PB_Start_Click:
error=0
breaked=0
qname="VCDBURNQ"
call RXQueue 'Create',qname
oldq=RXQUEUE('Set',qname)
/* Clean queue */
DO WHILE QUEUED()\=0
  PULL str
END
'RXQUEUE 'qname' /CLEAR'

ok = VRSet( "PB_Start", "Enabled", 0 )
ok = VRSet( "PB_Settings", "Enabled", 0 )
ok = VRSet( "PB_Media", "Enabled", 0 )
ok = VRSet( "PB_Add", "Enabled", 0 )
ok = VRSet( "PB_Remove", "Enabled", 0 )
ok = VRSet( "DT_Operation", "Caption", "" )
ok = VRSet( "SL_Progress", "Percentile", '0' )
ok = VRSet( "DT_Percent", "Caption", '0'||'%' )
ok = VRSet( "PB_logshow", "Enabled", 0 )
ok = VRSet( "PB_logclear", "Enabled", 0 )
ok = VRSet( "DT_FREE_1", "Visible", 1 )
ok = VRSet( "DT_FREE_1MB", "Visible", 1 )
ok = VRSet( "DT_TEXT_MBF1", "Visible", 1 )

SourceSystem = 'NTSC'
VCDName = VRGet( "Combo_Name", Value )
VCDtype = VRGet( "Combo_Type", Value )
if VCDType = 'VCD' then VCDType = 'vcd'
if VCDType = 'SVCD' then VCDType = 'svcd'
if VCDType = 'XVCD' then VCDType = 'xvcd'
position = VRMethod( "LB_Output", "AddString", "Starting operations...",  )
ffmpegfolder = VRParseFilePath( ffmpegpath, "DP" )

nPosLastBS = lastpos('\',structpath )
length  = Length( structpath )
if length != nPosLastBS then
  structpath = structpath||'\'

if length(encodepath) > 0 then do
  nPosLastBS = lastpos('\',encodepath )
  length  = Length( encodepath )
  if length != nPosLastBS then
    encodepathused = encodepath||'\'
  else
    encodepathused = encodepath
end
else
  encodepathused = structpath

imagepath = structpath||VCDName

logfile=structpath||VCDName||'_log.txt'
position = VRMethod( "LB_Output", "AddString", "Logfile is "||logfile,  )
call SysMkDir structpath||VCDName
count = VRGet( "LB_MPGFiles", "Count" )

MBComplete = 0
kBReady=0
kBCum = 0

echo 'log for creating '||VCDName||' > ' ||logfile
setTranscode = VRGet( "CB_Transcode", "Set" )
if setTranscode = 1 then do
  progstarted = translate(VRParseFileName( ffmpegpath, "NE" ))
  MBComplete = 0
  do n = 1 to count
    filename = VRMethod( "LB_MPGFiles", "GetString", n )
    filename = SpaceCheck(filename)
    FileSize = GetFileSize(filename)

    launch=ffmpegpath ' -i ' filename||' 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
    launch='"'launch'"'
    allreadyencodet = 0
    '@start "Get source bitrate" /C /B /MIN 'launch
    call ParseOutput 'Bitrate', FileSize
    if allreadyencodet = 2 then
      position = VRMethod( "LB_Output", "AddString", filename||' seems already encodet!',  )
    if FileSize > 0 then do
      MBComplete = MBComplete + (FileSize * Factor )
    end
  end
  ok = VRSet( "CB_Transcode", "Enabled", 0 )
  ok = VRSet( "DT_Operation", "Caption", "Written:" )
  ok = VRSet( "DT_TEXT_MB", "Visible", 1 )

  do n = 1 to count
    ok = VRSet( "DT_TEXT_MB", "Caption", "MB of approx." )
    string = VRMethod( "LB_MPGFiles", "GetString", n )
    filename = VRParseFileName( string, "NE" )
    newfile = (VRParseFileName( string, "N" ))||'.MPG'
    string = SpaceCheck(string)
    ok = VRSet( "DT_Operation", "Caption", "Transcoded" )
    neudir = directory(ffmpegfolder)

    call VCDTarget

    if ffmpeg2pass = 1 then do
      position = VRMethod( "LB_Output", "AddString", "Transcoding "||filename||" pass 1",  )
      launch = launch ' -pass 1'   
    end
    else
      position = VRMethod( "LB_Output", "AddString", "Transcoding "||filename,  )
    if (ffmpeginterlace = 1) & (VCDType <> 'xvcd') & (VCDType <> 'vcd') then
      launch = launch ' -ildct -ilme'
    if ffmpegdeintlace = 1 then
      launch = launch ' -deinterlace'

    encodefile = SpaceCheck(encodepathused||newfile)

    if (VCDType = 'xvcd') then
      launch = launch ' -b ' ffmpegxvrate||'k -ab ' ffmpegxaurate
    else
      if (VCDType = 'svcd') then
        launch = launch ' -b ' ffmpegrate||'k -ab ' ffmpegaurate

    launch = launch ' ' ffmpegpar1 ' ' encodefile||' 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
    launch='"'launch'"'
    echo launch '>> '|| logfile
    '@start "Transcode MPEG file p1" /C /B /MIN 'launch
    call ParseOutput 'Trans', MBComplete
    kBCum = kBCum + kBReady

    if breaked=1 then do
      call PB_Start_End
      return
    end

    if ffmpeg2pass = 1 then do                  /* second pass */
      position = VRMethod( "LB_Output", "AddString", "Transcoding "||filename||" pass 2",  )
      ok = VRSet( "DT_Operation", "Caption", "Transcoded" )

      call VCDTarget
      launch = launch ' -pass 2'   

      if (ffmpeginterlace = 1) & (VCDType <> 'xvcd') & (VCDType <> 'vcd') then
        launch = launch ' -ildct -ilme'
      if ffmpegdeintlace = 1 then
        launch = launch ' -deinterlace'

      encodefile = SpaceCheck(encodepathused||newfile)

      if (VCDType = 'xvcd') then
        launch = launch ' -b ' ffmpegxvrate||'k -ab ' ffmpegxaurate
      else
        if (VCDType = 'svcd') then
          launch = launch ' -b ' ffmpegrate||'k -ab ' ffmpegaurate

      launch = launch ' ' ffmpegpar2 ' ' encodefile||' 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
      launch='"'launch'"'
      echo launch '>> '|| logfile
      '@start "Transcode MPEG file p2" /C /B /MIN 'launch
      call ParseOutput 'Trans', MBComplete
      kBCum = kBCum + kBReady

      if breaked=1 then do
        call PB_Start_End
        return
      end

    end
  end
  ok = VRSet( "MainWin", "Caption", mainTitle )
  ok = VRSet( "DT_Percent", "Caption", '100%' )
  ok = VRSet( "SL_Progress", "Percentile", 100 )
end
setVCD = VRGet( "CB_CreateVCD", "Set" )
ok = VRSet( "DT_TEXT_MB", "Visible", 0 )
if setVCD = 1 then do
  progstarted = translate(VRParseFileName( vcdimagerpath, "NE" ))
  ok = VRSet( "CB_Transcode", "Enabled", 0 )
  ok = VRSet( "CB_CreateVCD", "Enabled", 0 )
  ok = VRSet( "DT_Operation", "Caption", "Creating image..." )
  position = VRMethod( "LB_Output", "AddString", "Creating image file",  )
  neudir = directory(imagepath)
  launch=vcdimagerpath' 'vcdimagerpar
  if VCDType = 'vcd' then
    launch = launch||' -c vcd.cue -b vcd.bin -t VCD2'
  else
  do
    if VCDType = 'svcd' then
      launch = launch||' -c svcd.cue -b svcd.bin -t SVCD --update-scan-offsets'
  end  
  launch = launch||' --iso-volume-label="'||VCDName||'"'

  ok = VRRedirectStdIO( "Off" )
  do n = 1 to count
    string = VRMethod( "LB_MPGFiles", "GetString", n )
    filename = VRParseFileName( string, "NE" )
    newfile = (VRParseFileName( string, "N" ))||'.MPG'
    ext = VRParseFileName( string, "E" )
    string = SpaceCheck(string)
    encodefile = SpaceCheck(encodepathused||newfile)
    if (GetFileSize(encodefile) = 0) then do
      if (Translate(ext) = 'MPG') | (Translate(ext) = 'MPEG') then
        launch = launch||' '||string
      else do 
        ok  = Beep( "200", "250" )
        position = VRMethod( "LB_Output", "AddString", "File not found: "||filename  )
        position = VRMethod( "LB_Output", "AddString", "You must encode it first !"  )
        error = 1
        call PB_Start_End
        return
      end
    end
    else
      launch = launch||' '||encodefile
  end
  ok = VRRedirectStdIO( "On" )

  launch = launch||' 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
  launch='"'launch'"'
  echo launch '>> '|| logfile
  ok = VRSet( "SL_Progress", "Visible", 0 )
  ok = VRSet( "DT_Percent", "Visible", 0 )
  ok = VRSet( "DT_TEXT_MB", "Visible", 0 )
  '@start "Run VCDImager" /C /B /MIN 'launch
  call ParseOutput 'MakeImg'

  if (breaked=1) | (error=1) then do
    call PB_Start_End
    return
  end
  ok = VRSet( "MainWin", "Caption", mainTitle )
end
setBurn = VRGet( "CB_BurnIMG", "Set" )
if (setBurn = 1) then do
  progstarted = translate(VRParseFileName( cdrdaopath, "NE" ))
  ok = VRSet( "CB_Transcode", "Enabled", 0 )
  ok = VRSet( "CB_CreateVCD", "Enabled", 0 )
  ok = VRSet( "CB_BurnIMG", "Enabled", 0 )
  ok = VRSet( "DT_Operation", "Caption", "Written to CD:" )
  ok = VRSet( "MainWin", "Caption", mainTitle )
  ok = VRSet( "DT_Percent", "Caption", '0%' )
  ok = VRSet( "SL_Progress", "Percentile", 0 )
  position = VRMethod( "LB_Output", "AddString", "Burning image file",  )
  if VCDType = 'vcd' then do
    cuefile = imagepath||'\vcd.cue'
    binfile = imagepath||'\vcd.bin'
  end
  else
  do
    if VCDType = 'svcd' then do
      cuefile = imagepath||'\svcd.cue'
      binfile = imagepath||'\svcd.bin'
    end
  end  

  if (VRFileExists( cuefile ) = 1) & (VRFileExists( binfile ) = 1) then do
    binfilesize = GetFileSize(binfile)
    if binfilesize > 800 then
      if RxMessageBox("Image is bigger than 700 MB, continue ?", "Warning", "YesNo", "Warning") <> 6 then do
        breaked = 1
        call PB_Start_End
        return
      end
    ok = VRSet( "DT_TEXT_MB", "Visible", 1 )
    ok = VRSet( "DT_TEXT_MB", "Caption", "MB of" )
    ok = VRSet( "DT_Operation", "Caption", "Written to CD:" )
    ok = VRSet( "SL_Progress", "Visible", 1 )
    ok = VRSet( "DT_Percent", "Visible", 1 )

    if cdrspeed > 0 then speedpar = "--speed "||cdrspeed
    else speedpar = ""
    neudir = directory(cdrdaopath)
    launch=cdrdaopath 'write -v 2 --device '||cdrdevice||' '||speedpar||' --driver '||cdrdriver||' --overburn --force --reload --eject '||cdrdaopar||' '||cuefile||' 2>&1 |RXQUEUE '||qname||' /FIFO & ECHO DONEACTION 2>&1 |RXQUEUE '||qname||' /FIFO'
    launch='"'launch'"'
    echo launch '>> '|| logfile
    '@start "Burn CD with cdrdao" /C /B /MIN 'launch
    call ParseOutput 'Burn'

    if (breaked=1) | (error=1) then do
      call PB_Start_End
      return
    end
  end
  else do
    ok  = Beep( "200", "250" )
    position = VRMethod( "LB_Output", "AddString", "Image and/or cue file not found !",  )
    error = 1
  end
  ok = VRSet( "MainWin", "Caption", mainTitle )
  ok = VRSet( "DT_Percent", "Caption", '100%' )
  ok = VRSet( "SL_Progress", "Percentile", 100 )
end
call PB_Start_End
return

PB_Start_End:
/* Clean queue */
DO WHILE QUEUED()\=0
  PULL str
END
'RXQUEUE 'qname' /CLEAR'
oldq=RXQUEUE('Set',oldq)  

setStructure = 1
setVCD = 1
setBurn = 1

ok = VRChDir(structpath)         /* necessary for deleting vcd folder */ 
if (breaked = 0) & (error = 0) then do
  if (setVCD = 1) | (setBurn = 1) then do
    if (delmpgfiles = 1) then do
      position = VRMethod( "LB_Output", "AddString", "Deleting encoded files...",  )      
      count = VRGet( "LB_MPGFiles", "Count" )      
      do n = 1 to count
        string = VRMethod( "LB_MPGFiles", "GetString", n )
        newfile = (VRParseFileName( string, "N" ))||'.MPG'
        encodefile = encodepathused||newfile        
        if VRFileExists( encodefile ) = 1 then do
          ok = VRDeleteFile( encodefile )
        end
      end
    end
  end
  if (setBurn = 1) then do
    if (delimage = 1) then do
      if (VRFileExists(cuefile)=1) then do
        position = VRMethod( "LB_Output", "AddString", "Deleting cue file...",  )      
        ok = VRDeleteFile( cuefile )
      end
      if (VRFileExists(binfile)=1) then do
        position = VRMethod( "LB_Output", "AddString", "Deleting image file...",  )      
        ok = VRDeleteFile( binfile )
      end
      ok = VRRmDir( structpath||VCDName )
    end
  end
  if (dellogfile = 1) then do
    call stream logfile, 'c', 'close'
    call SysSleep(0.5)
    position = VRMethod( "LB_Output", "AddString", "Deleting logfile...",  )      
    ok = VRDeleteFile( logfile )
  end
end

if breaked=1 then do
  ok  = Beep( "200", "100" )
  position = VRMethod( "LB_Output", "AddString", "Operation(s) canceled.", )
end
else
  if error=0 then
    position = VRMethod( "LB_Output", "AddString", "Finished.",  )
  else
    position = VRMethod( "LB_Output", "AddString", "Error(s) occured.",  )

ok = VRSet( "MainWin", "Caption", mainTitle )
ok = VRSet( "DT_Operation", "Caption", "" )
ok = VRSet( "DT_TEXT_MB", "Caption", "" )
ok = VRSet( "DT_MBReady", "Caption", "" )
ok = VRSet( "DT_MBAll", "Caption", "" )
hinttext = VRGet( "MainWin", "HintText" )
ok = VRSet( "MainWin", "HintText", "Action ready." )

ok = VRSet( "PB_Start", "Enabled", 1 )
ok = VRSet( "PB_Settings", "Enabled", 1 )
ok = VRSet( "PB_Media", "Enabled", 1 )
ok = VRSet( "PB_Add", "Enabled", 1 )
ok = VRSet( "PB_Remove", "Enabled", 1 )
ok = VRSet( "CB_Transcode", "Enabled", 1 )
ok = VRSet( "CB_CreateVCD", "Enabled", 1 )
ok = VRSet( "CB_BurnIMG", "Enabled", 1 )
ok = VRSet( "PB_logshow", "Enabled", VRFileExists(logfile) )
ok = VRSet( "PB_logclear", "Enabled", 1 )
call CheckChecked
ok = VRSet( "DT_FREE_1", "Visible", 0 )
ok = VRSet( "DT_FREE_1MB", "Visible", 0 )
ok = VRSet( "DT_TEXT_MBF1", "Visible", 0 )

return
/*:VRX         PB_structurepathsel_Click
*/
PB_structurepathsel_Click: 
  sFile = VRGet( "EF_structurepath", "Value" )
  sInitialPath = VRParseFilePath( sFile, "DP" )||"\"
  sFile = DirDialg( VRWindow(), "Choose structure root path", sInitialPath )
  if length( sFile ) > 0 then ok = VRSet( "EF_structurepath", "Value", sFile )
return

/*:VRX         PB_vcdimagerpathsel_Click
*/
PB_vcdimagerpathsel_Click: 
  sFile = VRGet( "EF_vcdimagerpath", "Value" )
  sInitialPath = VRParseFilePath( sFile, "DP" )||"\"
  sFile = VRFileDialog( VRWindow(), "Choose DVDAuthor executable", "Open", sInitialPath, "", ,  )
  bExists = VRFileExists( sFile )
  if bExists==1 then
    ok = VRSet( "EF_vcdimagerpath", "Value", sFile )
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         ReadFolders
*/
ReadFolders: 
  ok = VRMethod( "Combo_Name", "Clear" )
  rc = SysFileTree(structpath'*', folders, 'DO') 
  i=1
  do folders.0
    lbs = lastpos("\",folders.i)
    folders.i = strip(substr(folders.i,lbs+1,25))
    i=i+1
  end
  status = VRMethod( "Combo_Name", "AddStringList", "folders." )
return

/*:VRX         ReadSetup
*/
ReadSetup: 
 SetupDatei = ARG(1)
 i = 0
 do while lines(SetupDatei) <> 0
  i = i+1
  Zeile = linein(SetupDatei)
  j = pos('=',Zeile)
  if j <> 0 then do
   SetupKeys.i = strip(substr(Zeile,1,j-1),'B')
   SetupStrings.i = strip(substr(Zeile,j+1),'B')
  end
  else do
   SetupKeys.i = strip(Zeile,'B')
   SetupStrings.i = ''
  end
 end
 ok = lineout(SetupDatei)
 SetupKeys.0 = i
 SetupStrings.0 = i

return

/*:VRX         SetLanguage
*/
SetLanguage: 
  workingdirectory = VRGet( "Application", "WorkingDirectory" )
  ok = VRFileExists( workingdirectory"\lang.txt" )
  if ok = 1 then do
    call ReadSetup 'lang.txt'
    ok = VRSet( "DT_7", "Caption", SetupVar("DVD name") )

  end
return

/*:VRX         Settings_Close
*/
Settings_Close: 
    call Settings_Fini
return

/*:VRX         Settings_Create
*/
Settings_Create: 
    call Settings_Init
return

/*:VRX         Settings_Fini
*/
Settings_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         Settings_Init
*/
Settings_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SetupVar
*/
SetupVar: 
 Key = ARG(1)
 Inhalt = ARG(2)
 gef = 0
 j = 0
 do i = 1 to SetupKeys.0
  if gef <> 1 then do
   if pos(translate(Key), translate(SetupKeys.i)) == 1 then do
    if Inhalt <> '' then do
     if translate(Inhalt) = '/L' then do
      SetupStrings.i = ''
      SetupKeys.i = '--/L--'
      j = j+1
     end
     else SetupStrings.i = Inhalt
    end
    gef = 1
    Ergebnis = strip( SetupStrings.i, 'B' )
   end
  end
 end
 Anzahl = SetupKeys.0+1-j
 SetupKeys.0 = Anzahl
 SetupStrings.0 = Anzahl
 if gef == 0 then do
  SetupKeys.Anzahl = Key
  SetupStrings.Anzahl = Inhalt
  Ergebnis = strip( SetupStrings.Anzahl, 'B' )
 end

return Ergebnis
/*:VRX         SpaceCheck
*/
SpaceCheck: 
  parse arg checkfolder
  nPosSpace = pos(' ',checkfolder)
  if (nPosSpace <> 0) & (substr(checkfolder,1,1) <> '"') then
    checkfolder = '"'||checkfolder||'"'
return checkfolder
/*:VRX         SW_Media_Close
*/
SW_Media_Close: 
    call SW_Media_Fini
return

/*:VRX         SW_Media_Create
*/
SW_Media_Create: 
    call SW_Media_Init
return

/*:VRX         SW_Media_Fini
*/
SW_Media_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_Media_Init
*/
SW_Media_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_P0_Close
*/
SW_P0_Close: 
    call SW_P0_Fini
return

/*:VRX         SW_P0_Create
*/
SW_P0_Create: 
    call SW_P0_Init
    ok = VRSet( "EF_structurepath", "Value", structpath )
    ok = VRSet( "CB_delmpgfiles", "Set", delmpgfiles )
    ok = VRSet( "CB_delimage", "Set", delimage )
    ok = VRSet( "CB_dellogfile", "Set", dellogfile )
return

/*:VRX         SW_P0_Fini
*/
SW_P0_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_P0_Init
*/
SW_P0_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_P1_Close
*/
SW_P1_Close: 
    call SW_P1_Fini
return

/*:VRX         SW_P1_Create
*/
SW_P1_Create: 
    call SW_P1_Init
    ok = VRSet( "EF_ffmpegpath", "Value", ffmpegpath )
    ok = VRSet( "EF_encodepath", "Value", encodepath )
    ok = VRSet( "EF_ffmpegPar1", "Value", ffmpegpar1 )
    ok = VRSet( "EF_ffmpegPar2", "Value", ffmpegpar2 )
    ok = VRSet( "EF_SVCDvidrate", Value, ffmpegrate )
    ok = VRSet( "EF_SVCDaurate", Value, ffmpegaurate )
    ok = VRSet( "EF_XVCDvidrate", Value, ffmpegxvrate )
    ok = VRSet( "EF_XVCDaurate", Value, ffmpegxaurate )
    ok = VRSet( "CB_Interlace", "Set", ffmpeginterlace )
    ok = VRSet( "CB_DeInterlace", "Set", ffmpegdeinterlace )
    ok = VRSet( "CB_2PassEncode", "Set", ffmpeg2pass )
    ok = VRSet( "DDCB_SYS", "Value", ffmpegsys )
    call CB_2PassEncode_Click
return

/*:VRX         SW_P1_Fini
*/
SW_P1_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_P1_Init
*/
SW_P1_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_P2_Close
*/
SW_P2_Close: 
    call SW_P2_Fini
return

/*:VRX         SW_P2_Create
*/
SW_P2_Create: 
    call SW_P2_Init
    ok = VRSet( "EF_vcdimagerpath", "Value", vcdimagerpath )
    ok = VRSet( "EF_vcdimagerpar", "Value", vcdimagerpar )
return
/*:VRX         SW_P2_Fini
*/
SW_P2_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_P2_Init
*/
SW_P2_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_P4_Close
*/
SW_P4_Close: 
    call SW_P4_Fini
return

/*:VRX         SW_P4_Create
*/
SW_P4_Create: 
    call SW_P4_Init
    ok = VRSet( "EF_cdrdaopath", "Value", cdrdaopath )
    ok = VRSet( "EF_cdrdaoPar", "Value", cdrdaopar )
    ok = VRSet( "EF_cdrdevice", "Value", cdrdevice )
    ok = VRSet( "DDCB_driver", "Value", cdrdriver )
    if length(errorignore) > 0 then
       ok = VRSet( "MLE_ignoreErr", "Value", errorignore )
    ok = VRSet( "EF_speed", "Value", cdrspeed )
return

/*:VRX         SW_P4_Fini
*/
SW_P4_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_P4_Init
*/
SW_P4_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         VCDTarget
*/
VCDTarget: 
    if (VCDType = 'xvcd') then do
      if ffmpegsys = "auto" then do
        if SourceSystem = "PAL" then
          launch=ffmpegpath ' -i ' string ' -r 25 -s 352x288 -vcodec mpeg1video'
        else
          launch=ffmpegpath ' -i ' string ' -r 29.97 -s 352x240 -vcodec mpeg1video'
      end
      else do
        if ffmpegsys = "pal" then
          launch=ffmpegpath ' -i ' string ' -r 25 -s 352x288 -vcodec mpeg1video'
        else
          launch=ffmpegpath ' -i ' string ' -r 29.97 -s 352x240 -vcodec mpeg1video'
      end
    end
    else do
      if ffmpegsys = "auto" then
        launch=ffmpegpath ' -i ' string ' -target '||VCDtype
      else
        launch=ffmpegpath ' -i ' string ' -target '||ffmpegsys||'-'||VCDtype
    end
return

