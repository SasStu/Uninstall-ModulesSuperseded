function Uninstall-ModulesSuperseded
{
    <#
    .SYNOPSIS
    This module uninstalls every module version except the latest
    
    .DESCRIPTION
    The function checks all availabale modules and unsinatlls every version except the latest.
    
    .EXAMPLE
    Uninstall-ModulesSuperseded -WhatIf
    
    .NOTES
    Administrator privileges are required to uninstall modules which are installed in the Computer Scope.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param()  
    $LatestModules = @{}
    Do
    {
        $ReRun = $false
        $modules = Get-Module -ListAvailable | Select-Object Name, Version | Sort-Object -Property Version -Descending
        Foreach ($module in $modules)
        {
            If (!($LatestModules.ContainsKey($module.name)))
            {
                $LatestModules.Add($module.name, $module.version)
            }
            ElseIf ($LatestModules.ContainsKey($module.name) -and ([System.Version]$LatestModules.Item($module.name) -lt [System.Version]$module.Version))
            {
                $LatestModules.Item($module.name) = $module.Version
                $ReRun = $true
            }
            ElseIf ($LatestModules.ContainsKey($module.name) -and ([System.Version]$LatestModules.Item($module.name) -gt [System.Version]$module.Version))
            {
                if ($PSCmdlet.ShouldProcess(($module.name + ' ' + $module.version ), 'Remove'))
                {
                    Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force -Verbose 
                }
            }
        }
    }While ($ReRun -ne $false)    
}
