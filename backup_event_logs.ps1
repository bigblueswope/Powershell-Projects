#Commented out line adds all Event Log Files to an array
$colLogFiles = Get-WmiObject -Class Win32_NTEventLogFile

if ( (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain ){
    $domname = (Get-WmiObject -Class Win32_ComputerSystem).Domain
} elseif ( (Get-WmiObject -Class Win32_ComputerSystem).Workgroup) {
    $domname = (Get-WmiObject -Class Win32_ComputerSystem).Workgroup
} else {
    $domname = "NONE"
}
$compname = $env:computername
$temp = $env:temp
$dt = Get-Date -format "yyyyMMdd_HHmmss"
$id = $env:temp + "\" + $domname + "_" + $compname + "_" + $dt
$zipname = $id + "_logs.zip"
$tasklistfile= $id + "_tasklist.txt"
$startupcommandsfile = $id + "_startupcommands.txt"
$fwrulesfile = $id + "_fwrules.txt"
$logs = @()

function Add-Zip
{
	param([string]$zipfilename)

	if(-not (test-path($zipfilename)))
	{
		set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		(dir $zipfilename).IsReadOnly = $false	
	}
	
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($zipfilename)
	
	foreach($file in $input) 
	{ 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 500
			Remove-Item $file
	}
}


foreach ($objLogFile in $colLogFiles) 
{ 
	if ( $objLogFile.NumberOfRecords -gt 0 ) {
        $logname = split-path $objLogFile.Name -leaf
		$fqlogname = $id + "_" + $logname
		[void]$objLogFile.BackupEventlog("$fqlogname")
		$logs += "$fqlogname"
		dir "$fqlogname" | Add-Zip $zipname
	}
}

tasklist /m | Out-File $tasklistfile -width 500
dir $tasklistfile | Add-Zip $zipname

wmic startup | Out-File $startupcommandsfile 
dir $startupcommandsfile | Add-Zip $zipname

netsh advfirewall firewall show rule name=all | $fwrulesfile
dir $fwrulesfile | Add-Zip $zipname

