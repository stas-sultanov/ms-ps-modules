using namespace System;
using namespace System.Collections.Generic;
using namespace System.IO;
using namespace System.Text;
using namespace Microsoft.PowerShell.Commands;

<# ############################### #>
<# Functions to Admin Environments #>
<# ############################### #>

function Admin.AddUser
{
	<#
	.SYNOPSIS
		Add an Entra User to the environment.
	.DESCRIPTION
		Can be executed by an Identity that has Power Platform Administrator role within Entra.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://service.powerapps.com/'.
	.PARAMETER apiVersion
		Version of the Power Platform API to use.
	.PARAMETER environmentName
		Name of the Power Platform environment.
	.PARAMETER userObjectId
		The ObjectId of a user.
	.OUTPUTS
		Information about the user.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Void])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2021-04-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $environmentName,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $userObjectId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$admin.AddUser($apiVersion, $environmentName, $userObjectId);
	}
}

function Admin.Create
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
		Environment unique id.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
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

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$result = $admin.Create($apiVersion, $properties);

		return $result;
	}
}

function Admin.Delete
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
	.PARAMETER environmentName
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $environmentName
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$result = $admin.Delete($apiVersion, $environmentName);

		return $result;
	}
}

function Admin.Retrieve
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
	.PARAMETER environmentName
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $environmentName
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$result = $admin.Retrieve($apiVersion, $environmentName);

		return $result;
	}
}

function Admin.RetrieveAll
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

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$result = $admin.RetrieveAll($apiVersion);

		return $result;
	}
}

function Admin.Update
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
	.PARAMETER environmentName
		Name of the Power Platform environment.
	.PARAMETER properties
		Object that contains configuration properties to update the environment.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Void])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $false)] [ValidateNotNullOrEmpty()] [String]       $apiVersion = '2024-05-01',
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $environmentName,
		[Parameter(Mandatory = $true)]  [ValidateNotNull()]        [Object]       $properties
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment admin
		$admin = [EnvironmentAdmin]::new($accessToken, $isVerbose);

		# execute
		$admin.Update($apiVersion, $environmentName, $properties);
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
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.OUTPUTS
		Business Unit Id.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.BusinessUnit_GetRootId();

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
	.PARAMETER applicationId
		Application (Client) Id of the Service Principal within the Entra tenant.
	.PARAMETER environmentUrl
		Url of the Power Platform environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER managedIdentityId
		Id of the Managed Identity within the Power Platform Environment.
	.PARAMETER name
		The name assigned to this Managed Identity.
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $applicationId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $managedIdentityId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $tenantId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.ManagedIdentity_CreateIfNotExist($managedIdentityId, $applicationId, $name, $tenantId);

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
	.PARAMETER managedIdentityId
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $managedIdentityId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.ManagedIdentity_DeleteIfExist($managedIdentityId);

		return $result;
	}
}

<# ######################################## #>
<# Functions to work with Plugin Assemblies #>
<# ######################################## #>

function PluginAssembly.BindManagedIdentity
{
	<#
	.SYNOPSIS
		Bind the Plugin Assembly with the Managed Identity.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/pluginassembly
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER managedIdentityId
		Id of the Managed Identity.
	.PARAMETER pluginAssemblyId
		Id of the Plugin Assembly.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Void])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $managedIdentityId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $pluginAssemblyId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$manager.PluginAssembly_BindManagedIdentity($pluginAssemblyId, $managedIdentityId);
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
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER roleName
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $roleName
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.Role_GetIdByName($roleName);

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
	[OutputType([Void])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Boolean]      $managed,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $outputFile
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$manager.Solution_Export($managed, $name, $outputFile);
	}
}

