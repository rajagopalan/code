$sdc_url = "http://downloads.dev.support.com/package/sdcinstall/v76/sdcinstall_76.0.11.0.7z.exe"
$console_url = "http://downloads.dev.support.com/package/console/v76/console_76.0.9.0.zip"
$build = "sdcinstall_76.0.11.0.7z.exe"
$pack = "console_76.0.9.0.zip"
$major_version = "V76"
$sub_version = ""
$sdms_instance = "SaaS"
$downloadDir = ""
$storageDir = ""
$string = "Release"
$type_release = "stage"


write-host $sdms_instance

if($sdms_instance -eq "Prod"){
    $downloadDir = "D:\sdc\download\prod\$major_version"
}

if($sdms_instance -eq "Care"){
    $downloadDir = "D:\sdc\download\care\$major_version"
}

if($sdms_instance -eq "SaaS"){
    $downloadDir = "D:\sdc\download\ustech\$major_version"
}

write-host $downloadDir

if(!(Test-Path -Path $downloadDir)){
    Invoke-Expression "mkdir $downloadDir"
}

$build_exe = "$downloadDir\$build"
$console_package = "$downloadDir\$pack"
$webclient = New-Object System.Net.WebClient


IF(!([string]::IsNullOrEmpty($sdc_url))){
    #$webclient.DownloadFile($sdc_url,$build_exe)
    write-host "finished downloading sdc"
 }
IF(!([string]::IsNullOrEmpty($console_url))){
    #$webclient.DownloadFile($console_url,$console_package)
    write-host "findished downloading console package"
}


write-host $type_release
write-host $lastexitcode

$build_dir = $build.Replace(".7z.exe","")
$build_dir1 =  "$downloadDir\$build_dir"
$sz= "C:\Program Files\7-zip\7z.exe"
$targetConsoleDir = "$downloadDir\final_patch"


#& $sz x $console_package "-o$targetConsoleDir"

Set-Location -Path $downloadDir
Get-Location
#cmd /c $build

#cmd /c xcopy  $targetConsoleDir $build_dir1 /EYF

cmd /c xcopy $build_dir1 \\172.16.50.100\d$\sdc\stageustech\$build_dir /EYFI