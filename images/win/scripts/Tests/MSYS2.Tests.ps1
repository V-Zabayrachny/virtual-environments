function Test-VersionOutput {
    param (
        [Parameter(Mandatory)] [string] $Executable,
        [string] $CallParameter = "version", 
        [string] $Dash
    )
    try {
        $ChangeParam = $dash + $CallParameter
        $fullCommand = "$Executable $ChangeParam"
        $result = ShouldReturnZeroExitCode -ActualValue $fullCommand
        if (-not $result.Succeeded)
        {
            throw
        }
        Write-Host "Tool '$Executable' installed"
    }
    catch {
        if ( $Dash.Length -eq 2  )
        {
            Write-Host "Tool '$Executable' not installed" 
            Exit 1
        }
        $Dash = $Dash + '-'
        Test-VersionOutput -Executable $Executable -Dash $Dash 
    }
    return
}

$archs = (Get-ToolsetContent).MsysPackages.mingw.arch
 foreach ($arch in $archs)
 {

    foreach ( $tool in $tools)
    {
         Describe "$tool" {
            Context "$tool"{

            $Executables = (Get-ToolsetContent).MsysPackages.mingw.arch.name.executable

            foreach ( $Executable in $Executables )
            {
                if ($arch -eq "mingw-w64-i686-")
                {
                    $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin;$origPath"
                }

                It "$Executable" -Testcases @{Executable=$Executable} {
                    Test-VersionOutput -Executable $Executable | Should -ReturnZeroExitCode
                }

            }
        }
        }
    }
}