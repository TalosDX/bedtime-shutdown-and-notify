# Создаёт (или перезаписывает) задачу «Автовыключение Компа» в Планировщике:
# запуск в 21:45, 22:45 … 6:45, выключение ровно в 22:00, 23:00 … 7:00.
$taskName = 'Автовыключение Компа'

$triggers = foreach ($hour in (21..23) + (0..6)) {
    New-ScheduledTaskTrigger -Daily -At ('{0}:45' -f $hour)
}
$action = New-ScheduledTaskAction -Execute 'wscript.exe' `
    -Argument "`"$PSScriptRoot\run-hidden.vbs`" bedtime-shutdown.ps1"
# Interactive = «Выполнять только для зарегистрированного пользователя», иначе баннер и звук не видны
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
$settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $taskName -Description 'Неотключаемое' -Trigger $triggers `
    -Action $action -Principal $principal -Settings $settings -Force | Out-Null

Get-ScheduledTask -TaskName $taskName | Select-Object -ExpandProperty Triggers |
    ForEach-Object { ([datetime]$_.StartBoundary).ToString('HH:mm') }
"Готово: задача «$taskName» обновлена."
