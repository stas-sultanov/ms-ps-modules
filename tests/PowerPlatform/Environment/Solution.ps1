<#
.SYNOPSIS
	Run tests related to Solution.
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
	[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]     $environmentUrl,
	[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]  $solutionUniqueueName = 'SolutionManageTest',
	[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]  $solutionV1File = 'Solution\SolutionManageTest_1_0_0_2_managed.zip',
	[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]  $solutionV2File = 'Solution\SolutionManageTest_1_0_0_3_managed.zip',
	[Parameter(Mandatory = $false)]                            [Boolean] $isVerbose = $false
)
process
{
	# get current script directory
	$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

	# import PowerShell module: Helpers
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\Helpers.psm1') -NoClobber -Force;

	# improt PowerShell module: Power Platform
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	# disable annoying Az warnings
	$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

	$log = New-ConsoleLogHelper 16;

	$log.ProcessBegin();

	# PROCESS BEGIN

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	# STEP 01

	$log.OperationBegin('Import Stage');

	$importStageInfo = PowerPlatform.Solution.Stage `
		-accessToken $environmentAccessToken `
		-customizationFile (Join-Path $invocationDirectory $solutionV1File) `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($importStageInfo.success, ($importStageInfo.success ? "version: $($importStageInfo.versionCurrent), uploadId: $($importStageInfo.uploadId)" : $null));

	# STEP 02

	$log.OperationBegin('Import Check');

	$noPreviousVersion = [String]::IsNullOrWhiteSpace($importStageInfo.versionPrevious);

	$log.OperationEnd($noPreviousVersion, ($noPreviousVersion ? $null : "versionPrevious: $($importStageInfo.versionPrevious)"));

	if (-not $noPreviousVersion)
	{
		Write-Host 'Process Abort' -ForegroundColor Red;

		return;
	}

	# STEP 03

	$log.OperationBegin('Import Async');

	$importAsyncOperationId = PowerPlatform.Solution.ImportAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-importJobId ([Guid]::NewGuid()) `
		-overwriteUnmanagedCustomizations $false `
		-publishWorkflows $false `
		-stageSolutionUploadId $importStageInfo.uploadId;

	$log.OperationEndSuccess("asyncOperationId: $($importAsyncOperationId)");

	# STEP 04

	$log.OperationBegin('Import Await');

	$importAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $importAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($importAwaitResult);

	# STEP 05

	$log.OperationBegin('Upgrade Stage');

	$upgradeStageInfo = PowerPlatform.Solution.Stage `
		-accessToken $environmentAccessToken `
		-customizationFile (Join-Path $invocationDirectory $solutionV2File) `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($upgradeStageInfo.success, $upgradeStageInfo.success ? "version: $($upgradeStageInfo.versionCurrent), uploadId: $($upgradeStageInfo.uploadId)" : $null);

	# STEP 06

	$log.OperationBegin('Upgrade Async');

	$upgradeAsyncOperationId = PowerPlatform.Solution.StageAndUpgradeAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-importJobId ([Guid]::NewGuid()) `
		-overwriteUnmanagedCustomizations $false `
		-publishWorkflows $false `
		-stageSolutionUploadId $upgradeStageInfo.uploadId;

	$log.OperationEndSuccess("asyncOperationId: $($upgradeAsyncOperationId)");

	# STEP 07

	$log.OperationBegin('Upgrade Await');

	$upgradeAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $upgradeAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($upgradeAwaitResult);

	# STEP 08

	$log.OperationBegin('Uninstall Async');

	$uninstallAsyncOperationId = PowerPlatform.Solution.UninstallAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-solutionUniqueName $solutionUniqueueName;

	$log.OperationEndSuccess("asyncOperationId: $($uninstallAsyncOperationId)");

	# STEP 09

	$log.OperationBegin('Uninstall Await');

	$uninstallAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $uninstallAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($uninstallAwaitResult);

	# PROCESS END

	$log.ProcessEnd();
}