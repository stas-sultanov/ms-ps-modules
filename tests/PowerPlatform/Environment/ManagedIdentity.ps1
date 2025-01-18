<#
.SYNOPSIS
	Run tests related to Managed Identity.
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
	[Parameter(Mandatory = $true)]  [Guid]    $identityClientId,
	[Parameter(Mandatory = $true)]  [Guid]    $identityTenantId,
	[Parameter(Mandatory = $true)]  [Guid]    $managedIdentityId,
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
	$log = New-ConsoleOperationLogger 16;

	<# PROCESS BEGIN #>

	$log.ProcessBegin();

	<# STEP #>

	$log.OperationBegin('Get Access Token');

	$environmentAccessToken = (Get-AzAccessToken -ResourceUrl $environmentUrl -AsSecureString).Token;

	$log.OperationEnd( ($null -ne $environmentAccessToken) -and (0 -lt $environmentAccessToken.Length) );

	<# STEP : test create if not exist #>

	$log.OperationBegin('Create not exist');

	$createdManagedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-name 'Test' `
		-tenantId $identityTenantId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $createdManagedIdentityId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($createdManagedIdentityId)" : $null);

	<# STEP : test create if exist #>

	$log.OperationBegin('Create exist');

	$createdManagedIdentityId = PowerPlatform.ManagedIdentity.CreateIfNotExist `
		-accessToken $environmentAccessToken `
		-applicationId $identityClientId `
		-environmentUrl $environmentUrl `
		-managedIdentityId $managedIdentityId `
		-name 'Test' `
		-tenantId $identityTenantId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $null -ne $createdManagedIdentityId;

	$log.OperationEnd($operationSuccess, $operationSuccess ? "id: $($createdManagedIdentityId)" : $null);

	<# STEP : test delete if exist #>

	$log.OperationBegin('Delete exist');

	$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $createdManagedIdentityId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $true -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# STEP : test delete if not exist #>

	$log.OperationBegin('Delete not exist');

	$deleteResult = PowerPlatform.ManagedIdentity.DeleteIfExist `
		-accessToken $environmentAccessToken `
		-environmentUrl $environmentUrl `
		-managedIdentityId $createdManagedIdentityId `
		-ErrorAction:Stop `
		-Verbose:$isVerbose;

	$operationSuccess = $false -eq $deleteResult;

	$log.OperationEnd($operationSuccess);

	<# PROCESS END #>

	$log.ProcessEnd();
}


