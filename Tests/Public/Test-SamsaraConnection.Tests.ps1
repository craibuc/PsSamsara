BeforeAll {

}

Describe 'Test-SamsaraConneciton' {

    Context 'Request' {
        BeforeEach {
            Mock Invoke-WebRequest
            $Expected = @{
                Token = ConvertTo-SecureString 'abcdefghij' -AsPlainText
            }
         
            Test-SamsaraConnection -Token $Expected.Token
        }

        It 'uses the correct Uri' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Uri -eq 'https://api.samsara.com/me'
            }
        }

        It 'uses the correct Accept header' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Headers.Accept -eq 'application/json'
            }
        }

        It 'uses the correct Authentication and Token' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Authentication -eq 'Bearer' -and
                $Token -eq $Expected.Token
            }
        }
    }
    
    Context 'Response' {
        BeforeEach {
            $Token = ConvertTo-SecureString 'abcdefghij' -AsPlainText
        }
    Context 'When a valid token is supplied' {
            BeforeEach {
                Mock Invoke-WebRequest {
                    $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject
                    $Response | Add-Member -Type NoteProperty -Name 'StatusCode' -Value 200 -Force
                    $Response    
                }
            }
            It 'returns $true' {
                Test-SamsaraConnection -Token $Token | Should -Be $true
            }
        }

        Context 'When an ivvalid token is supplied' {
            It 'throws an unauthorized excaption' {
                { Test-SamsaraConnection -Token $Token -ErrorAction Stop } | Should -Throw 'Response status code does not indicate success: 401 (Unauthorized).'
            }
        }

    }
}