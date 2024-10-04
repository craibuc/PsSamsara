<#
.SYNOPSIS

.PARAMETER Token
The API token.

.PARAMETER Id
ID of the driver. This can either be the Samsara-specified ID, or an external ID.  To specify an external ID, use the following format: `key:value`. For example, `payrollId:ABFS18600`.

.PARAMETER Name
The driver's name.

.PARAMETER Username
The driver's username.

.PARAMETER Password
The driver's password.

.PARAMETER Phone
The driver's telephone number.

.PARAMETER LicenseNumber
The driver's license number.

.PARAMETER LicenseState
The state/province that issue the driver's license.

.PARAMETER ExternalID
Hashtable specifying the external ID's name and value.  For example, @{payrollId='ABFS18600'}

.PARAMETER Status
active or deactivated.

.EXAMPLE
@{
    Id='1'
    Name='Duck, Donald'
    Username='dduck'
    Password='secret'
    Phone='800-555-1212'
    LicenseNumber='abcdef123456'
    LicenseState='XX'
    ExternalID=@{payrollId='ABFS18600'}
    Status='active'
} | Set-SamsaraDriver -Token 'abcdefghijklmnopqrstuvwzxyz'

#>

function Set-SamsaraDriver
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(ValueFromPipelineByPropertyName)]
        [SecureString]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Phone,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LicenseNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LicenseState,

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]$ExternalID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('active','deactivated')]
        [string]$Status
    )
    
    begin {
        $BaseUri='https://api.samsara.com'
        
        $Headers =@{
            Authorization='Bearer {0}' -f (ConvertFrom-SecureString -SecureString $Token -AsPlainText)
            'Content-Type'='application/json'
            Accept='application/json'
        }
    }
    
    process 
    {
        $Uri = "$BaseUri/fleet/drivers/$Id"
        Write-Debug "Uri: $Uri"

        $Body = @{}
        if ($Name) { $Body.name = $Name }
        if ($Username) { $Body.username = $Username }
        if ($Password) { $Body.password = $Password | ConvertFrom-SecureString -AsPlainText }
        if ($Phone) { $Body.phone = $Phone }
        if ($LicenseNumber) { $Body.licenseNumber = $LicenseNumber }
        if ($LicenseState) { $Body.licenseState = $LicenseState }
        if ($ExternalID) { $Body.externalIds = $ExternalID }
        if ($Status) { $Body.driverActivationStatus = $Status }

        Write-Debug ($Body | ConvertTo-Json)

        if ($PSCmdlet.ShouldProcess($Id, "Invoke-WebRequest")) {
            
            $Response = Invoke-WebRequest -Uri $Uri -Method Patch -Body ( $Body | ConvertTo-Json ) -Headers $Headers -Verbose:$False

            if ($Response.Content) {
                ($Response.Content | ConvertFrom-Json).data
            }

        }

    }
    
    end {}

}
