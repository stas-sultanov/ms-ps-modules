<#
.SYNOPSIS
	Run tests related to Power Platform Environment.
.DESCRIPTION
	Connect-AzAccount must be run prior executing this script.
.NOTES
	Copyright © 2024 Stas Sultanov.
#>
param
(
	[Parameter(Mandatory = $false)] [Boolean] $isVerbose = $false,
	[Parameter(Mandatory = $false)] [String]  $parametersFile = 'testenv.params.json'
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
	$log = New-ConsoleOperationLogger 24;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Tenant Access Token');

	$tenantAccessToken = (Get-AzAccessToken -ResourceUrl 'https://service.powerapps.com/' -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $tenantAccessToken) -and (0 -lt $tenantAccessToken.Length) );

	<# STEP #>

	$log.OperationBegin('Read Environment params');

	$parametersFile = Join-Path $invocationDirectory $parametersFile;

	$parameters = Get-Content $parametersFile | Out-String | ConvertFrom-Json -AsHashtable;

	$log.OperationEndSuccess();

	<# STEP #>

	$log.OperationBegin('Create Environment');

	$environmentName = PowerPlatform.Admin.Create `
		-accessToken $tenantAccessToken `
		-properties $parameters.properties `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess("name: $($environmentName)");

	<# STEP #>

	$log.OperationBegin('Retrieve Environment');

	$environmentInfo = PowerPlatform.Admin.Retrieve `
		-accessToken $tenantAccessToken `
		-environmentName $environmentName `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess("url: $($environmentInfo.url)");

	<# STEP #>

	$log.OperationBegin('Update Environment');

	$updateProperties = @{
		linkedEnvironmentMetadata = @{
			domainName = $parameters.properties.linkedEnvironmentMetadata.domainName + 'upd'
		}
	};

	PowerPlatform.Admin.Update `
		-accessToken $tenantAccessToken `
		-environmentName $environmentInfo.name `
		-properties $updateProperties `
		-ErrorAction:Stop;

	$environmentInfo = PowerPlatform.Admin.Retrieve `
		-accessToken $tenantAccessToken `
		-environmentName $environmentInfo.name `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess("url: $($environmentInfo.url)");

	<# STEP #>

	$log.OperationBegin('Retrieve Environments');

	$environmentInfoList = PowerPlatform.Admin.RetrieveAll `
		-accessToken $tenantAccessToken `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$log.OperationEndSuccess("count: $($environmentInfoList.Count)");

	<# STEP #>

	$log.OperationBegin('Filter Environments');

	$filterResultEnvironmentName = $environmentInfoList | Where-Object { $_.domainName -eq $environmentInfo.domainName } | Select-Object -ExpandProperty name;

	$log.OperationEnd($null -ne $filterResultEnvironmentName, $null -ne $filterResultEnvironmentName ? "name: $($filterResultEnvironmentName)" : $null);

	<# STEP #>

	foreach ($key in $parameters.users.Keys)
	{
		$user = $parameters.users[$key];
	
		$log.OperationBegin('Add User to Environment');
	
		# add user
		PowerPlatform.Admin.AddUser `
			-accessToken $tenantAccessToken `
			-environmentName $environmentInfo.name `
			-userObjectId $user.objectId `
			-ErrorAction:Stop;
	
		$log.OperationEndSuccess("key: $($key), objectId: $($user.objectId)");
	};

	<# STEP #>

	$log.OperationBegin('Delete Environment');

	$deleteResult = PowerPlatform.Admin.Delete `
		-accessToken $tenantAccessToken `
		-environmentName $environmentInfo.name `
		-ErrorAction:Stop;

	$log.OperationEnd($deleteResult);

	<# PROCESS END #>

	$log.ProcessEnd();
}
