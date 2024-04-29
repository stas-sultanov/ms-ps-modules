<#
	author:		Stas Sultanov
	contact:	stas.sultanov@outlook.com
	gitHub:		https://github.com/stas-sultanov
	profile:	https://www.linkedin.com/in/stas-sultanov
.SYNOPSIS
	Create or Reset ApiKey with name specified.
.NOTES
	Copyright © 2024 Stas Sultanov.
.PARAMETER resourceId
	Id of the Application Insights Resource.
.PARAMETER keyName
	Name of the secret key.
.OUTPUTS
	System.String
	Value of the secret key.
#>

param
(
	[Parameter(Mandatory = $true)] [System.String]	$resourceId,
	[Parameter(Mandatory = $true)] [System.String]	$keyName
)

# split resource id to get resource group name and resource name
$resourceId_split = $resourceId.Split('/');

$resourceGroupName = $resourceId_split[4];
$appInsightsName = $resourceId_split[8];

Write-Information "Application Insights [$appInsightsName] ApiKey GetAll";

# get all keys
[Array]$apiKeyList = az monitor app-insights api-key show -g $resourceGroupName --app $appInsightsName -o tsv --query '[].[name]';

# check if there are keys and required one exist
if (($null -ne $apiKeyList) -and $apiKeyList.Contains($keyName))
{
	Write-Information "Application Insights [$appInsightsName] ApiKey Remove [$keyName]";

	# remove key
	$_ = az monitor app-insights api-key delete -g $resourceGroupName --app $appInsightsName --api-key $keyName --yes;
}

Write-Information "Application Insights [$appInsightsName] ApiKey Create [$keyName]";

# create ApiKey and get key value
$result = az monitor app-insights api-key create -g $resourceGroupName --app $appInsightsName --api-key $keyName --read-properties ReadTelemetry -o tsv --query '[apiKey]';

return $result;