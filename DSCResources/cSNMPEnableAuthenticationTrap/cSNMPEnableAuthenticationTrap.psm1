function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$EnableAuthenticationTraps
	)

	$ReturnValue = @{
        EnableAuthenticationTraps = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters | Select EnableAuthenticationTraps).EnableAuthenticationTraps
    }
    $ReturnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$EnableAuthenticationTraps,
        
        [parameter(Mandatory = $true)]
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

	switch ($Ensure) {
        "Present" {
            Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters -Name EnableAuthenticationTraps -Value 1 
        }
        "Absent" {
            Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters -Name EnableAuthenticationTraps -Value 0
        }
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$EnableAuthenticationTraps,
        
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

	switch ($Ensure) {
        "Present" {
            if ((Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters | Select EnableAuthenticationTraps).EnableAuthenticationTraps -eq 1) {
                $Return = $true
            }
            else { $Return = $false }
        }
        "Absent" {
             if ((Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters | Select EnableAuthenticationTraps).EnableAuthenticationTraps -eq 0) {
                $Return = $false
            }
            else { $Return = $true }
        }
    }
    $Return
}


Export-ModuleMember -Function *-TargetResource

