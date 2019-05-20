# Requires -Version 3.0
# This script is used to apply/clear policy to a endpoint
#
# The following steps are performed:
#
# 1. Disable SSL
# 2. Input Validation
# 3. Fetch Config File Data
# 4. Apply/Clear Policy
# 
#==========================================#
# LogRhythm SmartResponse Plugin           #
# pxGrid - SmartResponse                   #
# Sakshi.rawal@logrhythm.com               #
# v2.0  --  March, 2019                    #
#==========================================#

[CmdletBinding()] 
Param( 
[Parameter(Mandatory=$True)] 
[string]$HostName,
[Parameter(Mandatory=$True)]
[string]$PolicyName,
[Parameter(Mandatory=$True)] 
[string]$Action,
[string]$pxGridUserName,
[string]$pxGridPassword
)


# Trap for an exception during the script
trap [Exception]
{
    if($PSItem.ToString() -eq "ExecutionFailure")
	{
		exit 1
	}
	elseif ($PSItem.ToString() -eq "ExecutionSuccess")
	{
		exit
	}
	else
	{
		write-error $("Trapped: $_")
		write-host "Aborting Operation."
		exit
	}
}




#Function to disable SSL
function Disable-SSLError
{
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
 [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Forcing to use TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}


# Function to fetch saved parameter data

function Get-ConfigFileData
{
	try{
		if (!(Test-Path -Path $global:ConfigurationFilePath))
		{
			write-host "No Config File Found."
			write-error "Error: Config File Not Found. Please run 'Create pxGrid Configuration File' action."
			throw "ExecutionFailure"
		}
		else
		{
			$ConfigFileContent = Import-Clixml -Path $global:ConfigurationFilePath
			$EncryptedpxGridUserName = $ConfigFileContent.pxGridUserName
			$EncryptedpxGridPassword = $ConfigFileContent.pxGridPassword
			$EncryptedpxGridServerIP = $ConfigFileContent.pxGridServerIP
			$EncryptedpxGridPort = $ConfigFileContent.pxGridPort
			$global:PlainpxGridUserName = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($EncryptedpxGridUserName))))
			$global:PlainpxGridPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($EncryptedpxGridPassword))))
			$global:PlainpxGridServerIP = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($EncryptedpxGridServerIP))))
			$global:PlainpxGridPort = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($EncryptedpxGridPort))))
		}
	}
	catch{
		$message = $_.Exception.message
		if($message -eq "ExecutionFailure"){
			throw "ExecutionFailure"
		}
		else{
			write-host "Error: User does not have access to Config File."
			write-error $message
			throw "ExecutionFailure"
		}
	}
}


# Function to create Credential variable and validate

function Create-Credential{
	try{
		if ($InputParameterFlag -eq 1){
			$SecurePassword = ConvertTo-SecureString -AsPlainText -Force -String "$global:PlainpxGridPassword"
			$global:pxGridCredential = New-Object System.Management.Automation.PSCredential ($global:PlainpxGridUserName, $SecurePassword)
			write-host "Using Value from Configuration File as pxGrid UserName and Password.`n"
		}
		else{
			$SecurePassword = ConvertTo-SecureString -AsPlainText -Force -String "$pxGridPassword"
			$global:pxGridCredential = New-Object System.Management.Automation.PSCredential ($pxGridUserName, $SecurePassword)
			$VersionInfoURL = "https://" + $global:PlainpxGridServerIP + ":" + $global:PlainpxGridPort + "/ers/config/endpoint/versioninfo"
			$Output = Invoke-RestMethod -Uri $VersionInfoURL -Method Get -Headers $Header -Credential $global:pxGridCredential -errorvariable Check
			write-host "Using Passed Input Value as pxGrid UserName and Password.`n"
		}
	}
	catch{
		$ExceptionMessage = $_.Exception.Message
		if ($ExceptionMessage -eq "Unable to connect to the remote server"){
			write-host "Unable to connect to the remote server."
			write-error "Error: API call Unsuccessful. Wrong Server IP or Port."
			throw "ExecutionFailure"
		}
		else {
			write-host "Unauthorized to make API call."
			write-error "Error: API call Unsuccessful. Wrong username or password."
			throw "ExecutionFailure"
		}
	}
}

