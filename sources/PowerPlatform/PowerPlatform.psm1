using namespace System;
using namespace System.Collections.Generic;
using namespace System.IO;
using namespace Microsoft.PowerShell.Commands;

<# ##### #>
<# Types #>
<# ##### #>

class PowerPlatformEnvironmentInfo
{
	[ValidateNotNullOrEmpty()] [String] $azureLocation
	[ValidateNotNullOrEmpty()] [String] $domainName
	[ValidateNotNullOrEmpty()] [String] $name
	[ValidateNotNullOrEmpty()] [Uri]    $url
}

<# ################################### #>
<# Functions to work with Environments #>
<# ################################### #>

$EnvironmentApiUri = 'https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform';

$EnvironmentSelect = '$select=properties.linkedEnvironmentMetadata.instanceUrl,properties.azureRegion,properties.linkedEnvironmentMetadata.domainName,name';

function AdminEnvironment.Create
{
	<#
	.SYNOPSIS
		Create an environment within the Power Platform tenant.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER properties
		Object that contains configuration properties to create an environment.
	.OUTPUTS
		Short information about the environment.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([PowerPlatformEnvironmentInfo])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2024-05-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNull()]        [Object]       $properties
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($EnvironmentApiUri)/environments?api-version=$($apiVersion)&retainOnProvisionFailure=false";

		# invoke web request
		$response = InvokeWebRequestAndGetComplete -accessToken $accessToken -body @{properties = $properties } -method Post -uri $uri -verbose $isVerbose;

		# get environment name
		$name = ($response.Content | ConvertFrom-Json -AsHashtable).links.environment.path.Split('/')[4];

		# retrieve environment info
		$result = AdminEnvironment.Retrieve -accessToken $accessToken -apiVersion $apiVersion -name $name -Verbose:$isVerbose;

		return $result;
	}
}

function AdminEnvironment.Delete
{
	<#
	.SYNOPSIS
		Delete an environment from the Power Platform tenant.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER name
		Name of the Power Platform environment.
	.OUTPUTS
		True if environment deleted, False otherwise.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Boolean])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2021-04-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create requests base uri
		$baseRequestUri = "$($EnvironmentApiUri)/scopes/admin/environments/$($name)";

		# create validation web request uri
		$validateUri = [Uri] "$($baseRequestUri)/validateDelete?api-version=$($apiVersion)";

		# invoke web request to validate deletion
		$validateResponse = InvokeWebRequest -accessToken $accessToken -method Post -uri $validateUri -verbose $isVerbose;

		# get validation response content
		$validateResponseContent = $validateResponse.Content | ConvertFrom-Json -AsHashtable;

		# check if can delete
		if (-not $validateResponseContent.canInitiateDelete)
		{
			return $false;
		}

		# create deletion web request uri
		$deleteUri = [Uri] "$($baseRequestUri)?api-version=$($apiVersion)";

		# invoke web request to delete and get to completion
		$null = InvokeWebRequestAndGetComplete -accessToken $accessToken -method Delete -uri $deleteUri -verbose $isVerbose;

		return $true;
	}
}

function AdminEnvironment.Retrieve
{
	<#
	.SYNOPSIS
		Retrieve an environment info.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER name
		Name of the Power Platform environment.
	.OUTPUTS
		Short information about the environment.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([PowerPlatformEnvironmentInfo])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2024-05-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($EnvironmentApiUri)/scopes/admin/environments/$($name)?api-version=$($apiVersion)&$($EnvironmentSelect)";

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $uri -verbose $isVerbose;

		# convert config response content
		$environment = $response.Content | ConvertFrom-Json -AsHashtable;

		# create result
		$result = [PowerPlatformEnvironmentInfo]@{
			azureLocation = $environment.properties.azureRegion
			domainName    = $environment.properties.linkedEnvironmentMetadata.domainName
			name          = $environment.name
			url           = $environment.properties.linkedEnvironmentMetadata.instanceUrl
		};

		return $result;
	}
}

