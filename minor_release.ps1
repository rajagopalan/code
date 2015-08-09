move-item batch batch_temp_76.2.bat #this command will move the batch file provided in deployment doc, uploaded through jenkins to a temp file name. This is because jenkins will upload file in the name of the control.
$web_url = "http://downloads.dev.support.com/package/web/v76/web_76.1.18.0.zip" #user input
$web_url_parts = $web_url.split("/")
$m = $web_url_parts.length
$web_pack = $web_url_parts[$m-1]
$major_version = $web_url_parts[$m-2]
$console_url = "http://downloads.dev.support.com/package/console/v76/console_incontact_76.1.41.0.zip" #user input
$console_url_parts = $console_url.split("/")
$m = $console_url_parts.length
$console_pack = $console_url_parts[$m-1]
$minor_version = "2" #user input
$sdms_instance = "Prod" #user input
$string = "Release"
$type = "stage" #user input
$downloadDir = "D:\sdc\download\prod\$major_version$string\$major_version.$minor_verison"
$batch_file = "$downloadDir\web_batch.bat" #this is the actual batch file which is going to be executed.
$build = "sdcinstall_76.1.16.0" #user input
write-host $batch_file
write-host $batch_temp_76



if(([string]::IsNullOrEmpty($sdms_instance))){
	write-host "Error: sdms_instance variable is empty "
	exit 1
}
if(([string]::IsNullOrEmpty($type))){
	write-host "Error: instance_type variable is empty "
	exit 1
}
if($sdms_instance -eq "Prod"){
    write-host "D:\$major_version" #change path as per your convenience
    $downloadDir = "D:\sdc\download\prod\$major_version$string\$major_version.$minor_version"
}

if($sdms_instance -eq "SaaS"){
    $downloadDir = "D:\sdc\download\ustech\$major_version$string\$major_version"
}

write-host $downloadDir
$destination = $major_version.$minor_verison
$sz= "C:\Program Files\7-zip\7z.exe"

if(!(Test-Path -Path $downloadDir)){
	cmd /c mkdir $downloadDir
}
#move-item $batch_temp_76 -destination $batch_file
$console_pack = "$downloadDir\$console_pack"
$web_pack = "$downloadDir\$web_pack"
write-host $web_pack
write-host $web_url
$webclient = New-Object System.Net.WebClient
IF(!([string]::IsNullOrEmpty($console_url))){
    #$webclient.DownloadFile($console_url,$console_pack)
    write-host "finished downloading console package"
}
IF(!([string]::IsNullOrEmpty($web_url))){
    #$webclient.DownloadFile($web_url,$web_pack)
    write-host "finished downloading web package"
}
$targetConsoleDir = "$downloadDir\final_patch"
& $sz x -y $console_pack "-o$targetConsoleDir" #extract the console package into final patch
if(!(Test-Path -Path $web_pack)){
    write-host "web package not available to patch"
}
else{
	$c = "cmd /c $batch_file $web_pack $targetConsoleDir" #running the batch file provided by qa to extract the web package into final patch
	invoke-expression -Command:$c
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

foreach($element in $list) { write $element
write-host copy-item $targetConsoleDir -Destination\\$element\$build\ -recurse -verbose # copy the sdc build across all app servers
}

#Note:
#if there are more than two packages to be deployed, then run this job one time and then rename the final_patch folder
#run the job for the other set of packages to be deployed