function Solution.Import
{
	<#
	.SYNOPSIS
		Import solution.
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER customizationFile
		Path to Zipped solution file.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER environmentVariables
		Dictionary of environment variables to overwrite values from the solution.
	.PARAMETER overwriteUnmanagedCustomizations
		Indicates whether any unmanaged customizations that have been applied over existing managed solution components should be overwritten.
	.PARAMETER publishWorkflows
		Indicates whether any processes (workflows) included in the solution should be activated after they are imported.
	.OUTPUTS
		Unique identifier of the Import job.
	.NOTES
		Created by Stas Sultanov. https://www.linkedin.com/in/stas-sultanov/
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString]               $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]                     $customizationFile,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]                        $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNull()]        [Dictionary[String, String]] $environmentVariables,
		[Parameter(Mandatory = $true)]                             [Boolean]                    $overwriteUnmanagedCustomizations,
		[Parameter(Mandatory = $true)]                             [Boolean]                    $publishWorkflows
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.Solution_Import($customizationFile, $environmentVariables, $overwriteUnmanagedCustomizations, $publishWorkflows);

		return $result;
	}
}

<# ################################## #>
<# Functions to work with System User #>
<# ################################## #>

function SystemUser.AssociateRole
{
	<#
	.SYNOPSIS
		Associate role to the System User.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER roleId
		Id of the Role to assign to the System User.
	.PARAMETER systemUserId
		Id of the System User within the Power Platform Environment.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Void])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $roleId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $systemUserId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$manager.SystemUser_AssociateRole($systemUserId, $roleId);
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
	.PARAMETER applicationId
		Application (Client) Id of the Service Principal within the Entra tenant.
	.PARAMETER businessUnitId
		Unique identifier of the Business Unit with which the User is associated.
		If not specified root business unit will be used.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER name
		Name.
	.PARAMETER systemUserId
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $applicationId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $businessUnitId,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [String]       $name,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $systemUserId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.SystemUser_CreateIfNotExist($systemUserId, $applicationId, $businessUnitId, $name);

		return $result;
	}
}

function SystemUser.DisableAndDeleteIfExist
{
	<#
	.SYNOPSIS
		Delete a System User from the Power Platform environment.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER systemUserId
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
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $systemUserId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);

		# execute
		$result = $manager.SystemUser_DisableAndDeleteIfExist($systemUserId);

		return $result;
	}
}

function SystemUser.GetIdByEntraObjectId
{
	<#
	.SYNOPSIS
		Get Id of the System User by Entra Object Id.
	.DESCRIPTION
		More information here: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/reference/systemuser
	.PARAMETER accessToken
		Bearer token to access. The token AUD must include 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER environmentUrl
		Url of the Power Platform Environment.
		Format 'https://[DomainName].[DomainSuffix].dynamics.com/'.
	.PARAMETER objectId
		Object Id of the System User within the Entra.
	.OUTPUTS
		System User Id if found, $null otherwise.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	[CmdletBinding()]
	[OutputType([Guid])]
	param
	(
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [SecureString] $accessToken,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Uri]          $environmentUrl,
		[Parameter(Mandatory = $true)]  [ValidateNotNullOrEmpty()] [Guid]         $objectId
	)
	process
	{
		# get verbose parameter value
		$isVerbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'];

		# create environment manager
		$manager = [EnvironmentManager]::new($accessToken, $environmentUrl, $isVerbose);
		
		# execute
		$result = $manager.SystemUser_GetIdByEntraObjectId($objectId);
		
		return $result;
	}
}

<# ####### #>
<# Classes #>
<# ####### #>

class PowerPlatformEnvironmentInfo
{
	[ValidateNotNullOrEmpty()] [String] $azureRegion
	[ValidateNotNullOrEmpty()] [String] $domainName
	[ValidateNotNullOrEmpty()] [String] $name
	[ValidateNotNullOrEmpty()] [Uri]    $url
}

class ApiInvoker
{
	hidden [SecureString] $accessToken;
	hidden [Boolean]      $isVerbose;

	ApiInvoker ([SecureString] $accessToken, [Boolean] $isVerbose = $false)
	{
		$this.accessToken = $accessToken;
		$this.isVerbose = $isVerbose;
	}

