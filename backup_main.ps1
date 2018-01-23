#Created by Eric
#This is a wrapper script for test vCenter backup.

#Set variables
$today = (Get-Date).ToString("yyyyMMdd")

#Get current vmlist at first /edit by chenzhiyin 171024
PowerShell C:\Backup\Get-VM list bak.ps1

#Call out main script
PowerShell C:\Backup\Test_vCenter_Backup_Main.ps1 > C:\Backup\Test_vCenter_Backup_Log_$today.txt
