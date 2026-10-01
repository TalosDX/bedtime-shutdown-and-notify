# Создаёт (или перезаписывает) задачу «Автовыключение Компа» в Планировщике:
# запуск в 21:45, 22:45 … 6:45, выключение ровно в 22:00, 23:00 … 7:00.
# Копирует скрипты в постоянную папку, поэтому скачанную папку потом можно удалить.
$taskName = 'Автовыключение Компа'
$installDir = "$env:LOCALAPPDATA\BedtimeShutdown"

New-Item -ItemType Directory -Force $installDir | Out-Null
Copy-Item "$PSScriptRoot\bedtime-shutdown.ps1", "$PSScriptRoot\run-hidden.vbs", "$PSScriptRoot\tick.wav" `
    -Destination $installDir -Force

$triggers = foreach ($hour in (21..23) + (0..6)) {
    New-ScheduledTaskTrigger -Daily -At ('{0}:45' -f $hour)
}
$action = New-ScheduledTaskAction -Execute 'wscript.exe' `
    -Argument "`"$installDir\run-hidden.vbs`" bedtime-shutdown.ps1"
# Interactive = «Выполнять только для зарегистрированного пользователя», иначе баннер и звук не видны
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
$settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $taskName -Description 'Неотключаемое' -Trigger $triggers `
    -Action $action -Principal $principal -Settings $settings -Force | Out-Null

Get-ScheduledTask -TaskName $taskName | Select-Object -ExpandProperty Triggers |
    ForEach-Object { ([datetime]$_.StartBoundary).ToString('HH:mm') }
"Готово: задача «$taskName» обновлена, скрипты в $installDir"
