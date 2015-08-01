$error.clear()
try{
	$computers = "D:\saas_Stage.txt"
	get-content $computers -ErrorAction SilentlyContinue
	if ($error.count -gt 0){
		write-host $error[0]
	}
}
catch{
	write-host $error[0]
}