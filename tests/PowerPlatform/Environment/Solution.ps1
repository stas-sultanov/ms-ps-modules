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

# disable annoying Az warnings
$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

Write-Host 'Start.' -ForegroundColor Blue;

<# prerequisite #>

Write-Host 'Get access token to access the environment.' -ForegroundColor Yellow;

$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

<# Test Solution Import #>

Write-Host 'Test Solution Import Stage      ' -ForegroundColor Yellow -NoNewline;

$importStageInfo = PowerPlatform.Solution.Stage `
	-accessToken $environmentAccessToken `
	-customizationFile (Join-Path $invocationPath $solutionV1File) `
	-environmentUrl $environmentUrl;

if ($importStageInfo.success)
{
	Write-Host "Complete. version: $($importStageInfo.versionCurrent), uploadId: $($importStageInfo.uploadId)" -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

if ($importStageInfo.versionCurrent -eq $importStageInfo.versionPrevious)
{
	Write-Host 'Solution Already Imported. Abort.' -ForegroundColor Red;

	return;
}

Write-Host 'Test Solution Import Async      ' -ForegroundColor Yellow -NoNewline;

$importAsyncOperationId = PowerPlatform.Solution.ImportAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-importJobId ([Guid]::NewGuid()) `
	-overwriteUnmanagedCustomizations $false `
	-publishWorkflows $false `
	-stageSolutionUploadId $importStageInfo.uploadId;

Write-Host "Complete. asyncOperationId: $($importAsyncOperationId)" -ForegroundColor Green;

Write-Host 'Test Solution Import Await      ' -ForegroundColor Yellow -NoNewline;

$importResult = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $importAsyncOperationId `
	-environmentUrl $environmentUrl;

if ($importResult)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# Test Solution Upgrade #>

Write-Host 'Test Solution Upgrade Stage     ' -ForegroundColor Yellow -NoNewline;

$upgradeStageInfo = PowerPlatform.Solution.Stage `
	-accessToken $environmentAccessToken `
	-customizationFile (Join-Path $invocationPath $solutionV2File) `
	-environmentUrl $environmentUrl;

if ($upgradeStageInfo.success)
{
	Write-Host "Complete. version: $($upgradeStageInfo.versionCurrent), uploadId: $($upgradeStageInfo.uploadId)" -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

Write-Host 'Test Solution Upgrade Async     ' -ForegroundColor Yellow -NoNewline;

$upgradeAsyncOperationId = PowerPlatform.Solution.StageAndUpgradeAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-importJobId ([Guid]::NewGuid()) `
	-overwriteUnmanagedCustomizations $false `
	-publishWorkflows $false `
	-stageSolutionUploadId $upgradeStageInfo.uploadId;

Write-Host "Complete. asyncOperationId: $($upgradeAsyncOperationId)" -ForegroundColor Green;

Write-Host 'Test Solution Upgrade Await     ' -ForegroundColor Yellow -NoNewline;

$upgradeResult = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $upgradeAsyncOperationId `
	-environmentUrl $environmentUrl;

if ($upgradeResult)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# Test Solution Delete #>

Write-Host 'Test Solution Uninstall Async   ' -ForegroundColor Yellow -NoNewline;

$uninstallAsyncOperationId = PowerPlatform.Solution.UninstallAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-solutionUniqueName $solutionUniqueueName;

Write-Host "Complete. asyncOperationId: $($uninstallAsyncOperationId)" -ForegroundColor Green;

Write-Host 'Test Solution Uninstall Await   ' -ForegroundColor Yellow -NoNewline;

$uninstallResult = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $uninstallAsyncOperationId `
	-environmentUrl $environmentUrl;

if ($uninstallResult)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# end #>

Write-Host 'Complete.' -ForegroundColor Blue;