	[WebResponseObject] InvokeWebRequestAndGetComplete ([WebRequestMethod] $method, [Uri] $uri)
	{
		return $this.InvokeWebRequestAndGetComplete($method, $uri, $null);
	}

	[WebResponseObject] InvokeWebRequestAndGetComplete ([WebRequestMethod] $method, [Uri] $uri, [Object] $body)
	{
		# invoke web request to get operation status uri
		$response = $this.InvokeWebRequest($method, $uri, $body);

		if (!$response.Headers.ContainsKey('Location'))
		{
			return $response;
		}

		# get status uri
		$statusUri = $response.Headers['Location'][0];

		while ($true)
		{
			# invoke web request to get status update
			$response = $this.InvokeWebRequest([WebRequestMethod]::Get, $statusUri);

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

	[WebResponseObject] InvokeWebRequest ([WebRequestMethod] $method, [Uri] $uri)
	{
		return $this.InvokeWebRequest($method, $uri, $null);
	}

	[WebResponseObject] InvokeWebRequest ([WebRequestMethod] $method, [Uri] $uri, [Object] $body)
	{
		try
		{
			if ($null -eq $body)
			{
				# invoke web request
				return Invoke-WebRequest -Authentication Bearer -Method $method -Token $this.accessToken -Uri $uri -Verbose:($this.isVerbose);
			}

			$requestBody = $body | ConvertTo-Json -Compress -Depth 100;

			# invoke web request
			return Invoke-WebRequest -Authentication Bearer -Body $requestBody -ContentType 'application/json' -Method $method -Token $this.accessToken -Uri $uri -Verbose:($this.isVerbose);
		}
		catch [HttpResponseException]
		{
			Write-Host 'An error occurred calling the Power Platform:' -ForegroundColor Red;

			$response = $_.Exception.Response;

			Write-Host "StatusCode: $([Int32] $response.StatusCode) ($($response.StatusCode))";

			# Replaces escaped characters in the JSON
			$message = [Regex]::Replace($_.ErrorDetails.Message, '\\[Uu]([0-9A-Fa-f]{4})',
				{
					[Char]::ToString([Convert]::ToInt32($args[0].Groups[1].Value, 16))
				} );

			Write-Host "Message: $message";

			return $response;
		}
	}
}

class EnvironmentAdmin
{
	static [Uri] $ApiUri = [Uri] 'https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform';
	static [Uri] $SelectProjection = '$select=properties.linkedEnvironmentMetadata.instanceUrl,properties.azureRegion,properties.linkedEnvironmentMetadata.domainName,name';

	static hidden [Uri] CreateUri ([String] $apiVersion, [String] $environmentName, [String] $segment, [String] $queryParam)
	{
		$builder = [UriBuilder]::new([EnvironmentAdmin]::ApiUri);

		$pathBuilder = [StringBuilder]::new($builder.Path);

		$null = $pathBuilder.Append('/scopes/admin/environments');

		if (-not [String]::IsNullOrEmpty($environmentName))
		{
			$pathBuilder.Append('/');

			$pathBuilder.Append($environmentName);
		}

		if (-not [String]::IsNullOrEmpty($segment))
		{
			$pathBuilder.Append('/');

			$pathBuilder.Append($segment);
		}

		$builder.Path = $pathBuilder.ToString();

		if ([String]::IsNullOrEmpty($queryParam))
		{
			$builder.Query = "api-version=$($apiVersion)";
		}
		else
		{
			$builder.Query = "api-version=$($apiVersion)&$($queryParam)";
		}

		return $builder.Uri;
	}

	hidden [ApiInvoker] $apiInvoker;

	EnvironmentAdmin ([SecureString] $accessToken, [Boolean] $isVerbose = $false)
	{
		$this.apiInvoker = [ApiInvoker]::new($accessToken, $isVerbose);
	}

	[Void] AddUser ([String] $apiVersion, [String] $environmentName, [Guid] $userObjectId)
	{
		# create web request uri
		$uri = [EnvironmentAdmin]::CreateUri($apiVersion, $environmentName, 'addUser', $null);

		# create web request body
		$body = @{
			ObjectId = $userObjectId
		};

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Post, $uri, $body);
	}

	[Guid] Create ([String] $apiVersion, [Object] $properties)
	{
		# create web request uri
		$uri = [Uri] "$([EnvironmentAdmin]::ApiUri)/environments?api-version=$($apiVersion)&retainOnProvisionFailure=false";

		# create web request body
		$body = @{properties = $properties };

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Post, $uri, $body);

		# get environment name
		$result = [Guid] ($response.Content | ConvertFrom-Json -AsHashtable).links.environment.path.Split('/')[4];

		return $result;
	}

