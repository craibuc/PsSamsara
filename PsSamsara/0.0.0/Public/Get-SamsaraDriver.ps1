<#
.SYNOPSIS

.PARAMETER Token

.EXAMPLE
Get-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz'
#>

function Get-SamsaraDriver
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token
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
        $Uri = "$BaseUri/v1/fleet/drivers"
        Write-Debug "Uri: $Uri"

        $Resonse = Invoke-WebRequest -Uri $Uri -Headers $Headers -Verbose:$False
        ($Resonse.Content | ConvertFrom-Json).drivers
    }
    
    end {}

}
