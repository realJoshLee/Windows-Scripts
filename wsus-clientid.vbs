'SetAuthorization.vbs
'
'Version 1.2 - 05/31/07, Rob Dunn
'
'Email: uphold twothousand1 (the year as a number) at hotmail dot com
'Websites: www.vbshf.com, www.wsus.info
'
'This script can be run against a remote (or local) computer and delete the WSUS
' Client IDs and can force the computer to run a detectnow or 
' resetauthorization, so it will report back into the WSUS server with a 
' newly generated ID.
'
'This was based off of a script that I came across in the WSUS.info forums
' http://www.wsus.info/forums/index.php?showtopic=8698&hl=duplicate+script
'
'Usage:
'SetAuthorization.vbs computer:computername reset:true (will delete regkeys, stop/restart AU services, perform /resetauthorization /detectnow)
'SetAuthorization.vbs computer:computername (will stop/restart AU service, perform /detectnow)
'SetAuthorization.vbs computer:computername reset:true force:true (if you have run the script on the PC before, you will need to use the force switch to override the regkey marker to run again - then performs the same actions as the 'reset:true' listed above)
'
'Requirements:
'You must have full admin rights to the system and registry this script
' is run against.

Const ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002
Dim objLocator, objWMIService, oReg, strResetAuthorization, strComputer, iDebug, sIDDeleted, l
Dim strForceReset

'Set iDebug = 1 if you wish to see what is going on with the variables, etc. 
iDebug = 0

'Static variable - do not change.
sIDDeleted = ""

Set ws = CreateObject("Scripting.FileSystemObject")
Set objLocator = CreateObject("WbemScripting.SWbemLocator")
Set oShell = CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments
Set l = ws.OpenTextFile (".\setauthorization.log", ForAppending, True)

l.WriteLine "[" & now & "] - initializing script..." 

'Get command-line arguments
If objargs.count < 1 Then
  'if no command line arguments, then goto the input function
	Call fctInput
Else
 For I = 0 to objArgs.Count - 1
   'get computername - who are we running the script against?
   If InStr(1,LCase(objargs(I)),"computer:") Then
   	arrComputer = split(lcase(objargs(I)),"computer:")
   	strComputer = arrComputer(1)
    if iDebug = 1 then msgbox "Computername: " & strComputer
   'get reset switch - reset authorization or just detect now?
   ElseIf InStr(1,LCase(objargs(I)),"Reset:") Then
   	arrAuth = split(lcase(objargs(I)),"Reset:")
   	strResetAuthorization = arrAuth(1)
    if iDebug = 1 then msgbox "Reset Authorization: " & strResetAuthorization
    
    'If we get an invalid switch defined, catch it here.
    if not lcase(instr("true yes false no",lcase(strResetAuthorization))) then 
      msgbox "You have used an invalid switch for the 'Reset' option.  Use 'true|yes'.  Now exiting."
      l.WriteLine "[" & now & "] - Invalid switch specified: " & strResetAuthorization & ".  Exiting script."
      wscript.quit  
    End If
   'get force switch - force computer to delete WSUS ID keys again?
   ElseIf InStr(1,LCase(objargs(I)),"force:") Then
   	arrForce = split(lcase(objargs(I)),"force:")
   	strForceReset = arrForce(1)
    
    'If we get an invalid switch defined, catch it here.
    if not instr("true yes false no",lcase(strForceReset)) then 
      msgbox "You have used an invalid switch for the 'force' option.  Use 'true|yes'.  Now exiting."
      wscript.quit  
    End If
    
    if iDebug = 1 then msgbox "Force Reset Authorization: " & strResetAuthorization

   Else
  
   End If
 Next 
End If
l.WriteLine "=========================================================="

l.WriteLine "[" & now & "] - Computer: " & strComputer
l.WriteLine "[" & now & "] - Reset: " & strResetAuthorization
if strForceReset <> "" then l.WriteLine "[" & now & "] - Force: " & strForceReset

