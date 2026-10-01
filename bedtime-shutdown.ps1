# Предупреждает о выключении ПК, через 15 минут выключает.
# Запускается Планировщиком в :45 через run-hidden.vbs.
param(
    [switch]$Test   # только для проверки: паузы по 5 секунд и без выключения ПК
)

# Громкость звуков относительно системной (0.0 - 1.0)
$WarnVolume = 0.3   # звук предупреждений за 15/10/5 минут
$MinVolume  = 0.1   # с какой громкости начинается отсчёт
$MaxVolume  = 0.5   # потолок, громче не будет

$WarnSound = "$env:windir\Media\Windows Notify System Generic.wav"
$TickSound = "$PSScriptRoot\tick.wav"

Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing
$player = New-Object System.Windows.Media.MediaPlayer

function Play-Sound($path, $volume) {
    $player.Open([Uri]$path)
    $player.Volume = $volume
    $player.Play()
}

# Своё окно-баннер вместо уведомлений Windows: фокусировка внимания его не глушит.
# Поверх всех окон и не забирает фокус (игру не свернёт).
Add-Type -ReferencedAssemblies System.Windows.Forms -TypeDefinition @'
public class Banner : System.Windows.Forms.Form {
    protected override bool ShowWithoutActivation { get { return true; } }
    protected override System.Windows.Forms.CreateParams CreateParams {
        get {
            var cp = base.CreateParams;
            cp.ExStyle |= 0x08000000 | 0x08 | 0x80;   // NOACTIVATE | TOPMOST | TOOLWINDOW
            return cp;
        }
    }
}
'@
$banner = New-Object Banner
$banner.FormBorderStyle = 'None'
$banner.TopMost = $true
$banner.ShowInTaskbar = $false
$banner.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$banner.Size = New-Object System.Drawing.Size(640, 110)
$banner.StartPosition = 'Manual'
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$banner.Location = New-Object System.Drawing.Point((($screen.Width - $banner.Width) / 2), 40)
$label = New-Object System.Windows.Forms.Label
$label.Dock = 'Fill'
$label.TextAlign = 'MiddleCenter'
$label.ForeColor = [System.Drawing.Color]::White
$label.Font = New-Object System.Drawing.Font('Segoe UI', 20)
$banner.Controls.Add($label)
$hideBannerAt = [datetime]::MaxValue

function Show-Warning($text, [int]$seconds = 15) {
    $label.Text = $text
    $banner.Show()
    $script:hideBannerAt = (Get-Date).AddSeconds($seconds)
}

function Wait-Seconds($seconds) {
    $end = (Get-Date).AddSeconds($seconds)
    while ((Get-Date) -lt $end) {
        if ((Get-Date) -ge $hideBannerAt) { $banner.Hide(); $script:hideBannerAt = [datetime]::MaxValue }
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }
}

function Wait-Minutes($minutes) {
    if ($Test) { Wait-Seconds 5 } else { Wait-Seconds ($minutes * 60) }
}

# Чёрно-белый экран через Magnification API: держится, пока жив этот процесс,
# поэтому после перезагрузки цвета вернутся сами.
Add-Type -Namespace W -Name Mag -MemberDefinition @'
[DllImport("Magnification.dll")] public static extern bool MagInitialize();
[DllImport("Magnification.dll")] public static extern bool MagSetFullscreenColorEffect(float[] m);
'@
function Enable-Grayscale {
    $m = [float[]]@(0.3,0.3,0.3,0,0, 0.6,0.6,0.6,0,0, 0.1,0.1,0.1,0,0, 0,0,0,1,0, 0,0,0,0,1)
    [W.Mag]::MagInitialize() | Out-Null
    [W.Mag]::MagSetFullscreenColorEffect($m) | Out-Null
}

Show-Warning "Выключение через 15 минут`nПора закругляться"
Play-Sound $WarnSound $WarnVolume
Wait-Minutes 5

Show-Warning "Выключение через 10 минут`nСохраняйся"
Play-Sound $WarnSound $WarnVolume
Enable-Grayscale
Wait-Minutes 5

Show-Warning "Выключение через 5 минут`nСохраняйся и выходи из игры"
Play-Sound $WarnSound $WarnVolume
Wait-Minutes 4

# Отсчёт: баннер висит всю минуту, тик раз в секунду, громкость растёт от MinVolume до MaxVolume
for ($i = 60; $i -ge 1; $i--) {
    Show-Warning "Выключение через $i сек`nВсё, спать" 2
    Play-Sound $TickSound ($MinVolume + ($MaxVolume - $MinVolume) * (60 - $i) / 59)
    Wait-Seconds 1
}

if ($Test) {
    Show-Warning "ТЕСТ: здесь ПК бы выключился" 5
    Wait-Seconds 5
} else {
    & "$env:windir\System32\shutdown.exe" /s /t 0
    Start-Sleep -Seconds 300   # держим ч/б, пока идёт выключение
}
