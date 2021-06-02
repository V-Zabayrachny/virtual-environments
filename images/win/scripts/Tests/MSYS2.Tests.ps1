function Test-VersionOutput {
    param (
        [Parameter(Mandatory)] [string] $Executable,
        [switch] $Negate,
        [string] $CallParameter = "version", 
        [string] $Dash
    )

    $ChangeParam = $dash + $CallParameter
    $fullCommand = "$Executable $ChangeParam"

    [bool]$succeeded = $fullCommand.ExitCode -eq 0
    if ($Negate) {
        $succeeded = -not $succeeded
    } 

    if (-not $result.Succeeded)
    {
        if ( $Dash.Length -eq 2  )
        {
            Write-Host "Tool '$Executable' not installed" 
            Exit 1
        }
        $Dash = $Dash + '-'
        Test-VersionOutput -Executable $Executable -Dash $Dash    
    }
    Write-Host "Tool '$Executable' installed"

    return [PSCustomObject] @{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

 foreach ($arch in $archs)
 {
     Write-Host $arch 
    Describe "$arch" {

        $archPackages = $toolsetContent.mingw | Where-Object { $_.arch -eq $arch }
        $tools = $archPackages.runtime_packages.name | ForEach-Object { "$_" }

        foreach ( $tool in $tools){ 
            Context "$tool"{

            $executablesList = $archPackages.runtime_packages | Where-Object { $_.name -eq $tool }
            $executables = $executablesList.executables

            foreach ( $Executable in $Executables )
            {
                if ($arch -eq "mingw-w64-i686-")
                {
                    $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin;$origPath"
                }

                It "$Executable" -Testcases @{Executable=$Executable}{

                    Test-VersionOutput -Executable $Executable | Should -ReturnZeroExitCode
                }

            }
        }
        }
    }
}