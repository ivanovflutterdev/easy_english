param([string]$SourcePath)
$ErrorActionPreference = 'Stop'
$url = 'https://www.oxfordlearnersdictionaries.com/wordlists/oxford3000-5000'
if ($SourcePath) { $html = Get-Content -Raw -Encoding utf8 -LiteralPath $SourcePath }
else { $html = (Invoke-WebRequest -UseBasicParsing $url).Content }
$items = [regex]::Matches($html, '<li\s+data-hw="(?<word>[^"]+)"(?<attrs>[^>]*)>(?<body>.*?)</li>', 'Singleline')
if ($items.Count -lt 4500) { throw 'Oxford page structure changed or download is incomplete.' }
$words = [ordered]@{}
$levels = @('a1','a2','b1','b2','c1','c2')
foreach ($item in $items) {
    $word = [System.Net.WebUtility]::HtmlDecode($item.Groups['word'].Value)
    $attrs = $item.Groups['attrs'].Value
    $core = [regex]::Match($attrs, 'data-ox3000="([^"]*)"').Groups[1].Value
    $level = [regex]::Match($attrs, 'data-ox5000="([^"]*)"').Groups[1].Value
    $definition = [regex]::Match($item.Groups['body'].Value, 'href="([^"]+)"').Groups[1].Value
    if (!$level) { continue }
    if (!$words.Contains($word)) {
        $words[$word] = [ordered]@{id=$word;word=$word;translation='';example='';level=$level.ToUpper();advanced=(!$core);source=($url);definition=('https://www.oxfordlearnersdictionaries.com'+$definition)}
    } else {
        if ($core) { $words[$word].advanced = $false }
        if ($levels.IndexOf($level) -lt $levels.IndexOf($words[$word].level.ToLower())) { $words[$word].level = $level.ToUpper() }
    }
}
$destination = Join-Path $PSScriptRoot '../assets/oxford_catalog.json'
$json = ConvertTo-Json -InputObject @($words.get_Values()) -Depth 5
[System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($destination),$json,[System.Text.UTF8Encoding]::new($false))
Write-Output "Imported $($words.get_Count()) unique headwords from Oxford."
