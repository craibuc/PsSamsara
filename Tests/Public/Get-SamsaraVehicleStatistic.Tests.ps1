BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsSamsara/Public/"
    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . (Join-Path $PublicPath $SUT)

}

Describe 'Get-SamsaraVehicleStatistic' {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Get-SamsaraVehicleStatistic'
        }

        Context 'Token' {
            BeforeAll {
                $ParameterName = 'Token'
            }

            It "is a [securestring]" {
                $Command | Should -HaveParameter $ParameterName -Type securestring
            }
            It "is mandatory" {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'Type' {
            BeforeAll {
                $ParameterName = 'Type'
            }

            It "is a [string[]]" {
                $Command | Should -HaveParameter $ParameterName -Type string[]
            }
            It "is mandatory" {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'VehicleId' {
            BeforeAll {
                $ParameterName = 'VehicleId'
            }

            It "is a [string[]]" {
                $Command | Should -HaveParameter $ParameterName -Type string[]
            }
            It "is not mandatory" {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'Time' {
            BeforeAll {
                $ParameterName = 'Time'
            }

            It "is a [datetime]" {
                $Command | Should -HaveParameter $ParameterName -Type datetime
            }
            It "is not mandatory" {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

    }

    Context 'Request' {

        BeforeAll {
            # arrange
            Mock Invoke-WebRequest

            $ApiKey = '6713712c-f15e-4afd-b205-ba2ed26e6003'
            $Token = $ApiKey | ConvertTo-SecureString -AsPlainText -Force

            $Type = 'obdOdometerMeters','gpsOdometerMeters'
        }

        Context 'when the mandatory parameters (Token and Type) are suppled' {

            BeforeEach {
                # act
                Get-SamsaraVehicleStatistic -Token $Token -Type $Type
            }

            It 'adds the token to the autorization header' {
                # assert 
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Headers.Authorization -eq "Bearer $ApiKey"
                }

            }

            It 'adds the type to the URI' {
                # assert
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*types=$( $Type -join ',' )*"
                }

            }

        }

        Context 'when the Time parameter is suppled' {

            BeforeEach {
                # areange
                $Time = Get-Date

                # act
                Get-SamsaraVehicleStatistic -Token $Token -Type $Type -Time $Time
            }

            It 'adds the time to the URI' {

                # assert
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*time=$( $Time.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssfffZ') )*"
                }

            }

        }

        Context 'when the VehicleId parameter is suppled' {

            BeforeEach {
                # areange
                $vehicleId = '0123456','ABCDEF'

                # act
                Get-SamsaraVehicleStatistic -Token $Token -Type $Type -VehicleId $VehicleId
            }

            It 'adds the vehicleIds to the URI' {

                # assert
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*vehicleIds=$( $VehicleId -join ',' )*"
                }

            }

        }

    }

}