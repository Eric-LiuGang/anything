Add-PSSnapin VMware.VimAutomation.Core

$vcenter=''
$user=''
$password=''

Connect-VIServer -Server $vcenter -User $user -Password $password
Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"} | Select Name,@{N='TargetDS';E={'Backup volume'}},Host | ConvertTo-Csv -NoTypeInformation | Set-Content -Path C:\Backup\Test_vCenter_Backup_List.csv
