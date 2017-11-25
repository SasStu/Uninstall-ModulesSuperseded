$projectRoot = Resolve-Path "$PSScriptRoot\.."
$script:ModuleName = 'Uninstall-ModulesSuperseded'

Remove-Module Uninstall-ModulesSuperseded
Import-Module "$projectRoot\$Modulename\$modulename.psm1"
Import-Module PowerShellGet

InModuleScope -ModuleName Uninstall-ModulesSuperseded {
    Describe "Uninstall-ModulesSuperseded" -Tags Build {
        [System.Array]$MockedModules = @(
            [pscustomobject]@{ Name = 'TestA'; Version = [version]'10.0.0'}
            [pscustomobject]@{ Name = 'TestA'; Version = [version]'9.0.0'}
            [pscustomobject]@{ Name = 'TestA'; Version = [version]'8.0.0'}
            [pscustomobject]@{ Name = 'TestB'; Version = [version]'6.8.0'}
            [pscustomobject]@{ Name = 'TestB'; Version = [version]'7.1.0'}
            [pscustomobject]@{ Name = 'TestA'; Version = [version]'7.0.0'}
        )

        Mock -CommandName Get-Module -ParameterFilter {$ListAvailable -eq $true} -MockWith { return $MockedModules } -Verifiable 
    
        Mock -CommandName Uninstall-Module


        it -name  'should remove all old module versions' {
            Uninstall-ModulesSuperseded -Verbose 

            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestA' -and $RequiredVersion -eq '9.0.0'}  -Times 1
            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestA' -and $RequiredVersion -eq '8.0.0'}  -Times 1
            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestA' -and $RequiredVersion -eq '7.0.0'}  -Times 1
            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestB' -and $RequiredVersion -eq '6.8.0'}  -Times 1
            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestB' -and $RequiredVersion -eq '7.1.0'}  -Times 0
            Assert-MockCalled -CommandName Uninstall-Module -Scope It -ParameterFilter {$Name -eq 'TestA' -and $RequiredVersion -eq '10.0.0'} -Times 0

            Assert-VerifiableMocks
        }
    }
}
