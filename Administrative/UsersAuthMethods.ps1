$UserIds = Import-Csv -Path ".\userids.csv" | Select-Object -ExpandProperty UserId
$AuthInfo = [System.Collections.ArrayList]::new()
ForEach ($UserId in $UserIds){
    $User = Get-MgUser -UserId $UserId
    $UserAuthMethod = Get-MgUserAuthenticationMethod -UserId $UserId
    $object = [PSCustomObject]@{
            userPrincipalName      = $User.userPrincipalName
            UserType               = $User.UserType
            AccountEnabled         = $User.AccountEnabled
            id                     = $User.id
            DisplayName            = $User.Displayname
            AuthMethodsCount       = ($UserAuthMethod).count
            Phone                  = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.phoneAuthenticationMethod") {"Yes"} Else{"No"}
            MicrosoftAuthenticator = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod") {"Yes"} Else{"No"}
            Email                  = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.emailAuthenticationMethod") {"Yes"} Else{"No"}
            HelloForBusiness       = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod") {"Yes"} Else{"No"}
            fido2                  = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.fido2AuthenticationMethod") {"Yes"} Else{"No"}
            Password               = If ($UserAuthMethod.additionalproperties.values  -match "#microsoft.graph.passwordAuthenticationMethod") {"Yes"} Else{"No"}
            passwordless           = If ($UserAuthMethod.additionalproperties.values -match "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod") {"Yes"} Else{"No"}
        }
    [void]$AuthInfo.Add($object)
}
$AuthInfo | Export-Csv -Path ".\UserAuth.csv" -NoTypeInformation