function CheckPolicyExists{
	$PolicyUrl= "https://" + $global:PlainpxGridServerIP + ":" + $global:PlainpxGridPort + "/ers/config/ancpolicy/name/$PolicyName"
	try{
		$Policy = Invoke-RestMethod -Uri $PolicyUrl -Method Get -Headers $Header -Credential $global:pxGridCredential -ErrorVariable a
	}catch{
		$_.exception  
		$ErrorMessage= $a.Message.split(":")
		$Error=$ErrorMessage[4].split(",")[0]
		$Error = $Error.trim()
		$Error
		throw "Execution Failure"
	}

}



function GetExistingPolicy{
	$PolicyExits = 0
	$global:PlainPxGridAdminUserName 
    $global:PlainPxGridAdminPassword 
    $AncEndpointsUrl = "https://" + $global:PlainpxGridServerIP + ":" + $global:PlainpxGridPort + "/ers/config/ancendpoint"
	try{
        $AncEndpoints = Invoke-RestMethod -Uri $AncEndpointsUrl -Method Get -Headers $Header -Credential $global:pxGridCredential -ErrorVariable a
		$Resources = $AncEndpoints.SearchResult.resources
		#$Resources
		foreach($Resource in $Resources){
			$AncEndpointUrl = $Resource.link.href
			$AncEndpoint = Invoke-RestMethod -Uri $AncEndpointUrl -Method Get -Headers $Header -Credential $global:pxGridCredential -ErrorVariable a
			#$AncEndpoint
			$PolicyName = $AncEndpoint.ErsAncEndpoint.policyName
			if($AncEndpoint.ErsAncEndpoint.macAddress -eq $HostName){
				$PolicyExits = 1
				Write-Host "Existing policy : $PolicyName"
				break
			}
		}
		if($PolicyExits -eq 0){
			Write-Host "No existing policy.."
		}
    }catch{
        $_.exception  
		$ErrorMessage= $a.Message.split(":")
		$Error=$ErrorMessage[4].split(",")[0]
		$Error = $Error.trim()
		throw "Execution Failure"
    } 
	
}

function ApplyPolicy{
    $global:PlainPxGridAdminUserName 
    $global:PlainPxGridAdminPassword 
    $ApplyPolicyUrl = "https://" + $global:PlainpxGridServerIP + ":" + $global:PlainpxGridPort + "/ers/config/ancendpoint/apply"                                          
    $Value=@()
    $Value+=[pscustomobject]@{
        "name" = "macAddress"
        "value" = $HostName
   }

   $Value+=[pscustomobject]@{
        "name" = "policyName"
        "value" = $PolicyName
   }


   $Data=[pscustomobject]@{
        "additionalData" = $Value
      }

   $Body =[pscustomobject]@{
      "OperationAdditionalData"=[pscustomobject]$Data
   }


   $Body = $Body | ConvertTo-Json -Depth 3

    try{
        $ApplyPolicy = Invoke-RestMethod -Uri $ApplyPolicyUrl -Method Put -Body $Body -Headers $Header -Credential $global:pxGridCredential -ErrorVariable a
        Write-Host "$PolicyName successfully applied to $HostName"
    }catch{        
		$ErrorMessage= $a.Message.split(":")
		$Error= $ErrorMessage[4].split(",")[0]
		$Error = $Error.trim()
		if($Error -eq '"mac address is already associated with this policy"'){
			write-host "mac address is already associated with entered policy"
		}else{
			Write-Host "API Call Unsuccessful"
			$Error
			$_.exception
		}
		throw "ExecutionSuccess"
    } 

}

function ClearPolicy{
    $ClearPolicyUrl = "https://" + $global:PlainpxGridServerIP + ":" + $global:PlainpxGridPort + "/ers/config/ancendpoint/clear"                                          
    $Value=@()
    $Value+=[pscustomobject]@{
        "name" = "macAddress"
        "value" = $HostName
   }

   $Value+=[pscustomobject]@{
        "name" = "policyName"
        "value" = $PolicyName
   }


   $Data=[pscustomobject]@{
        "additionalData" = $Value
      }

   $Body =[pscustomobject]@{
      "OperationAdditionalData"=[pscustomobject]$Data
   }


   $Body = $Body | ConvertTo-Json -Depth 3

    try{
        $ClearPolicy = Invoke-RestMethod -Uri $ClearPolicyUrl -Method Put -Body $Body -Headers $Header -Credential $global:pxGridCredential -ErrorVariable a
        Write-Host "Policy successfully cleared"
    }catch{  
		$ErrorMessage= $a.Message.split(":")
		$Error=$ErrorMessage[4].split(",")[0]
		$Error = $Error.trim()
		if($Error -eq '"mac address is not associated with a policy"'){
			write-host "mac address is not associated with a policy"
		}else{
			Write-Host "API Call Unsuccessful"
			$Error
			$_.exception
		}
		throw "ExecutionSuccess"
		
    } 
}


