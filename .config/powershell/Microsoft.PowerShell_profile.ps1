$full_fqdn = [System.Net.Dns]::GetHostByName($env::computerName).HostName

function Add-DirToPath ($dir) {
    if (Test-Path -Path $dir -PathType Container) {
        if ($IsWindows -eq $true) {
            $env:Path += ";${dir}"
        } elseif ($IsLinux|| $IsMacOS -eq $true) {
            $env:PATH += ":${dir}"
        }
    }
}

function Get-IP4 {
    Invoke-RestMethod -Uri "http://4.ipaddr.io/ip" -Method Get
}

function Get-IP6 {
    Invoke-RestMethod -Uri "http://6.ipaddr.io/ip" -Method Get
}

function Get-GitIgnore ($ignore) {
    Invoke-RestMethod -Uri "https://www.gitignore.io/api/${ignore}" -Method get
}

if ($IsLinux) {

    $env:SSH_AUTH_SOCK = Join-Path $env:XDG_RUNTIME_DIR /ssh/S.ssh-agent
    
    $env:CARGO_HOME = Join-Path $HOME /.cargo
    $env:CARGO_BIN = Join-Path $env:CARGO_HOME /bin
    
    $env:GOPATH = Join-Path $HOME /go
    $env:GOBIN = Join-Path $env:GOPATH "/bin"
    $env:GO11MODULE = "on"

    $env:NPM_PACKAGES = Join-Path $HOME /.npm-packages
    
    $env:JAVA_TOOL_OPTIONS = "-Djavax.xml.accessExternalSchema=all"
    
    $env:MATES_DIR = Join-Path "HOME" /.contacts/dzr/contacts

    function Prompt {
        "$([Environment]::UserName)@${full_fqdn} :: $(Get-Location) :: CONSOLE > "
    }

    $Paths = @(
        "${env:NPM_PACKAGES}/bin",
        "${env:GOBIN}",
        "${env:CARGO_BIN}",
        "${HOME}/bin",
        "${HOME}/.local/share/mix",
        "${HOME}/.local/bin",
        "${HOME}/.guix-profile/bin",
        "/opt/zoom",
        "/opt/moneydance",
        "/opt/stumpwm/bin",
        "/opt/dotnet"
    )

    foreach ($path in $Paths) {
        Add-DirToPath $path
    }

    $env:RUST_SRC_PATH = Join-Path (& rustc --print sysroot) /lib/rustlib/src/rust/src

    # Set aliases.

    Set-Alias -Name irc -Value Enter-IRC

    Set-Alias -Name mutt -Value neomutt
    Set-Alias -Name rename -Value perl-rename
    Set-Alias -Name prename -Value rename

    Set-Alias -Name vim -Value nvim

    Set-Alias -Name git -Value hub
    Set-Alias -Name g -Value git
    
    Set-Alias -Name adbi -Value "adb shell input text"

    function Enter-IRC {
        $socket_weechat = "$env:HOME/.tmp/.weechat_shymega.sock"

        tmux -S $socket_weechat has-session -t irc *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Attaching to local Weechat client..."
            tmux -S $socket_weechat attach-session -t irc
        } else {
            Write-Host "[Mosh] Attaching to remote Weechat client..."
            mosh -- hell-knight.shymega.org.uk irc
            if ($LASTEXITCODE -ne 0) {
                Write-Error "[Mosh] Connection failed."
                Write-Warning "[SSH] Falling back to SSH."
                Write-Host "[SSH] Attaching to remote IRC client..."
                ssh -t hell-knight.shymega.org.uk irc
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "[SSH] Connection failed."
                    Write-Warning "No further connection methods available."
                    Write-Error "Aborting."
                }
            }
        }
    }
}
