Describe "PHP" {
    It "Check PHP version" {
        $phpMajorMinor = (Get-ToolsetContent).php.version
        "php --version" | Should -BeLike "*${phpMajorMinor}*"
    }

    It "Check Composer version" {
        $composerMajor = (Get-ToolsetContent).composer.version
        "composer --version" | Should -BeLike "*${composerMajor}*"
    }

    It "PHP Environment variables is set." {
        ${env:PHPROOT} | Should -Not -BeNullOrEmpty
        ${env:PHPROOT} | Should -Exist
    }
}
