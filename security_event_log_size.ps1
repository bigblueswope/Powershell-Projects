$strComputer = "."
$colLogFiles = Get-WmiObject -Class Win32_NTEventLogFile -ComputerName $strComputer | Where-Object {$_.LogFileName -eq 'security'}
foreach ($objLogFile in $colLogFiles) 
{ 
    "Record Number: " + $objLogFile.NumberOfRecords
    "Maximum Size: " + $objLogFile.MaxFileSize
}