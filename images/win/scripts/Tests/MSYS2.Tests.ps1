$origPath = $env:PATH
$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

function ShouldTestExecutable {
    param (
        [Parameter(Mandatory)] [string] $ActualValue,
        [switch] $Negate,
        [string] $CallParameter,
        [string] $CallerSessionState
    )

    while ($Dash.Length -le 2)
    {
        $ChangeParam = $Dash + $CallParameter
        $fullCommand = "$ActualValue $ChangeParam"
        [bool]$succeeded = (ShouldReturnZeroExitCode -ActualValue $fullCommand).Succeeded
        
        if ($succeeded)
        {
            break
        }
        $Dash = $Dash + '-'
    }

    if (-not $succeeded)
    {
        $failureMessage = "Tool '$ActualValue' not installed "
    }

    return [PSCustomObject] @{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

foreach ($arch in $archs)
{ 
    Describe "$arch" {
        
        if ($arch -eq "mingw-w64-i686-")
        {
            $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin;$origPath"
        }
        else
        {
            $env:PATH = "C:\msys64\usr\bin;C:\msys32usr\bin;$origPath"
        }

        $archPackages = $toolsetContent.mingw | Where-Object { $_.arch -eq $arch }
        $tools = $archPackages.runtime_packages.name | ForEach-Object { "$_" }

        foreach ( $tool in $tools){ 

            Context "$tool"{

            $executablesList = $archPackages.runtime_packages | Where-Object { $_.name -eq $tool }
            $executables = $executablesList.executables

            foreach ( $Executable in $Executables )
            {
                It "$Executable" -Testcases @{Executable=$Executable}{
                    "$Executable" | Should -TestExecutable -CallParameter "version"
                }
            }
            }
        
        }
    }
}

$env:PATH = "C:\msys64\usr\bin;C:\msys32usr\bin;$origPath"

Describe "MSYS2" {
    It "<ToolName>" -TestCases @(
        @{ ToolName = "bash.exe" }
        @{ ToolName = "tar.exe" }
        @{ ToolName = "make.exe" }
    ) {
        "$ToolName" | Should -TestExecutable -CallParameter "version"
    }
}