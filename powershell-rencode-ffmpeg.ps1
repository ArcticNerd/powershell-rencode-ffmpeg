$folderloc = "x"
$temploc = "x"

Get-ChildItem $folderloc -Recurse | Where-Object {$_.Length -gt 10GB} | Sort-Object Length | ForEach-Object {
if (-not($_ -like '*2160*')){
if (-not($_ -like '*.bak')){
Add-Content -Path ($temploc + '\BakupLog.Log') -Value $_.FullName
$outputlocation = $temploc + "\" + $_.DirectoryName.Substring(17) + "\" + $_.BaseName + " - conv" + $_.Extension
$newfolderlocation = $temploc + "\" + $_.DirectoryName.Substring(17) + "\"
$currentfile = $_
$stringname = $currentfile.FullName
if (-not(Test-Path -Path $outputlocation -PathType Leaf)){
New-Item -ItemType Directory -Path $newfolderlocation
ffmpeg -hwaccel cuda -i "$stringname" -pix_fmt p010le -map 0:0 -c:v hevc_nvenc -crf 12 -x265-params profile=main10 -map 0:1 -map 0:2 -c:a eac3 -map 0:4 -c:s copy $outputlocation
$logdata = $currentfile.FullName + " || " + [math]::Round(($currentfile.Length/1GB),2) + "GB || " + [math]::Round((Get-Item $outputlocation).Length/1GB,2) + "GB" + " || " + ([math]::Round(($currentfile.Length/1GB),2) - [math]::Round((Get-Item $outputlocation).Length/1GB,2)) + "GB"
rename-item $currentfile.FullName ($currentfile.FullName + ".bak")
Move-Item $outputlocation $currentfile.FullName
Add-Content -Path ($temploc + '\Log.Log') -Value $logdata
}
}
}
Start-Sleep -s 30
}
