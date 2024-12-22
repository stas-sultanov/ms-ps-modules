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
process
{
	# disable annoying Az warnings
	$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

	# get current script directory
	$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

	# import PowerShell module: Helpers
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\.NET\ConsoleOperationLogger.psm1') -NoClobber -Force;

	# improt PowerShell module: Power Platform
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	# create logger
	$log = New-ConsoleOperationLogger 30;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	<# STEP #>

	$log.OperationBegin('Get root Business Unit Id');

	$rootBusinessUnitId = PowerPlatform.BusinessUnit.GetRootId `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $rootBusinessUnitId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($rootBusinessUnitId)" : $null);

	<# STEP #>

	$log.OperationBegin('Get Role Id Basic User');

	$basicUserRoleId = PowerPlatform.Role.GetIdByName `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-roleName 'Basic User' `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $basicUserRoleId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($basicUserRoleId)" : $null);

	<# STEP : test create if not exist #>

	$log.OperationBegin('Create System User not exist');

	$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-businessUnitId $rootBusinessUnitId `
		-environmentUrl $environmentUrl `
		-name 'Supper App' `
		-systemUserId $identityClientId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $systemUserId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($systemUserId)" : $null);

	<# STEP : test create if exist #>

	$log.OperationBegin('Create System User exist');

	$systemUserId = PowerPlatform.SystemUser.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-businessUnitId $rootBusinessUnitId `
		-environmentUrl $environmentUrl `
		-name 'Supper App' `
		-systemUserId $identityClientId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $systemUserId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($systemUserId)" : $null);

	<# STEP : test assign role #>

	$log.OperationBegin('Associate Role to System User');

	PowerPlatform.SystemUser.AssociateRole `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-systemUserId $systemUserId `
		-roleId $basicUserRoleId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $systemUserId;

	$log.OperationEnd($operationSuccess);

	<# STEP : test delete if exist #>

	$log.OperationBegin('Delete System User exist');

	$deleteResult = PowerPlatform.SystemUser.DisableAndDeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-systemUserId $systemUserId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $true -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# STEP : test delete if not exist #>

	$log.OperationBegin('Delete System User not exist');

	$deleteResult = PowerPlatform.SystemUser.DisableAndDeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-systemUserId $systemUserId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $false -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# PROCESS END #>

	$log.ProcessEnd();
}
