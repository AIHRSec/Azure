## SCRIPT IS MOSTLY WORKING (Yes, the script can still create users)
## working on error handling

## This script is create multiple users by using Microsoft Graph PowerShell.
## Graph PowerShell requires specific permissions to be able to create users and view directory info.
## That being said, the following permissions are required:
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
$firstNames = @("James","Robert","John","Michael","David","William","Richard","Joseph","Thomas","Christopher","Charles","Daniel","Matthew","Anthony","Mark","Donald","Steven","Andrew","Paul","Joshua","Kenneth","Kevin","Brian","George","Timothy","Ronald","Jason","Edward","Jeffrey","Ryan","Jacob","Gary","Nicholas","Eric","Jonathan","Stephen","Larry","Justin","Scott","Brandon","Benjamin","Samuel","Gregory","Alexander","Patrick","Frank","Raymond","Jack","Dennis","Jerry","Tyler","Aaron","Jose","Adam","Nathan","Henry","Zachary","Douglas","Peter","Kyle","Noah","Ethan","Jeremy","Walter","Christian","Keith","Roger","Terry","Austin","Sean","Gerald","Carl","Harold","Dylan","Arthur","Lawrence","Jordan","Jesse","Bryan","Billy","Bruce","Gabriel","Joe","Logan","Alan","Juan","Albert","Willie","Elijah","Wayne","Randy","Vincent","Mason","Roy","Ralph","Bobby","Russell","Bradley","Philip","Eugene","Mary","Patricia","Jennifer","Linda","Elizabeth","Barbara","Susan","Jessica","Sarah","Karen","Lisa","Nancy","Betty","Sandra","Margaret","Ashley","Kimberly","Emily","Donna","Michelle","Carol","Amanda","Melissa","Deborah","Stephanie","Dorothy","Rebecca","Sharon","Laura","Cynthia","Amy","Kathleen","Angela","Shirley","Brenda","Emma","Anna","Pamela","Nicole","Samantha","Katherine","Christine","Helen","Debra","Rachel","Carolyn","Janet","Maria","Catherine","Heather","Diane","Olivia","Julie","Joyce","Victoria","Ruth","Virginia","Lauren","Kelly","Christina","Joan","Evelyn","Judith","Andrea","Hannah","Megan","Cheryl","Jacqueline","Martha","Madison","Teresa","Gloria","Sara","Janice","Ann","Kathryn","Abigail","Sophia","Frances","Jean","Alice","Judy","Isabella","Julia","Grace","Amber","Denise","Danielle","Marilyn","Beverly","Charlotte","Natalie","Theresa","Diana","Brittany","Doris","Kayla","Alexis","Lori","Marie")
$lastNames = @("Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Hernandez","Lopez","Gonzales","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin","Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson","Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores","Green","Adams","Nelson","Baker","Hall","Rivera","Campbell","Mitchell","Carter","Roberts","Gomez","Phillips","Evans","Turner","Diaz","Parker","Cruz","Edwards","Collins","Reyes","Stewart","Morris","Morales","Murphy","Cook","Rogers","Gutierrez","Ortiz","Morgan","Cooper","Peterson","Bailey","Reed","Kelly","Howard","Ramos","Kim","Cox","Ward","Richardson","Watson","Brooks","Chavez","Wood","James","Bennet","Gray","Mendoza","Ruiz","Hughes","Price","Alvarez","Castillo","Sanders","Patel","Myers","Long","Ross","Foster","Jimenez","Gonzalez","Bell","Bennett","Barnes","Henderson","Cole","Jenkins","Perry","Powell","Patterson","Washington","Butler","Simmons","Bryant","Alexander","Russell","Griffin","Hayes","Hart","Hunt","Sullivan","Fisher","Henry","Ford","Hamilton","Spencer","Ferguson","Stevens","Pierce","Weaver","Warren","Carpenter","Harvey","Olson","Gardner","Fuller","Castro","Montgomery","Welch","Larson","Bishop","Riley","Wells","Knight","Curtis","Hudson","Murray","Wagner","Garza","Lynch","Franklin","Wong","Jacobs","Shaw","Hopkins","Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin","Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson","Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores","Green","Adams","Nelson","Baker","Hall","Rivera","Campbell","Mitchell","Carter","Roberts","Gomez","Phillips","Evans","Turner","Diaz","Parker","Cruz","Edwards","Collins","Reyes","Stewart","Morris","Morales","Murphy","Cook","Rogers","Gutierrez","Ortiz","Morgan","Cooper","Peterson","Bailey","Reed","Kelly","Howard","Ramos","Kim","Cox","Ward","Richardson","Watson","Brooks","Chavez","Wood","James","Bennett","Gray","Mendoza","Ruiz","Hughes","Price","Alvarez","Castillo","Sanders","Patel","Myers","Long","Ross","Foster","Jimenez","Powell","Jenkins","Perry","Russell","Sullivan","Bell","Coleman","Butler","Henderson","Barnes","Gonzales","Fisher","Vasquez","Simmons","Romero","Jordan","Patterson","Alexander","Hamilton","Graham","Reynolds","Griffin","Wallace","Moreno","West","Cole","Hayes","Bryant","Herrera","Gibson","Ellis","Tran","Medina","Aguilar","Stevens","Murray","Ford","Castro","Marshall","Owens","Harrison","Fernandez","Mcdonald","Woods","Washington","Kennedy","Wells","Vargas","Henry","Chen","Freeman","Webb","Tucker","Guzman","Burns","Crawford","Olson","Simpson","Porter","Hunter","Gordon","Mendez","Silva","Shaw","Snyder","Mason","Dixon","Muñoz","Hunt","Hicks","Holmes","Palmer","Wagner","Black","Robertson","Boyd","Rose","Stone","Salazar","Fox","Warren","Mills","Meyer","Rice","Schmidt","Garza","Daniels","Ferguson","Nichols","Stephens","Soto","Weaver","Ryan","Gardner","Payne","Grant","Dunn","Kelley","Spencer","Hawkins","Arnold","Pierce","Vazquez","Hansen","Peters","Santos","Hart","Bradley","Knight","Elliott","Cunningham","Duncan","Armstrong","Hudson","Carroll","Lane","Riley","Andrews","Alvarado","Ray","Delgado","Berry","Perkins","Hoffman","Johnston","Matthews","Peña","Richards","Contreras","Willis","Carpenter","Lawrence","Sandoval","Guerrero","George","Chapman","Rios","Estrada","Ortega","Watkins","Greene","Nuñez","Wheeler","Valdez","Harper","Burke","Larson","Santiago","Maldonado","Morrison","Franklin","Carlson","Austin","Dominguez","Carr","Lawson","Jacobs","O’Brien","Lynch","Singh","Vega","Bishop","Montgomery","Oliver","Jensen","Harvey","Williamson","Gilbert","Dean","Sims","Espinoza","Howell","Li","Wong","Reid","Hanson","Le","McCoy","Garrett","Burton","Fuller","Wang","Weber","Welch","Rojas","Lucas","Marquez","Fields","Park","Yang","Little","Banks","Padilla","Day","Walsh","Bowman","Schultz","Luna","Fowler","Mejia","Davidson","Acosta","Brewer","May","Holland","Juarez","Newman","Pearson","Curtis","Cortéz","Douglas","Schneider","Joseph","Barrett","Navarro","Figueroa","Keller","Ávila","Wade","Molina","Stanley","Hopkins","Campos","Barnett","Bates","Chambers","Caldwell","Beck","Lambert","Miranda","Byrd","Craig","Ayala","Lowe","Frazier","Powers","Neal","Leonard","Gregory","Carrillo","Sutton","Fleming","Rhodes","Shelton","Schwartz","Norris","Jennings","Watts","Duran","Walters","Cohen","Mcdaniel","Moran","Parks","Steele","Vaughn","Becker","Holt","Deleon","Barker","Terry","Hale","Leon","Hail","Benson","Haynes","Horton","Miles","Lyons","Pham","Graves","Bush","Thornton","Wolfe","Warner","Cabrera","Mckinney","Mann","Zimmerman","Dawson","Lara","Fletcher","Page","Mccarthy","Love","Robles","Cervantes","Solis","Erickson","Reeves","Chang","Klein","Salinas","Fuentes","Baldwin","Daniel","Simon","Velasquez","Hardy","Higgins","Aguirre","Lin","Cummings","Chandler","Sharp","Barber","Bowen","Ochoa","Dennis","Robbins","Liu","Ramsey","Francis","Griffith","Paul","Blair","O’Connor","Cardenas","Pacheco","Cross","Calderon","Quinn","Moss","Swanson","Chan","Rivas","Khan","Rodgers","Serrano","Fitzgerald","Rosales","Stevenson","Christensen","Manning","Gill","Curry","Mclaughlin","Harmon","Mcgee","Gross","Doyle","Garner","Newton","Burgess","Reese","Walton","Blake","Trujillo","Adkins","Brady","Goodman","Roman","Webster","Goodwin","Fischer","Huang","Potter","Delacruz","Montoya","Todd","Wu","Hines","Mullins","Castaneda","Malone","Cannon","Tate","Mack","Sherman","Hubbard","Hodges","Zhang","Guerra","Wolf","Valencia","Saunders","Franco","Rowe","Gallagher","Farmer","Hammond","Hampton","Townsend","Ingram","Wise","Gallegos","Clarke","Barton","Schroeder","Maxwell","Waters","Logan","Camacho","Strickland","Norman","Person","Colón","Parsons","Frank","Harrington","Glover","Osborne","Buchanan","Casey","Floyd","Patton","Ibarra","Ball","Tyler","Suarez","Bowers","Orozco","Salas","Cobb","Gibbs","Andrade","Bauer","Conner","Moody","Escobar","Mcguire","Lloyd","Mueller","Hartman","French","Kramer","Mcbride","Pope","Lindsey","Velazquez","Norton","Mccormick","Sparks","Flynn","Yates","Hogan","Marsh","Macias","Villanueva","Zamora","Pratt","Stokes","Owen","Ballard","Lang","Brock","Villarreal","Charles","Drake","Barrera","Cain","Patrick","Piñeda","Burnett","Mercado","Santana","Shepherd","Bautista","Ali","Shaffer","Lamb","Trevino","Mckenzie","Hess","Beil","Olsen","Cochran","Morton","Nash","Wilkins","Petersen","Briggs","Shah","Roth","Nicholson","Holloway","Lozano","Rangel","Flowers","Hoover","Short","Arias","Mora","Valenzuela","Bryan","Meyers","Weiss","Underwood","Bass","Greer","Summers","Houston","Carson","Morrow","Clayton","Whitaker","Decker","Yoder","Collier","Zuniga","Carey","Wilcox","Melendez","Poole","Roberson","Larsen","Conley","Davenport","Copeland")

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
    for ($i = 1; $i -le $NumUsers; $i++) {
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
    Write-Host -ForegroundColor Green "Your session has the required permissions to run this script successfully."
    $NumUsers = Read-Host "How many user's would you like to create? "
    $NumUsers = [int]$NumUsers
    if (($NumUsers -is [int] -and $NumUsers -gt 0) -eq $true){
        CreateUser # Calls the CreateUser function
    } elseif ($NumUsers -isnot [int] ){
        Write-Warning "Invalid input silly: Input should be an integer"
    } elseif ($NumUsers -le 0){
        Write-Warning "Invalid input: Input should be great than 0"
    } else{
        Write-Output "I don't know how you got here ¯\_(.-.)_/¯"
    }
} else {
    Write-Warning "Your session does not contain the required permissions. Please connect to Graph PowerShell with Directory.Read.All and User.ReadWrite.All. You can add those permissions by running the following command and consenting to the permissions creates."
    Write-Host -ForegroundColor Green "Connect-MgGraph -Scopes 'Directory.Read.All', 'User.ReadWrite.All'" 
    Write-Host -ForegroundColor Yellow "User.ReadWrite.All - required to create user(s)."
    Write-Host -ForegroundColor Yellow "Directory.Read.All - required to retrieve the domain name."
}
