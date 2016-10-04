#provide input for sdc_url,console_url,sdms_instance, type and web_config.
$sdc_url = "http://downloads.dev.support.com/package/sdcinstall/v76/sdcinstall_76.0.11.0.7z.exe"
$console_url = "http://downloads.dev.support.com/package/console/v76/console_incontact_76.0.6.0.zip"
$sdc_url_parts = $sdc_url.split("/")
$m = $sdc_url_parts.length
$build = $sdc_url_parts[$m-1]
$console_url_parts = $console_url.split("/")
$n = $console_url_parts.length
$pack = $console_url_parts[$n-1]
$major_version = $sdc_url_parts[$m-2]
$sdms_instance = "prod" #give Value as Prod for Prod/Care
$downloadDir = ""
$storageDir = ""
$string = "Release" #user input not required
$type = "stage"
$output = ""
$web_config = "\\any.network.share\d$\jenkins\workspace\prod\web.config" #this template file contains ninjato vpn whitelisting. To avoid writing
#whitelisting into all machines after install, we copy the template into the sdc folder before we push it to app servers


if(([string]::IsNullOrEmpty($sdms_instance))){
	"output=Sdms instance variable is empty " | Out-File env.properties.
                   write-host "Error: sdms instance variable is empty"
                  exit 1
}
if(([string]::IsNullOrEmpty($type))){
	"output=type release variable is empty " | Out-File env.properites
                   write-host "Error: type release variable is empty"
	exit 1
}
if($sdms_instance -eq "Prod"){
    write-host "D:\sdc\download\prod\$major_version" #change path as per your convenience
    $downloadDir = "D:\sdc\download\prod\$major_version$string"
}

elseif($sdms_instance -eq "SaaS"){
    $downloadDir = "D:\sdc\download\ustech\$major_version$string"
}
else{
   write-host "Error: sdms instance name is not correct, it should be either Prod or SaaS. The provided value is $sdms_instance"
    exit 1
}

write-host $downloadDir #to check if download directory is created in the right place

if(!(Test-Path -Path $downloadDir)){
    Invoke-Expression "mkdir $downloadDir"
    if($lastexitcode -gt 0){
          write-host "Error: The directory creation is failed"
          write-host $lastexitcode
    }
}

$build_exe = "$downloadDir\$build"
$console_package = "$downloadDir\$pack"
$webclient = New-Object System.Net.WebClient


IF(!([string]::IsNullOrEmpty($sdc_url))){
    $webclient.DownloadFile($sdc_url,$build_exe)
   if(!(Test-Path -Path $console_package)){
          write-host "Error: sdc not downloaded"
          exit 1
    }
else{
    write-host "finished downloading sdc"
   }
 }

IF(!([string]::IsNullOrEmpty($console_url))){
    #$webclient.DownloadFile($console_url,$console_package)
    if (!(Test-Path -Path $console_package)){
       write-host "Error: console not downloaded"
       exit 1
    }
else{
       write-host "findished downloading console package"
     }
}


$build_dir = $build.Replace(".7z.exe","")
$build_dir1 =  "$downloadDir\$build_dir"
$sz= "C:\Program Files\7-zip\7z.exe" #configure 7zip executable path
$targetConsoleDir = "$downloadDir\final_patch"


#& $sz x $console_package "-o$targetConsoleDir" # extract the console package into a temp folder

if($lastexitcode -gt 0){
          write-host "Error: in extracting console package"
          exit 1
    }

Set-Location -Path $downloadDir
Get-Location
#run build command
cmd /c $build # run sdcinstall

#cmd /c xcopy $targetConsoleDir $build_dir1 /EYF # copy the contents of console package into sdcinstall folder

if($sdms_instance -eq "Prod"){
                  if(!(Test-Path -Path $web_config)){
                       write-host "Error: web_config not available"
                       exit 1
                  }
	Copy-Item $web_config -Destination $build_dir1\root\www -verbose -Force # copy the web.config into sdcinstall\root\www only incase of prod/care
}

if($sdms_instance -eq "Prod") {
	$computers =  "D:\sdc\prod_$type.txt" # use relevant file to get list of servers either for stage or production. $type determines the list
	#file should contain values like \\172.0.0.0\sdc\
}
else{
	$computers = "D:\sdc\saas_$type.txt"
}

if(!(Test-Path -Path $computers)){
       write-host "Error: The servers list is not found in $computers"
        exit 1
}

$list = Get-Content $computers 

#already release in stage, so don't do again
foreach($element in $list) { write $element
#copy-item $build_dir1 -Destination \\$element\$build_dir\ -recurse # copy the sdc build across all app servers
}