	[Boolean] Delete ([String] $apiVersion, [String] $environmentName)
	{
		# create validation web request uri
		$validateUri = [EnvironmentAdmin]::CreateUri($apiVersion, $environmentName, 'validateDelete', $null);

		# invoke web request to validate deletion
		$validateResponse = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Post, $validateUri);

		# get validation response content
		$validateResponseContent = $validateResponse.Content | ConvertFrom-Json -AsHashtable;

		# check if can delete
		if (-not $validateResponseContent.canInitiateDelete)
		{
			return $false;
		}

		# create deletion web request uri
		$deleteUri = [EnvironmentAdmin]::CreateUri($apiVersion, $environmentName, $null, $null);

		# invoke web request to delete and get to completion
		$null = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Delete, $deleteUri);

		return $true;
	}

	[PowerPlatformEnvironmentInfo] Retrieve ([String] $apiVersion, [String] $environmentName)
	{
		# create web request uri
		$uri = [EnvironmentAdmin]::CreateUri($apiVersion, $environmentName, $null, [EnvironmentAdmin]::SelectProjection);

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert config response content
		$environment = $response.Content | ConvertFrom-Json -AsHashtable;

		# create result
		$result = [PowerPlatformEnvironmentInfo]@{
			azureRegion = $environment.properties.azureRegion
			domainName  = $environment.properties.linkedEnvironmentMetadata.domainName
			name        = $environment.name
			url         = $environment.properties.linkedEnvironmentMetadata.instanceUrl
		};

		return $result;
	}

	[PowerPlatformEnvironmentInfo[]] RetrieveAll ([String] $apiVersion)
	{
		# create web request uri
		$uri = [EnvironmentAdmin]::CreateUri($apiVersion, $null, $null, [EnvironmentAdmin]::SelectProjection);

		# invoke web request | OData $filter does not work :(
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert content
		$environmentList = ($response.Content | ConvertFrom-Json -AsHashtable).value;

		# convert items
		$result = $environmentList | ForEach-Object {
			[PowerPlatformEnvironmentInfo]@{
				azureRegion = $_.properties.azureRegion
				domainName  = $_.properties.linkedEnvironmentMetadata.domainName
				name        = $_.name
				url         = $_.properties.linkedEnvironmentMetadata.instanceUrl
			}
		};

		return [PowerPlatformEnvironmentInfo[]] $result;
	}

	[Void] Update ([String] $apiVersion, [String] $environmentName, [Object] $properties)
	{
		# create web request uri
		$uri = [EnvironmentAdmin]::CreateUri($apiVersion, $environmentName, $null, $null);

		# create web request body
		$body = @{properties = $properties };

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Patch, $uri, $body);
	}
}

class EnvironmentManager
{
	static [String] $ApiVersion = 'v9.2';

	hidden [Uri]        $environmentUrl;
	hidden [ApiInvoker] $apiInvoker;

	EnvironmentManager ([SecureString] $accessToken, [Uri] $environmentUrl, [Boolean] $isVerbose = $false)
	{
		$this.apiInvoker = [ApiInvoker]::new($accessToken, $isVerbose);

		$this.environmentUrl = $environmentUrl;
	}

	[WebResponseObject] InvokeGet ([String] $segment, [String] $query = $null)
	{
		# create web request uri
		$uri = CreateUri($segment, $query);

		# invoke web request
		$result = InvokeWebRequestAndGetComplete -accessToken $this.accessToken [WebRequestMethod]::Get , $uri -verbose $this.verbose;

		return $result;
	}

