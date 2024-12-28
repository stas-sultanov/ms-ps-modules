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
	[Parameter(Mandatory = $true)]  [Guid]    $identityTenantId,
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false
)
process
{
	# disable annoying Az warnings
	$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

	# get current script directory
	$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

	# import PowerShell module: Helpers
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\.NET\ConsoleOperationLogger.psm1') -NoClobber -Force;

	# import PowerShell module: Power Platform
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	# create logger
	$log = New-ConsoleOperationLogger 16;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	<# STEP : test create if not exist #>

	$log.OperationBegin('Create not exist');

	$managedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-environmentUrl $environmentUrl `
		-managedIdentityId $identityClientId `
		-name 'Test' `
		-tenantId $identityTenantId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $managedIdentityId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($managedIdentityId)" : $null);

	<# STEP : test create if exist #>

	$log.OperationBegin('Create exist');

	$managedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-environmentUrl $environmentUrl `
		-managedIdentityId $identityClientId `
		-name 'Test' `
		-tenantId $identityTenantId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $managedIdentityId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($managedIdentityId)" : $null);

	<# STEP : test delete if exist #>

	$log.OperationBegin('Delete exist');

	$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $true -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# STEP : test delete if not exist #>

	$log.OperationBegin('Delete not exist');

	$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $false -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# PROCESS END #>

	$log.ProcessEnd();
}
