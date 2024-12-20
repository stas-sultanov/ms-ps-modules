<#
.SYNOPSIS
	Run tests related to Managed Identity.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
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
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false
)

# disable annoying Az warnings
$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationDirectory '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

<# prerequisite #>

Write-Host 'Get access token to access the environment.';

$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

Write-Host 'Get root Business Unit Id.';

$rootBusinessUnitId = PowerPlatform.BusinessUnit.GetRootId `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Get root Business Unit Id Complete. id: $rootBusinessUnitId";

Write-Host 'Get Basic User Role Id.';

$basicUserRoleId = PowerPlatform.Role.GetIdByName `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-roleName 'Basic User' `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Get Basic User Role Id Complete. id: $basicUserRoleId";

<# test create if not exist #>

Write-Host "Create System User. applicationId: $identityClientId";

$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
	-accessToken $environmentAccessToken `
	-applicationId $identityClientId `
	-businessUnitId $rootBusinessUnitId `
	-environmentUrl $environmentUrl `
	-name 'Supper App' `
	-systemUserId $identityClientId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Create System User Complete. id: $systemUserId";

<# test create if exist #>

Write-Host "Create System User. applicationId: $identityClientId";

$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
	-accessToken $environmentAccessToken `
	-applicationId $identityClientId `
	-businessUnitId $rootBusinessUnitId `
	-environmentUrl $environmentUrl `
	-name 'Supper App' `
	-systemUserId $identityClientId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Create System User Complete. id: $systemUserId";

<# test assign role #>

Write-Host 'Associate Role to System User.';

PowerPlatform.SystemUser.AssociateRole `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-systemUserId $systemUserId `
	-roleId $basicUserRoleId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host 'Associate Role to System User Complete.';

<# test delete if exist #>

Write-Host "Delete System User. id: $systemUserId";

$deleteResult = PowerPlatform.SystemUser.DisableAndDeleteIfExist `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-systemUserId $systemUserId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Delete System User Complete. success: $deleteResult";

<# test delete if not exist #>

Write-Host "Delete System User. id: $systemUserId";

$deleteResult = PowerPlatform.SystemUser.DisableAndDeleteIfExist `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-systemUserId $systemUserId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Delete System User Complete. success: $deleteResult";

<# end #>
