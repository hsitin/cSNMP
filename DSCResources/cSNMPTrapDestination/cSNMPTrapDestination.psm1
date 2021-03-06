function Get-TargetResource 
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param 
    (
		[parameter(Mandatory = $true)]
		[System.String]
		$Destination,

        [System.String]
        $Community        
	)

	Write-Verbose "Gathering all permitted Managers"
	$Destinations = [PSCustomObject](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community").psbase.properties | ? { 
            $_.Name -notin @('PSDrive','PSProvider','PSCHildName','PSPath','PSParentPath') 
         } | Select Name,Value

    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community") {
        $Script:DestinationList = ""
        $ofs = "="
        $Destinations | % { $Script:DestinationList += ","+"$($_.Name,$_.Value)" }
    
    
        $ReturnValue = @{
            CommunityList=$Script:DestinationList.substring(1)
        }
    }
    else {
        $ReturnValue = @{
            CommunityList="No destinations specified"
        }
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
		$Destination,
        
        [System.String]
		$Community,

        [ValidateSet("Present","Absent")]
		[System.String]
		$Ensure

	)
    
    # Gather all registered permitted managers
    $Destinations = [PSCustomObject](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community").psbase.properties | ? { 
            $_.Name -notin @('PSDrive','PSProvider','PSCHildName','PSPath','PSParentPath') 
         } | Select Name,Value
    switch ($Ensure) {
        "Present" {
            [Int]$LastNum = ($Destinations |  Sort-Object Name | Select Name -Last 1).Name
            $LastNum++
            Write-Verbose "Adding new Manager to permitted list"
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community" -Name $LastNum -PropertyType String -Value $Destination
        }
        "Absent" {
            Write-Verbose "Removing Manager of permitted list"
            $Destinations | ? { $_.value -eq $Destination } | % {
                $Name = $_.Name.Trim()
                Remove-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community" -Name $Name
            }
        }
    }
}


function Test-TargetResource 
{
	[CmdletBinding()]
	param 
    (
		[parameter(Mandatory = $true)]
		[System.String]
		$Destination,

		[System.String]
		$Community,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

	Write-Verbose "Gathering all permitted Managers"
	$Destinations = [PSCustomObject](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$Community").psbase.properties | ? { 
            $_.Name -notin @('PSDrive','PSProvider','PSCHildName','PSPath','PSParentPath') 
         } | Select Name,Value

    #Building the Hashtable
    $Destinations | ? { $_.Value -eq $Destination } | % {
        if ($Ensure -eq "Present") {
            if ($_.Value -eq $Destination) { $Return = $true }
            else { $Return = $false }
        }
        elseif ($Ensure -eq "Absent") {
            if ($_.Value -eq $Destination) { $Return = $false }
            else { $Return = $true }
        }
    }
    $Return
}


Export-ModuleMember -Function *-TargetResource

