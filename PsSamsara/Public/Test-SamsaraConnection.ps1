function Test-SamsaraConnection {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [securestring]$Token
    )
    
    $BaseUri='https://api.samsara.com'
    $Headers =@{
        Accept='application/json'
    }

    $Uri = "$BaseUri/me"
    Write-Debug "Uri: $Uri"

    try {
        $Response = Invoke-WebRequest -Uri $Uri -Authentication Bearer -Token $Token -Headers $Headers -Verbose:$False
        $Response.StatusCode -eq 200
    }
    catch {
        Write-Debug "Module: $($MyInvocation.MyCommand.Module.Name)"
        Write-Debug "Command: $($MyInvocation.MyCommand.Name)"
        # Write-Debug "description2: $($Content.response.operation.result.errormessage.error.description2)"
        # Write-Debug "correction: $($Content.response.operation.result.errormessage.error.correction)"

        # create ErrorRecord
        $Exception = New-Object ApplicationException $_.Exception.Message #$Content.response.operation.result.errormessage.error.description2
        $ErrorId = "$($MyInvocation.MyCommand.Module.Name).$($MyInvocation.MyCommand.Name) - $($_.Exception.Message)" # 401
        $ErrorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified
        $ErrorRecord = New-Object Management.Automation.ErrorRecord $Exception, $ErrorId, $ErrorCategory, $Content

        # write ErrorRecord
        Write-Error -ErrorRecord $ErrorRecord # -RecommendedAction $Content.response.operation.result.errormessage.error.correction
        # Write-Error $_.Exception.Message
    }

}
