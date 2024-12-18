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
	[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]  $solutionV1File = 'test_1.zip',
	[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]  $solutionV2File = 'test_2.zip',
	[Parameter(Mandatory = $false)]                            [Boolean] $isVerbose = $false
)

# disable annoying Az warnings
$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

<# prerequisite #>

Write-Host 'Get access token to access the environment.' -ForegroundColor Yellow;

$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

<# Test Solution Install #>

Write-Host 'Test Solution V1 Stage ' -ForegroundColor Yellow -NoNewline;

$solutionStageInfoV1 = PowerPlatform.Solution.Stage `
	-accessToken $environmentAccessToken `
	-customizationFile (Join-Path $invocationPath $solutionV1File) `
	-environmentUrl $environmentUrl;

if ($solutionStageInfoV1.success)
{
	Write-Host "Complete. version: $($solutionStageInfoV1.versionCurrent), uploadId: $($solutionStageInfoV1.uploadId)" -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

if ($solutionStageInfoV1.versionCurrent -eq $solutionStageInfoV1.versionPrevious)
{
	Write-Host 'Solution Already Imported. Abort.' -ForegroundColor Red;

	return;
}

Write-Host 'Test Solution V1 Import Async ' -ForegroundColor Yellow -NoNewline;

$importAsyncOperationIdV1 = PowerPlatform.Solution.ImportAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-overwriteUnmanagedCustomizations $false `
	-publishWorkflows $false `
	-stageSolutionUploadId $solutionStageInfoV1.uploadId;

Write-Host "Complete. asyncOperationId: $($importAsyncOperationIdV1)" -ForegroundColor Green;

Write-Host 'Test Solution V1 Import Await ' -ForegroundColor Yellow -NoNewline;

$importCompleteV1 = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $importAsyncOperationIdV1 `
	-environmentUrl $environmentUrl;

if ($importCompleteV1)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# Test Solution Upgrade #>

Write-Host 'Test Solution V2 Stage ' -ForegroundColor Yellow -NoNewline;

$solutionStageInfoV2 = PowerPlatform.Solution.Stage `
	-accessToken $environmentAccessToken `
	-customizationFile (Join-Path $invocationPath $solutionV2File) `
	-environmentUrl $environmentUrl;

if ($solutionStageInfoV2.success)
{
	Write-Host "Complete. version: $($solutionStageInfoV2.versionCurrent), uploadId: $($solutionStageInfoV2.uploadId)" -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

Write-Host 'Test Solution V2 Import Async ' -ForegroundColor Yellow -NoNewline;

$importAsyncOperationIdV2 = PowerPlatform.Solution.ImportAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-overwriteUnmanagedCustomizations $false `
	-publishWorkflows $false `
	-stageSolutionUploadId $solutionStageInfoV2.uploadId;

Write-Host "Complete. asyncOperationId: $($importAsyncOperationIdV2)" -ForegroundColor Green;

Write-Host 'Test Solution V2 Import Await ' -ForegroundColor Yellow -NoNewline;

$importCompleteV2 = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $importAsyncOperationIdV2 `
	-environmentUrl $environmentUrl;

if ($importCompleteV2)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# Test Solution Delete #>

Write-Host 'Test Solution Uninstall Async ' -ForegroundColor Yellow -NoNewline;

$uninstallAsyncOperationId = PowerPlatform.Solution.UninstallAsync `
	-accessToken $environmentAccessToken `
	-environmentUrl $environmentUrl `
	-solutionUniqueName 'hesseses';

Write-Host "Complete. asyncOperationId: $($uninstallAsyncOperationId)" -ForegroundColor Green;

Write-Host 'Test Solution Uninstall Await ' -ForegroundColor Yellow -NoNewline;

$uninstallOperationComplete = PowerPlatform.AsyncOperation.Await `
	-accessToken $environmentAccessToken `
	-asyncOperationId $uninstallAsyncOperationId `
	-environmentUrl $environmentUrl;

if ($uninstallOperationComplete)
{
	Write-Host 'Complete.' -ForegroundColor Green;
}
else
{
	Write-Host 'Fail.' -ForegroundColor Red;
}

<# end #>