	[Uri] CreateUri ([String] $segment, [String] $query)
	{
		$builder = [UriBuilder]::new($this.environmentUrl);

		$pathBuilder = [StringBuilder]::new($builder.Path);

		$null = $pathBuilder.Append('api/data/');

		$null = $pathBuilder.Append([EnvironmentManager]::ApiVersion);

		$null = $pathBuilder.Append('/');

		$null = $pathBuilder.Append($segment);

		$builder.Path = $pathBuilder.ToString();

		if (-not [String]::IsNullOrEmpty($query))
		{
			$builder.Query = $query;
		}

		return $builder.Uri;
	}

	[Guid] BusinessUnit_GetRootId ()
	{
		# create web request uri
		$uri = $this.CreateUri('businessunits', '%24select=businessunitid&%24filter=_parentbusinessunitid_value%20eq%20null');

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# get business unit id
		$result = $responseContent.value[0].businessunitid;

		return $result;
	}

	[Guid] ManagedIdentity_CreateIfNotExist ([Guid] $managedIdentityId, [Guid] $applicationId, [String] $name, [Guid] $tenantId)
	{
		# check if managed identity exist
		$exist = $this.ManagedIdentity_Exist($managedIdentityId);

		if ($exist)
		{
			return $managedIdentityId;
		}

		# create web request body
		$body = @{
			applicationid     = $applicationId
			credentialsource  = 2
			managedidentityid = $managedIdentityId
			name              = $name
			subjectscope      = 1
			tenantid          = $tenantId
		};

		# create web request uri
		$uri = $this.CreateUri('managedidentities', $null);

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Post, $uri, $body);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# create result from response
		$result = $responseContent.managedidentityid;

