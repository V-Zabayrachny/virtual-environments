$origPath = $env:PATH
$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch


Describe "MSYS2" {
    Context 'MSYS2' {
        BeforeAll {
            $msys2Dir = "C:\msys64"
            $env:PATH = "C:\msys64\usr\bin;$origPath"
        }
        
        It "msys2Dir" {
            $msys2Dir | Should -Exist
        }

        
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
}




foreach ($arch in $archs){
    Describe "$arch" {

        $archPackages = $toolsetContent.mingw | Where-Object { $_.arch -eq $arch }
        $tools = $archPackages.runtime_packages.name | ForEach-Object { "$_" }

        foreach ( $tool in $tools){

            Context "$tool"{
                        
            BeforeAll {
                if ($arch -eq "mingw-w64-i686")
                {
                    $env:PATH = "C:\msys64\mingw32\bin;$origPath"
                    $ExecDir = "C:\msys64\mingw32"
                }
                else
                {
                    $env:PATH = "C:\msys64\mingw64\bin;$origPath"
                    $ExecDir = "C:\msys64\mingw64"
                }
            }

            $executables = ($archPackages.runtime_packages | Where-Object { $_.name -eq $tool }).executables | ForEach-Object { @{ExecName = $_} }

            It "Executable <ExecName> is installed" -TestCases $executables {
                "$ExecName" | Should -TestExecutable
            }
            
            It "way <ExecName>" -TestCases $executables {
                (get-command "$ExecName").Source | Should -BeLike "$ExecDir*"
            }

            }
        }
    }
}