<#
.SYNOPSIS
	Run tests related to Plugin Assembly.
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
	[Parameter(Mandatory = $true)]  [Guid]    $pluginAssemblyId,
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

	PowerPlatform.PluginAssembly.BindManagedIdentity `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-pluginAssemblyId $pluginAssemblyId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess();

	<# STEP #>

	$log.OperationEnd($operationSuccess);

	<# PROCESS END #>

	$log.ProcessEnd();
}
