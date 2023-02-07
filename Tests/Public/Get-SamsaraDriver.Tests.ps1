BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsSamsara/Public/"
    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . (Join-Path $PublicPath $SUT)

}

Describe 'Get-SamsaraDriver' {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Get-SamsaraDriver'
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

        Context 'Id' {
            BeforeAll {
                $ParameterName = 'Id'
            }

            It "is a [string]" {
                $Command | Should -HaveParameter $ParameterName -Type string
            }
            It "is mandatory" {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'Status' {
            BeforeAll {
                $ParameterName = 'Status'
            }

            It "is a [string]" {
                $Command | Should -HaveParameter $ParameterName -Type [string]
            }
            It "is not mandatory" {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

    }

    Context 'Request' {

        BeforeEach {
            Mock Invoke-WebRequest

            $ApiKey = '6713712c-f15e-4afd-b205-ba2ed26e6003'
            $Token = $ApiKey | ConvertTo-SecureString -AsPlainText -Force
        }

        Context 'when no, optional parameters' {

            BeforeEach {
                Get-SamsaraDriver -Token $Token
            }

            It "uses the GET method" {        
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Method -eq 'Get'
                }
            }
    
            It "adds an Authorization header" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Headers.Authorization -eq "Bearer $ApiKey"
                }
            }
    
        }

        Context 'when the Id parameter is supplied' {

            BeforeEach {
                $Id = '0123456789'

                Get-SamsaraDriver -Token $Token -Id $Id
            }

            It "adds the Id to the URL" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*/$Id*"
                }
            }

        }

        Context 'when the Status parameter is set to deactivated' {

            BeforeEach {
                $Status = 'deactivated'

                Get-SamsaraDriver -Token $Token -Status $Status
            }

            It "adds Status to the querystring" {
                Should -Invoke Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*status=deactivated*"
                }
            }
        }
    
    }

}