function AdminEnvironment.RetrieveAll
{
	<#
	.SYNOPSIS
		Retrieve information about all accessible environments.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.OUTPUTS
		Array of objects that each provides a short information about the environments.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([PowerPlatformEnvironmentInfo[]])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2024-05-01'
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($EnvironmentApiUri)/scopes/admin/environments?api-version=$($apiVersion)&$($EnvironmentSelect)";

		# invoke web request | OData $filter does not work :(
		$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $uri -verbose $isVerbose;

		# convert content
		$environmentList = ($response.Content | ConvertFrom-Json -AsHashtable).value;

		# convert items
		$result = $environmentList | ForEach-Object {
			[PowerPlatformEnvironmentInfo]@{
				azureLocation = $_.properties.azureRegion
				domainName    = $_.properties.linkedEnvironmentMetadata.domainName
				name          = $_.name
				url           = $_.properties.linkedEnvironmentMetadata.instanceUrl
			}
		};

		return [PowerPlatformEnvironmentInfo[]] $result;
	}
}

function AdminEnvironment.Update
{
	<#
	.SYNOPSIS
		Update an environment within the Power Platform tenant.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER name
		Name of the Power Platform environment.
	.PARAMETER properties
		Object that contains configuration properties to update the environment.
	.OUTPUTS
		Short information about the environment.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([PowerPlatformEnvironmentInfo])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2024-05-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name,
		[Parameter(Mandatory = $true)]  [ValidateNotNull()]        [Object]       $properties
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($EnvironmentApiUri)/scopes/admin/environments/$($name)?api-version=$($apiVersion)";
		
		# invoke web request
		$null = InvokeWebRequestAndGetComplete -accessToken $accessToken -body @{properties = $properties } -uri $uri -method Patch -verbose $isVerbose;

		# retrieve environment info
		$result = AdminEnvironment.Retrieve -accessToken $accessToken -apiVersion $apiVersion -name $name -Verbose:$isVerbose;

		return $result;
	}
}

<# ##################################### #>
<# Functions to work with Business Units #>
<# ##################################### #>

function BusinessUnit.GetRootId
{
	<#
	.SYNOPSIS
		Get Id of the root Business Unit within the Power Platform Environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/businessunit
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.OUTPUTS
		Business Unit Id.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([String])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/businessunits?%24select=businessunitid&%24filter=_parentbusinessunitid_value%20eq%20null";

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -method Get -Uri $uri -verbose $isVerbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# get business unit id
		$result = $responseContent.value[0].businessunitid;

		return $result;
	}
}

<# ####################################### #>
<# Functions to work with Managed Identity #>
<# ####################################### #>

function ManagedIdentity.CreateIfNotExist
{
	<#
	.SYNOPSIS
		Create a Managed Identity within the Power Platform Environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/managedidentity
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER applicationId
		Application (Client) Id of the Service Principal within the Entra tenant.
	.PARAMETER environmentUrl
		Url of the Power Platform environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER id
		Id of the Managed Identity within the Power Platform Environment.
	.PARAMETER tenantId
		Id of the Entra tenant.
	.OUTPUTS
		Managed Identity Id.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $applicationId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $id,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $tenantId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# check if identity exist
		$exist = ManagedIdentity.Exist -accessToken $accessToken -apiVersion $apiVersion -environmentUrl $environmentUrl -id $id -isVerbose $isVerbose;

		if ($exist)
		{
			return $id;
		}

		# create web request body
		$body = @{
			applicationid     = $applicationId
			credentialsource  = 2
			managedidentityid = $id
			subjectscope      = 1
			tenantid          = $tenantId
		};

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/managedidentities";

		# invoke web request
		$response = InvokeWebRequestAndGetComplete -accessToken $accessToken -body $body -method Post -uri $uri -verbose $isVerbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# create result from response
		$result = $responseContent.managedidentityid;

		return $result;
	}
}

function ManagedIdentity.DeleteIfExist
{
	<#
	.SYNOPSIS
		Delete a Managed Identity from the Power Platform environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/managedidentity
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER id
		Id of the Managed Identity within the Power Platform Environment.
	.OUTPUTS
		True if Managed Identity deleted, False otherwise.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Boolean])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $id
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# check if identity exist
		$exist = ManagedIdentity.Exist -accessToken $accessToken -apiVersion $apiVersion -environmentUrl $environmentUrl -id $id -verbose $isVerbose;

		if (!$exist)
		{
			return $false;
		}

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/managedidentities($($id))";

		# invoke web request
		$null = InvokeWebRequest -accessToken $accessToken -method Delete -uri $uri -verbose $isVerbose;

		return $true;
	}
}

