<#
.SYNOPSIS
	Run tests related to Plugin Package.
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
	[Parameter(Mandatory = $true)]  [Guid]    $managedIdentityId,
	[Parameter(Mandatory = $true)]  [Guid]    $pluginPackageId,
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
	$log = New-ConsoleOperationLogger 30;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	<# STEP #>

	$log.OperationBegin('Bind Managed Identity');

	PowerPlatform.PluginPackage.BindManagedIdentity `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-pluginPackageId $pluginPackageId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess();

	<# PROCESS END #>

	$log.ProcessEnd();
}