'******************************************************************************
'   Subroutine fctInput - Inputbox to prompt user for computername and 
'     choice to reset the authorization or not...
'   Inputs - None
'******************************************************************************
Sub fctInput()
  'input the computer name you wish to run against.
	strComputer = InputBox("Type the name of the computer.","Input computer name")
	If strComputer = "" Then wscript.quit
  if iDebug = 1 then msgbox "Computername: " & strComputer
  
  'do you want to reset authorization or run a 'detect now'?
  strResetAuthorization = InputBox("Do you wish to delete the WSUS SIDs and reset '" & strComputer & "' authorization to the WSUS server?" & vbcrlf & vbcrlf & "Type 'yes' or 'no' then click 'OK'.","Reset computer's membership on the WSUS server?")
  
  if strResetAuthorization = "" then strResetAuthorization = "no"
  
End Sub

'Set the registry keypath that we are going to work with
strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate"
l.WriteLine "[" & now & "] - Working with " & strKeyPath & "..."

'Set the value name that we will use to create the registry marker
' (to determine if we've run the script before on this computer)
strValueName = "IDDeleted"
l.WriteLine "[" & now & "] - Checking for " & strValueName

on error resume next

set objWMIService = objLocator.ConnectServer(strComputer,"root\default") 

If err.number <> 0 then 
  strMsg = "Unable to connect to " & strComputer & " via WMI.  Please check the connection and try again."
  msgbox strMsg,48,"Cannot connect"
  l.WriteLine "[" & now & "] - " & strMsg
  wscript.quit
End if

'We will need to use WMI to connect to the registry...
Set oReg = objWMIService.Get("StdRegProv")

If err.number <> 0 then 
  'if we cannot connect to the computer via WMI, show message, and then quit
  ' the script.
  strMsg = "Could not connect to computer '" & strComputer & "'.  Check to see if the computer is powered on or not behind a firewall."
  Msgbox strMsg,48,"Could not connect to " & strComputer
  l.WriteLine "[" & now & "] - " & strMsg
  wscript.quit
End If
on error goto 0

'Check for registry marker to find out if we ran this script against the computer
' we specified in strComputer.
oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strIDDeleted
If strIDDeleted = null then 
  l.WriteLine "[" & now & "] - WSUS SID has not been previously deleted.  Setting to 'no'."
  sIDDeleted = "no"
Else
  l.writeline "[" & now & "] - Current value of sIDDeleted: " & strIDDeleted 
  l.WriteLine "[" & now & "] - WSUS SID has been previously deleted."
End if

'To be sure values is only deleted once, test on marker
If strIDDeleted = "yes" and lcase(strResetAuthorization) = "no" then
  l.writeline "[" & now & "] - Running wuauclt detect process"
  Call RunWUAUCLT()
  
Else
  
  on error resume next
  
  'Delete values - if debug = 1 (set in the beginning of the script), then show
  ' a messagebox for every delete.
  If iDebug = 1 then msgbox "Deleting " & strKeyPath & "\AccountDomainSid"
  
  l.WriteLine "[" & now & "] - Removing " & strKeyPath & "\AccountDomainSid"
  
  oReg.DeleteValue  HKEY_LOCAL_MACHINE, strKeyPath,"AccountDomainSid"

  if iDebug = 1 then msgbox "Deleting " & strKeyPath & "\PingID"

  l.WriteLine "[" & now & "] - Removing " & strKeyPath & "\PingID"

  oReg.DeleteValue  HKEY_LOCAL_MACHINE, strKeyPath,"PingID"
  
  if iDebug = 1 then msgbox "Deleting " & strKeyPath & "\SusClientId"

  l.WriteLine "[" & now & "] - Removing " & strKeyPath & "\SusClientId"
  
  oReg.DeleteValue  HKEY_LOCAL_MACHINE, strKeyPath,"SusClientId"

  'Run remote wuauclt process on strComputer.
  Call RunWUAUCLT()

  if iDebug = 1 then msgbox "Creating regkey marker: HKLM\" & strkeyPath & "\" & strValueName

  On error resume next
  'Create registry marker
  oreg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,"yes"
  
  If err.number <> 0 then
    'If we can't create the registry marker, show messagebox and then quit the 
    ' script.
    Msgbox "Could not make registry change to computer '" & strComputer & "'.  Check to see if the computer is behind a firewall, or if remote registry permissions have been disabled.",48,"Could not connect to " & strComputer
    wscript.quit
  End If
  On Error goto 0
  
