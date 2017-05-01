#1.	Replace primary phone number in AD with column E, new phone number.
#2.	Enable UM.
#3.	Enable and configure OCS with data from column M and N.
#4.	Enable MWI Service.
#5.	User would be batched according to deployment date, column Q.  ~8am on the day of should work to execute.
#6.	Once complete can you extract a report showing all fields updated in AD.  Something the IPTEL team can use as a reference to what was scripted when.  Maybe something similar to the mail migration reports in MOSS.


# Execute on server with MWI Powershell, Exchange Management Powershell, and Quest AD Tools Powershell enabled
# Following attribs polled from csv:  DisplayName,Phone,DN,LineURI,ServerURI,WindowsEmailAddress
# Run following command:  "WSE-enable-IPTEL.ps1 [csv file]"

param([string] $file = $(throw "Please specify a CSV file."))

$users = import-csv $file -erroraction stop


$HomeServer = "CN=LC Services,CN=Microsoft,CN=OCSPool,CN=Pools,CN=RTC Service,CN=Services,CN=Configuration,DC=internal,DC=local"
$Location = "CN={C3C28BAB-454F-46DE-A856-890D49B49E2F},CN=Location Profiles,CN=RTC Service,CN=Services,CN=Configuration,DC=internal,DC=local"

foreach ($user in $users) {
	write-host $user
	add-mailboxpermission $user.DisplayName -user SEATTLE\svc_geomantmwi -accessright fullaccess
	Enable-MWIService -UMUser $user.DisplayName -IPGateway "Nortel CS1000-10.6.10.10" -Extension $user.DN -VM yes -FX no -MC no -SmsOnVM no -SmsOnFX no -SmsOnMC no -OOF no
	get-mailbox $user.DisplayName | set-mailbox -customattribute1 ("UM Enabled on " + (get-date -format g))
} 