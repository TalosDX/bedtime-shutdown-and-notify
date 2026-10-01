' Runs a .ps1 from this folder without any console window.
' Usage: wscript.exe run-hidden.vbs <script.ps1> [args...]
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
args = ""
For i = 1 To WScript.Arguments.Count - 1
    args = args & " " & WScript.Arguments(i)
Next
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & dir & "\" & WScript.Arguments(0) & """" & args, 0, False
