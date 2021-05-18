;#include "C:\Scripts\Tests\GlobalHotKey.au3"
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <File.au3>
#include "C:\Scripts\Tests\TCP.au3"
#include <TrayConstants.au3>
;Global Const $VK_OEM_PLUS = 0xBB
;Global Const $VK_OEM_MINUS = 0xBD
;Global Const $VK_OEM_DEL = 0x2E
;_HotKey_Assign(BitOR($CK_CONTROL, $VK_OEM_DEL), 'Quit')
Local $iPort = 6090
TrayTip("Server","Hide and show RDP Connection Bar Server has been Started",10,1)
$hServer = _TCP_Server_Create($iPort)
Sleep(1000)
$ServerIP = GetServer()
TrayTip("Server","Running On Port "&$iPort,10)
Opt("TrayMenuMode",3);
TraySetState($TRAY_ICONSTATE_SHOW)
Local $iHide = TrayCreateItem("Send Hide To Server!",-1,-1,0)
Local $iShow = TrayCreateItem("Send Show To Server!",-1,-1,0)
TrayCreateItem("")
Local $iAbout = TrayCreateItem("About!",-1,-1,0)
Local $iExit = TrayCreateItem("Exit...",-1,-1,0)



_TCP_RegisterEvent($hServer, $TCP_RECEIVE, "SeverReceive")
_TCP_RegisterEvent($hServer, $TCP_NEWCLIENT, "NewClient")
_TCP_RegisterEvent($hServer, $TCP_DISCONNECT, "DisConnect")
Local $WinHndl = WinWait("[CLASS:BBarWindowClass]","",10)

While 1
   ;Sleep(10)
   $msg = TrayGetMsg()
   Select
   Case $msg = 0
	  ContinueLoop
   Case $msg = $iAbout
	  MsgBox($MB_SYSTEMMODAL,"Show/Hide RDP bar!", "Simple Program just to Show/Hide RDP Bar"&@CRLF&"Send Hide/Show/Bye to via port: "&$iPort&" to work with the server"& @CRLF&"Server IP Its: " & $ServerIP)
   Case $msg = $iExit
	  ExitLoop
   Case $msg = $iShow
	  SendToServer("show")
   Case $msg = $iHide
	  SendToServer("hide")
   EndSelect
WEnd


Func SendToServer($sAction)
	$hClient = _TCP_Client_Create($ServerIP, $iPort); Create the client. Which will connect to the local ip address on port 88
	Sleep(1000)
   if $sAction = "show" Then
	    TrayTip("Server","Send Show Command",30)
	  _TCP_Send($hClient, "show" & @CRLF)
   elseif $sAction = "hide" Then
	  TrayTip("Server","Send Hide Command",30)
	  _TCP_Send($hClient, "hide" & @CRLF)
   EndIf
	Sleep(1000)
   _TCP_Send($hClient, "bye" & @CRLF)
EndFunc

Func SeverReceive($hSocket, $sReceived,$iError)
   Switch StringLower($sReceived)
   Case "hide"&@CRLF
	  TrayTip("Server","Hide RDP Bar!",30)
	  WinSetState($WinHndl,"",@SW_HIDE)
   Case "show"&@CRLF
	  TrayTip("Server","Show RDP Bar!",30)
	  WinSetState($WinHndl,"",@SW_SHOW)
   Case "bye"&@CRLF
	  TrayTip("Server","Client Send bye msg",30)
	  TCPCloseSocket($hSocket)
   Case Else
	  TrayTip("Server","Unknow Command " & $sReceived,30)
   EndSwitch

EndFunc

Func NewClient($hSocket, $iError)
   ;TrayTip("Server","New Client Arrived, Sending Hello MSG ",10)
   _TCP_Send($hSocket, "Welcome To Hide And Show RDP Connection BAR..." & @CRLF)
EndFunc

Func DisConnect($hSocket, $iError)
   ;TrayTip("Server","Client Has Been Disconnect...",10)
EndFunc

Func GetServer()
   Local $iPID = Run('c:\Windows\System32\cmd.exe /c ping ' & EnvGet("CLIENTNAME") & ' -n 1 ', 'c:\Windows\System32\', @SW_HIDE, $STDOUT_CHILD)
   ProcessWaitClose($iPID)
   Local $sOutput = StdoutRead($iPID)
   ;ConsoleWrite($sOutput)
   Local $aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)
   Local $sIP = StringReplace(StringSplit($aArray[3],' ')[3],":","")

   If @error Then
        MsgBox($MB_SYSTEMMODAL, "", @error)
    Else
	  Return $sIP
    EndIf
EndFunc