<# ########################### #>
<# Functions to work with Role #>
<# ########################### #>

function Role.GetIdByName
{
	<#
	.SYNOPSIS
		Get Id of the Role by Name.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/role
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER name
		Name of the role.
	.OUTPUTS
		Id of the Role if it is found, null otherwise.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/roles?`$select=roleid&`$filter=name eq '$($name)'";

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $uri -verbose $isVerbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 0)
		{
			return $null;
		}

		# get result
		$result = [Guid] $responseContent.value[0].roleid;

		return $result;
	}
}

<# ############################### #>
<# Functions to work with Solution #>
<# ############################### #>

function Solution.Export
{
	<#
	.SYNOPSIS
		Export a Solution.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/exportsolutionresponse
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER managed
		True if solution should be exported as managed, False otherwise.
	.PARAMETER name
		Name of the solution to export.
	.PARAMETER outputFile
		File to write output.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Boolean]      $managed,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $outputFile
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/ExportSolution";

		# create web request body
		$requestBody = @{
			Managed      = $managed
			SolutionName = $name
		};

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -body $requestBody -method Post -uri $uri -verbose $isVerbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# convert file from base64 string to byte array
		$fileAsByteArray = [Convert]::FromBase64String($responseContent.ExportSolutionFile);

		# write byte array to file
		[File]::WriteAllBytes($outputFile, $fileAsByteArray);
	}
}

<# ################################## #>
<# Functions to work with System User #>
<# ################################## #>

function SystemUser.AssociateRoles
{
	<#
	.SYNOPSIS
		Associate role to the System User.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER id
		Id of the System User within the Power Platform Environment.
	.PARAMETER roleId
		Id of the Role to assign to the System User.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $id,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $roleId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/systemusers($($id))%2Fsystemuserroles_association%2F%24ref";

		# create web request body
		$requestBody = @{
			'@odata.id' = "$($environmentUrl)api/data/$($apiVersion)/roles($($roleId))"
		};

		# invoke web request
		$null = InvokeWebRequest -accessToken $accessToken -body $requestBody -method Post -uri $uri -verbose $isVerbose;
	}
}

function SystemUser.CreateIfNotExist
{
	<#
	.SYNOPSIS
		Create a System User within the Power Platform Environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER applicationId
		Application (Client) Id of the Service Principal within the Entra tenant.
	.PARAMETER businessUnitId
		Unique identifier of the Business Unit with which the User is associated.
		If not specified root business unit will be used.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER id
		Id of the System User within the Power Platform Environment.
	.OUTPUTS
		System User Id.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $applicationId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $businessUnitId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $id
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# check if system user exist
		$exist = SystemUser.Exist -accessToken $accessToken -apiVersion $apiVersion -environmentUrl $environmentUrl -id $id -verbose $isVerbose;

		if ($exist)
		{
			return $id;
		}

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/systemusers";

		# create web request body
		$requestBody = @{
			accessmode                  = 4
			applicationid               = $applicationId
			'businessunitid@odata.bind' = "/businessunits($businessUnitId)"
			isdisabled                  = $false
			systemuserid                = $id
		};

		# invoke web request
		$response = InvokeWebRequestAndGetComplete -accessToken $accessToken -body $requestBody -method Post -uri $uri -verbose $isVerbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;
		
		# create result from response
		$result = $responseContent.systemuserid;

		# return result
		return $result;
	}
}

function SystemUser.DeleteIfExist
{
	<#
	.SYNOPSIS
		Delete a System User from the Power Platform environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER id
		Id of the System User within the Power Platform Environment.
	.OUTPUTS
		True if System User deleted, False otherwise.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Boolean])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = 'v9.2',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $id,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# check if system user exist
		$exist = SystemUser.Exist -accessToken $accessToken -apiVersion $apiVersion -environmentUrl $environmentUrl -id $id -verbose $isVerbose;

		if (!$exist)
		{
			return $false;
		}

		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/systemusers($($id))";

		# invoke web request to disable system user
		$null = InvokeWebRequestAndGetComplete -accessToken $accessToken -body @{ isdisabled = $true } -method Patch -uri $uri -verbose $isVerbose;

		# invoke web request to change state to deleted
		$null = InvokeWebRequest -accessToken $accessToken -method Delete -uri $uri -verbose $isVerbose;

		# invoke web request to delete system user
		$null = InvokeWebRequest -accessToken $accessToken -method Delete -uri $uri -verbose $isVerbose;

		return $true;
	}
}