$global:ConfigurationFilePath = "C:\Program Files\LogRhythm\SmartResponse Plugins\pxGridConfigFile.xml"
$InputParameterFlag = 0

$Header = @{
            "Content-Type"= "application/json";
            "Accept"= "application/json"
}

if ((($pxGridUserName -eq "") -or ($pxGridUserName -eq $null)) -or (($pxGridPassword -eq "") -or ($pxGridPassword -eq $null))){
	$InputParameterFlag = 1
}
else{
	$pxGridUserName = $pxGridUserName.Trim()
	$pxGridPassword = $pxGridPassword.Trim()
}

Disable-SSLError
Get-ConfigFileData
Create-Credential
CheckPolicyExists
GetExistingPolicy

$Action = $Action.ToUpper()

if ($Action -eq "APPLY"){
    ApplyPolicy
}elseif($Action -eq "CLEAR"){
    ClearPolicy
}else{
    Write-Host "Action can either be Apply or Clear"
	throw "ExecutionSuccess"
}

# SIG # Begin signature block
# MIIcdQYJKoZIhvcNAQcCoIIcZjCCHGICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUD8GVsX9VLYEGixpoLEf2Uypw
# s6agghebMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTKMIIDsqADAgECAhA7fcSpOOvoChwkFo65IyOmMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE3MDQwNDAwMDAwMFoX
# DTIwMDQwNDIzNTk1OVowYjELMAkGA1UEBhMCVVMxETAPBgNVBAgMCENvbG9yYWRv
# MRAwDgYDVQQHDAdCb3VsZGVyMRYwFAYDVQQKDA1Mb2dSaHl0aG0gSW5jMRYwFAYD
# VQQDDA1Mb2dSaHl0aG0gSW5jMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEArr9SaqNn81S+mF151igpNeqvzWs40uPSf5tXu9iQUqXCWx25pECOcNk7W/Z5
# O9dXiQmdIvIFF5FqCkP6rzYtKx3OH9xIzoSlOKTxRWj3wo+R1vxwT9ThOvYiz/5T
# G5TJZ1n4ILFTd5JexoS9YTA7tt+2gbDtjKLBorYUCvXv5m6PREHpZ0uHXGCDWrJp
# zhiYQdtyAfxGQ6J9SOekYu3AiK9Wf3nbuoxLDoeEQ4boFW3iQgYJv1rRFA1k4AsT
# nsxDmEhd9enLZEQd/ikkYrIwkPVN9rPH6B+uRsBxIWIy1PXHwyaCTO0HdizjQlhS
# RaV/EzzbyTMPyWNluUjLWe0C4wIDAQABo4IBXTCCAVkwCQYDVR0TBAIwADAOBgNV
# HQ8BAf8EBAMCB4AwKwYDVR0fBCQwIjAgoB6gHIYaaHR0cDovL3N2LnN5bWNiLmNv
# bS9zdi5jcmwwYQYDVR0gBFowWDBWBgZngQwBBAEwTDAjBggrBgEFBQcCARYXaHR0
# cHM6Ly9kLnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGQwXaHR0cHM6Ly9kLnN5
# bWNiLmNvbS9ycGEwEwYDVR0lBAwwCgYIKwYBBQUHAwMwVwYIKwYBBQUHAQEESzBJ
# MB8GCCsGAQUFBzABhhNodHRwOi8vc3Yuc3ltY2QuY29tMCYGCCsGAQUFBzAChhpo
# dHRwOi8vc3Yuc3ltY2IuY29tL3N2LmNydDAfBgNVHSMEGDAWgBSWO1PweTOXr32D
# 7y4rzMq3hh5yZjAdBgNVHQ4EFgQUf2bE5CWM4/1XmNZgr/W9NahQJkcwDQYJKoZI
# hvcNAQELBQADggEBAHfeSWKiWK1eI+cD/1z/coADJfCnPynzk+eY/MVh0jOGM2dJ
# eu8MBcweZdvjv4KYN/22Zv0FgDbwytBFgGxBM6pSRU3wFJN9XroLJCLAKCmyPN7H
# IIaGp5RqkeL4jgKpB5R6NqSb3ES9e2obzpOEvq49nPCSCzdtv+oANVYj7cIxwBon
# VvIqOZFxM9Bj6tiMDwdvtm0y47LQXM3+gWUHNf5P7M8hAPw+O2t93hPmd2xA3+U7
# FqUAkhww4IhdIfaJoxNPDjQ4dU+dbYL9BaDfasYQovY25hSe66a9S9blz9Ew2uNR
# iGEvYMyxaDElEXfyDSTnmR5448q1jxFpY5giBY0wggTTMIIDu6ADAgECAhAY2tGe
# Jn3ou0ohWM3MaztKMA0GCSqGSIb3DQEBBQUAMIHKMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5l
# dHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1
# dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVi
# bGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTAeFw0wNjEx
# MDgwMDAwMDBaFw0zNjA3MTYyMzU5NTlaMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdv
# cmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhv
# cml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVibGlj
# IFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAK8kCAgpejWeYAyq50s7Ttx8vDxFHLsr4P4p
# AvlXCKNkhRUn9fGtyDGJXSLoKqqmQrOP+LlVt7G3S7P+j34HV+zvQ9tmYhVhz2AN
# pNje+ODDYgg9VBPrScpZVIUm5SuPG5/r9aGRwjNJ2ENjalJL0o/ocFFN0Ylpe8dw
# 9rPcEnTbe11LVtOWvxV3obD0oiXyrxySZxjl9AYE75C55ADk3Tq1Gf8CuvQ87uCL
# 6zeL7PTXrPL28D2v3XWRMxkdHEDLdCQZIZPZFP6sKlLHj9UESeSNY0eIPGmDy/5H
# vSt+T8WVrg6d1NFDwGdz4xQIfuU/n3O4MwrPXT80h5aK7lPoJRUCAwEAAaOBsjCB
# rzAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjBtBggrBgEFBQcBDARh
# MF+hXaBbMFkwVzBVFglpbWFnZS9naWYwITAfMAcGBSsOAwIaBBSP5dMahqyNjmvD
# z4Bq1EgYLHsZLjAlFiNodHRwOi8vbG9nby52ZXJpc2lnbi5jb20vdnNsb2dvLmdp
# ZjAdBgNVHQ4EFgQUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwDQYJKoZIhvcNAQEFBQAD
# ggEBAJMkSjBfYs/YGpgvPercmS29d/aleSI47MSnoHgSrWIORXBkxeeXZi2YCX5f
# r9bMKGXyAaoIGkfe+fl8kloIaSAN2T5tbjwNbtjmBpFAGLn4we3f20Gq4JYgyc1k
# FTiByZTuooQpCxNvjtsM3SUC26SLGUTSQXoFaUpYT2DKfoJqCwKqJRc5tdt/54Rl
# KpWKvYbeXoEWgy0QzN79qIIqbSgfDQvE5ecaJhnh9BFvELWV/OdCBTLbzp1RXii2
# noXTW++lfUVAco63DmsOBvszNUhxuJ0ni8RlXw2GdpxEevaVXPZdMggzpFS2GD9o
# XPJCSoU4VINf0egs8qwR1qjtY2owggVZMIIEQaADAgECAhA9eNf5dklgsmF99PAe
# yoYqMA0GCSqGSIb3DQEBCwUAMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVy
# aVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4
# BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQg
# dXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVibGljIFByaW1h
# cnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTAeFw0xMzEyMTAwMDAwMDBa
# Fw0yMzEyMDkyMzU5NTlaMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRl
# YyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEw
# MC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENB
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl4MeABavLLHSCMTXaJNR
# YB5x9uJHtNtYTSNiarS/WhtR96MNGHdou9g2qy8hUNqe8+dfJ04LwpfICXCTqdpc
# DU6kDZGgtOwUzpFyVC7Oo9tE6VIbP0E8ykrkqsDoOatTzCHQzM9/m+bCzFhqghXu
# PTbPHMWXBySO8Xu+MS09bty1mUKfS2GVXxxw7hd924vlYYl4x2gbrxF4GpiuxFVH
# U9mzMtahDkZAxZeSitFTp5lbhTVX0+qTYmEgCscwdyQRTWKDtrp7aIIx7mXK3/nV
# jbI13Iwrb2pyXGCEnPIMlF7AVlIASMzT+KV93i/XE+Q4qITVRrgThsIbnepaON2b
# 2wIDAQABo4IBgzCCAX8wLwYIKwYBBQUHAQEEIzAhMB8GCCsGAQUFBzABhhNodHRw
# Oi8vczIuc3ltY2IuY29tMBIGA1UdEwEB/wQIMAYBAf8CAQAwbAYDVR0gBGUwYzBh
# BgtghkgBhvhFAQcXAzBSMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LnN5bWF1dGgu
# Y29tL2NwczAoBggrBgEFBQcCAjAcGhpodHRwOi8vd3d3LnN5bWF1dGguY29tL3Jw
# YTAwBgNVHR8EKTAnMCWgI6Ahhh9odHRwOi8vczEuc3ltY2IuY29tL3BjYTMtZzUu
# Y3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMC
# AQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVN5bWFudGVjUEtJLTEtNTY3MB0G
# A1UdDgQWBBSWO1PweTOXr32D7y4rzMq3hh5yZjAfBgNVHSMEGDAWgBR/02Wnwt3s
# u/AwCfNDOfoCrzMxMzANBgkqhkiG9w0BAQsFAAOCAQEAE4UaHmmpN/egvaSvfh1h
# U/6djF4MpnUeeBcj3f3sGgNVOftxlcdlWqeOMNJEWmHbcG/aIQXCLnO6SfHRk/5d
# yc1eA+CJnj90Htf3OIup1s+7NS8zWKiSVtHITTuC5nmEFvwosLFH8x2iPu6H2aZ/
# pFalP62ELinefLyoqqM9BAHqupOiDlAiKRdMh+Q6EV/WpCWJmwVrL7TJAUwnewus
# GQUioGAVP9rJ+01Mj/tyZ3f9J5THujUOiEn+jf0or0oSvQ2zlwXeRAwV+jYrA9zB
# UAHxoRFdFOXivSdLVL4rhF4PpsN0BQrvl8OJIrEfd/O9zUPU8UypP7WLhK9k8tAU
# ITGCBEQwggRAAgEBMIGTMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRl
# YyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEw
# MC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENB
# AhA7fcSpOOvoChwkFo65IyOmMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRvN35wBTTY0AnMgIdH
# MplZU/L9szANBgkqhkiG9w0BAQEFAASCAQCHgp1T2DBBLOmX4J953MoRkGh/w99u
# JIo/4g98bpIjfhCsQnv+loFw6Yo6eWon+K8wabQrd+5E1tXAEf2keV9yJC2EEeef
# vs9x1Ejd67jhvapNnl9as6JZZb0SjUnJ6+CaPs8UWfLQDHlfTIzTsLcs+LOqLfD3
# d8wOLlbxhTslXgLB/tga9Ft06A1kq7dJ4mPxWjwmGUKKLYjklfr+em/+pOaJZV7z
# F5xnHrAlQaCFXd25OfU3IdS2YmAVfqFqhf06ft0jxyL+McUHU4H+eH8q+NaUG+Ww
# SbomW8MpZTNIHHs6q3Gnf70EMVMsuYGKCcm5Ar5T1XxBOAZAWMNyk5KMoYICCzCC
# AgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1l
# IFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYF
# Kw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDMyODExMTgzOFowIwYJKoZIhvcNAQkEMRYEFCc3Y9i2iDJAsghyszvu
# +9A8A2/TMA0GCSqGSIb3DQEBAQUABIIBAEWVqlG14Jub4nRIb8ofEKNo6uIgWnuV
# kEVnEAasXAJBKTMw08SoZwvGrZS7/6EpgvWCl1Iu9BH21f90hVmlqQeCdD27IJ5t
# BMhAWYQW4P+IBOcwMGhW5EXGdGs+06xtaWKgrGV34JQnGF7ihxemiUhgnp6shtU4
# A9qEHBqMVXs65LDthmNKTnDY/4WtGjhw0lme5dZwfzJoaWowmIbdSSV0/cMv3adU
# j8mmT8ZrqGjIEOtXYhNKy4TcpoZbDb0SczOhWhroKNQ4b4Lcz7pacpHctbWbX+L5
# YNXcY4Zw8n7Al0JrksJHMD3uY3YkyCgWWIEv56GWXjBSGrAi8SlV/2U=
# SIG # End signature block
