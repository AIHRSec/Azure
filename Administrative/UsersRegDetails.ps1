Select-MgProfile -Name "beta" # Needed since Get-MgReportAuthenticationMethodUserRegistrationDetail is part of Beta
$UserIds = Import-Csv -Path ".\userids.csv" | Select-Object -ExpandProperty UserId
$RegDetails = [System.Collections.ArrayList]::new()
ForEach ($UserId in $UserIds){
    $User = Get-MgUser -UserId $UserId
    $UserRegDetail =  Get-MgReportAuthenticationMethodUserRegistrationDetail -UserRegistrationDetailsId $UserId
    $object = [PSCustomObject]@{
            userPrincipalName      = $User.userPrincipalName
            UserType               = $User.UserType
            AccountEnabled         = $User.AccountEnabled
            Admin                  = If ($UserRegDetail.IsAdmin -match "True") {"Yes"} Else{"No"}
            id                     = $User.id
            DisplayName            = $User.Displayname
            AuthMethodsCount       = ($UserRegDetail).count
            DefaultMethod          = $UserRegDetail.DefaultMfaMethod
            MFA_Registered         = If ($UserRegDetail.IsMfaRegistered -match "True") {"Yes"} Else{"No"}
            MFA_Capable            = If ($UserRegDetail.IsMfaRegistered -match "True") {"Yes"} Else{"No"}
            Passwordless_Capable   = If ($UserRegDetail.IsPasswordlessCapable -match "True") {"Yes"} Else{"No"}
            SSPR_Capable           = If ($UserRegDetail.IsSsprCapable -match "True") {"Yes"} Else{"No"}
            SSPR_Enabled           = If ($UserRegDetail.IsSsprEnabled -match "True") {"Yes"} Else{"No"}
            SSPR_Registered        = If ($UserRegDetail.IsSsprRegistered  -match "True") {"Yes"} Else{"No"} 
        }
    [void]$RegDetails.Add($object)
}
$RegDetails | Export-Csv -Path ".\Sample1.csv" -NoTypeInformation