$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("ARRAffinity", "f6b704ddfbb5d43ed2e16871e8e35e1ae58f2212197626a8478b2616a4fb913915134d20c556b0b34b9b6ae43ec3f5dcdad61788de889ffc592af7aca85fc1c508DD28D977B83FD8618192145", "/", "stasppdemodev32.crm4.dynamics.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("CrmOwinAuth", "MAAAAGhGOL22VBHvuOQAIkihVCP5EA8YgKWzLLDsx_68dPcJ_-5SpmAR9SMSqqOWTFJYvR-LCAAAAAAABADFWGuvo8YZPifndJNNmypSpChSFWml7qe2-HC_rLpKwcYY24Bt8I0vaAwDxpjLYcBcfkR_aX9E8Tm7TTeN1HTtbkYGYWZ43nfmfea9zN3Nzc3vjSpM-mkahVAsi_3tze3NQ_f6DpTea_y5cdj5_nxz3z-9b7c3b_dFkaE3Dw-oQL0OzEsr1Etg8eBRHAU4IGCusAMYzfg8Jvg4j0GPoAGB7-gdQTzc3tyFCF2KcbkOoPiS4CgGpwSOx_90huvQqqrqVVQvzYMHEseJh402Nd09jMEfw6SAAcxZ-mLJyc7_lSTDOnuWTFPsJ5V8D1y3uP3lEinyUolv3olCT7ioF4dunqLUL3puGj-4RxDG6AF0_E9iWOxTD-XQhzlMXIjussq7nGCXKJAj8OsqEPtXUODlGdwpwhieSUcLnEAQ3CekwAvX2QO0__ZYLuqZMHHHUfWocdVYGmnJsLp8fp-5rtUPZFEOsmRH6fh2o5W2siKVvTqR5eMYJuRkISy0mLV3RO5C4yiHcpDO7dVxtcqLGZSbhD8NK-FBhOJA7S9WS1oU3769XLO3PzF9HR9RCrKn1a7QecGZh-4XejApwqJ5TwZU5gmI4RdmeSxAkp4uV-SHj1MkCE8wOatybxYAXa7Gb0KvaLL7EsH8crAXYQY8L_-K43sk2yMpqkfg9OWwXx7TIEycfUf_v98avX44r7aHiNm2dmSHRKS1q2hqzSutVYutFVRbE6f0eHXUD17XtyS21tIcK_NWb_W9TsrMdK0x21gu9MEqNvo4Yx9EerpeRZq12GuWFOqKWmuLdOtSi73bMK23rvHtmjl5kfQBmdWJKl0-ufuzMb86G_PV9cj1U5Z_6OB-yql0d4Bu8fzWD2H-Gt8Jgst6PuZRjIfROEVigMcBxrEQslz3kgHMFWaelaH3NYF38N2F82JnC-YKOdRn-V4geiKgxUfgtTiXjzF57fcNfJnOi6k8d8X3rfrXU78UZawUxd7l4n-HwiDp6IoKUMD7KEbh5ZiDj3MWZ2r9aNY_K9ojNUTDteHt9cHC8AFtWs4Smyb1itz4keQZ2aLils1qegUrfFPABCSFk8MgTLvVcNMMfiYvLwdm_iduP2sReq9_Cfrlyt3efNfZHfXQu638tyB9-u_BK-xq4eNYUGbJ_1Gpu7IIv_2PuO10cVu8AvgJ5ndE7wp0vK9CD73meY-HFKQw3mcYrOuHmMBQABN2Ai_wO57n2N21ZLEkFLo6hsZYwe9kkRSHCYTQFYwESXAcQTOQuNq8dpzg73zawyjoCxjN8gLGEzTVOewdIdCQ7_yqcLmsz-sYOS6At1fYKC-esNy7_uwKYF-fwfzwWMDc6b6G9R3BXSHveHmGDb0cHu-JV-QVjPXFGTDO3PAFyQjddv2EGf-T7TrJ9xT7SeU-2Tn3vsZ7NDk9bKVFuEaueg3f8DQjhOJrsPHJMBUKi3uC_6TLc1czxR9aIkfb0Wjcbdo4CAp6hOySlyaRNKvOEaUbFYXefx_1bdop0HPzuHeuLos06sJAk8GfOdR6prbXJE5e_OPlR-dKYiBKYiV3rwZr9nCkiFiiLK4M8rVl8dkQitWgW9WlKMx4h94pjbxdD6fcyCOWvg7Q3CmbPAnmo0nL6MPUwNSSdRagNpn0KMkzkQhW0x0xkWs_2ZcRVfCmPrc4yZ4VBu3pjOw5gISEAXYnHKUz3Z1T1EoOHwmID-S2WAn1MWAfs5IdmPEhKLG0SCQlittHJrZ1euRubNk4GXpUZVThn7gMIGsvSgS7HCVTa6bae4E3Uh2tRjGhqhhhIlOWp9Win7mTZJiqyfEo9Mm-HmMIBnpCyPOS5HVIi9SJqB28zpt1LDdWsy4hw8ac0kh8wpSltz4Mcrj0ZC9IJupmI1Y7Hacz2ICWdSONaLtgpDB4TkoVubWOPFpjgsvofFmOpNNjuLISO1vYY6fRlsxSrWfU2MRyT12samm2YdpkfMD0csFWY6KVrJTLSqsqFxNlXHm003ixrwSIDYvx1lUzZ8PazaqZh545c5fW9ICHrmFSE422lRKRYduPdGtEYOLKJj0tdtqOIY1FEuyOnG7r9dRILPPoDaBdKns32tRGPTgo5BxojILUrYqL3EifsWSNbwDIdhvMzIBRS8F2PS6AwBL6npgCNGRxLxgsk8ORsNb8dr4IF5Df4HvcElRmkoeG0xD4Qcc37lqsqMkUhVK8pA1pDitpnuehKlQFEcrtIu1PBWKytyl7xpBLVkh8aky2k_oY9RN84AyjxQFMt_24wGt3w4zTktPVQ1qRy-G8rBxmx_H79jAU2NRKNA2NT1KgTCJagoUSmSJK1wurkBlzBO2opUJZMsK8aYll0erlKt9K_jTV021A80W-9RnNbH03KuxFfzXONma_JfviZCcoTbg0YrdEmb1RAxjtlNhfSrUt1W4IsUyifCI4Ju6ClPNH-nE1IotcwQbdjqi1LqOqtYHviOLCcPdTY0CxTMO7p-xwIIDh-yJhI47eqAu6Chmeth_pZEFPljgmb7RaHMUHxZ6uLdo_MJs83ZrmZhjFs3g8Ux1lNgl4TphvffPQpkd21Icg71xbdTSwo6k0raXNVqNGNEMJ6m2N-oYMGqDZfYDXpzmYu0zKyVTqH1cjg_adgg77zUzljQ31WNPEHsfqlPN4WalK19lt-_pQaaBkrZerdVCOQQpkoVFLP0-KgnaEOBGo04k36Zl6MjkqqqJcOyV1a8sa2gnzdp0KSqBK0yrbAcDKpmvJBybwEuJxfRjmMKucsKUOq8fHabxuncyQJK8R-YZTE_wwV-bjdv7s_b585_2C_PmgmxEohqU_7Dv-TN-5ne8vuutlL4demHeFc__HGAAQ9j7JPjtiutchga5AQU-1SQw6_wxQVv-AYFGESYDS5Ni8LfISftVDEKGuUDLPVWNXrFAe7wKySxZhV4ADnMYAzdAYTfg7AbA0xfnkN70uFrmR-fydOsy7Yu-v71V5OjH5sTTq5IQJfD7dTOM4TR7Sc4wgH54g3on-bS-DOQpRVzIVN1_0YJ1100Pfm2Xyl1ck_WoA3S4JouhXBPGGot_Q-CtFsz7vhQiV0PveKuG_jSI_HPVPTk3B51wZAAA", "/", ".crm4.dynamics.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("testcookie", "1", "/", "stasppdemodev32.crm4.dynamics.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MicrosoftApplicationsTelemetryDeviceId", "70dfb438-899e-4c95-bcc8-29319b719a1c", "/", "stasppdemodev32.crm4.dynamics.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MSFPC", "GUID=08a9edad587b4756a930c3d907424db7&HASH=08a9&LV=202412&V=4&LU=1734979179916", "/", "stasppdemodev32.crm4.dynamics.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("ai_session", "faaXVHMNSyjfA/SXr4uBNC|1735595364030|1735595498256", "/", "stasppdemodev32.crm4.dynamics.com")))
Invoke-WebRequest -UseBasicParsing -Uri "https://stasppdemodev32.crm4.dynamics.com/api/data/v9.0/organizations%2893c3d9c6-f1c5-ef11-b8e4-000d3ab5d972%29" `
-Method "PATCH" `
-WebSession $session `
-Headers @{
"authority"="stasppdemodev32.crm4.dynamics.com"
  "method"="PATCH"
  "path"="/api/data/v9.0/organizations%2893c3d9c6-f1c5-ef11-b8e4-000d3ab5d972%29"
  "scheme"="https"
  "accept"="application/json"
  "accept-encoding"="gzip, deflate, br, zstd"
  "accept-language"="en-US,en;q=0.9"
  "authorization"="Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InoxcnNZSEhKOS04bWdndDRIc1p1OEJLa0JQdyIsImtpZCI6InoxcnNZSEhKOS04bWdndDRIc1p1OEJLa0JQdyJ9.eyJhdWQiOiJodHRwczovL3N0YXNwcGRlbW9kZXYzMi5jcm00LmR5bmFtaWNzLmNvbS8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kMzczYTdhOS1jOWJhLTQ1ZjgtOWYwOC1lZDE0YTEwYjRiMTEvIiwiaWF0IjoxNzM1NTkzMjQ4LCJuYmYiOjE3MzU1OTMyNDgsImV4cCI6MTczNTU5NzY5NCwiYWNjdCI6MCwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhZQUFBQVkrZ3hDbnM3dkpWeFprN3BjbFNZYXRaaUNhaU45M3hUdGRJU3d4aVA4YUZuN3E2U0pDMG9BVlNmaExmUnBTbmNXOXVReG9SV2hoU09IbGxGblU5elR2czlFWXIwdWxEenowb25DSWx1aERFPSIsImFtciI6WyJwd2QiLCJyc2EiLCJtZmEiXSwiYXBwaWQiOiJhOGY3YTY1Yy1mNWJhLTQ4NTktYjJkNi1kZjc3MmMyNjRlOWQiLCJhcHBpZGFjciI6IjAiLCJkZXZpY2VpZCI6Ijk1YWI2N2NkLWNjOTctNGRiMC05NDA0LTc0MGFmOGVmYTg4YyIsImZhbWlseV9uYW1lIjoiU3VsdGFub3YiLCJnaXZlbl9uYW1lIjoiU3RhcyIsImlkdHlwIjoidXNlciIsImlwYWRkciI6Ijc4LjI2LjIzMy4xMDQiLCJsb2dpbl9oaW50IjoiTy5DaVF3WWprNVl6WmtaaTFrTXpWa0xUUXdNekl0WVRnd1lTMDNObVZsTmpka016VTFZVFVTSkdRek56TmhOMkU1TFdNNVltRXRORFZtT0MwNVpqQTRMV1ZrTVRSaE1UQmlOR0l4TVJvWWMzUmhjeTV6ZFd4MFlXNXZka0JuYjNOMFlYTXVaR1YySUtJQiIsIm5hbWUiOiJTdGFzIFN1bHRhbm92Iiwib2lkIjoiMGI5OWM2ZGYtZDM1ZC00MDMyLWE4MGEtNzZlZTY3ZDM1NWE1IiwicHVpZCI6IjEwMDMyMDAzMDhBQzA1NTAiLCJyaCI6IjEuQWE0QXFhZHowN3JKLUVXZkNPMFVvUXRMRVFjQUFBQUFBQUFBd0FBQUFBQUFBQUN1QUUtdUFBLiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IkdNcTNGc0ZXT2RoTkRST2ZhNFNUX1UtTG54VjJYZmtCZE9wUnc3VXlWTDAiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJkMzczYTdhOS1jOWJhLTQ1ZjgtOWYwOC1lZDE0YTEwYjRiMTEiLCJ1bmlxdWVfbmFtZSI6InN0YXMuc3VsdGFub3ZAZ29zdGFzLmRldiIsInVwbiI6InN0YXMuc3VsdGFub3ZAZ29zdGFzLmRldiIsInV0aSI6InhiSW1wMHRta1U2ZndmNXFXYkNiQVEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbIjg4ZDhlM2UzLThmNTUtNGExZS05NTNhLTliOTg5OGI4ODc2YiIsIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCIsImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdLCJ4bXNfaWRyZWwiOiIxIDMwIn0.grtHEmxV7XIH-kAkUqZfyhYoXWBhXymsWuxZGURF0yy1Uiv_t1-Hqn4KktoRMiOAVy9PYf_W8kdrL3hu3bv4Mo2Ta51JS26EgqM_tk1qW0yzQwWzeP0JJDo7QNL5wllJDIdynieCKTxpX4FpJgwIYMZbKA0Lcj92gDihBzisGRzJYBVdeEC-ClmVc05UNYfWpihFqB4PhkSVi7HN75899uWxfuevG9jBk_4pPdGOzi5kFpCuOT_ABaGwb5AO5xGt9cw8jnmwgWkas0ywmK-G0bq_RZM_90xTYEZg8dY0wWZfpkDQdVJ1Ra2K19btWn5-p6lNmu4te0XMPacd8OWR6A"
  "clienthost"="Browser"
  "origin"="https://stasppdemodev32.crm4.dynamics.com"
  "prefer"="return=representation,odata.include-annotations=*"
  "priority"="u=1, i"
  "referer"="https://stasppdemodev32.crm4.dynamics.com/uclient/main.htm?cmdbar=true&channelId=bdac095a-959c-4baf-82d5-688d1e0cd1a9&flags=FCB.PreLoadAppHostClient%3Dfalse%2CFCB.CollaborationOwnerHeader%3Dfalse%2CFCB.CollaborationCoPresenceFacepile%3Dfalse%2CFCB.GridPersonaControl%3Dfalse%2CFCB.LookupPersona%3Dfalse%2CFCB.UsePhotoInMeControl%3Dfalse%2CFCB.FormPredict%3Dfalse%2CFCB.UseCopilotMCSRuntime%3Dfalse%2CFCB.AppCopilotEnabledFCB%3Dfalse%2CFCB.ClientDataStorageReplay%3Dfalse%2CFCB.ClientGCMStorageReplay%3Dfalse%2CFCB.UseBearerAuthForPreview%3Dtrue%2CFCB.DraftAppPreviewForCustomPages%3Dfalse&forceUCI=1&hostCorrelationId=d8a57030-c6f6-11ef-b33e-0de6f1f082db&pagetype=custom&name=cat_plugintracelog_d12af"
  "sec-ch-ua"="`"Microsoft Edge`";v=`"131`", `"Chromium`";v=`"131`", `"Not_A Brand`";v=`"24`""
  "sec-ch-ua-mobile"="?0"
  "sec-ch-ua-platform"="`"Windows`""
  "sec-fetch-dest"="empty"
  "sec-fetch-mode"="cors"
  "sec-fetch-site"="same-origin"
  "x-ms-app-id"="700120f0-f7c6-ef11-b8e8-000d3ab8bc29"
  "x-ms-app-name"="cat_DataverseCompanionApp"
  "x-ms-client-request-id"="6e6e754b-ad29-4b38-b7f4-7b04b06bfe12"
  "x-ms-client-session-id"="e01e940d-e3af-4370-afd7-063d0bf20d4b"
  "x-ms-correlation-id"="13917db0-afb8-4a3c-949f-46e32e65db33"
  "x-ms-sw-objectid"=""
  "x-ms-sw-tenantid"=""
  "x-ms-user-agent"="PowerApps-UCI/1.4.9550-2411.3 (Browser; AppName=cat_DataverseCompanionApp)"
} `
-ContentType "application/json" `
-Body "{`"plugintracelogsetting`":2}"