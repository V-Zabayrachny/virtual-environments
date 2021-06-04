If (Get-Command -Name Add-ShouldOperator -ErrorAction SilentlyContinue) {
    Add-ShouldOperator -Name TestVersionOutput -InternalName ShouldTestVersionOutput -Test ${function:ShouldTestVersionOutput}
}


function ShouldTestVersionOutput {
    param (
        [Parameter(Mandatory)] [string] $Executable,
        [switch] $Negate,
        [string] $CallParameter = "version", 
        [string] $Dash
    )

    $ChangeParam = $dash + $CallParameter
    $fullCommand = "$Executable $ChangeParam"

    $succeeded = (ShouldReturnZeroExitCode -ActualValue $fullCommand).Succeeded

    if ($Negate) {
        $succeeded = -not $succeeded
    } 
    if ( $succeeded -ne  "true" )
    {
        if ( $Dash.Length -le "1" )
        {
            $Dash = $Dash + '-'
            ShouldTestVersionOutput -Executable $Executable -Dash $Dash
            exit
        }
        $failureMessage = "Tool '$Executable' not installed "
    }

    if ( $succeeded.succeeded -eq  "true" )
    {
        $failureMessage = "Tool '$Executable' installed "
    }

    return @{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

 foreach ($arch in $archs)
 { 
    Describe "$arch" {
        
        if ($arch -eq "mingw-w64-i686-")
        {
            $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin"
        }
        else
        {
            $env:PATH = "C:\msys64\mingw64\bin;C:\msys32usr\bin"
        }

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
                    $env:PATH = "C:\msys64\mingw32\bin;C:\msys32usr\bin"
                }

                It "$Executable" -Testcases @{Executable=$Executable}{

                    ShouldTestVersionOutput -Executable $Executable
                }

            }
        }
        
    }
 }
}