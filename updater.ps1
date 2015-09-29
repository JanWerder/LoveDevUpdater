
Write-Host "                                                  " 
Write-Host "                  `..-::::::-..`                  "
Write-Host "              .:///:--......--:/+/:.              "
Write-Host "           ./+/-..................:/+:.           "
Write-Host "         -++:........................:++-         "
Write-Host "       .+o/............................/o+.       "
Write-Host "      :o+-..............................:oo:      "
Write-Host "     /oo:................................/oo/     "
Write-Host "    /oo+-----.......------------.....-----+oo:    "
Write-Host "   -oo+/----.      `.---------.      .----/+oo.   "
Write-Host "   /oo+/---.  .---.  .-------.  .--.  .---/++o/   "
Write-Host "   ooo+/----------------------.------.---:++/oo   "
Write-Host "   ooo++/::::::::::::::::::::::::::::::::/+/:oo   "
Write-Host "   ooo+++/::::::::::::::::::::::::::::::/++/:oo   "
Write-Host "   /oo++++//:::::::::::::::::::::::::://++/:/o/   "
Write-Host "   -oo++++++///::::::::::::::::::::///+++/::+o.   "
Write-Host "    /oo++++++++////////////////////++++//::/o:    "
Write-Host "    `/oo++++++++++++///////////+++++////:-/o/     "
Write-Host "      /oo+++++++++++++++++++++++//////:-:/o:      "
Write-Host "       -+oo+//+++++++++++++++///////::-/++.       "
Write-Host "         -+o+/////+++++++/////////:-:/++-         "
Write-Host "           ./+o+//::://////::::-::/++:.           "
Write-Host "              .:/+o+++////////+++/:.              "
Write-Host "                  `..-::::::-..`                  "
Write-Host "                                           "



Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

$apiUrl = 'https://ci.appveyor.com/api'
$token = 'xxx'
$headers = @{
  "Authorization" = "Bearer $token"
  "Content-type" = "application/json"
}
$accountName = 'AlexSzpakowski'
$projectSlug = 'love'

$downloadLocation = ''

# get project with last build details
$project = Invoke-RestMethod -Method Get -Uri "$apiUrl/projects/$accountName/$projectSlug" -Headers $headers

# we assume here that build has a single job
# get this job id
$jobId = $project.build.jobs[0].jobId

# get job artifacts (just to see what we've got)
$artifacts = Invoke-RestMethod -Method Get -Uri "$apiUrl/buildjobs/$jobId/artifacts" -Headers $headers

# Choose the second artifact, to download the zip
$artifactFileName = $artifacts[1].fileName

# Artifact will be downloaded as love.zip
$localArtifactPath = "$env:APPDATA\love.zip"

Write-Host "Found Latest Build..."
Write-Host "Downloading Latest Build..."

# download artifact
# -OutFile - is local file name where artifact will be downloaded into
Invoke-RestMethod -Method Get -Uri "$apiUrl/buildjobs/$jobId/artifacts/$artifactFileName" `
     -OutFile $localArtifactPath -Headers $headers

Write-Host "Downloaded Latest Build..."

#Generate the unzipped folder String. Might fail if the content doesn't match the name of the zip file
$folderName = $artifactFileName.TrimStart("build").SubString(1).TrimEnd(".zip")

Write-Host "Unzipping The Build..."
#unzip
Unzip $localArtifactPath "$env:APPDATA\love_unzip"

Get-ChildItem -Path "$env:APPDATA\love_unzip\$folderName\*.*" -Recurse -Force | Move-Item -Destination "C:\Program Files\LOVE" -Force

Write-Host "Copied new files..."
Write-Host "Done."