<#
.SYNOPSIS
	Run tests related to Power Platform Environment.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
.NOTES
	Copyright © 2024 Stas Sultanov.
#>
param
(
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false,
	[Parameter(Mandatory = $false)] [String]  $settingsFile = 'environment.json'
)

# disable annoying Az warnings
Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

$settingsFile = Join-Path $invocationPath $settingsFile;

<# prerequisite #>

Write-Host 'Get access token to access the Power Platform Tenant.';

$tenantAccessToken = (Get-AzAccessToken -ResourceUrl 'https://service.powerapps.com/' -AsSecureString).Token;

Write-Host 'Load environment configuration settings.';

$settings = Get-Content $settingsFile | Out-String | ConvertFrom-Json;

<# test create #>

Write-Host 'Create Environment.';

$environmentInfo = PowerPlatform.Admin.Environment.Create `
	-accessToken $tenantAccessToken `
	-properties $settings.properties `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

if ($null -eq $environmentInfo)
{
	throw 'Create Fail.';
}

Write-Host "Create Environment Complete. url: $($environmentInfo.url)";

<# test retrieve #>

Write-Host 'Retrieve Environment.';

$environmentInfoList = PowerPlatform.Admin.Environment.RetrieveAll `
	-accessToken $tenantAccessToken `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

$environmentInfo = $environmentInfoList | Where-Object { $_.domainName -eq $environmentInfo.domainName };

if ($null -eq $environmentInfo)
{
	throw 'Retrieve Fail.';
}

Write-Host "Retrieve Environment Complete. url: $($environmentInfo.url)";

<# test update #>

Write-Host 'Update Environment.';

$updateProperties = @{
	linkedEnvironmentMetadata = @{
		domainName = $settings.properties.linkedEnvironmentMetadata.domainName + 'upd'
	}
};

$environmentInfo = PowerPlatform.Admin.Environment.Update `
	-accessToken $tenantAccessToken `
	-name $environmentInfo.name `
	-properties $updateProperties `
	-ErrorAction:Stop;

Write-Host "Update Environment Complete. url: $($environmentInfo.url)";

<# test delete #>

Write-Host 'Delete Environment.';

$deleteResult = PowerPlatform.Admin.Environment.Delete `
	-accessToken $tenantAccessToken `
	-name $environmentInfo.name `
	-ErrorAction:Stop;

Write-Host "Delete Environment Complete. success: $deleteResult";