<# ######################### #>
<# Internal helper functions #>
<# ######################### #>

function ManagedIdentity.Exist
{
	[OutputType([Boolean])]
	param
	(
		[SecureString] $accessToken,
		[String]       $apiVersion,
		[Uri]          $environmentUrl,
		[Guid]         $id,
		[Boolean]      $verbose
	)
	process
	{
		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/managedidentities?`$select=managedidentityid&`$filter=managedidentityid eq '$($id)'";

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $uri -verbose $verbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 1)
		{
			return $true;
		}

		return $false;
	}
}

function SystemUser.Exist
{
	[OutputType([Boolean])]
	param
	(
		[SecureString] $accessToken,
		[String]       $apiVersion,
		[Uri]          $environmentUrl,
		[Guid]         $id,
		[Boolean]      $verbose
	)
	process
	{
		# create web request uri
		$uri = [Uri] "$($environmentUrl)api/data/$($apiVersion)/systemusers?`$select=systemuserid&`$filter=systemuserid eq '$($id)'";

		# invoke web request
		$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $uri -verbose $verbose;

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 1)
		{
			return $true;
		}

		return $false;
	}
}

function InvokeWebRequestAndGetComplete
{
	[OutputType([WebResponseObject])]
	param
	(
		[SecureString]     $accessToken,
		[Object]           $body = $null,
		[WebRequestMethod] $method,
		[Uri]              $uri,
		[Boolean]          $verbose
	)
	process
	{
		# invoke web request to get operation status uri
		$response = InvokeWebRequest -accessToken $accessToken -body $body -method $method -uri $uri -verbose $verbose;

		if (!$response.Headers.ContainsKey('Location'))
		{
			return $response;
		}

		# get status uri
		$statusUri = $response.Headers['Location'][0];

		while ($true)
		{
			# invoke web request to get status update
			$response = InvokeWebRequest -accessToken $accessToken -method Get -uri $statusUri -verbose $verbose;

			if (!$response.Headers.ContainsKey('Retry-After'))
			{
				break;
			}

			# get amount of seconds to sleep
			$retryAfter = [Int32] $response.Headers['Retry-After'][0];

			# fall sleep
			Start-Sleep -s $retryAfter;
		}

		# return response
		return $response;
	}
}

function InvokeWebRequest
{
	[OutputType([WebResponseObject])]
	param
	(
		[SecureString]     $accessToken,
		[Object]           $body = $null,
		[WebRequestMethod] $method,
		[Uri]              $uri,
		[Boolean]          $verbose
	)
	process
	{
		try
		{
			if ($null -eq $body)
			{
				# invoke web request
				return Invoke-WebRequest -Authentication Bearer -Method $method -Token $accessToken -Uri $uri -Verbose:$verbose;
			}

			$requestBody = $body | ConvertTo-Json -Compress -Depth 100;

			# invoke web request
			return Invoke-WebRequest -Authentication Bearer -Body $requestBody -ContentType 'application/json' -Method $method -Token $accessToken -Uri $uri -Verbose:$verbose;
		}
		catch [HttpResponseException]
		{
			Write-Host 'An error occurred calling the Power Platform:' -ForegroundColor Red;

			Write-Host "StatusCode: $([Int32] $_.Exception.StatusCode) ($($_.Exception.StatusCode))";

			# Replaces escaped characters in the JSON
			[Regex]::Replace($_.ErrorDetails.Message, '\\[Uu]([0-9A-Fa-f]{4})', { [Char]::ToString([Convert]::ToInt32($args[0].Groups[1].Value, 16)) } )
		}
		catch
		{
			Write-Host 'An error occurred in the script:' -ForegroundColor Red;

			Write-Host $_;
		}
	}
}