Properties {
  $RepositoryName='Lorenz-Nexus'
  $ModuleName='PsSamsara'
}

Task Symlink -description "Create a symlink for '$ModuleName' module" {
  $Here = Get-Location
  Push-Location ~/.local/share/powershell/Modules
  ln -s "$Here/$ModuleName" $ModuleName
  Pop-Location
}

Task Publish -description "Publish module '$ModuleName' to repository '$($RepositoryName)'" {
  Publish-Module -name $ModuleName -Repository $RepositoryName -NuGetApiKey $NuGetApiKey
}
