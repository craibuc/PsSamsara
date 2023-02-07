<#
.SYNOPSIS
Get Samsara drivers.

.PARAMETER Token
The API token

.PARAMETER Id
ID of the driver. This can either be the Samsara-specified ID, or an external ID.  To specify an external ID, use the following format: `key:value`. For example, `payrollId:ABFS18600`.

.PARAMETER Status
active or deactivated.  Not valid when the Id parameter is specified.

.EXAMPLE
Get-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz'

Get all active drivers.

.EXAMPLE
Get-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz' -Status deactivated

Get all inactive drivers.

.EXAMPLE
Get-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz' -Id 123456

Get the driver with the specified Samsara ID.

.EXAMPLE
Get-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz' -Id 'payrollId:ABFS18600'

Get the driver with the specified external ID.
#>

function Get-SamsaraDriver
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(ParameterSetName='ById',Mandatory)]
        [string]$Id,

        [Parameter(ParameterSetName='All')]
        [ValidateSet('active','deactivated')]
        [string]$Status
    )
        
    $Headers =@{
        Authorization='Bearer {0}' -f (ConvertFrom-SecureString -SecureString $Token -AsPlainText)
        Accept='application/json'
    }

    $BaseUri='https://api.samsara.com'

    $Query = @{}
    if ($Status) { $Query.driverActivationStatus = $Status }

    do {

        # build querystring components
        $QS = foreach($Q in $Query.GetEnumerator()) {
            "{0}={1}" -f $Q.Name, $Q.Value
        }

        $Uri = if ($PSCmdlet.ParameterSetName -eq 'ById') {
            "$BaseUri/fleet/drivers/$Id"
        }
        else {
            $QS.Length -gt 0 ? "$BaseUri/fleet/drivers?$( $QS -join '&' )" : "$BaseUri/fleet/drivers"
        }
        Write-Debug "Uri: $Uri"
    
        $Response = Invoke-WebRequest -Method Get -Uri $Uri -Headers $Headers -Verbose:$False

        if ($Response) {

            # data and pagination
            $Content = $Response.Content | ConvertFrom-Json

            # next page
            $Query.after = $Content.pagination.endCursor
    
            # return data
            $Content.data
        }
    
    } while ( $Content.pagination.hasNextPage -eq $True )

}
