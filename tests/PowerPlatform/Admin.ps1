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
	[Parameter(Mandatory = $false)] [String]  $parametersFile = 'environment.json'
)
process
{
	# disable annoying Az warnings
	$null = Update-AzConfig -DisplayBreakingChangeWarning $false;

	# get current script location
	$invocationPath = Split-Path $script:MyInvocation.MyCommand.Path;

	Import-Module (Join-Path $invocationPath '..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	$parametersFile = Join-Path $invocationPath $parametersFile;

	<# prerequisite #>

	Write-Host 'Get access token to access the Power Platform Tenant.';

	$tenantAccessToken = (Get-AzAccessToken -ResourceUrl 'https://service.powerapps.com/' -AsSecureString).Token;

	Write-Host 'Load environment parameters.';

	$parameters = Get-Content $parametersFile | Out-String | ConvertFrom-Json -AsHashtable;

	<# test create #>

	Write-Host 'Create Environment.';

	$environmentName = PowerPlatform.Admin.Create `
		-accessToken $tenantAccessToken `
		-properties $parameters.properties `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Create Environment Complete. id: $($environmentName)";

	Write-Host 'Retrieve Environment Info.';

	$environmentInfo = PowerPlatform.Admin.Retrieve `
		-accessToken $tenantAccessToken `
		-environmentName $environmentName `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Retrieve Environment Complete. url: $($environmentInfo.url)";

	<# test retrieve #>

	Write-Host 'Retrieve All Environments.';

	$environmentInfoList = PowerPlatform.Admin.RetrieveAll `
		-accessToken $tenantAccessToken `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Retrieve All Environments Complete. count: $($environmentInfoList.Count)";

	Write-Host 'Look for Environment.';

	$searchEnvironmentName = $environmentInfoList | Where-Object { $_.domainName -eq $environmentInfo.domainName } | Select-Object -Property name;

	if ($null -eq $searchEnvironmentName)
	{
		throw 'Look for Environment Fail.';
	}

	Write-Host "Look for Environment Complete.";

	<# test add user #>

	Write-Host 'Get access token to access the environment.';

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentInfo.url -AsSecureString).Token;

	Write-Host 'Add User to Environment.';

	foreach ($key in $parameters.users.Keys)
	{
		$user = $parameters.users[$key];

		Write-Host "User: $key";

		# add user
		PowerPlatform.Admin.AddUser `
			-accessToken $tenantAccessToken `
			-environmentName $environmentInfo.name `
			-userObjectId $user.objectId `
			-ErrorAction:Stop;

		# get user id
		$systemUserId = PowerPlatform.SystemUser.GetIdByEntraObjectId `
			-accessToken $environmentAccessToken `
			-environmentUrl $environmentInfo.url `
			-objectId $user.objectId `
			-ErrorAction:Stop;

		foreach ($roleName in $user.roles)
		{
			# get role id
			$roleId = PowerPlatform.Role.GetIdByName `
				-accessToken $environmentAccessToken `
				-environmentUrl $environmentInfo.url `
				-roleName $roleName `
				-ErrorAction:Stop;

			# associate role to user
			PowerPlatform.SystemUser.AssociateRole `
				-accessToken $environmentAccessToken `
				-environmentUrl $environmentInfo.url `
				-systemUserId $systemUserId `
				-roleId $roleId `
				-ErrorAction:Stop `
				-Verbose:$isVerbose;
		}

		Write-Host "User: $key, id: $systemUserId";
	};

	Write-Host 'Add User to Environment Complete.';

	<# test update #>

	Write-Host 'Update Environment.';

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

	Write-Host "Update Environment Complete. url: $($environmentInfo.url)";

	<# test delete #>

	Write-Host 'Delete Environment.';

	$deleteResult = PowerPlatform.Admin.Delete `
		-accessToken $tenantAccessToken `
		-environmentName $environmentInfo.name `
		-ErrorAction:Stop;

	Write-Host "Delete Environment Complete. success: $deleteResult";

	<# end #>
}