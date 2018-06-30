#Get-EventLog System -Newest 20 -Source "Service*" | Format-Table TimeWritten, EventID, Source, EntryType, MachineName, UserName, Message -auto
Get-EventLog System -Newest 20 | Format-Table TimeWritten, EventID, Source, EntryType, MachineName, UserName, Message -auto
