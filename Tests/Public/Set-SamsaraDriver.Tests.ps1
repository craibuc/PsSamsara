BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsSamsara/Public/"
    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . (Join-Path $PublicPath $SUT)

}

Describe 'Set-SamsaraDriver' {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Set-SamsaraDriver'

        }

        @{ParameterName='Token';Type=[securestring];Mandatory=$true},
        @{ParameterName='Id';Type=[string];Mandatory=$true},
        @{ParameterName='Name';Type=[string];Mandatory=$false},
        @{ParameterName='Username';Type=[string];Mandatory=$false},
        @{ParameterName='Password';Type=[securestring];Mandatory=$false},
        @{ParameterName='Phone';Type=[string];Mandatory=$false},
        @{ParameterName='LicenseNumber';Type=[string];Mandatory=$false},
        @{ParameterName='LicenseState';Type=[string];Mandatory=$false},
        @{ParameterName='ExternalID';Type=[object[]];Mandatory=$false},
        @{ParameterName='Status';Type=[string];Mandatory=$false} | 
        ForEach-Object {

            It "<ParameterName> is a <Type>" -TestCases $_ {
                param ($ParameterName, $Type)
                $Command | Should -HaveParameter $ParameterName -Type $Type
            }

            It "<ParameterName> mandatory is <Mandatory>" -TestCases $_ {
                param ($ParameterName, $Mandatory)

                switch ($Mandatory)
                {
                    $true { 
                        $Command | Should -HaveParameter $ParameterName -Mandatory
                    }
                    $false {
                        $Command | Should -HaveParameter $ParameterName -Not -Mandatory
                    }
                }

            }

        }

    }

    Context 'Request' {
     
        BeforeEach {
            Mock Invoke-WebRequest {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject
                $Response | Add-Member -Type NoteProperty -Name 'Content' -Value $Null -Force
                $Response
            }

            $ApiKey = '6713712c-f15e-4afd-b205-ba2ed26e6003'
            $Token = $ApiKey | ConvertTo-SecureString -AsPlainText -Force
        }

        Context 'when the mandatory parameters are supplied' {

            BeforeEach {
                $Id = '0123456789'

                Set-SamsaraDriver -Token $Token -Id $Id
            }

            It "uses the PATCH method" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Method -eq 'Patch'
                }
            }
    
            It "adds an Authorization header" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Headers.Authorization -eq "Bearer $ApiKey"
                }
            }
    
            It "adds the Id to the URL" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*/$Id*"
                }
            }

        }
    
    }

}