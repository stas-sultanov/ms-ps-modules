<#
.SYNOPSIS
	Run tests related to Managed Identity.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
.PARAMETER applicationId
	Application (Client) Id of the Azure Managed Identity Resource.
.PARAMETER environmentUrl
	Url of the Power Platform Environment.
	Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
.NOTES
	Copyright © 2024 Stas Sultanov.
#>
param
(
	[Parameter(Mandatory = $true)]  [Uri]     $environmentUrl,
	[Parameter(Mandatory = $true)]  [Guid]    $identityClientId,
	[Parameter(Mandatory = $true)]  [Guid]    $identityTenantId,
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false
)

# disable annoying Az warnings
Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

<# prerequisite #>

Write-Host 'Get access token to access the environment.';

$accessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

<# test create if not exist #>

Write-Host "Create Managed Identity. applicationId: $identityClientId";

$managedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
	-accessToken $accessToken `
	-applicationId $identityClientId `
	-environmentUrl $environmentInfo.url `
	-id $identityClientId `
	-tenantId $identityTenantId;

Write-Host "Create Managed Identity Complete. id: $managedIdentityId";

<# test create if exist #>

Write-Host "Create Managed Identity. applicationId: $identityClientId";

$managedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
	-accessToken $accessToken `
	-applicationId $identityClientId `
	-environmentUrl $environmentInfo.url `
	-id $identityClientId `
	-tenantId 'd373a7a9-c9ba-45f8-9f08-ed14a10b4b11';

Write-Host "Create Managed Identity Complete. id: $managedIdentityId";

<# test delete if exist #>

Write-Host "Delete Managed Identity. id: $managedIdentityId";

$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
	-accessToken $accessToken `
	-environmentUrl $environmentInfo.url `
	-id $managedIdentityId;

Write-Host "Delete Managed Identity $deleteResult.";

<# test delete if not exist #>

Write-Host "Delete Managed Identity. id: $managedIdentityId";

$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
	-accessToken $accessToken `
	-environmentUrl $environmentInfo.url `
	-id $managedIdentityId;

Write-Host "Delete Managed Identity. success: $deleteResult";
