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
	# disable annoying Az warnings
	$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

	# get current script directory
	$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

	# import PowerShell module: Helpers
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\.NET\ConsoleOperationLogger.psm1') -NoClobber -Force;

	# improt PowerShell module: Power Platform
	Import-Module (Join-Path $invocationDirectory '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	# create logger
	$log = New-ConsoleOperationLogger 16;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	<# STEP #>

	$log.OperationBegin('Import Stage');

	$importStageInfo = PowerPlatform.Solution.Stage `
		-accessToken $environmentAccessToken `
		-customizationFile (Join-Path $invocationDirectory $solutionV1File) `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($importStageInfo.success, ($importStageInfo.success ? "version: $($importStageInfo.versionCurrent), uploadId: $($importStageInfo.uploadId)" : $null));

	<# STEP #>

	$log.OperationBegin('Import Check');

	$noPreviousVersion = [String]::IsNullOrWhiteSpace($importStageInfo.versionPrevious);

	$log.OperationEnd($noPreviousVersion, ($noPreviousVersion ? $null : "versionPrevious: $($importStageInfo.versionPrevious)"));

	if (-not $noPreviousVersion)
	{
		Write-Host 'Process Abort' -ForegroundColor Red;

		return;
	}

	<# STEP #>

	$log.OperationBegin('Import Async');

	$importAsyncOperationId = PowerPlatform.Solution.ImportAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-importJobId ([Guid]::NewGuid()) `
		-overwriteUnmanagedCustomizations $false `
		-publishWorkflows $false `
		-stageSolutionUploadId $importStageInfo.uploadId;

	$log.OperationEndSuccess("asyncOperationId: $($importAsyncOperationId)");

	<# STEP #>

	$log.OperationBegin('Import Await');

	$importAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $importAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($importAwaitResult);

	<# STEP #>

	$log.OperationBegin('Upgrade Stage');

	$upgradeStageInfo = PowerPlatform.Solution.Stage `
		-accessToken $environmentAccessToken `
		-customizationFile (Join-Path $invocationDirectory $solutionV2File) `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($upgradeStageInfo.success, $upgradeStageInfo.success ? "version: $($upgradeStageInfo.versionCurrent), uploadId: $($upgradeStageInfo.uploadId)" : $null);

	<# STEP #>

	$log.OperationBegin('Upgrade Async');

	$upgradeAsyncOperationId = PowerPlatform.Solution.StageAndUpgradeAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-importJobId ([Guid]::NewGuid()) `
		-overwriteUnmanagedCustomizations $false `
		-publishWorkflows $false `
		-stageSolutionUploadId $upgradeStageInfo.uploadId;

	$log.OperationEndSuccess("asyncOperationId: $($upgradeAsyncOperationId)");

	<# STEP #>

	$log.OperationBegin('Upgrade Await');

	$upgradeAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $upgradeAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($upgradeAwaitResult);

	<# STEP #>

	$log.OperationBegin('Uninstall Async');

	$uninstallAsyncOperationId = PowerPlatform.Solution.UninstallAsync `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-solutionUniqueName $solutionUniqueueName;

	$log.OperationEndSuccess("asyncOperationId: $($uninstallAsyncOperationId)");

	<# STEP #>

	$log.OperationBegin('Uninstall Await');

	$uninstallAwaitResult = PowerPlatform.AsyncOperation.Await `
		-accessToken $environmentAccessToken `
		-asyncOperationId $uninstallAsyncOperationId `
		-environmentUrl $environmentUrl;

	$log.OperationEnd($uninstallAwaitResult);

	<# PROCESS END #>

	$log.ProcessEnd();
}
