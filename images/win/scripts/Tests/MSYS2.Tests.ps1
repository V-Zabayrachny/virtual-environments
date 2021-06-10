$origPath = $env:PATH
$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

BeforeAll {
    $msys2Dir = "C:\msys64"
}

Describe "MSYS2" {

    It "msys2Dir" {
        $msys2Dir | Should -Exist
    }

    $env:PATH = "C:\msys64\usr\bin;C:\msys32usr\bin;$origPath"
    $TestCases = @(
        @{ ToolName = "bash.exe" }
        @{ ToolName = "tar.exe" }
        @{ ToolName = "make.exe" }
    )

    It "call <ToolName>" -TestCases $TestCases {
        (get-command "$ToolName").Source | Should -BeLike "$msys2Dir*"
    }
    
    It "way <ToolName>" -TestCases $TestCases {
        "$ToolName" | Should -TestExecutable
    }
}

foreach ($arch in $archs){
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

            $executables = ($archPackages.runtime_packages | Where-Object { $_.name -eq $tool }).executables | ForEach-Object { @{ExecName = $_} }

            It "Executable <ExecName> is installed" -TestCases $executables {
                "$ExecName" | Should -TestExecutable
            }
            }
        }
    }
}