End If

l.writeline "[" & now & "] - Script completed.  Check WSUS console for updated entry for " & strComputer & "."
l.close

'******************************************************************************
'   Function RunWUAUCLT - function to execute wuauclt.exe
'   Inputs - None
'******************************************************************************
Function RunWUAUCLT()
  l.WriteLine "[" & now & "] - Attempting to stop wuauserv service..."
  
  sCmd = chr(34) & "net.exe" & chr(34) & " stop wuauserv"
  
  if iDebug = 1 then msgbox "Running command on '" & strComputer & "': " & sCmd
  
  'Stop the Automatic updates service
  Call RunProcess(sCmd,strComputer)

  if iDebug = 1 then msgbox "Sleeping for 2 seconds...(after you click 'OK')"

  'Pause for 2 seconds
  wscript.sleep 2000

  l.WriteLine "[" & now & "] - Attempting to start wuauserv service..."
  
  sCmd = chr(34) & "net.exe" & chr(34) & " start wuauserv"

  if iDebug = 1 then msgbox "Running command on '" & strComputer & "': " & sCmd

  'Start the Automatic updates service
  Call RunProcess(sCmd,strComputer)
  
If sIDDeleted <> "yes" or lcase(strResetAuthorization) = "true" or lcase(strResetAuthorization) = "yes" or lcase(strForceReset) = "true" Then

    sCmd = "wuauclt.exe /resetauthorization /detectnow"

    l.WriteLine "[" & now & "] - Running " & sCmd & " on " & strComputer

    if iDebug = 1 then msgbox "Running command on '" & strComputer & "': " & sCmd

    'Run wuauclt.exe with resetauthorization
    Call RunProcess(sCmd,strComputer)
  Else
    sCmd = "wuauclt.exe /detectnow"
    
    l.WriteLine "[" & now & "] - Running " & sCmd & " on " & strComputer

    if iDebug = 1 then msgbox "Running command on '" & strComputer & "': " & sCmd

    'Run wuauclt.exe with detectnow only
    Call RunProcess(sCmd,strComputer)
  
  End If
End Function

'******************************************************************************
'   Function RunProcess
'   Inputs -
'     strCommand: command-line you wish to run on strComputer
'     strComputer: computername you wish to run the command on
'******************************************************************************
Function RunProcess(strCommand,strComputer)
  On Error resume next

  strArgs = " "
  StrExeName = strCommand
  
  'I hard-coded this in (I was lazy) - but you may need to change this
  ' if your root drive is 'R:\', etc.
  strCurrentDir = "C:\"

  Set objService = objLocator.ConnectServer(strComputer,"root/cimv2")
  Set objProcess = objService.Get("WIN32_Process")
  Set objProcessStartup = objService.Get("Win32_ProcessStartup")

  objProcessStartup.PriorityClass = 128
  objProcessStartup.ShowWindow = 1

  Set objMethod = objProcess.Methods_("Create")
  Set objInParameters = objMethod.inParameters.SpawnInstance_()

  objInParameters.CommandLine = strExeName & strArgs
  objInParameters.CurrentDirectory = strCurrentDir

  Set objInParameters.ProcessStartupInformation = objProcessStartup
  Set objOutParameters = objProcess.ExecMethod_("Create", objInParameters)

  If objOutParameters.returnValue = 0 Then
    strPID = objOutParameters.ProcessID
  Else

  End If

  dim errDescription

  If objOutParameters.returnValue = 0 Then errdescription = "Successfully created process on " & strComputer & " with PID: " & strPID
  If objOutParameters.returnValue = 2 Then errdescription = "Access denied"
  If objOutParameters.returnValue = 3 Then errdescription = "Insufficient privileges to create a process on " & strComputer
  If objOutParameters.returnValue = 9 Then errdescription = "Path not found for " & strCommand & " on " & strComputer
    
  If iDebug = 1 then msgbox errdescription
  l.WriteLine "[" & now & "] - Process '" & strCommand & "' result:" & errdescription
  
End Function