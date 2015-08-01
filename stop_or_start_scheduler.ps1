$instance = "Prod"
$instanceType = "stage"
write-host $instance
$action = "false"
write-host $action
$do = "stop"
if ($instance -eq "Prod"){
	$computers = "D:\sdc\prod_$instanceType.txt"
	if($instanceType -eq "prod") { $serviceType = "prod" } else { $serviceType = "stage" }
}
elseif ($instance -eq "Care"){
	$computers = "D:\sdc\care_$instanceType.txt"
	if($instanceType -eq "prod") { $serviceType = "care" } else { $serviceType = "carestage" }
}
else  {
	$computers = "D:\sdc\saas_$instanceType.txt"
	if($instanceType -eq "prod") { $serviceType = "ustech" } else { $serviceType = "ustechstage" }
}
switch($instance){
      Prod {Get-Content $Computers | foreach { 
		cmd /c sc \\$_ $do sdc.scheduler.$serviceType
		}}
      Care {Get-Content $Computers | foreach { 
		cmd /c sc \\$_ $do sdc.scheduler.$serviceType
		}}
      Ustech {Get-Content $Computers | foreach { 
		cmd /c sc \\$_ $do sdc.scheduler.$serviceType
		}}
      default{write-host "no action"}
}
write-host $lastexitcode
exit $lastexitcode