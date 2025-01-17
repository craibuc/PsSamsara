<#
.SYNOPSIS
Get Samsara vehicle.

.PARAMETER Token
The API token

.PARAMETER Id
ID of the vehicle. This can either be the Samsara-specified ID, or an external ID.  To specify an external ID, use the following format: `key:value`. For example, `payrollId:ABFS18600`.

.EXAMPLE
Get-SamsaraVehicle -Token 'abcdefghijklmnopqrstuvwzxyz'

Get all vehicles.

.EXAMPLE
Get-SamsaraVehicle -Token 'abcdefghijklmnopqrstuvwzxyz' -Id 123456

Get the vehicle with the specified Samsara ID.
#>

function Get-SamsaraVehicle
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(ParameterSetName='ById')]
        [string]$Id
    )
        
    $Headers =@{
        Authorization='Bearer {0}' -f (ConvertFrom-SecureString -SecureString $Token -AsPlainText)
        Accept='application/json'
    }

    $BaseUri='https://api.samsara.com'

    $Query = @{}
    
    do {

        # build querystring components
        $QS = foreach($Q in $Query.GetEnumerator()) {
            "{0}={1}" -f $Q.Name, $Q.Value
        }

        $Uri = if ($PSCmdlet.ParameterSetName -eq 'ById') {
            "$BaseUri/fleet/vehicles/$Id"
        }
        else {
            $QS.Length -gt 0 ? "$BaseUri/fleet/vehicles?$( $QS -join '&' )" : "$BaseUri/fleet/vehicles"
        }
        Write-Debug "Uri: $Uri"
    
        try {

            $Response = Invoke-WebRequest -Method Get -Uri $Uri -Headers $Headers -Verbose:$False

            if ($Response) {
    
                # data and pagination
                $Content = $Response.Content | ConvertFrom-Json
    
                # next page
                $Query.after = $Content.pagination.endCursor ? $Content.pagination.endCursor : $null
        
                # return data
                $Content.data
            }
                
        }
        catch {
            if ( $_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound ) {
                Microsoft.PowerShell.Utility\Write-Warning "NOT FOUND: Samsara Vehicle - $Id"
            }
            else {
                Write-Error ("ERROR: {0}" -f $_.ErrorDetails.Message)
            }
        }
    
    } while ( $Content.pagination.hasNextPage -eq $True )

}
