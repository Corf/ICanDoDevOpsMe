function Get-RandomPassword {
    param (
        [int]$minLength = 15,
        [int]$maxLength = 22
    )

    # Character
    # Generate character groups using ASCII ranges
    $upperCase = [char[]](65..90)    # A-Z (ASCII 65-90)
    $lowerCase = [char[]](97..122)   # a-z (ASCII 97-122)
    $numbers = [char[]](48..57)      # 0-9 (ASCII 48-57)
    $specialChars = '!@#$%^&*()-_=+[]{}<>?/' -split '' | Where-Object { $_ -ne "" } # Manual for special characters

    # Combine all character sets into one array
    $allChars = $upperCase + $lowerCase + $numbers + $specialChars



    # Determine random password length
    $passwordLength = Get-Random -Minimum $minLength -Maximum ($maxLength + 1)

    # Ensure at least one character from each category for better security
    $password = (((
        (Get-Random -InputObject $upperCase) +
        (Get-Random -InputObject $lowerCase) +
        (Get-Random -InputObject $numbers) +
        (Get-Random -InputObject $specialChars) +
        ( -join (1..($passwordLength - 4) | ForEach-Object { Get-Random -InputObject $allChars }))
            ) -split '') | Sort-Object { Get-Random } ) -join ''  # Shuffle password characters
    


    return $password
}