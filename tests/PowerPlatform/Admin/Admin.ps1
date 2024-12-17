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

	Import-Module (Join-Path $invocationPath '..\..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

	$parametersFile = Join-Path $invocationPath $parametersFile;

	Write-Host 'Start.' -ForegroundColor Blue;

	<# prerequisite #>

	Write-Host 'Get access token to access the Power Platform Tenant.' -ForegroundColor Yellow;

	$tenantAccessToken = (Get-AzAccessToken -ResourceUrl 'https://service.powerapps.com/' -AsSecureString).Token;

	Write-Host 'Load environment parameters.' -ForegroundColor Yellow;

	$parameters = Get-Content $parametersFile | Out-String | ConvertFrom-Json -AsHashtable;

	<# test create #>

	Write-Host 'Test Create Environment.        ' -NoNewline;

	$environmentName = PowerPlatform.Admin.Create `
		-accessToken $tenantAccessToken `
		-properties $parameters.properties `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Complete. name: $($environmentName)" -ForegroundColor Green;

	Write-Host 'Test Retrieve Environment.      ' -NoNewline;

	$environmentInfo = PowerPlatform.Admin.Retrieve `
		-accessToken $tenantAccessToken `
		-environmentName $environmentName `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Complete. url: $($environmentInfo.url)" -ForegroundColor Green;

	<# test retrieve #>

	Write-Host 'Test Retrieve All Environments. ' -NoNewline;

	$environmentInfoList = PowerPlatform.Admin.RetrieveAll `
		-accessToken $tenantAccessToken `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	Write-Host "Complete. count: $($environmentInfoList.Count)" -ForegroundColor Green;

	Write-Host 'Test Filter Environments.       ' -NoNewline;

	$filterResultEnvironmentName = $environmentInfoList | Where-Object { $_.domainName -eq $environmentInfo.domainName } | Select-Object -ExpandProperty name;

	if ($null -ne $filterResultEnvironmentName)
	{
		Write-Host "Complete. name: $($filterResultEnvironmentName)" -ForegroundColor Green;
	}
	else
	{
		Write-Host 'Fail.' -ForegroundColor Red;
	}

	<# test add user #>

	foreach ($key in $parameters.users.Keys)
	{
		$user = $parameters.users[$key];

		Write-Host "Test Add User.                  " -NoNewline;

		# add user
		PowerPlatform.Admin.AddUser `
			-accessToken $tenantAccessToken `
			-environmentName $environmentInfo.name `
			-userObjectId $user.objectId `
			-ErrorAction:Stop;

		Write-Host "Complete. key: $($key), objectId: $($user.objectId)" -ForegroundColor Green;
	};

	<# test update #>

	Write-Host 'Test Update Environment.        ' -NoNewline;

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

	Write-Host "Complete. url: $($environmentInfo.url)" -ForegroundColor Green;

	<# test delete #>

	Write-Host 'Test Delete Environment.        ' -NoNewline;

	$deleteResult = PowerPlatform.Admin.Delete `
		-accessToken $tenantAccessToken `
		-environmentName $environmentInfo.name `
		-ErrorAction:Stop;

	if ($true -eq $deleteResult)
	{
		Write-Host 'Complete.' -ForegroundColor Green;
	}
	else
	{
		Write-Host 'Fail.' -ForegroundColor Red;
	}

	<# end #>

	Write-Host 'Complete.' -ForegroundColor Blue;
}
