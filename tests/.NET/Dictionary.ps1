<#
.SYNOPSIS
	Run tests for 
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

# disable annoying Az warnings
Update-AzConfig -DisplayBreakingChangeWarning $false;

# get current script location
$invocationDirectory = Split-Path $script:MyInvocation.MyCommand.Path;

Import-Module (Join-Path $invocationDirectory '..\..\sources\PowerPlatform\PowerPlatform.psd1') -NoClobber -Force;

$config0 = [Ordered]@{
	a      = @(1, 10)
	x      = $null
	z      = $null
	global = [Ordered]@{
		company  = [Ordered]@{
			name = 'stas'
		}
		solution = [Ordered]@{
			name = 'test'
		}
	}
};

$config1 = [Ordered]@{
	global = [Ordered]@{
		realm = [Ordered]@{
			name     = 'testName'
			revision = 'testRevision'
		}
	}
	a      = @(10, 20)
	y      = $null
	z      = 'supper fly'
};

$config1.GetType();

$actualResult = Dictionary.Merge -first $config0 -second $config1;

$actualResult | ConvertTo-Json -Depth 100;