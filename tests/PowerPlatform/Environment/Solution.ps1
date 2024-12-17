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
	[Parameter(Mandatory = $true)]  [Uri]     $environmentUrl,
	[Parameter(Mandatory = $true)]  [String]  $solutionFile1,
	[Parameter(Mandatory = $true)]  [String]  $solutionFile2,
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false
)

# disable annoying Az warnings
$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationPath '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

<# prerequisite #>

Write-Host 'Get access token to access the environment.' -ForegroundColor Yellow;

$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

<# #>
Write-Host 'Solution Import ' -ForegroundColor Yellow -NoNewline;

$importJobId = PowerPlatform.Solution.Import `
	-accessToken $environmentAccessToken `
	-customizationFile $solutionFile1 `
	-environmentUrl $environmentUrl `
	-importJobId ([Guid]::NewGuid()) `
	-overwriteUnmanagedCustomizations $false `
	-publishWorkflows $false;

Write-Host "Complete. importJobId: $($importJobId)" -ForegroundColor Green;

<# #>

Write-Host 'Solution Stage And Upgrade ' -ForegroundColor Yellow -NoNewline;

$solutionId = PowerPlatform.Solution.StageAndUpgrade `
	-accessToken $environmentAccessToken `
	-customizationFile $solutionFile2 `
	-environmentUrl $environmentUrl;

Write-Host "Complete. solutionId: $($solutionId)" -ForegroundColor Green;

<# end #>
