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
    if ($arch -eq "mingw-w64-x86_64")
    {
        $env:PATH = "C:\msys64\mingw64\bin;C:\msys32usr\bin;$origPath"
    }
    else
    {
        $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin;$origPath"
    }

    $tools = (Get-ToolsetContent).MsysPackages.mingw.arch.name

    foreach ( $tool in $tools)
    { 
         $Executables = (Get-ToolsetContent).MsysPackages.mingw.arch.name.executable

         foreach ( $Executable in $Executables )  

            $Executables = (Get-ToolsetContent).MsysPackages.mingw.arch.name.


            Describe "$Executable" {
            It "$Executable" -Testcases @{Executable=$Executable} {
                Test-VersionOutput -Executable $Executable | Should -ReturnZeroExitCode
            }

            }
    }
}