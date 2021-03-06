#Created by Eric
#This is the main script for test vCenter backup.

Add-PSSnapin VMware.VimAutomation.Core

#Connect to vCenter
$vcenter=''
$user=''
$password=''
Connect-VIServer -Server $vcenter -User $user -Password $password

#Import backup list
$backuplist = Import-Csv "C:\Backup\Test_vCenter_Backup_List.csv"

#Set variables
$today = (Get-Date).ToString("yyyyMMdd")
$1weekago = (Get-Date).AddDays(-7).ToString("yyyyMMdd")
$clonefailedcount = $clonesucceededcount = 0
$deletefailedcount = $deletesucceededcount = 0
$clonefailedlog = "C:\Backup\clonefailedlog.txt"
$clonesucceededlog = "C:\Backup\clonesucceededlog.txt"
$deletefailedlog = "C:\Backup\deletefailedlog.txt"
$deletesucceededlog = "C:\Backup\deletesucceededlog.txt"
$newlog = "C:\Backup\Test_vCenter_Backup_Report_$today.txt"
$oldlog = "C:\Backup\Test_vCenter_Backup_Report_$1weekago.txt"

#Begin circular process
ForEach ($target in $backuplist) {

	#Set variables
	$sourcevm = $target.Name
	$targetds = $target.TargetDS
	$targethost = $target.Host
	$clonename = $sourcevm,"backup",$today -join "_"
	$deletename = $sourcevm,"backup",$1weekago -join "_"

	#Create new backup
	New-VM -Name $clonename -VM $sourcevm -DataStore $targetds -VMHost $targethost -DiskStorageFormat thin

	#Record backup result
	If ($? -eq $false)
		{
		Out-File -FilePath $clonefailedlog -InputObject "$sourcevm" -Append
		$clonefailedcount = $clonefailedcount + 1
		}
	else
		{
		Out-File -FilePath $clonesucceededlog -InputObject "$sourcevm" -Append
		$clonesucceededcount = $clonesucceededcount + 1

		#Delete old backup
		Get-VM $deletename | Remove-VM -DeleteFromDisk -Confirm:$false

		#Record cleanup result
		If ($? -eq $false)
			{
			Out-File -FilePath $deletefailedlog -InputObject "$deletename" -Append
			$deletefailedcount = $deletefailedcount + 1
			}
		else
			{
			Out-File -FilePath $deletesucceededlog -InputObject "$deletename" -Append
			$deletesucceededcount = $deletesucceededcount + 1
			}
		}
}

#Set variables
$logtime=Get-Date
$clonefailedvm = Get-Content $clonefailedlog
$clonesucceededvm = Get-Content $clonesucceededlog
$deletefailedvm = Get-Content $deletefailedlog
$deletesucceededvm = Get-Content $deletesucceededlog

#Create new log
Out-File -FilePath $newlog -InputObject "Test vCenter Backup Report"
Out-File -FilePath $newlog -InputObject $logtime -Append
Out-File -FilePath $newlog -InputObject "==============================" -Append
Out-File -FilePath $newlog -InputObject "The following $clonesucceededcount VMs have been successfully backed up." -Append
Out-File -FilePath $newlog -InputObject $clonesucceededvm -Append
Out-File -FilePath $newlog -InputObject "" -Append
Out-File -FilePath $newlog -InputObject "The following $clonefailedcount VMs failed to backup." -Append
Out-File -FilePath $newlog -InputObject $clonefailedvm -Append
Out-File -FilePath $newlog -InputObject "" -Append
Out-File -FilePath $newlog -InputObject "==============================" -Append
Out-File -FilePath $newlog -InputObject "The following $deletesucceededcount backups have been successfully deleted." -Append
Out-File -FilePath $newlog -InputObject $deletesucceededvm -Append
Out-File -FilePath $newlog -InputObject "" -Append
Out-File -FilePath $newlog -InputObject "The following $deletefailedcount backups failed to delete." -Append
Out-File -FilePath $newlog -InputObject $deletefailedvm -Append

#Delete old log
Remove-Item $clonefailedlog -Confirm:$false
Remove-Item $clonesucceededlog -Confirm:$false
Remove-Item $deletefailedlog -Confirm:$false
Remove-Item $deletesucceededlog -Confirm:$false
Remove-Item $oldlog -Confirm:$false

#Report by mail
$mail = New-Object System.Net.Mail.MailMessage

#Set sender address
$mail.From = "itsms@ivision-china.cn";

#Set recipient address
$mail.To.Add("monitor@ivision-china.cn");
#--end--#

#Set mail subject
$mail.Subject = "Test vCenter Backup Report";

#Set mail body
$mail.Body = (Get-Content $newlog | Out-String)

#Connect to mail server
$smtp = New-Object System.Net.Mail.SmtpClient("mail.ivision-china.cn");

#Set credential
$smtp_user=''
$smtp_password=''

$smtp.Credentials = New-Object System.Net.NetworkCredential($smtp_user, $smtp_password);

#Send mail
$smtp.Send($mail);
