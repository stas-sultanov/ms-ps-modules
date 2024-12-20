<#
.SYNOPSIS
	Run tests related to Azure Resource Group.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
.NOTES
	Copyright © 2024 Stas Sultanov.
#>
param
(
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false,
	[Parameter(Mandatory = $false)] [String]  $templateFile = 'test.bicep'
)

# disable annoying Az warnings
Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationDirectory '..\..\sources\Azure\ResourceGroup.psm1') -NoClobber -Force;

$templateFile = Join-Path $invocationDirectory $templateFile;

$context = Get-AzContext;

$context.Tenant.Id

<# test provision #>

Write-Host "Execute script.";
$result = Azure.ResourceGroup.Provision `
	-deploymentModeComplete $true `
	-deploymentName 'PROVISION TEST' `
	-location 'northeurope' `
	-tenant $context.Tenant.Id `
	-resourceGroupName 'TEST' `
	-subscription $context.Subscription.Id `
	-templateFile $testTemplateFile `
	-templateParameters @{ testInput = 'supperinput' };

$resultAsString = $result.resourceGroups.Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable;

