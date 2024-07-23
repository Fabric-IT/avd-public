# Set time zone to "GMT Standard Time" (London time)
Set-TimeZone -Id "GMT Standard Time"

# Verify if daylight saving time is enabled
$timeZone = Get-TimeZone
if ($timeZone.SupportsDaylightSavingTime) {
    Write-Host "Daylight saving time is enabled."
} else {
    Write-Host "Daylight saving time is not enabled."
}

# Set system locale to English (United Kingdom)
Set-WinSystemLocale -SystemLocale en-GB

# Set user locale to English (United Kingdom)
Set-WinUserLanguageList -LanguageList en-GB -Force

# Set input method to English (United Kingdom)
Set-WinUILanguageOverride -Language en-GB

# Set region to United Kingdom
Set-WinHomeLocation -GeoId 242

# Apply settings to the default user profile
$defaultProfile = "C:\Users\Default"
$controlPanelUser = "Control Panel\International"
$controlPanelMachine = "Control Panel\International\Geo"

# Update registry for default user profile
New-ItemProperty -Path "HKU\$defaultProfile\$controlPanelUser" -Name "LocaleName" -Value "en-GB" -PropertyType String -Force
New-ItemProperty -Path "HKU\$defaultProfile\$controlPanelUser" -Name "GeoID" -Value 242 -PropertyType DWord -Force
New-ItemProperty -Path "HKU\$defaultProfile\$controlPanelMachine" -Name "Nation" -Value 242 -PropertyType DWord -Force
New-ItemProperty -Path "HKU\$defaultProfile\$controlPanelUser" -Name "UserLocale" -Value "en-GB" -PropertyType String -Force
New-ItemProperty -Path "HKU\$defaultProfile\$controlPanelUser" -Name "Locale" -Value 2057 -PropertyType DWord -Force

# Function to copy settings from the current user to the default user
function Copy-InternationalSettingsToDefault {
    $currentUserSID = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).Identity.Value
    $currentUserRegPath = "HKU\$currentUserSID\$controlPanelUser"
    $defaultUserRegPath = "HKU\$defaultProfile\$controlPanelUser"

    $settings = @("LocaleName", "GeoID", "UserLocale", "Locale")

    foreach ($setting in $settings) {
        $value = (Get-ItemProperty -Path $currentUserRegPath -Name $setting).$setting
        New-ItemProperty -Path $defaultUserRegPath -Name $setting -Value $value -PropertyType String -Force
    }
}

Copy-InternationalSettingsToDefault

Write-Host "Time, location, and region settings applied successfully for new users."
