<#
.SYNOPSIS
	Run tests related to Managed Identity.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
.PARAMETER applicationId
	Application (Client) Id of the Entra Service Identity.
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
Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

<# prerequisite #>

Write-Host 'Get access token to access the environment.';

$accessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

Write-Host 'Get root Business Unit Id.';

$rootBusinessUnitId = PowerPlatform.BusinessUnit.GetRootId `
	-accessToken $accessToken `
	-environmentUrl $environmentUrl `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Get root Business Unit Id Complete. id: $rootBusinessUnitId";

Write-Host 'Get Basic User Role Id.';

$basicUserRoleId = PowerPlatform.Role.GetIdByName `
	-accessToken $accessToken `
	-environmentUrl $environmentUrl `
	-name 'Basic User' `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Get Basic User Role Id Complete. id: $basicUserRoleId";

<# test create if not exist #>

Write-Host "Create System User. applicationId: $identityClientId";

$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
	-accessToken $accessToken `
	-applicationId $identityClientId `
	-businessUnitId $rootBusinessUnitId `
	-environmentUrl $environmentUrl `
	-id $identityClientId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Create System User Complete. id: $systemUserId";

<# test create if exist #>

Write-Host "Create System User. applicationId: $identityClientId";

$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
	-accessToken $accessToken `
	-applicationId $identityClientId `
	-businessUnitId $rootBusinessUnitId `
	-environmentUrl $environmentUrl `
	-id $identityClientId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Create System User Complete. id: $systemUserId";

Write-Host 'Associate Role to System User.';

PowerPlatform.SystemUser.AssociateRoles `
	-accessToken $accessToken `
	-environmentUrl $environmentUrl `
	-id $systemUserId `
	-roleId $basicUserRoleId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host 'Associate Role to System User Complete.';

Write-Host "Delete System User. id: $systemUserId";

$deleteResult = PowerPlatform.SystemUser.DeleteIfExist `
	-accessToken $accessToken `
	-environmentUrl $environmentUrl `
	-id $systemUserId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Delete System User Complete. success: $deleteResult";

Write-Host "Delete System User. id: $systemUserId";

$deleteResult = PowerPlatform.SystemUser.DeleteIfExist `
	-accessToken $accessToken `
	-environmentUrl $environmentUrl `
	-id $systemUserId `
	-ErrorAction:Stop `
	-Verbose:$isVerbose;

Write-Host "Delete System User Complete. success: $deleteResult";
