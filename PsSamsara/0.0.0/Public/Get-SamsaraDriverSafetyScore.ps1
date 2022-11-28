<#
.SYNOPSIS

.PARAMETER Token

.PARAMETER DriverId

.PARAMETER From

.PARAMETER To

.EXAMPLE
Get-SamsaraDriverSafetyScore -Token 'abcdefghijklmnopqrstuvwzxyz' -DriverId BC8611 -From '11/1/2022' -To '11/2/22'

#>
function Get-SamsaraDriverSafetyScore
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory)]
        [int]$DriverId,

        [Parameter(Mandatory)]
        [datetime]$From,

        [Parameter(Mandatory)]
        [datetime]$To
    )
    
    begin {
        $BaseUri='https://api.samsara.com'
        
        $Headers =@{
            Authorization='Bearer {0}' -f (ConvertFrom-SecureString -SecureString $Token -AsPlainText)
            Accept='application/json'
        }
    }
    
    process 
    {
        Write-Debug "DriverId: $DriverId"
        Write-Debug "From: $From"
        Write-Debug "To: $To"

        # convert date/time to Epoch timestamp (# of elapsed seconds since 1/1/1970 at UTC)
        $FromEpoch = "{0}000" -f (Get-Date -Date $From -UFormat %s)
        $ToEpoch = "{0}000" -f (Get-Date -Date $To -UFormat %s)

        $Uri = "$BaseUri/v1/fleet/drivers/$DriverId/safety/score?startMs=$FromEpoch&endMs=$ToEpoch"
        Write-Debug "Uri: $Uri"

        $Resonse = Invoke-WebRequest -Uri $Uri -Headers $Headers -Verbose:$False
        $Resonse.Content | ConvertFrom-Json
    }
    
    end {}

}