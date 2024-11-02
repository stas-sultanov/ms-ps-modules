function Azure.CDN.EnableSecure
{
	<#
	.SYNOPSIS
		Enable HTTPS for all CDN profiles.
	.PARAMETER resourceGroupName
		Name of the resource group.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>

	param
	(
		[Parameter(Mandatory = $true)] [String] $resourceGroupName
	)
	process
	{
		# List CDN profile names
		$profileNameList = $(az cdn profile list -g $resourceGroupName --query '[].name') | ConvertFrom-Json;

		# for each profile in profiles list
		foreach ($profileName in $profileNameList)
		{
			# list endpoints
			$endpointNameList = $(az cdn endpoint list -g $resourceGroupName --profile-name $profileName --query '[].name') | ConvertFrom-Json;

			# for each endpoint in endpoints list
			foreach ($endpointName in $endpointNameList)
			{
				# list custom domains
				$customDomainNameList = $(az cdn custom-domain list -g $resourceGroupName --profile-name $profileName --endpoint-name $endpointName --query '[].name') | ConvertFrom-Json
	
				# for each custom domain in custom domains list
				foreach ($customDomainName in $customDomainNameList)
				{
					# enable https for custom domain
					az cdn custom-domain enable-https -g $resourceGroupName --profile-name $profileName --endpoint-name $endpointName --name $customDomainName
				}
			}
		}
	}
}
