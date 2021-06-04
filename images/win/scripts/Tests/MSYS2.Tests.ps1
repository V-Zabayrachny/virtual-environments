$origPath = $env:PATH
$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

function CallExecutable {
    param (
        [Parameter(Mandatory)] [string] $Executable,
        [switch] $Negate,
        [string] $CallParameter = "version", 
        [string] $Dash
    )

    $ChangeParam = $dash + $CallParameter
    $fullCommand = "$Executable $ChangeParam"

    [bool]$succeeded = (ShouldReturnZeroExitCode -ActualValue $fullCommand).Succeeded

    if ($Negate) { $succeeded = -not $succeeded }

    if ( -not $succeeded)
    {
        if ( $Dash.Length -le "1" )
        {
            $Dash = $Dash + '-'
            CallExecutable -Executable $Executable -Dash $Dash
            return
        }
        $failureMessage = "Tool '$Executable' not installed "
    }
    else {
        $failureMessage = "Tool '$Executable' installed "
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
            $env:PATH = "C:\msys64\mingw64\bin;C:\msys32usr\bin;$origPath"
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
                    CallExecutable -Executable $Executable | Should -BeTrue 
                }
            }
            }
        
        }
 }
}

Describe "MSYS2" {
    It "<ToolName>" -TestCases @(
        @{ ToolName = "bash.exe" }
        @{ ToolName = "tar.exe" }
        @{ ToolName = "make.exe" }
    ) {
        Join-Path $msys2BinDir $ToolName | Should -Exist
    }
}