## This script is create multiple users by using Microsoft Graph PowerShell.
## Graph PowerShell requires specific permissions to be able to create users and view directory info.
## That being said, the following permissions are required.
## User.ReadWrite.All - required to create user(s).
## Directory.Read.All - required to retrieve the domain name.
## Connect-MgGraph -Scopes 'Directory.Read.All', 'User.ReadWrite.All'

## Created by AIHRSec

# Plans for future use
Function Get-MgUserInfo {
    $users = Get-MgUser
    foreach ($user in $users) {
        Write-Output "User ID: $($user.id)"
        Write-Output "Display Name: $($user.displayName)"
        Write-Output "User Principal Name: $($user.userPrincipalName)"
        Write-Output "------------------------"
    }
}

Function Get-RandomPassword {
    param(
        [int]$PasswordLength = 12
    )

    # Define character sets
    $Lowercase = (97..122) | Get-Random -Count 12 | ForEach-Object {[char]$_}
    $Uppercase = (65..90)  | Get-Random -Count 12 | ForEach-Object {[char]$_}
    $Numeric = (48..57)  | Get-Random -Count 12 | ForEach-Object {[char]$_}
    $SpecialChar = (33..47) + (58..64) + (91..96) + (123..126) | Get-Random -Count 12 | ForEach-Object {[char]$_}
 
    # Combine character sets
    $StringSet = $Uppercase + $Lowercase + $Numeric + $SpecialChar
 
    # Generate random password
    -join (Get-Random -Count $PasswordLength -InputObject $StringSet)
}

# Define arrays of first and last names
$domain = (Get-MgDomain | Where-Object { $_.IsDefault -eq $true } | Select-Object -ExpandProperty Id)
$firstNames = @("James","John","Robert","Michael","William","David","Richard","Joseph","Charles","Thomas","Christopher","Daniel","Matthew","Anthony","Donald","Mark","Paul","Steven","Andrew","Kenneth","Joshua","George","Kevin","Brian","Edward","Ronald","Timothy","Jason","Jeffrey","Ryan","Gary","Nicholas","Eric","Stephen","Jacob","Larry","Frank","Jonathan","Scott","Justin","Brandon","Raymond","Gregory","Benjamin","Samuel","Patrick","Alexander","Jack","Dennis","Jerry","Tyler","Aaron","Jose","Henry","Adam","Douglas","Nathan","Peter","Zachary","Kyle","Walter","Harold","Jeremy","Ethan","Carl","Keith","Roger","Gerald","Christian","Terry","Sean","Arthur","Austin","Noah","Lawrence","Jesse","Joe","Bryan","Billy","Jordan","Albert","Dylan","Bruce","Willie","Gabriel","Alan","Juan","Logan","Wayne","Ralph","Roy","Eugene","Randy","Vincent","Russell","Mary","Patricia","Jennifer","Linda","Elizabeth","Barbara","Susan","Jessica","Sarah","Karen","Nancy","Margaret","Lisa","Betty","Dorothy","Sandra","Ashley","Kimberly","Donna","Emily","Michelle","Carol","Amanda","Melissa","Deborah","Stephanie","Rebecca","Laura","Sharon","Cynthia","Kathleen","Amy","Shirley","Angela","Helen","Anna","Brenda","Pamela","Nicole","Emma","Samantha","Katherine","Christine","Debra","Rachel","Carolyn","Janet")
$lastNames = @("Smith","Johnson","Williams","Jones","Brown","Davis","Miller","Wilson","Moore","Taylor","Anderson","Jackson","White","Harris","Martin","Thompson","Garcia","Martinez","Robinson","Clark","Rodriguez","Lewis","Lee","Walker","Hall","Allen","Young","Hernandez","King","Wright","Lopez","Hill","Scott","Green","Adams","Baker","Gonzalez","Nelson","Carter","Mitchell","Perez","Roberts","Turner","Phillips","Campbell","Parker","Evans","Edwards","Collins","Stewart","Sanchez","Morris","Rogers","Reed","Cook","Morgan","Bell","Murphy","Bailey","Rivera","Cooper","Richardson","Cox","Howard","Ward","Torres","Peterson","Gray","Ramirez","James","Watson","Brooks","Kelly","Sanders","Price","Bennett","Wood","Barnes","Ross","Henderson","Cole","Jenkins","Perry","Powell","Long","Patterson","Hughes","Flores","Washington","Butler","Simmons","Foster","Gonzales","Bryant","Alexander","Russell","Griffin","Diaz","Hayes","Hart","Hunt","Sullivan","Fisher","Henry","Reyes","Myers","Ford","Hamilton","Spencer","Ferguson","Stevens","Pierce","Weaver","Warren","Carpenter","Harvey","Olson","Gardner","Fuller","Castro","Montgomery","Welch","Larson","Gomez","Bishop","Mendoza","Riley","Wells","Knight","Curtis","Hudson","Murray","Wagner","Garza","Lynch","Franklin","Wong","Jacobs","Shaw","Hopkins","Cruz","Nguyen")

Function CreateUser {
    param(
        [string]$DisplayName,
        [string]$MailNickName,
        [string]$UserPrincipalName
    )
    
    # Define other attributes as needed
    $OtherAttributes = @{
        AccountEnabled = $true
        PasswordProfile = @{
            Password = Get-RandomPassword -PasswordLength 12
            ForceChangePasswordNextSignIn = $true
        }
    }

    # Create the user
    for ($i = 1; $i -le 3; $i++) {
        # Randomly select a first name and last name
        $randomFirstName = Get-Random -InputObject $firstNames
        $randomLastName = Get-Random -InputObject $lastNames
        
        # Declare the variables
        $DisplayName = "$randomFirstName $randomLastName"
        $MailNickName = "$randomFirstName.$randomLastName"
        $UserPrincipalName = "$MailNickName@$domain"

        # Creates the user
        New-MgUser -DisplayName $DisplayName -MailNickName $MailNickName -UserPrincipalName $UserPrincipalName @OtherAttributes
    }
    # Print password used
    Write-Output ("Here is the password for the account(s) created: " + $OtherAttributes.PasswordProfile.Password)
}

# Checks if the current session has the required permissions
Function CheckPermission {
    # Get the current context
    $context = Get-MgContext

    # Check if the context contains User.ReadWrite.All scope
    $CorrectScopes = ($context.Scopes -contains "Directory.Read.All") -and ($context.Scopes -contains "User.ReadWrite.All")

    return $CorrectScopes
}
if (CheckPermission) {
    Write-Output "Your session has the required permissions to run this script successfully."
    #CreateUser # Calls the CreateUser function
} else {
    Write-Warning "Your session does not contain the required permissions. Please connect to Graph PowerShell with Directory.Read.All and User.ReadWrite.All. You can add those permissions by running the following command and consenting to the permissions creates."
    Write-Host -ForegroundColor Green "Connect-MgGraph -Scopes 'Directory.Read.All', 'User.ReadWrite.All'" 
    Write-Host -ForegroundColor Yellow "User.ReadWrite.All - required to create user(s)."
    Write-Host -ForegroundColor Yellow "Directory.Read.All - required to retrieve the domain name."
}
