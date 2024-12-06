Authored by Stas Sultanov [ [linkedIn](https://www.linkedin.com/in/stas-sultanov) | [gitHub](https://github.com/stas-sultanov) ]

# About

The Microsoft Power Platform Powershell module.

## Purpose

The module has been developed with the purpose to be used for automated management of Power Platform environments.

## Licensing

The module is developed exclusively by Stas Sultanov and is distributed under the MIT license.

# Functions

The following functions are implemented.

| Name                               | Area               | Description
| :---                               | :--                | :---
| Admin.AddUser                      | Environments       | Add an Entra User to the environment.
| Admin.Create                       | Environments       | Create an environment within the Power Platform tenant.
| Admin.Delete                       | Environments       | Delete an environment from the Power Platform tenant.
| Admin.Retrieve                     | Environments       | Retrieve an environment info.
| Admin.RetrieveAll                  | Environments       | Retrieve information about all accessible environments.
| Admin.Update                       | Environments       | Update an environment within the Power Platform tenant.
| BusinessUnit.GetRootId             | Business Units     | Get Id of the root Business Unit within the Power Platform Environment.
| ManagedIdentity.CreateIfNotExist   | Managed Identities | Create a Managed Identity within the Power Platform Environment.
| ManagedIdentity.DeleteIfExist      | Managed Identities | Delete a Managed Identity from the Power Platform environment.
| PluginAssembly.BindManagedIdentity | Plugin Assemblies  | Bind the Plugin Assembly with the Managed Identity.
| Role.GetIdByName                   | Roles              | Get Id of the Role by Name.
| Solution.Export                    | Solutions          | Export a Solution.
| Solution.Import                    | Solutions          | Import a Solution.
| SystemUser.AssociateRole           | System Users       | Associate roles to the System User.
| SystemUser.CreateIfNotExist        | System Users       | Create a System User within the Power Platform Environment.
| SystemUser.DisableAndDeleteIfExist | System Users       | Disable and delete a System User from the Power Platform environment.
| SystemUser.GetIdByEntraObjectId    | System Users       | Get Id of the System User by Entra Object Id.

# Use

## Import

To start using the module, the following code must be executed to import the module.

```powershell
Import-Module '.\PowerPlatform.psd1' -Force;
```

By default all functions will be imported with the prefix 'PowerPlatform.'.
To change this behavior use Import-Module -Prefix parameter.

## Authentication and Authorization

Each function requires the 'accessToken' parameter to be specified.


The access token can be obtained with help of the following code
```powershell
$accessToken = (Get-AzAccessToken -ResourceUrl '[AUD]' -AsSecureString).Token;
```


Operations related to work with Environment requires having
- a [Power Platform Administrator](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference#power-platform-administrator) Role within Entra.
- a https://service.powerapps.com/ as AUD in the access token.


Operations related to work with entities within the Environment requires having
- a System Administrator role within the Power Platform Environment.
- an environment url in format https://[DomainName].[DomainSuffix].dynamics.com/ as AUD in the access token.