		return $result;
	}

	[Boolean] ManagedIdentity_DeleteIfExist ([Guid] $managedIdentityId)
	{
		# check if identity exist
		$exist = $this.ManagedIdentity_Exist($managedIdentityId);

		if (!$exist)
		{
			return $false;
		}

		# create web request uri
		$uri = $this.CreateUri("managedidentities($($managedIdentityId))", $null);

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Delete, $uri);

		return $true;
	}

	[Boolean] ManagedIdentity_Exist ([Guid] $managedIdentityId)
	{
		# create web request uri
		$uri = $this.CreateUri('managedidentities', "`$select=managedidentityid&`$filter=managedidentityid eq '$($managedIdentityId)'");

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 1)
		{
			return $true;
		}

		return $false;
	}

	[Void] PluginAssembly_BindManagedIdentity ([Guid] $pluginAssemblyId, [Guid] $managedIdentityId)
	{
		# create web request uri
		$uri = $this.CreateUri("pluginassemblies($($pluginAssemblyId))", $null);

		# create web request body
		$body = @{
			'managedidentityid@odata.bind' = "/managedidentities($($managedIdentityId))";
		};

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Patch, $uri, $body);
	}

	[Guid] Role_GetIdByName ([String] $roleName)
	{
		# create web request uri
		$uri = $this.CreateUri('roles', "`$select=roleid&`$filter=name eq '$($roleName)'");

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

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

	[Void] Solution_Export ([Boolean] $managed, [String] $name, [String] $outputFile)
	{
		# create web request uri
		$uri = $this.CreateUri('ExportSolution', $null);

		# create web request body
		$body = @{
			Managed      = $managed
			SolutionName = $name
		};

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Post, $uri, $body);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# convert file from base64 string to byte array
		$fileAsByteArray = [Convert]::FromBase64String($responseContent.ExportSolutionFile);

		# write byte array to file
		[File]::WriteAllBytes($outputFile, $fileAsByteArray);
	}

	[Guid] Solution_Import ([Dictionary[String, String]] $environmentVariables, [String] $customizationFile, [Boolean] $overwriteUnmanagedCustomizations, [Boolean] $publishWorkflows)
	{
		# create import job id
		$importJobId = [Guid]::NewGuid();

		# read file as byte array
		$customizationFileAsByteArray = [File]::ReadAllBytes($customizationFile);

		# convert file from byte array to base64 string
		$customizationFileAsString = [Convert]::ToBase64String($customizationFileAsByteArray);

		$componentParameters = @();

		foreach ($pair in $environmentVariables.GetEnumerator())
		{
			$componentParameters += @{
				'@odata.type' = 'Microsoft.Dynamics.CRM.environmentvariablevalue'
				schemaname    = $pair.Key
				value         = $pair.Value
			}
		}

		# create web request uri
		$uri = $this.CreateUri('ImportSolution', $null);

		# create web request body
		$body = @{
			ComponentParameters              = $componentParameters
			CustomizationFile                = $customizationFileAsString
			OverwriteUnmanagedCustomizations = $overwriteUnmanagedCustomizations
			PublishWorkflows                 = $publishWorkflows
			ImportJobId                      = $importJobId
		};

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Post, $uri, $body);

		return $importJobId;
	}

	[Void] SystemUser_AssociateRole ([Guid] $systemUserId, [Guid] $roleId)
	{
		# create web request uri
		$uri = $this.CreateUri("systemusers($($systemUserId))%2Fsystemuserroles_association%2F%24ref", $null);

		# create web request body
		$body = @{
			'@odata.id' = $this.CreateUri("roles($($roleId))", $null);
		};

		# invoke web request
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Post, $uri, $body);
	}

	[Guid] SystemUser_CreateIfNotExist ([Guid] $systemUserId, [Guid] $applicationId, [Guid] $businessUnitId, [String] $name)
	{
		# check if system user exist
		$exist = $this.SystemUser_Exist($systemUserId);

		if ($exist)
		{
			return $systemUserId;
		}

		# create web request uri
		$uri = $this.CreateUri('systemusers', $null);

		# create web request body
		$body = @{
			accessmode                  = 4
			applicationid               = $applicationId
			'businessunitid@odata.bind' = "/businessunits($businessUnitId)"
			firstname                   = $name
			isdisabled                  = $false
			systemuserid                = $systemUserId
		};

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Post, $uri, $body);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		# create result from response
		$result = $responseContent.systemuserid;

		return $result;
	}

	[Boolean] SystemUser_DisableAndDeleteIfExist([Guid] $systemUserId)
	{
		# check if system user exist
		$exist = $this.SystemUser_Exist($systemUserId);

		if (!$exist)
		{
			return $false;
		}

		# create web request uri
		$uri = $this.CreateUri("systemusers($($systemUserId))", $null);

		$body = @{
			isdisabled = $true
		};

		# invoke web request to disable system user
		$null = $this.apiInvoker.InvokeWebRequestAndGetComplete([WebRequestMethod]::Patch, $uri, $body);

		# invoke web request to change state to deleted
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Delete, $uri);

		# invoke web request to delete system user
		$null = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Delete, $uri);

		return $true;
	}

	[Boolean] SystemUser_Exist ([Guid] $systemUserId)
	{
		# create web request uri
		$uri = $this.CreateUri('systemusers', "`$select=systemuserid&`$filter=systemuserid eq '$($systemUserId)'");

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 1)
		{
			return $true;
		}

		return $false;
	}

	[Guid] SystemUser_GetIdByEntraObjectId([Guid] $objectId)
	{
		# create web request uri
		$uri = $this.CreateUri('systemusers', "`$select=systemuserid&`$filter=azureactivedirectoryobjectid eq '$($objectId)'");

		# invoke web request
		$response = $this.apiInvoker.InvokeWebRequest([WebRequestMethod]::Get, $uri);

		# convert response content
		$responseContent = $response.Content | ConvertFrom-Json -AsHashtable;

		if ($responseContent.value.Count -eq 0)
		{
			return $null;
		}

		$result = $responseContent.value[0].systemuserid;

		return $result;
	}
}
