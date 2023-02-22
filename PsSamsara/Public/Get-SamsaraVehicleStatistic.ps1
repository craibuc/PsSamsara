<#
.SYNOPSIS

.PARAMETER Token
The API token.

.PARAMETER Type
At least one of the allowed statistics.

.PARAMETER Time
A filter on the data that returns the last known data points with timestamps less than or equal to this value. Defaults to now if not provided.

.PARAMETER VehicleId
A filter on the data based on this comma-separated list of vehicle IDs.

.EXAMPLE
Get-SamsaraVehicleStatistic -Token $Token -Type 'obdOdometerMeters','gpsOdometerMeters'

.EXAMPLE
Get-SamsaraVehicleStatistic -Token $Token -Type 'obdOdometerMeters','gpsOdometerMeters' -Time "1/1/2023 23:59"

.EXAMPLE
Get-SamsaraVehicleStatistic -Token $Token -Type 'obdOdometerMeters','gpsOdometerMeters' -VehicleId '0123456789','9876543210'

.LINK
https://developers.samsara.com/reference/getvehiclestats

#>
function Get-SamsaraVehicleStatistic
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory)]
        [ValidateSet('ambientAirTemperatureMilliC','auxInput1-auxInput13','barometricPressurePa','batteryMilliVolts','defLevelMilliPercent','ecuSpeedMph','engineCoolantTemperatureMilliC','engineImmobilizer','engineLoadPercent','engineOilPressureKPa','engineRpm','engineStates','faultCodes','fuelPercents','gps','gpsDistanceMeters','gpsOdometerMeters','intakeManifoldTemperatureMilliC','nfcCardScans','obdEngineSeconds','obdOdometerMeters','syntheticEngineSeconds','evStateOfChargeMilliPercent','evChargingStatus','evChargingEnergyMicroWh','evChargingVoltageMilliVolt','evChargingCurrentMilliAmp','evConsumedEnergyMicroWh','evRegeneratedEnergyMicroWh','evBatteryVoltageMilliVolt','evBatteryCurrentMilliAmp','evBatteryStateOfHealthMilliPercent','evAverageBatteryTemperatureMilliCelsius','evDistanceDrivenMeters','spreaderLiquidRate','spreaderGranularRate','spreaderPrewetRate','spreaderAirTemp','spreaderRoadTemp','spreaderOnState','spreaderBlastState')]
        [string[]]$Type,

        [Parameter()]
        [datetime]$Time,

        [Parameter()]
        [string[]]$VehicleId
    )

    Write-Debug "Token: $Token"
    Write-Debug "Type: $Type"
    Write-Debug "Time: $Time"
    Write-Debug "VehicleId: $VehicleId"

    $Headers =@{
        Authorization='Bearer {0}' -f (ConvertFrom-SecureString -SecureString $Token -AsPlainText)
        Accept='application/json'
    }

    $BaseUri='https://api.samsara.com/fleet/vehicles/stats'

    $Query = @{}
    if ($Type) { $Query.types = ($Type -join ',') }
    if ($VehicleId) { $Query.vehicleIds = ($VehicleId -join ',') }
    if ($Time) { $Query.time = $Time.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }

    do {

        # build querystring components
        $QS = foreach($Q in $Query.GetEnumerator()) {
            "{0}={1}" -f $Q.Name, $Q.Value
        }
        Write-Debug "QS: $QS"

        $Uri = $QS.Length -gt 0 ? "$BaseUri`?$( $QS -join '&' )" : $BaseUri
        Write-Debug "Uri: $Uri"
    
        try {

            $Response = Invoke-WebRequest -Method Get -Uri $Uri -Headers $Headers -Verbose:$False

            if ($Response) {
    
                # data and pagination
                $Content = $Response.Content | ConvertFrom-Json
    
                # next page
                $Query.after = $Content.pagination.endCursor
        
                # return data
                $Content.data
            }
                
        }
        catch {
            if ( $_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound ) {
                Microsoft.PowerShell.Utility\Write-Warning "NOT FOUND: Samsara Driver - $Id"
            }
            else {
                Write-Error ("ERROR: {0}" -f $_.ErrorDetails.Message)
            }
        }
    
    } while ( $Content.pagination.hasNextPage -eq $True )

}