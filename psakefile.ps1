# Include ./shared.psakefile.ps1

Properties {
  $ModuleName='PsSamsara'
}

Task Symlink -description "Create a symlink for '$ModuleName' module" {
  $Here = Get-Location
  Push-Location ~/.local/share/powershell/Modules
  ln -s "$Here/$ModuleName" $ModuleName
  Pop-Location
}

Task Publish -description "Publish module '$ModuleName' to repository '$($Repository.Name)'" {
  Publish-Module -name $ModuleName -Repository $Repository.Name -NuGetApiKey $NuGetApiKey
}
