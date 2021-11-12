Describe "PHP" {
    It "Check version PHP" {
        $phpMajorMinor = "(Get-ToolsetContent).php.version"
        "php --version" | Should -BeLike "*${phpMajorMinor}*"
    }

    It "Check version Composer" {
        $composerMajorMinor = "(Get-ToolsetContent).composer.version"
        "composer --version" | Should -BeLike "*${composerMajorMinor}*"
    }

    It "PHP Environment variables is set." {
        ${env:PHPROOT} | Should -Not -BeNullOrEmpty
        ${env:PHPROOT} | Should -Exist
    }
}
