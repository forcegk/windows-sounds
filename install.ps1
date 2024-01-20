param(
    [Parameter(Mandatory = $false)][String]$install_folder = "$env:LOCALAPPDATA\WAEE",
    [Parameter(Mandatory = $false)][switch]$uninstall
)

$sounds = @(
    #,@("Sound name"       , "sound file in install folder") # Description
    , @(".Default\WindowsLogon"         , "poweron.wav"    ) # THX con corte de inyección
    , @(".Default\WindowsLogoff"        , "poweroff.wav"   ) # Pipipipipi popopopopo
    , @(".Default\DeviceConnect"        , "distort_paa.wav") # Pop potente de conexión
    , @(".Default\DeviceDisconnect"     , "poo_verb.wav"   ) # Pop chiquito
    , @(".Default\WindowsUAC"           , "distort_poi.wav") # Poi (reverb)
    , @(".Default\Notification.Default" , "lobster.wav"    ) # Blue lobster (earrape)
    , @(".Default\Minimize"             , "sshuw.wav"      ) # sshuw
    , @(".Default\Maximize"             , "wshh.wav"       ) # wshh
    , @(".Default\RestoreUp"            , "wshh.wav"       ) # wshh
    , @(".Default\RestoreDown"          , "sshuw.wav"      ) # sshuw
    , @(".Default\PrintComplete"        , "sonic.wav"      ) # Sonic complete
    , @(".Default\AppGPFault"           , "alarm.wav"      ) # Alarm
    , @(".Default\SystemHand"           , "alarm.wav"      ) # Alarm
    , @(".Default\SystemNotification"   , "und_gong.wav"   ) # Undertaker's Bong
    , @(".Default\SystemExclamation"    , "bong.wav"       ) # Bong Taco Bell
    , @(".Default\SystemAsterisk"       , "pipe.wav"       ) # Metal Pipe
    , @(".Default\SystemQuestion"       , "huh.wav"        ) # Huh
    , @(".Default\.Default"             , "anvil.wav"      ) # Anvil
    , @(".Default\CCSelect"             , "poo.wav"        ) # Poo
    , @(".Default\MenuPopup"            , "paa.wav"        ) # Paa
    , @("Explorer\Navigating"           , "poo.wav"        ) # Poo
    , @("Explorer\EmptyRecycleBin"      , "diarrea.wav"    ) # Diarrea
)

function Install-SoundPack($scheme) {
    # Copy sounds to temporary directory
    if (-not (Test-Path $install_folder -PathType Container)) {
        New-Item -ItemType directory -Path $install_folder | Out-Null
        Copy-Item -Force ${PSScriptRoot}\media\* $install_folder
    }

    # For each sound
    foreach ($s in $sounds) {
        try {
            # Create registry key for the sound and new scheme
            New-Item `
                -Path "HKCU:\AppEvents\Schemes\Apps\$($s[0])"`
                -Name "${scheme}" | Out-Null
            # Set filename in registry key value for the new scheme
            Set-ItemProperty `
                -Path "HKCU:\AppEvents\Schemes\Apps\$($s[0])\${scheme}"`
                -Name "(default)"`
                -Value "${install_folder}\$($s[1])"
            # Update in current loaded sound scheme as well
            Set-ItemProperty `
                -Path "HKCU:\AppEvents\Schemes\Apps\$($s[0])\.Current"`
                -Name "(default)"`
                -Value "${install_folder}\$($s[1])"
        }
        catch {
            $_
        }
    }

    # Add display name key
    New-Item `
        -Path "HKCU:\AppEvents\Schemes\Names"`
        -Name "${scheme}" | Out-Null

    # Set display name
    Set-ItemProperty `
        -Path "HKCU:\AppEvents\Schemes\Names\${scheme}"`
        -Name "(default)"`
        -Value "Windows Audio Experience Enhancer"

    # Set default scheme
    Set-ItemProperty `
        -Path "HKCU:\AppEvents\Schemes"`
        -Name "(default)"`
        -Value "$scheme"

    # Enable Windows startup sound if admin role
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Set-ItemProperty `
            -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation"`
            -Name "DisableStartupSound"`
            -Value 0
        Set-ItemProperty `
            -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation"`
            -Name "DisableStartupSound"`
            -Value 0
    }
}

function Uninstall-SoundPack($scheme) {
    # Restore the default Windows scheme
    Set-ItemProperty `
        -Path "HKCU:\AppEvents\Schemes"`
        -Name "(default)"`
        -Value ".Default"

    # For each configured sound
    foreach ($s in $sounds) {
        try {
            # Remove generated keys
            Remove-Item "HKCU:\AppEvents\Schemes\Apps\$($s[0])\${scheme}"

            # Reset sounds to the default scheme
            $sound = $(Get-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\$($s[0])\.Default").'(default)'
            Set-ItemProperty `
                -Path "HKCU:\AppEvents\Schemes\Apps\$($s[0])\.Current"`
                -Name "(default)"`
                -Value "${sound}"
        }
        catch {
            $_
        }
    }

    # Remove the display name
    Remove-Item "HKCU:\AppEvents\Schemes\Names\${scheme}"

    # Remove sound files
    Remove-Item -Recurse $install_folder
}

# Uninstall if switch provided
if ($uninstall) {
    Uninstall-SoundPack ".WAEE"
}
else {
    Install-SoundPack ".WAEE"
}
